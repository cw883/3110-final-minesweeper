(* @authors Cougar Hashikura (ch999), Xavier Diaz-Sun (xsd2), Tami Takada
   (tt554) *)

type square = Square.t

type board = square array array
(** [board] is the representation type of a game board. *)

val init_board : int -> int -> int -> (int -> int -> (int * int) list) -> board
(** [init_board width height mines adj_func] is a new board with dimensions
    [width] by [height] randomly initialized with [mines] mines, where each
    square uses [adj_func] to detect its neighbors. Requires: area [width] *
    [height] >= 2. *)

val reveal_square : square -> board -> bool
(** [reveal_square s b] reveals the square [s] in [b], as well as all adjacent
    empty squares. Returns [true] if [s] is not a mine, and [false] otherwise. *)

val reveal_square_at : int -> int -> board -> bool
(** [reveal_square_at x y b] reveals the square at row y, column x in [b], as
    well as all adjacent empty squares. Returns [true] if [s] is not a mine, and
    [false] otherwise. *)

val is_solved : board -> bool
(** [is_solved b] is [true] if all the non-mine tiles in [b] have been revealed
    and [false] otherwise. *)

val print_board : board -> unit
(** [print_board board] prints a human-readable form of the current state of
    [board] to the terminal. *)

val cheat_mode : board -> unit
(** [cheat_mode board] prints a version of [board] with all squares revealed to
    the terminal. *)
