type t = Types.fluidExpr

(** Generate a new EBlank *)
val newB : unit -> t

(** We use this to convert to the old Expr type, and also to convert to
 * tokens. *)
val functions : Types.function_ list ref

(** [id e] returns the id of [e] *)
val id : t -> Types.id

(** [show e] returns a string representation of [e]. *)
val show : t -> string

(** [walk f ast] is a helper for recursively walking an expression tree. It
    returns a new ast with every subexpression e replaced by [f e]. To use
    effectively, [f] must call [walk]. *)
val walk : f:(t -> t) -> t -> t

(** [filterMap f ast] calls f on every expression, keeping any Some results
 * of f, returning them in a list. Recurses into expressions: if a child and
 * its parent (or grandparent, etc) both match, then both will be in the
 * result list. *)
val filterMap : f:(t -> 'a option) -> t -> 'a list

(** [filter f ast] calls f on every expression, returning a list of all
 * expressions for which [f e] is true. Recurses into expressions: if a
 * child and its parent (or grandparent, etc) both match, then both will be
 * in the result list.  *)
val filter : f:(t -> bool) -> t -> t list

(** [findExprOrPat target within] recursively finds the subtree
    with the id = [target] inside the [within] tree, returning the subtree
    wrapped in fluidPatOrExpr, or None if there is no subtree with the id [target] *)
val findExprOrPat :
  Types.id -> Types.fluidPatOrExpr -> Types.fluidPatOrExpr option

(** [find target ast] recursively finds the expression having an id of [target]
   and returns it if found. *)
val find : Types.id -> t -> t option

(** [findParent target ast] recursively finds the expression having an id of
    [target] and then returns the parent of that expression. *)
val findParent : Types.id -> t -> t option

(** [isEmpty e] returns true if e is an EBlank or a collection (ERecord or
    EList) with only EBlanks inside. *)
val isEmpty : t -> bool

(** [hasEmptyWithId target ast] recursively finds the expression having an id
    of [target] and returns true if that expression exists and [isEmpty]. *)
val hasEmptyWithId : Types.id -> t -> bool

(** [isBlank e] returns true iff [e] is an EBlank. *)
val isBlank : t -> bool

(** [update f target ast] recursively searches [ast] for an expression e
    having an id of [target].

    If found, replaces the expression with the result of [f e] and returns the new ast.
    If not found, will assertT before returning the unmodified [ast]. *)
val update : ?failIfMissing:bool -> f:(t -> t) -> Types.id -> t -> t

(** [replace replacement target ast] finds the expression with id of [target] in the [ast] and replaces it with [replacement]. *)
val replace : replacement:t -> Types.id -> t -> t

val removeVariableUse : string -> t -> t

val renameVariableUses : oldName:string -> newName:string -> t -> t

val updateVariableUses : string -> f:(t -> t) -> t -> t

val clone : t -> t
