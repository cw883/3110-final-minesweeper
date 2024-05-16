(* @authors Tami Takada (tt554) *)

module type DatabaseTypes = sig
  type t
  (** [t] is a one-of-many type that represents the options for the types 
      of documents stored in a database. *)

  type sort_property
  (** [sort_property] is a nested one-of-many type that represents the
      sortable properties of each type in [t]. *)

  val root_dir : string
  (** [root_dir] is the root directory for all database files. *)

  val get_str : sort_property -> t -> string
  (** [get_str p d] is the string representation of the property [p] in [d].
      Requires: [p] is a valid property for [d]. *)

  val empty_with : sort_property -> string -> t
  (** [empty_with p str] is a dummy document used for comparisons with only
      property [p] set to the value represented by [str]. *)

  val serialize : t -> string
  (** [serialize d] is a JSON string representation of [d]. *)

  val decode : string -> t
  (** [decode str] is the document represented by the JSON string [str]. *)

  val compare : sort_property -> t -> t -> int
  (** [compare p d1 d2] compares [d1] and [d2] on their values for property [p].
      Requires: [p] is a valid property for [d1] and [d2]. *)

  val string_of_property : sort_property -> string
  (** [string_of_property p] is the name of [p]. *)

  val property_of_string : string -> sort_property
  (** [property_of_string str] is the property named [str]. *)
end

module Database (T : DatabaseTypes) : sig 

  type index_cache

  val init_dir : unit -> unit
  (** [init_dir ()] creates T.root_dir if it does not exist. *)

  val init_cache : unit -> index_cache
  (** [init_cache ()] is an index cache initialized with data from any existing index files. *)

  val write_cache : index_cache -> unit
  (** [write_cache cache] overwrites existing index files with [cache] data. *)

  val create_collection : ?data:T.t list -> ?indices:T.sort_property list -> string -> index_cache -> index_cache
  (** [create_collection ?data:data ?indices:indices name cache] attempts to create a new
      collection of [data] with unique identifier [name]. If [indices] is specified,
      creates a sorted index for each property in [indices] to optimize queries. [cache] is
      updated with any new indices. Returns updated [cache].
      Requires: [name] is unique. *)

  val insert_document : string -> T.t -> index_cache -> index_cache
  (** [insert_document name d cache] inserts [d] into the collection named [name] in
      the database and returns the updated [cache] reindexed to include [d]. *)

  val get_all : ?filter:(T.t -> bool) -> ?filter_on_sort:(string -> bool) -> sort_by:T.sort_property -> string -> index_cache -> T.t list
  (** [get_all ?filter:f2 ?filter_on_sort:f1 ~sort_by:p name cache] executes a query on the
      collection named [name] using [cache], ordering results by [p] and optionally applying 
      filters [f2] and [f1]. [f1] is applied first because the sort property is already fetched
      in the index, so filtering does not require extra fetching. [f2] is applied next 
      to the full fetched document. Returns list of documents queried.
      Requires: [p] is a valid property for all documents in the collection.  *)

end