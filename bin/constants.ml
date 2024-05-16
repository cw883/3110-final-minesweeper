(* @authors Xavier Diaz-Sun (xsd2), Tami Takada (tt554) *)

let bwidth = 750
let bheight = 750

type color_palette = {
  name : string;
  background_color : int * int * int;
  empty_tile_color : int * int * int;
  losing_color : int * int * int;
  winning_color : int * int * int;
  number_color : int * int * int;
  flag_color : int * int * int;
}

let default =
  {
    name = "Default";
    background_color = (31, 72, 126);
    (* dark blue *)
    empty_tile_color = (36, 123, 160);
    (* blue *)
    losing_color = (251, 54, 64);
    (* red *)
    winning_color = (246, 201, 40);
    (* yellow *)
    number_color = (244, 237, 237);
    (* white *)
    flag_color = (0, 255, 0);
    (* green *)
  }

let inverse =
  {
    name = "Inverse";
    background_color = (224, 183, 129);
    empty_tile_color = (219, 132, 95);
    losing_color = (4, 100, 191);
    winning_color = (9, 155, 215);
    number_color = (11, 18, 18);
    flag_color = (255, 0, 255);
  }

let vintage =
  {
    name = "Vintage";
    background_color = (244, 241, 222);
    empty_tile_color = (193, 154, 107);
    losing_color = (140, 21, 21);
    winning_color = (168, 219, 168);
    number_color = (77, 38, 22);
    flag_color = (255, 167, 38);
  }

let ocean =
  {
    name = "Ocean";
    background_color = (28, 163, 236);
    empty_tile_color = (27, 116, 187);
    losing_color = (255, 87, 34);
    winning_color = (113, 201, 206);
    number_color = (255, 255, 255);
    flag_color = (137, 196, 244);
  }

let pastel =
  {
    name = "Pastel";
    background_color = (242, 181, 219);
    empty_tile_color = (197, 225, 165);
    losing_color = (244, 143, 177);
    winning_color = (179, 167, 252);
    number_color = (255, 245, 157);
    flag_color = (255, 183, 77);
  }

let midnight =
  {
    name = "Midnight";
    background_color = (23, 23, 82);
    empty_tile_color = (25, 39, 139);
    losing_color = (139, 0, 0);
    winning_color = (211, 211, 211);
    number_color = (248, 248, 255);
    flag_color = (75, 0, 130);
  }

let zen =
  {
    name = "Zen";
    background_color = (233, 228, 220);
    empty_tile_color = (168, 176, 183);
    losing_color = (238, 207, 230);
    winning_color = (129, 161, 193);
    number_color = (181, 187, 227);
    flag_color = (69, 123, 157);
  }

let neon =
  {
    name = "Neon";
    background_color = (25, 25, 25);
    empty_tile_color = (0, 255, 255);
    losing_color = (255, 20, 147);
    winning_color = (173, 255, 47);
    number_color = (255, 20, 147);
    flag_color = (255, 85, 255);
  }

let nature =
  {
    name = "Nature";
    background_color = (25, 111, 61);
    empty_tile_color = (133, 187, 101);
    losing_color = (181, 101, 29);
    winning_color = (255, 223, 0);
    number_color = (255, 255, 255);
    flag_color = (204, 0, 0);
  }

let sunset =
  {
    name = "Sunset";
    background_color = (255, 87, 34);
    empty_tile_color = (255, 195, 113);
    losing_color = (114, 9, 183);
    winning_color = (255, 216, 0);
    number_color = (0, 0, 0);
    flag_color = (128, 0, 32);
  }

let retro =
  {
    name = "Retro";
    background_color = (58, 12, 163);
    empty_tile_color = (138, 3, 3);
    losing_color = (4, 4, 74);
    winning_color = (204, 204, 0);
    number_color = (255, 255, 255);
    flag_color = (0, 255, 255);
  }

let eclipse =
  {
    name = "Eclipse";
    background_color = (100, 100, 100);
    empty_tile_color = (60, 60, 60);
    losing_color = (255, 0, 0);
    winning_color = (255, 255, 255);
    number_color = (204, 204, 204);
    flag_color = (139, 0, 139);
  }

let lantern =
  {
    name = "Lantern";
    background_color = (128, 0, 0);
    empty_tile_color = (252, 142, 48);
    losing_color = (183, 104, 14);
    winning_color = (255, 215, 0);
    number_color = (255, 250, 240);
    flag_color = (153, 76, 0);
  }

let cherry_blossom =
  {
    name = "Cherry Blossom";
    background_color = (255, 182, 193);
    empty_tile_color = (250, 235, 215);
    losing_color = (100, 100, 100);
    winning_color = (255, 250, 205);
    number_color = (255, 105, 180);
    flag_color = (160, 82, 45);
  }

let grayscale =
  {
    name = "Grayscale";
    background_color = (100, 100, 100);
    empty_tile_color = (200, 200, 200);
    losing_color = (150, 150, 150);
    winning_color = (150, 150, 150);
    number_color = (0, 0, 0);
    flag_color = (0, 0, 0);
  }
