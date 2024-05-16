(* @authors Cougar Hashikura (ch999) *)
(** Each function is of type [int -> int -> (int * int) list], where each
    function takes a row and a column argument on a 0-based indexed board, and
    returns a list of row/column tuples that describe which tiles on the board
    would be considered "adjacent" to the square specified by the two initial
    arguments. *)

val find_adjacent_squares_default : int -> int -> (int * int) list
(** [find_adjacent_squares_default] finds the eight squares directly adjacent to
    the specified square. *)

val find_adjacent_squares_knight : int -> int -> (int * int) list
(** [find_adjacent_squares_knight] finds the eight squares that a chess knight
    could reach from the specified square. *)

val find_adjacent_squares_cross : int -> int -> (int * int) list
(** [find_adjacent_squares_cross] finds the four squares above, below, left, and
    right of the specified square. *)

val find_adjacent_squares_big_cross : int -> int -> (int * int) list
(** [find_adjacent_squares_big_cross] finds the eight squares extending out two
    squares in each of the four directions of the cross from the specified
    square. *)

val find_adjacent_squares_diag : int -> int -> (int * int) list
(** [find_adjacent_squares_diag] finds the four squares diagonal to the
    specified square. *)

val find_adjacent_squares_big_diag : int -> int -> (int * int) list
(** [find_adjacent_squares_big_diag] finds the eight squares extending otu two
    squares in each of the diagonal directions from the specified square. *)

val find_adjacent_squares_ring : int -> int -> (int * int) list
(** [find_adjacent_squares_ring] finds the twelve squares in a ring shape one
    space away from the specified square. *)
