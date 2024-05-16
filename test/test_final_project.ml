(* @authors Caleb Woo (cw883), Cougar Hashikura (ch999), Tami Takada (tt554) *)

open OUnit2
open Final_project

(* module Square = Square_types.DefaultSquare *)
open Square

(* module Board = Board_types.DefaultBoard *)
open Board
open Adjacency_funcs

let square = empty_square find_adjacent_squares_default
let square' = empty_square find_adjacent_squares_default

let square_list =
  [
    empty_square find_adjacent_squares_default;
    empty_square find_adjacent_squares_default;
  ]

let square_list' =
  [
    empty_square find_adjacent_squares_default;
    empty_square find_adjacent_squares_default;
  ]

let test_board = init_board 5 5 3 find_adjacent_squares_default
let no_mine_board = init_board 5 5 0 find_adjacent_squares_default
let all_mine_board = init_board 3 3 9 find_adjacent_squares_default

let square_tests =
  "test suite"
  >::: [
         ( "is_mine (set_mine square false;square) is false" >:: fun _ ->
           assert_equal false
             (is_mine
                (set_mine square false;
                 square)) );
         ( "to_string square is ." >:: fun _ ->
           assert_equal "." (to_string square) );
         ( "is_mine (set_mine square true;square) is true" >:: fun _ ->
           assert_equal true
             (is_mine
                (set_mine square true;
                 square)) );
         ( "get_adjacents (set_adjacents square [];square) is []" >:: fun _ ->
           assert_equal []
             (get_adjacents
                (set_adjacents square [];
                 square)) );
         (* ( "get_adjacents (set_adjacents square square_list;square) is \
            square_list" >:: fun _ -> assert_equal square_list (get_adjacents
            (set_adjacents square square_list; square)) ); *)
         ( "is_revealed (square) is false" >:: fun _ ->
           assert_equal false (is_revealed square) );
         ( "is_revealed (reveal square;square) is true" >:: fun _ ->
           assert_equal true
             (is_revealed
                (reveal square;
                 square)) );
         ( "After being revealed, the non_mine square, the to_string square is -"
         >:: fun _ ->
           assert_equal "-"
             (to_string
                (reveal square;
                 set_mine square false;
                 square)) );
         ( "After being set as a mine and revealed, the to_string square is X"
         >:: fun _ ->
           assert_equal "X"
             (to_string
                (reveal square;
                 set_mine square true;
                 square)) );
         ( " get_adjacents_mines square is 0" >:: fun _ ->
           assert_equal 0 (get_adjacent_mines square) );
         ( "is_flagged square is false" >:: fun _ ->
           assert_equal false (is_flagged square) );
         ( "After flagging, is_flagged square is true" >:: fun _ ->
           assert_equal true
             (set_flag square true;
              is_flagged square) );
         ( "TODO: get_adjacent_mines when only some of its adjacents are mines"
         >:: fun _ -> assert_equal false (is_flagged square) );
         ( "**After setting both neighbors to mines, get_adjacents_mines \
            square is 2"
         >:: fun _ ->
           assert_equal 2
             (List.iter (fun square -> set_mine square true) square_list';
              set_adjacents square' square_list';
              get_adjacent_mines square') );
         (* ( "**After revealing square and setting its neighbors as mines, the
            \ to_string representation is the number of mines that it neighbors"
            >:: fun _ -> assert_equal "2" (reveal square'; print_endline
            (to_string square'); to_string square') ); *)
       ]

let board_tests =
  "test suite"
  >::: [
         ( "Board with more mines than squares raises an error" >:: fun _ ->
           assert_raises ~msg:"Should raise Too many mines error"
             (Failure "Too many mines") (fun () ->
               init_board 3 3 10 find_adjacent_squares_default) );
         ( "Revealing a square at invalid coordinates raises an error"
         >:: fun _ ->
           assert_raises ~msg:"Should raise Invalid coordinates error"
             (Failure "Invalid coordinates") (fun () ->
               reveal_square_at 10 5 test_board) );
         ( "After revealing a square that is not a mine, reveal_square_at 1 1 \
            no_mine_board is true"
         >:: fun _ -> assert_equal true (reveal_square_at 1 1 no_mine_board) );
         ( "is solved test_board is false" >:: fun _ ->
           assert_equal false (is_solved test_board) );
         ( "After revealing all squares, is solved no_mine_board is true"
         >:: fun _ ->
           ignore (reveal_square_at 1 1 no_mine_board);
           assert_equal true (is_solved no_mine_board) );
         ( "Revealing a mine is false" >:: fun _ ->
           assert_equal false (reveal_square_at 1 1 all_mine_board) );
         ( "is_flagged square is false" >:: fun _ ->
           assert_equal false (is_flagged square) );
         ( "TODO: testing size of list returned by find_adjacent_squares"
         >:: fun _ ->
           assert_equal 3
             (List.length (find_adjacent_squares 0 5 0 5 test_board)) );
         ( "TODO: testing size of list returned by find_adjacent_squares"
         >:: fun _ ->
           assert_equal 5
             (List.length (find_adjacent_squares 0 5 1 5 test_board)) );
         ( "TODO: testing size of list returned by find_adjacent_squares"
         >:: fun _ ->
           assert_equal 8
             (List.length (find_adjacent_squares 3 5 2 5 test_board)) );
       ]

let find_adjacent_squares_test row col = [ (row, col - 1) ]
let custom_test_board = Board.init_board 10 10 20 find_adjacent_squares_test
let no_mines_test_board = Board.init_board 5 5 0 find_adjacent_squares_test
let all_mines_test_board = Board.init_board 5 5 25 find_adjacent_squares_test

let custom_board_tests =
  "test suite"
  >::: [
         ( "Adjacency list size" >:: fun _ ->
           assert_equal 1
             (let s = custom_test_board.(1).(1) in
              let adj_list = get_adjacents s in
              List.length adj_list) );
         ( "Adjacency list size at edge case" >:: fun _ ->
           assert_equal 0
             (let s = custom_test_board.(0).(0) in
              let adj_list = get_adjacents s in
              List.length adj_list) );
         ( "Reveal on no-mine field returns true" >:: fun _ ->
           assert_equal true (Board.reveal_square_at 0 0 no_mines_test_board) );
         ( "Reveal on all-mine field returns false" >:: fun _ ->
           assert_equal false (Board.reveal_square_at 0 0 all_mines_test_board)
         );
       ]

open Game_db
open GameTypes

let db_type_tests =
  "game db type tests"
  >::: [
         ( "get_str TimeEnded" >:: fun _ ->
           assert_equal "2024-05-13 10:00:00"
             (get_str TimeEnded
                (Score
                   {
                     time_started = "";
                     time_ended = "2024-05-13 10:00:00";
                     won = true;
                     moves = 10;
                   })) );
         ( "get_str Moves" >:: fun _ ->
           assert_equal "10"
             (get_str Moves
                (Score
                   {
                     time_started = "";
                     time_ended = "2024-05-13 10:00:00";
                     won = true;
                     moves = 10;
                   })) );
         ( "get_str Won" >:: fun _ ->
           assert_equal "true"
             (get_str Won
                (Score
                   {
                     time_started = "";
                     time_ended = "2024-05-13 10:00:00";
                     won = true;
                     moves = 10;
                   })) );
         ( "empty_with TimeEnded 2024-05-13 10:00:00" >:: fun _ ->
           assert_equal "2024-05-13 10:00:00"
             (empty_with TimeEnded "2024-05-13 10:00:00" |> get_str TimeEnded)
         );
         ( "empty_with Moves 10" >:: fun _ ->
           assert_equal "10" (empty_with Moves "10" |> get_str Moves) );
         ( "empty_with Won true" >:: fun _ ->
           assert_equal "true" (empty_with Won "true" |> get_str Won) );
         ( "decode serialize empty_with TimeEnded 2024-05-13 10:00:00"
         >:: fun _ ->
           assert_equal "2024-05-13 10:00:00"
             (empty_with TimeEnded "2024-05-13 10:00:00"
             |> serialize |> decode |> get_str TimeEnded) );
         ( "decode bad JSON - not enough properties" >:: fun _ ->
           assert_raises (Failure "Bad JSON") (fun () ->
               decode
                 "{\"timestarted\": \"2024-05-13 10:00:00\", \"timeended\": \
                  \"2024-05-13 10:05:00\", \"won\": false}") );
         ( "serialize decode JSON" >:: fun _ ->
           assert_equal
             "{\"timestarted\":\"2024-05-13 \
              10:00:00\",\"timeended\":\"2024-05-13 \
              10:05:00\",\"won\":false,\"moves\":10}"
             (decode
                "{\"timestarted\": \"2024-05-13 10:00:00\", \"timeended\": \
                 \"2024-05-13 10:05:00\", \"won\": false, \"moves\": 10}"
             |> serialize) );
         ( "property_of_string string_of_property TimeEnded" >:: fun _ ->
           assert_equal TimeEnded
             (TimeEnded |> string_of_property |> property_of_string) );
         ( "property_of_string string_of_property Moves" >:: fun _ ->
           assert_equal Moves (Moves |> string_of_property |> property_of_string)
         );
         ( "property_of_string string_of_property Won" >:: fun _ ->
           assert_equal Won (Won |> string_of_property |> property_of_string) );
         ( "compare empty_with 2024-05-13 10:00:00, 2024-05-13 10:05:00 \
            TimeEnded"
         >:: fun _ ->
           assert_equal (-1)
             (compare TimeEnded
                (empty_with TimeEnded "2024-05-13 10:00:00")
                (empty_with TimeEnded "2024-05-13 10:05:00")) );
         ( "compare empty_with 2024-05-13 10:00:00, 2023-05-13 10:05:00 \
            TimeEnded"
         >:: fun _ ->
           assert_equal 1
             (compare TimeEnded
                (empty_with TimeEnded "2024-05-13 10:00:00")
                (empty_with TimeEnded "2023-05-13 10:05:00")) );
         ( "compare empty_with 2024-05-13 10:00:00, 2024-05-13 10:00:00 \
            TimeEnded"
         >:: fun _ ->
           assert_equal 0
             (compare TimeEnded
                (empty_with TimeEnded "2024-05-13 10:00:00")
                (empty_with TimeEnded "2024-05-13 10:00:00")) );
         ( "compare empty_with 6, 4 Moves" >:: fun _ ->
           assert_equal 1
             (compare Moves (empty_with Moves "6") (empty_with Moves "4")) );
         ( "compare empty_with false false Won" >:: fun _ ->
           assert_equal 0
             (compare Won (empty_with Won "false") (empty_with Won "false")) );
         ( "compare empty_with false true Won" >:: fun _ ->
           assert_equal (-1)
             (compare Won (empty_with Won "false") (empty_with Won "true")) );
       ]

open Stats

let stats_tests =
  "game stats tests"
  >::: [
         ( "get_timestamp 2024-01-10 17:15:45" >:: fun _ ->
           assert_equal "2024-01-10 17:15:45"
             (get_timestamp
                {
                  tm_sec = 45;
                  tm_min = 15;
                  tm_hour = 17;
                  tm_mday = 10;
                  tm_mon = 0;
                  tm_year = 124;
                  tm_wday = 3;
                  tm_yday = 10;
                  tm_isdst = false;
                }) );
         ( "get_stats" >:: fun _ ->
           assert_equal
             (true, "01/10/2024 17:15", "5m 15s", "58")
             (get_stats
                (Score
                   {
                     time_started = "2024-01-10 17:10:30";
                     time_ended = "2024-01-10 17:15:45";
                     won = true;
                     moves = 58;
                   })) );
         ( "get_stats no gap" >:: fun _ ->
           assert_equal
             (true, "01/10/2024 17:15", "0s", "58")
             (get_stats
                (Score
                   {
                     time_started = "2024-01-10 17:15:45";
                     time_ended = "2024-01-10 17:15:45";
                     won = true;
                     moves = 58;
                   })) );
         ( "get_stats years gap" >:: fun _ ->
           assert_equal
             (false, "01/10/2024 17:15", "1y 0s", "17")
             (get_stats
                (Score
                   {
                     time_started = "2023-01-10 17:15:45";
                     time_ended = "2024-01-10 17:15:45";
                     won = false;
                     moves = 17;
                   })) );
         ( "get_stats invalid no space" >:: fun _ ->
           assert_raises (Failure "Invalid timestamp format") (fun () ->
               get_stats
                 (Score
                    {
                      time_started = "2023-1-1017:15:45";
                      time_ended = "2024-01-10 17:15:45";
                      won = false;
                      moves = 17;
                    })) );
         ( "get_stats invalid no mins" >:: fun _ ->
           assert_raises (Failure "Invalid timestamp format") (fun () ->
               get_stats
                 (Score
                    {
                      time_started = "2023-1-10 17:45";
                      time_ended = "2024-01-10 17:15:45";
                      won = false;
                      moves = 17;
                    })) );
       ]

(* module TestGameTypes : Db.DatabaseTypes with type t = game_types and type
   sort_property = game_sort_property = struct include GameTypes let root_dir =
   "test_data" end module TestGameDB = Db.Database (TestGameTypes) *)

let _ = run_test_tt_main square_tests
let _ = run_test_tt_main board_tests
let _ = run_test_tt_main custom_board_tests
let _ = run_test_tt_main db_type_tests
let _ = run_test_tt_main stats_tests
