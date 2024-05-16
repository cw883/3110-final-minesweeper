(* @authors Tami Takada (tt554) *)

val get_timestamp : Unix.tm -> string
(** [get_timestamp tm] returns [tm] as a formatted string. *)

val get_stats : Game_db.game_types -> bool * string * string * string
(** [get_stats s] returns a 4-tuple of whether [s] represents a game that was won,
    the time the game ended formatted in MM/DD/YYYY HH:MM, the time spent on the
    game, and the number of moves made. *)
