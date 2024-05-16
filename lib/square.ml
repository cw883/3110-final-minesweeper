(* @authors Cougar Hashikura (ch999), Xavier Diaz-Sun (xsd2) *)

type t = {
  mutable is_revealed : bool;
  mutable is_mine : bool;
  mutable adjacent_mines : int;
  mutable adjacent_squares : t list;
  mutable contains_flag : bool;
  adjacency_func : int -> int -> (int * int) list;
}
(* AF: [is_revealed], [is_mine], and [contains_flag] describe the current
   condition of the square in the game. [adjacent_squares] contains all of the
   squares adjacent to this square, as described by [adjacency_func]. (The
   specification and behavior of [adjacency_func] is written in the
   [Adjacency_funcs] module.) [adjacent_mines] stores how many mines are
   adjacent to this square by the adjacency function. *)
(* RI: [adjacent_mines] is between 0 and the size of [adjacent_squares]
   inclusive. *)

let empty_square adj_fun =
  {
    is_revealed = false;
    is_mine = false;
    adjacent_mines = 0;
    adjacent_squares = [];
    contains_flag = false;
    adjacency_func = adj_fun;
  }

let set_mine square mine = square.is_mine <- mine
let is_mine square = square.is_mine

let set_adjacents square adj_list =
  let () = square.adjacent_squares <- adj_list in
  let num_adj_mines =
    List.fold_left
      (fun num_mines sq -> if is_mine sq then num_mines + 1 else num_mines)
      0 adj_list
  in
  square.adjacent_mines <- num_adj_mines

let get_adjacents square = square.adjacent_squares
let set_flag square flag_setting = square.contains_flag <- flag_setting
let is_flagged square = square.contains_flag
let get_adjacent_mines square = square.adjacent_mines
let reveal square = square.is_revealed <- true
let is_revealed square = square.is_revealed

let find_adjacent_squares row num_rows col num_cols board =
  let s = board.(row).(col) in
  let adjs = s.adjacency_func row col in
  let valid_adjs =
    List.filter
      (fun (x, y) -> x >= 0 && y >= 0 && x < num_cols && y < num_rows)
      adjs
  in
  List.map (fun (x, y) -> board.(x).(y)) valid_adjs

let to_string square =
  if not square.is_revealed then "."
  else if square.is_mine then "X"
  else if square.adjacent_mines <> 0 then string_of_int square.adjacent_mines
  else "-"
