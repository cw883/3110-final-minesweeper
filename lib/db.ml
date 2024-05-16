(* @authors Tami Takada (tt554) *)

module type DatabaseTypes = sig
  type t
  type sort_property

  val root_dir : string
  val get_str : sort_property -> t -> string
  val empty_with : sort_property -> string -> t
  val serialize : t -> string
  val decode : string -> t
  val compare : sort_property -> t -> t -> int
  val string_of_property : sort_property -> string
  val property_of_string : string -> sort_property
end

module Database (T : DatabaseTypes) = struct
  type index_cache = (string * string * (string * int * int) list) list
  (** [[(coll_name, prop_name, coll_data)]] is a list of cached indices.
      [coll_data] is sorted by [prop_name] for each index, and contains only the
      sorted property. *)

  let root_dir = T.root_dir
  let db_path name = root_dir ^ name ^ ".db"

  let init_dir () =
    try
      match Sys.mkdir root_dir 0o770 with
      | () -> ()
    with Sys_error _ -> ()

  let extract_names_from fname =
    match String.split_on_char '.' fname with
    | [ elt; _ ] -> begin
        match String.split_on_char '_' elt with
        | [ coll_name; prop_name ] -> (coll_name, prop_name)
        | _ -> failwith "Invalid index file name"
      end
    | _ -> failwith "Invalid index file name"

  let file_name_from coll_name prop_name = coll_name ^ "_" ^ prop_name ^ ".idx"

  let init_cache () =
    Sys.readdir root_dir
    |> Array.fold_left
         (fun acc fname ->
           if String.ends_with ~suffix:".idx" fname then (
             let coll_name, prop_name = extract_names_from fname in
             let f = Unix.openfile (root_dir ^ fname) [ Unix.O_RDONLY ] 0 in
             let size = (Unix.stat (root_dir ^ fname)).st_size in
             let buf = Bytes.create size in
             let read = Unix.read f buf 0 size in
             Unix.close f;
             if read <> size then failwith "Failed to read index"
             else begin
               match buf |> Bytes.to_string |> Yojson.Basic.from_string with
               | `Assoc [ ("data", `List l) ] ->
                   ( coll_name,
                     prop_name,
                     l
                     |> List.map (fun elt ->
                            match elt with
                            | `Assoc
                                [
                                  ("d", `String d);
                                  ("ls", `Int ls);
                                  ("le", `Int le);
                                ] -> (d, ls, le)
                            | _ -> failwith "Bad JSON") )
                   :: acc
               | _ -> failwith "Bad JSON"
             end)
           else acc)
         []

  let update_cache name (d, ls, le) =
    List.fold_left
      (fun acc (coll_name, prop_name, coll_data) ->
        if coll_name = name then begin
          let p = T.property_of_string prop_name in
          let new_data =
            if List.is_empty coll_data then [ (T.get_str p d, ls, le) ]
            else begin
              let appended = (T.get_str p d, ls, le) :: coll_data in
              List.sort
                (fun (d1, _, _) (d2, _, _) ->
                  T.compare p (T.empty_with p d1) (T.empty_with p d2))
                appended
            end
          in
          (coll_name, prop_name, new_data) :: acc
        end
        else (coll_name, prop_name, coll_data) :: acc)
      []

  let insert_index p name data (cache : index_cache) =
    if
      String.contains name '_'
      || String.contains (T.string_of_property p) '_'
      || String.contains name '.'
      || String.contains (T.string_of_property p) '.'
    then failwith "Collection/property names cannot contain _ or .";

    let sorted =
      List.sort (fun (d1, _, _) (d2, _, _) -> T.compare p d1 d2) data
    in
    let str =
      "{\"data\": ["
      ^ fst
          (List.fold_left
             (fun (acc, i) (d, ls, le) ->
               ( (if i = 0 then "" else ", ")
                 ^ Yojson.Basic.to_string
                     (`Assoc
                       [
                         ("d", `String (T.get_str p d));
                         ("ls", `Int ls);
                         ("le", `Int le);
                       ])
                 ^ acc,
                 i - 1 ))
             ("]}", List.length sorted - 1)
             sorted)
    in

    let f =
      Unix.openfile
        (root_dir ^ file_name_from name (T.string_of_property p))
        [ Unix.O_CREAT; Unix.O_WRONLY ]
        0o600
    in
    let bstr = Bytes.of_string str in
    let len = Bytes.length bstr in
    let res = Unix.single_write f bstr 0 len = len in
    Unix.close f;

    if res then
      ( name,
        T.string_of_property p,
        List.map (fun (d, ls, le) -> (T.get_str p d, ls, le)) sorted )
      :: cache
    else failwith "Read error"

  let write_cache (cache : index_cache) =
    List.iter
      (fun (coll_name, prop_name, coll_data) ->
        let f =
          Unix.openfile
            (root_dir ^ file_name_from coll_name prop_name)
            [ Unix.O_TRUNC; Unix.O_WRONLY ]
            0
        in
        let str =
          "{\"data\": ["
          ^ fst
              (List.fold_left
                 (fun (acc, i) (d, ls, le) ->
                   ( (if i = 0 then "" else ", ")
                     ^ Yojson.Basic.to_string
                         (`Assoc
                           [
                             ("d", `String d); ("ls", `Int ls); ("le", `Int le);
                           ])
                     ^ acc,
                     i - 1 ))
                 ("]}", List.length coll_data - 1)
                 coll_data)
        in
        let bstr = Bytes.of_string str in
        let len = Bytes.length bstr in
        let res = Unix.single_write f bstr 0 len = len in
        Unix.close f;
        if not res then failwith "Write error")
      cache

  let create_collection ?(data = []) ?(indices = []) name cache =
    let f =
      Unix.openfile (db_path name)
        [ Unix.O_EXCL; Unix.O_CREAT; Unix.O_WRONLY ]
        0o600
    in
    let bs, locs, len =
      List.fold_left
        (fun (bs, locs, len) elt ->
          let b = elt |> T.serialize |> String.to_bytes in
          let bend = Bytes.length b + len in
          (b :: bs, (elt, len, bend) :: locs, bend))
        ([], [], 0) data
    in
    let written =
      Unix.single_write f (Bytes.concat Bytes.empty (List.rev bs)) 0 len
    in
    Unix.close f;
    if written <> len then failwith "Write error";
    List.fold_left
      (fun new_cache p -> insert_index p name locs new_cache)
      cache indices

  let read_data f ls le =
    let buf = Bytes.create (le - ls) in
    ignore (Unix.lseek f ls Unix.SEEK_SET);
    let read = Unix.read f buf 0 (le - ls) in
    if read <> le - ls then failwith "Read Error"
    else buf |> Bytes.to_string |> T.decode

  let get_all ?filter ?filter_on_sort ~sort_by name cache =
    let f = Unix.openfile (db_path name) [ Unix.O_RDONLY ] 0 in
    let _, _, locs =
      List.find
        (fun (coll_name, prop_name, _) ->
          coll_name = name && prop_name = T.string_of_property sort_by)
        cache
    in
    List.fold_left
      (fun acc (d, ls, le) ->
        match (filter_on_sort, filter) with
        | Some f1, Some f2 ->
            if f1 d then
              let data = read_data f ls le in
              if f2 data then data :: acc else acc
            else acc
        | Some f1, None -> if f1 d then read_data f ls le :: acc else acc
        | None, Some f2 ->
            let data = read_data f ls le in
            if f2 data then data :: acc else acc
        | None, None -> read_data f ls le :: acc)
      [] locs

  let insert_document name d cache =
    let f = Unix.openfile (db_path name) [ Unix.O_WRONLY; Unix.O_APPEND ] 0 in
    let b = d |> T.serialize |> String.to_bytes in
    let ls = (Unix.stat (db_path name)).st_size in
    let len = Bytes.length b in
    let written = Unix.single_write f b 0 len in
    Unix.close f;
    if written <> len then failwith "";
    update_cache name (d, ls, ls + len) cache
end
