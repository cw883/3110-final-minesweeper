(* @authors Tami Takada (tt554), Xavier Diaz-Sun (xsd2) *)

val square : ?w:(int option) -> ?h:(int option) -> ?radius:int -> ?bg:Bogue.Draw.color -> unit -> Bogue.Widget.t
(** [square ~w:w ~h:h ~radius:r ~bg:bg ()] is a square with width [w], height [h], corner radius [r], and
    background color [bg]. *)

val text_button : ?w:(int option) -> ?h:(int option) -> ?radius:int -> ?bg:Bogue.Draw.color -> 
    ?fg:Bogue.Draw.color -> ?size:int -> ?f:(Bogue.Widget.t -> unit) -> text:string -> icon:string -> unit -> Bogue.Layout.t
(** [text_button ~w:w ~h:h ~radius:r ~bg:bg ~fg:fg ~size:size ~f:f ~text:text ~icon:icon ()] is a
    layout with width [w], height [h], corner radius [r], background color [bg], foreground color [fg],
    font and icon size [size], label text [text], and FontAwesome icon named [icon]. Connected to
    callback [f] on click event. *)

val picker : ?fg:Bogue.Draw.color -> ?size:int -> options:(string * 'a) list -> selected:int ref -> unit -> Bogue.Layout.t
(** [picker ~fg:fg ~size:size ~options:options ~selected:selected ()] is a picker view with foreground color 
    [fg] and font size [size]. [options] is the list of options displayed in the picker view, where each 
    [(str, value)] in [options] represents the string description (displayed value) and the actual value of 
    each option. [selected] points to the initial selected index. [selected] is updated when a new value is
    selected.
    Fails if [options] is empty or [selected] is out of bounds for [options]. *)

val generate_int_range_picker_options : int -> int -> int -> (string * int) list
(** [generate_int_range_picker_options start stop step] is a list of options that can be used to initialize
    the [picker]. The options are generated from the interval \[[start], [stop]) where each successive int
    is [step] greater than the last. The option descriptions are the result of [string_of_int] on each int. *)

val theme : Constants.color_palette ref
(** [theme] is a reference to the current theme. *)

val create_theme_picker : Bogue.Layout.t -> (unit -> unit) -> Bogue.Layout.t
(** [create_theme_picker] is a drop down menu that allows the user to select the theme they would like to 
    set for the game they are playing. **)