(* @authors Tami Takada (tt554) *)

open Game_db

let get_timestamp tm =
  Printf.sprintf "%04d-%02d-%02d %02d:%02d:%02d" (tm.Unix.tm_year + 1900)
    (tm.Unix.tm_mon + 1) tm.Unix.tm_mday tm.Unix.tm_hour tm.Unix.tm_min
    tm.Unix.tm_sec

let get_stats s =
  match s with
  | Score s -> begin
      match
        ( String.split_on_char ' ' s.time_started,
          String.split_on_char ' ' s.time_ended )
      with
      | [ ymd1; hms1 ], [ ymd2; hms2 ] -> begin
          match
            ( String.split_on_char '-' ymd1,
              String.split_on_char ':' hms1,
              String.split_on_char '-' ymd2,
              String.split_on_char ':' hms2 )
          with
          | [ y1; mo1; d1 ], [ h1; m1; s1 ], [ y2; mo2; d2 ], [ h2; m2; s2 ] ->
              let ydiff = int_of_string y2 - int_of_string y1 in
              let modiff = int_of_string mo2 - int_of_string mo1 in
              let ddiff = int_of_string d2 - int_of_string d1 in
              let hdiff = int_of_string h2 - int_of_string h1 in
              let mdiff = int_of_string m2 - int_of_string m1 in
              let sdiff = int_of_string s2 - int_of_string s1 in

              let time_spent =
                (if ydiff > 0 then string_of_int ydiff ^ "y " else "")
                ^ (if modiff > 0 then string_of_int modiff ^ "mo " else "")
                ^ (if ddiff > 0 then string_of_int ddiff ^ "d " else "")
                ^ (if hdiff > 0 then string_of_int hdiff ^ "h " else "")
                ^ (if mdiff > 0 then string_of_int mdiff ^ "m " else "")
                ^ if sdiff > 0 then string_of_int sdiff ^ "s" else "0s"
              in

              ( s.won,
                mo2 ^ "/" ^ d2 ^ "/" ^ y2 ^ " " ^ h2 ^ ":" ^ m2,
                time_spent,
                string_of_int s.moves )
          | _ -> failwith "Invalid timestamp format"
        end
      | _ -> failwith "Invalid timestamp format"
    end
