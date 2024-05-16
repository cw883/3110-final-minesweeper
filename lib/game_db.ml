(* @authors Tami Takada (tt554) *)

type game_types =
  | Score of {
      time_started : string;
      time_ended : string;
      won : bool;
      moves : int;
    }

type game_sort_property =
  | TimeEnded
  | Moves
  | Won

module GameTypes :
  Db.DatabaseTypes
    with type t = game_types
     and type sort_property = game_sort_property = struct
  type t = game_types
  type sort_property = game_sort_property

  let root_dir = "_data/"

  let empty_with p str =
    match p with
    | TimeEnded ->
        Score { time_ended = str; time_started = ""; won = true; moves = 0 }
    | Moves ->
        Score
          {
            moves = int_of_string str;
            time_ended = "";
            time_started = "";
            won = true;
          }
    | Won ->
        Score
          {
            won = bool_of_string str;
            time_ended = "";
            time_started = "";
            moves = 0;
          }

  let get_str p d =
    match (p, d) with
    | TimeEnded, Score d -> d.time_ended
    | Moves, Score d -> d.moves |> string_of_int
    | Won, Score d -> d.won |> string_of_bool

  let serialize d =
    match d with
    | Score d ->
        Yojson.Basic.to_string
          (`Assoc
            [
              ("timestarted", `String d.time_started);
              ("timeended", `String d.time_ended);
              ("won", `Bool d.won);
              ("moves", `Int d.moves);
            ])

  let decode str =
    match Yojson.Basic.from_string str with
    | `Assoc
        [
          ("timestarted", `String time_started);
          ("timeended", `String time_ended);
          ("won", `Bool won);
          ("moves", `Int moves);
        ] -> Score { time_started; time_ended; won; moves }
    | _ -> failwith "Bad JSON"

  let compare p d1 d2 =
    match (p, d1, d2) with
    | TimeEnded, Score { time_ended = t1; _ }, Score { time_ended = t2; _ } ->
        Stdlib.compare t1 t2
    | Moves, Score { moves = m1; _ }, Score { moves = m2; _ } ->
        Stdlib.compare m1 m2
    | Won, Score { won = w1; _ }, Score { won = w2; _ } ->
        if w1 = w2 then 0 else if w1 && not w2 then 1 else -1

  let string_of_property = function
    | TimeEnded -> "timeended"
    | Moves -> "moves"
    | Won -> "won"

  let property_of_string str =
    if str = string_of_property TimeEnded then TimeEnded
    else if str = string_of_property Moves then Moves
    else if str = string_of_property Won then Won
    else failwith ("No property with name " ^ str)
end

module GameDB = Db.Database (GameTypes)
