(* @authors Cougar Hashikura (ch999), Xavier Diaz-Sun (xsd2) *)

type t
(** The representation of a square on the board of a minesweeper grid. *)

val empty_square : (int -> int -> (int * int) list) -> t
(** [empty_square adj_fun] is a square with no mines and no adjacent mines, that
    uses [adj_fun] to detect its neighbors. [adj_fun] should be sourced from the
    [Adjacency_funcs] module. *)

val set_mine : t -> bool -> unit
(** [set_mine is_mine square] assigns the mine status of [square] to [is_mine]. *)

val is_mine : t -> bool
(** [is_mine square] returns whether or not [square] contains a mine. *)

val set_adjacents : t -> t list -> unit
(** [set_adjacents square adjacents] sets the corresponding square's adjacent
    square list. *)

val get_adjacents : t -> t list
(** [get_adjacents square] gets the list of squares adjacent to [square]. *)

val set_flag : t -> bool -> unit
(** [set_flag square contains_flag] assigns the flag status of [square] to
    [contains_flag]. *)

val is_flagged : t -> bool
(** [is_flagged square] returns whether or not [square] is currently flagged. *)

val reveal : t -> unit
(** [reveal square] reveals the contents of [square] to the board. *)

val is_revealed : t -> bool
(** [is_revealed square] returns whether or not [square] is currently revealed. *)

val get_adjacent_mines : t -> int
(** [get_adjacent_mines square] returns the number of mines adjacent to
    [square]. *)

val find_adjacent_squares : int -> int -> int -> int -> t array array -> t list
(** [find_adjacent_squares row num_rows col num_cols board] returns a list of
    squares adjacent to square at the [row]th row and the [col]th col, using
    0-based indices. The size of the returned list is 8 if all adjacent squares
    exist, 5 if the square is at an edge, and 3 if the square is at a corner. *)

val to_string : t -> string
(** [to_string square] creates a human-readable string representation of the
    square. "X" represents a mine, a number represents how many mines are
    adjacent to it, and "-" represents 0 adjacent mines. *)
