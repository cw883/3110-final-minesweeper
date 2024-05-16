(* @authors Cougar Hashikura (ch999), Xavier Diaz-Sun (xsd2), Tami Takada
   (tt554) *)

type square = Square.t
type board = square array array
(* AF: [board] is a 2D array that directly corresponds to the board as it is
   displayed in the game, where each element is of type [Square.t] *)
(* RI: None *)

let cheat_mode_row board row =
  let open Square in
  for i = 0 to Array.length board.(0) - 1 do
    let sq = board.(row).(i) in
    if is_mine sq then print_string "X "
    else
      let num_adjacent = get_adjacent_mines board.(row).(i) in
      print_string (string_of_int num_adjacent ^ " ")
  done

let print_last_line_cheatmode board =
  for _ = 0 to (Array.length board.(0) * 2) - 1 do
    print_string "-"
  done;
  print_newline ()

let cheat_mode board =
  for j = 0 to Array.length board - 1 do
    cheat_mode_row board j;
    print_newline ()
  done;
  print_last_line_cheatmode board

let num_clicks = ref 0

let rec get_mines_aux num rows cols lst =
  let range = rows * cols in
  match num with
  | 0 -> lst
  | _ ->
      let rand_num = Random.int range in
      let coords = (rand_num / rows, rand_num mod cols) in
      if List.mem coords lst then get_mines_aux num rows cols lst
      else get_mines_aux (num - 1) rows cols (coords :: lst)

let get_mines num rows cols = get_mines_aux num rows cols []

let swap_two_squares (sq1 : square) (sq2 : square) =
  let open Square in
  set_mine sq1 false;
  (* sq1 was previously a mine, now it is not *)
  set_mine sq2 true (* sq2 was previously not a mine, now it is *)

let find_non_mine_square_and_swap sq_is_mine board =
  let found = ref false in
  let width = Array.length board in
  let height = Array.length (Array.get board 0) in
  for i = 0 to width - 1 do
    for j = 0 to height - 1 do
      if board.(i).(j) |> Square.is_mine = false && !found = false then begin
        found := true;
        let curr_square = board.(i).(j) in
        swap_two_squares sq_is_mine curr_square
      end
    done
  done

let rec reveal_adjacents (s : square) : unit =
  let open Square in
  let adjs = get_adjacents s in
  List.iter
    (fun adj ->
      if is_revealed adj |> not && is_mine adj |> not then begin
        reveal adj;
        if get_adjacent_mines adj = 0 then reveal_adjacents adj
      end)
    adjs

let update_board_with_mines_set_for_loop board =
  let open Square in
  let width = Array.length board in
  let height = Array.length (Array.get board 0) in
  for i = 0 to width - 1 do
    for j = 0 to height - 1 do
      let curr_square = board.(i).(j) in
      let adj_squares = find_adjacent_squares i height j width board in
      set_adjacents curr_square adj_squares
    done
  done

let reveal_square s board =
  let open Square in
  (* print_endline (string_of_int !num_clicks); *)
  incr num_clicks;
  if !num_clicks = 1 && is_mine s = true then begin
    (* print_endline "First click was a mine, swapping"; *)
    find_non_mine_square_and_swap s board;
    update_board_with_mines_set_for_loop board
  end;
  let () = reveal s in
  if is_mine s then false
  else begin
    if get_adjacent_mines s = 0 then reveal_adjacents s;
    true
  end

let reveal_square_at x y b =
  if y < 0 || x < 0 || y >= Array.length b || x >= Array.length (Array.get b 0)
  then failwith "Invalid coordinates"
  else reveal_square b.(y).(x) b

let is_solved b =
  let open Square in
  Array.for_all (Array.for_all (fun sq -> is_mine sq || is_revealed sq)) b

let to_string b =
  let open Square in
  Array.fold_left
    (fun acc row ->
      acc ^ Array.fold_left (fun acc s -> acc ^ to_string s) "" row ^ "\n")
    "" b

let print_board b = to_string b |> print_string

let make_empty_board width height adj_fun =
  let open Square in
  let blank = Array.make_matrix width height None in
  Array.map (Array.map (fun _ -> empty_square adj_fun)) blank

let place_mines_on_board board mine_list =
  let open Array in
  iteri
    (fun y row ->
      iteri
        (fun x sq ->
          let is_mine = List.mem (x, y) mine_list in
          Square.set_mine sq is_mine)
        row)
    board

let init_board width height num (adj_fun : int -> int -> (int * int) list) =
  num_clicks := 0;
  if num > width * height then failwith "Too many mines"
  else
    let board = make_empty_board width height adj_fun in
    let mines = get_mines num width height in
    let () = place_mines_on_board board mines in
    let () = update_board_with_mines_set_for_loop board in
    board
