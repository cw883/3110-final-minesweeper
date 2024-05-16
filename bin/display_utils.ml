(* @authors Tami Takada (tt554), Xavier Diaz-Sun (xsd2) *)

open Constants
open Bogue
module W = Widget
module L = Layout

let theme = ref Constants.default

let theme_options =
  Array.of_list
    [
      "Default";
      "Inverse";
      "Vintage";
      "Ocean";
      "Pastel";
      "Midnight";
      "Zen";
      "Neon";
      "Nature";
      "Sunset";
      "Retro";
      "Eclipse";
      "Lantern";
      "Cherry Blossom";
      "Grayscale";
    ]

let apply_theme idx layout =
  L.unload_background layout;
  (* idk if this is actually doing anything (dont think so) *)
  theme :=
    match idx with
    | 0 -> Constants.default
    | 1 -> Constants.inverse
    | 2 -> Constants.vintage
    | 3 -> Constants.ocean
    | 4 -> Constants.pastel
    | 5 -> Constants.midnight
    | 6 -> Constants.zen
    | 7 -> Constants.neon
    | 8 -> Constants.nature
    | 9 -> Constants.sunset
    | 10 -> Constants.retro
    | 11 -> Constants.eclipse
    | 12 -> Constants.lantern
    | 13 -> Constants.cherry_blossom
    | 14 -> Constants.grayscale
    | _ -> Constants.default

let create_theme_picker layout update =
  let selected_index =
    match Array.find_index (fun x -> x = !theme.name) theme_options with
    | Some idx -> idx
    | None -> 0
  in
  Select.create ~name:"Theme"
    ~action:(fun idx ->
      apply_theme idx layout;
      update ())
    theme_options selected_index

let square ?(w = None) ?(h = None) ?(radius = 5)
    ?(bg = Draw.opaque !theme.background_color) () =
  let style =
    Solid bg |> Style.of_bg
    |> Style.with_border
         (Style.mk_border ~radius (Style.mk_line ~color:(0, 0, 0, 0) ()))
  in
  match (w, h) with
  | Some w, Some h -> W.box ~w ~h ~style ()
  | Some w, None -> W.box ~w ~style ()
  | None, Some h -> W.box ~h ~style ()
  | None, None -> W.box ~style ()

let text_button ?(w = Some 300) ?(h = Some 60) ?(radius = 5)
    ?(bg = Draw.opaque !theme.background_color)
    ?(fg = Draw.opaque !theme.number_color) ?(size = 18) ?f ~text ~icon () =
  let bg = square ~w ~h ~radius ~bg () in
  let click_fg = W.empty ~w:(Option.get w) ~h:(Option.get h) () in
  let label = W.label ~align:Draw.Min ~size ~fg text in
  let icon_label = W.icon ~size ~fg icon in
  let label_layout =
    match w with
    | Some w -> L.resident ~w:(w - 10 - size - (2 * 20)) label
    | None -> L.resident label
  in
  let () =
    match f with
    | Some f -> W.on_click ~click:f click_fg
    | None -> ()
  in
  let stack = L.flat ~sep:10 [ label_layout; L.resident icon_label ] in
  L.superpose ~center:true [ L.resident bg; stack; L.resident click_fg ]

let picker ?(fg = Draw.opaque !theme.number_color) ?(size = 16) ~options
    ~selected () =
  if List.is_empty options then failwith "Empty options"
  else if !selected < 0 || !selected >= List.length options then
    failwith "Invalid initial option"
  else
    let label =
      List.nth options !selected |> fst |> W.label ~align:Draw.Center ~size ~fg
    in
    let up_arrow = W.icon ~size:20 "caret-up" in
    let down_arrow = W.icon ~size:20 "caret-down" in
    W.on_click
      ~click:(fun _ ->
        selected := (!selected + 1) mod List.length options;
        W.set_text label (List.nth options !selected |> fst);
        W.update label)
      up_arrow;
    W.on_click
      ~click:(fun _ ->
        if !selected = 0 then selected := List.length options - 1
        else selected := !selected - 1;
        W.set_text label (List.nth options !selected |> fst);
        W.update label)
      down_arrow;
    L.tower ~clip:false ~sep:2 ~align:Draw.Center
      [ L.resident up_arrow; L.resident ~w:30 label; L.resident down_arrow ]

let generate_int_range_picker_options start stop step =
  let rec generate current acc =
    if current < start then acc
    else (string_of_int current, current) :: acc |> generate (current - step)
  in
  generate (stop - step) []
