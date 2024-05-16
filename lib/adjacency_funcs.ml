(* @authors Cougar Hashikura (ch999) *)

let find_adjacent_squares_default row col =
  [
    (row - 1, col - 1);
    (row, col - 1);
    (row + 1, col - 1);
    (row - 1, col);
    (row + 1, col);
    (row - 1, col + 1);
    (row, col + 1);
    (row + 1, col + 1);
  ]

let find_adjacent_squares_knight row col =
  [
    (row - 1, col - 2);
    (row + 1, col - 2);
    (row - 1, col + 2);
    (row + 1, col + 2);
    (row - 2, col - 1);
    (row + 2, col - 1);
    (row - 2, col + 1);
    (row + 2, col + 1);
  ]

let find_adjacent_squares_cross row col =
  [ (row - 1, col); (row + 1, col); (row, col - 1); (row, col + 1) ]

let find_adjacent_squares_big_cross row col =
  [
    (row - 1, col);
    (row - 2, col);
    (row + 1, col);
    (row + 2, col);
    (row, col - 1);
    (row, col - 2);
    (row, col + 1);
    (row, col + 2);
  ]

let find_adjacent_squares_diag row col =
  [
    (row - 1, col - 1);
    (row - 1, col + 1);
    (row + 1, col - 1);
    (row + 1, col + 1);
  ]

let find_adjacent_squares_big_diag row col =
  [
    (row - 1, col - 1);
    (row - 2, col - 2);
    (row - 1, col + 1);
    (row - 2, col + 2);
    (row + 1, col - 1);
    (row + 2, col - 2);
    (row + 1, col + 1);
    (row + 2, col + 2);
  ]

let find_adjacent_squares_ring row col =
  [
    (row - 2, col - 1);
    (row - 2, col);
    (row - 2, col + 1);
    (row + 2, col - 1);
    (row + 2, col);
    (row + 2, col + 1);
    (row - 1, col - 2);
    (row, col - 2);
    (row + 1, col - 2);
    (row - 1, col + 2);
    (row, col + 2);
    (row + 1, col + 2);
  ]
