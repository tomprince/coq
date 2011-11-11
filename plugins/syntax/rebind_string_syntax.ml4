(*i camlp4deps: "parsing/grammar.cma" i*)

open Pp
open Util
open Names
open Pcoq
open Libnames
open Topconstr
open Glob_term
open Coqlib
open Genarg

open Ascii_syntax
open String_syntax

let interp_custom as_str str dloc s =
  GApp (dloc, GRef (dloc, str),
    [(if as_str then interp_string else interp_ascii_string) dloc s])

let uninterp_custom as_str str r =
  match r with
  | GApp (_,GRef (_,k),[a]) when k = str ->
      if as_str then
        uninterp_string a
      else uninterp_ascii_string a
  | _ -> None

let register_custom_interp as_str str scope =
  Notation.declare_string_interpreter scope
  (Nametab.path_of_global str, [])
  (*json_path, json_module*)
  (interp_custom as_str str)
    ([GRef (dummy_loc,str)],
    uninterp_custom as_str str, true)

VERNAC COMMAND EXTEND StringNotation
  [ "String" "Notation" reference(str) ":" ident(scope) ] -> [ register_custom_interp true (Nametab.global str) (string_of_id scope) ]
END

VERNAC COMMAND EXTEND CharNotation
  [ "Char" "Notation" reference(str) ":" ident(scope) ] -> [ register_custom_interp false (Nametab.global str) (string_of_id scope) ]
END
