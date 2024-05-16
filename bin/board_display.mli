(* @authors Tami Takada (tt554), Xavier Diaz-Sun (xsd2) *)

val update_board :
  Final_project.Board.board ->
  Bogue.Layout.t ->
  (bool -> int -> string -> string -> unit) ->
  (unit -> Final_project.Game_db.game_types list) ->
  unit
(** [update_board b layout insert_score] queues a content update for [layout] to
    display an updated representation of [b] on the next frame draw.
    [insert_score] updates the app's database with stats when a new game is
    finished. *)

val display_main_menu :
  Bogue.Layout.t ->
  (bool -> int -> string -> string -> unit) ->
  (unit -> Final_project.Game_db.game_types list) ->
  unit
(** [display_main_menu layout insert_score] queues a content update for [layout]
    to display the main menu page of the game on the next frame draw.
    [insert_score] updates the app's database with stats when a new game is
    finished. *)

val create_base : unit -> Bogue.Layout.t
(** [create_base] sets up the background for all the other content to be placed
    onto the screen. **)
