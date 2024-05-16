(* @authors Cougar Hashikura (ch999), Xavier Diaz-Sun (xsd2), Tami Takada
   (tt554) *)

open Bogue
open Final_project
module W = Widget
module L = Layout

let () = Game_db.GameDB.init_dir ()

let cache =
  let open Game_db in
  let open GameDB in
  let initial = init_cache () in
  try
    match
      create_collection ~indices:[ Won; TimeEnded; Moves ] "scores" initial
    with
    | c -> ref c
  with Unix.Unix_error (Unix.EEXIST, _, _) -> ref initial

let insert_score won moves time_started time_ended =
  let open Game_db in
  let score = Score { won; moves; time_started; time_ended } in
  cache := GameDB.insert_document "scores" score !cache

let get_scores () =
  let open Game_db in
  let open GameDB in
  get_all ~sort_by:TimeEnded "scores" !cache |> List.rev

let () = Random.self_init ()

let main () =
  let () = Theme.set_label_font "assets/fonts/WorkSans-Regular.ttf" in
  let base = Board_display.create_base () in
  let () = Board_display.display_main_menu base insert_score get_scores in
  let board = Bogue.of_layout base in
  Bogue.run board

let rec game_loop board =
  if Board.is_solved board then print_endline "Solved"
  else
    let () =
      print_endline
        "Enter a coordinate x,y to reveal (top-left coordinate system): "
    in
    let s = read_line () in
    match String.split_on_char ',' s with
    | [ s_x; s_y ] -> begin
        match (int_of_string_opt s_x, int_of_string_opt s_y) with
        | Some x, Some y ->
            let safe_hit = Board.reveal_square_at x y board in
            if not safe_hit then print_endline "Hit a mine!"
            else
              let () = Board.print_board board in
              game_loop board
        | _ ->
            let () = print_endline "Invalid input, please try again." in
            game_loop board
      end
    | _ ->
        let () = print_endline "Invalid input, please try again." in
        game_loop board

let terminal_mode board =
  let () = Board.print_board board in
  Board.cheat_mode board;
  game_loop board

let () =
  let args = Sys.argv in
  if Array.length args = 1 then
    let () = main () in
    let () = Game_db.GameDB.write_cache !cache in
    Bogue.quit ()
  else
    terminal_mode
      (Board.init_board 10 10 20 Adjacency_funcs.find_adjacent_squares_default)
