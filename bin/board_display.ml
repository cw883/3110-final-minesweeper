(* @authors Tami Takada (tt554), Xavier Diaz-Sun (xsd2), Cougar Hashikura
   (ch999) *)

open Final_project.Board
open Final_project.Adjacency_funcs
open Final_project.Square

(* open Final_project.Square_types.DefaultSquare *)
open Bogue
module W = Widget
module L = Layout
open Constants

(* open Select *)
open Display_utils
open Final_project.Stats

let theme = Display_utils.theme

let adjacency_funcs =
  Array.of_list
    [
      "Default Ruleset";
      "Knight Ruleset";
      "Cross Ruleset";
      "Big Cross Ruleset";
      "X Ruleset";
      "Big X Ruleset";
      "Ring Ruleset";
    ]

let select_adj_func idx =
  match idx with
  | 0 -> find_adjacent_squares_default
  | 1 -> find_adjacent_squares_knight
  | 2 -> find_adjacent_squares_cross
  | 3 -> find_adjacent_squares_big_cross
  | 4 -> find_adjacent_squares_diag
  | 5 -> find_adjacent_squares_big_diag
  | 6 -> find_adjacent_squares_ring
  | _ -> failwith "IMPOSSIBLE"

let current_adj_func = ref find_adjacent_squares_default

let create_base () =
  L.empty ~w:Constants.bwidth ~h:Constants.bheight ~name:"Minesweeper"
    ~background:(L.opaque_bg !theme.background_color)
    ()

let square_bg_color s =
  if is_revealed s then
    if is_mine s then Draw.opaque !theme.losing_color
    else Draw.opaque !theme.winning_color
  else Draw.opaque !theme.empty_tile_color

let init_square s =
  let bg =
    square ~w:(Some 50) ~h:(Some 50) ~radius:10 ~bg:(square_bg_color s) ()
  in
  let label =
    W.label ~size:20
      ~fg:(Draw.opaque !theme.number_color)
      ~align:Draw.Center
      (if is_revealed s then string_of_int (get_adjacent_mines s) else "")
  in
  (L.superpose ~w:50 ~h:50 ~center:true [ L.resident bg; L.resident label ], bg)

let init_rooms row =
  Array.fold_right
    (fun s (sqs, ws) ->
      let sq, w = init_square s in
      (sq :: sqs, w :: ws))
    row ([], [])

let init_grid b =
  Array.fold_right
    (fun row (rows, ws) ->
      let sqs, rws = init_rooms row in
      let r = L.flat ~sep:10 ~vmargin:0 sqs in
      (r :: rows, rws :: ws))
    b ([], [])

let dimension_options = generate_int_range_picker_options 4 13 1
let w = ref 0
let h = ref 0
let moves = ref 0
let m = ref 0

let rec make_connection b ws layout time_started insert_score get_scores =
  let () = cheat_mode b in
  Array.of_list ws
  |> Array.iter2
       (fun br wr ->
         Array.of_list wr
         |> Array.iter2
              (fun sq w ->
                W.on_click
                  ~click:(fun _ ->
                    moves := !moves + 1;
                    if reveal_square sq b then
                      if is_solved b then begin
                        let time_ended =
                          Unix.time () |> Unix.gmtime |> get_timestamp
                        in
                        insert_score true !moves time_started time_ended;
                        display_result b layout true insert_score get_scores
                      end
                      else update_board b layout insert_score get_scores
                    else begin
                      let time_ended =
                        Unix.time () |> Unix.gmtime |> get_timestamp
                      in
                      insert_score false !moves time_started time_ended;
                      display_result b layout false insert_score get_scores
                    end)
                  w)
              br)
       b

and update_board b layout insert_score get_scores =
  let rows, ws = init_grid b in
  let time_started = Unix.time () |> Unix.gmtime |> get_timestamp in
  let selected_background = Some (L.opaque_bg !theme.background_color) in
  L.set_background layout selected_background;
  L.set_rooms layout
    [
      L.superpose ~center:true
        [ L.empty ~w:bwidth ~h:bheight (); L.tower ~sep:10 ~vmargin:0 rows ];
    ];
  make_connection b ws layout time_started insert_score get_scores

and display_result b layout won insert_score get_scores =
  moves := 0;
  let rows, _ = init_grid b in
  L.set_rooms layout
    [
      L.superpose ~w:bwidth ~h:bheight ~center:true
        [
          L.tower ~sep:10 ~vmargin:0 rows;
          (* TODO: Try to make bg transparent so board below is exposed *)
          L.superpose ~center:true
            [
              L.resident
                (square ~w:(Some bwidth) ~h:(Some bheight)
                   ~bg:
                     (Draw.opaque
                        (if won then !theme.winning_color
                         else !theme.losing_color))
                   ());
              L.tower ~align:Draw.Center ~sep:30
                [
                  L.resident
                    (W.image ~h:130
                       ("assets/images/" ^ if won then "win.png" else "lose.png"));
                  text_button ~w:(Some 360)
                    ~f:(fun _ ->
                      display_main_menu layout insert_score get_scores)
                    ~text:"Go to main menu" ~icon:"arrow-right" ();
                  text_button ~w:(Some 360)
                    ~f:(fun _ ->
                      let adj_fun = !current_adj_func in
                      let b =
                        init_board
                          (List.nth dimension_options !w |> snd)
                          (List.nth dimension_options !h |> snd)
                          (List.nth dimension_options !m |> snd)
                          adj_fun
                      in
                      update_board b layout insert_score get_scores)
                    ~text:"Start new game" ~icon:"arrow-right" ();
                ];
            ];
        ];
    ]

and display_stats layout insert_score get_scores =
  (* let open Final_project.Game_db in *)
  let selected_background = Some (L.opaque_bg !theme.background_color) in
  let scores = get_scores () in

  let back_arrow =
    W.icon ~fg:(Draw.opaque !theme.number_color) ~size:24 "arrow-left"
  in
  W.on_click
    ~click:(fun _ -> display_main_menu layout insert_score get_scores)
    back_arrow;

  L.set_background layout selected_background;
  L.set_rooms layout
    [
      L.superpose ~w:bwidth ~h:bheight ~center:true
        [
          L.tower ~sep:10
            [
              L.resident (W.image ~h:40 "assets/images/scores.png");
              L.empty ~w:10 ~h:10 ();
              L.flat ~sep:20 ~hmargin:0
                [
                  L.resident ~w:155
                    (W.label
                       ~fg:(Draw.opaque !theme.number_color)
                       "Date played");
                  L.resident ~w:155
                    (W.label ~fg:(Draw.opaque !theme.number_color) "Time spent");
                  L.resident ~w:155
                    (W.label ~fg:(Draw.opaque !theme.number_color) "Moves used");
                ];
              Long_list.create ~scrollbar_width:5 ~w:520 ~h:450
                ~length:(List.length scores)
                ~generate:(fun i ->
                  let s = List.nth scores i in
                  match get_stats s with
                  | won, date, time_spent, moves ->
                      L.flat ~vmargin:5 ~sep:20
                        [
                          L.superpose ~center:true
                            [
                              L.resident
                                (square ~w:(Some 155) ~h:(Some 40)
                                   ~bg:
                                     (if won then
                                        Draw.opaque !theme.winning_color
                                      else Draw.opaque !theme.losing_color)
                                   ());
                              L.resident (W.label date);
                            ];
                          L.superpose ~center:true
                            [
                              L.resident
                                (square ~w:(Some 155) ~h:(Some 40)
                                   ~bg:
                                     (if won then
                                        Draw.opaque !theme.winning_color
                                      else Draw.opaque !theme.losing_color)
                                   ());
                              L.resident (W.label time_spent);
                            ];
                          L.superpose ~center:true
                            [
                              L.resident
                                (square ~w:(Some 155) ~h:(Some 40)
                                   ~bg:
                                     (if won then
                                        Draw.opaque !theme.winning_color
                                      else Draw.opaque !theme.losing_color)
                                   ());
                              L.resident (W.label moves);
                            ];
                        ])
                ();
            ];
          L.resident ~x:(-(bwidth / 2) + 60) ~y:(-(bheight / 2) + 60) back_arrow;
        ];
    ]

and create_title_and_presenter () =
  L.tower ~sep:10
    [
      L.resident (W.image ~w:400 "assets/images/title.png");
      L.resident
        (W.label ~size:16
           ~fg:(Draw.opaque !theme.number_color)
           "Presented by ProYos");
    ]

and create_dimension_picker () =
  L.flat ~sep:0 ~align:Draw.Center
    [
      L.resident (W.label ~fg:(Draw.opaque !theme.winning_color) ~size:16 "W");
      picker ~options:dimension_options ~selected:w ();
      L.resident (W.empty ~w:20 ~h:10 ());
      L.resident (W.label ~fg:(Draw.opaque !theme.winning_color) ~size:16 "H");
      picker ~options:dimension_options ~selected:h ();
      L.resident (W.empty ~w:20 ~h:10 ());
      L.resident
        (W.label ~fg:(Draw.opaque !theme.winning_color) ~size:16 "Mines");
      picker ~options:dimension_options ~selected:m ();
    ]

and create_start_button layout insert_score get_scores =
  text_button ~w:(Some 410)
    ~bg:(Draw.opaque !theme.winning_color)
    ~fg:(Draw.opaque !theme.background_color)
    ~f:(fun _ ->
      let adj_func = !current_adj_func in
      let b =
        init_board
          (List.nth dimension_options !w |> snd)
          (List.nth dimension_options !h |> snd)
          (List.nth dimension_options !m |> snd)
          adj_func
      in

      update_board b layout insert_score get_scores)
    ~text:"Start a new game" ~icon:"arrow-right" ()

and create_adj_func_picker () =
  Select.create
    ~action:(fun idx -> current_adj_func := select_adj_func idx)
    adjacency_funcs 0

and display_main_menu layout insert_score get_scores =
  let selected_background = Some (L.opaque_bg !theme.background_color) in
  L.set_background layout selected_background;
  L.set_rooms layout
    [
      L.superpose ~w:bwidth ~h:bheight ~center:true
        [
          L.tower ~sep:40
            [
              L.flat ~sep:30
                [
                  Display_utils.create_theme_picker layout (fun () ->
                      display_main_menu layout insert_score get_scores);
                  create_adj_func_picker ();
                ];
              (* Display_utils.create_theme_picker (); *)
              create_title_and_presenter ();
              create_dimension_picker ();
              create_start_button layout insert_score get_scores;
              text_button ~w:(Some 410)
                ~bg:(Draw.opaque !theme.winning_color)
                ~fg:(Draw.opaque !theme.background_color)
                ~f:(fun _ -> display_stats layout insert_score get_scores)
                ~text:"View scores" ~icon:"arrow-right" ();
            ];
        ];
    ]
