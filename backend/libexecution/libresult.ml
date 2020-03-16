open Core_kernel
open Lib
open Types.RuntimeT
module RT = Runtime

let fns : fn list =
  [ { prefix_names = ["Result::map"]
    ; infix_names = []
    ; parameters = [par "result" TResult; func ["val"]]
    ; return_type = TResult
    ; description =
        "Transform a Result using `f`, only if the Result is an Ok. If Error, doesn't nothing."
    ; func =
        InProcess
          (function
          | state, [DResult r; DBlock b] ->
            ( match r with
            | ResOk dv ->
                let result = Ast.execute_dblock ~state b [dv] in
                DResult (ResOk result)
            | ResError _ ->
                DResult r )
          | args ->
              fail args)
    ; preview_safety = Safe
    ; deprecated = true }
  ; { prefix_names = ["Result::map_v1"]
    ; infix_names = []
    ; parameters = [par "result" TResult; func ["val"]]
    ; return_type = TResult
    ; description =
        "Transform a Result using `f`, only if the Result is an Ok. If Error, doesn't nothing."
    ; func =
        InProcess
          (function
          | state, [DResult r; DBlock d] ->
            ( match r with
            | ResOk dv ->
                let result = Ast.execute_dblock ~state d [dv] in
                Dval.to_res_ok result
            | ResError _ ->
                DResult r )
          | args ->
              fail args)
    ; preview_safety = Safe
    ; deprecated = false }
  ; { prefix_names = ["Result::mapError"]
    ; infix_names = []
    ; parameters = [par "result" TResult; func ["val"]]
    ; return_type = TAny
    ; description =
        "Transform a Result by calling `f` on the Error portion of the Result. If Ok , does nothing."
    ; func =
        InProcess
          (function
          | state, [DResult r; DBlock b] ->
            ( match r with
            | ResOk _ ->
                DResult r
            | ResError err ->
                let result = Ast.execute_dblock ~state b [err] in
                DResult (ResError result) )
          | args ->
              fail args)
    ; preview_safety = Safe
    ; deprecated = true }
  ; { prefix_names = ["Result::mapError_v1"]
    ; infix_names = []
    ; parameters = [par "result" TResult; func ["val"]]
    ; return_type = TAny
    ; description =
        "Transform a Result by calling `f` on the Error portion of the Result. If Ok , does nothing."
    ; func =
        InProcess
          (function
          | state, [DResult r; DBlock b] ->
            ( match r with
            | ResOk _ ->
                DResult r
            | ResError err ->
                let result = Ast.execute_dblock ~state b [err] in
                Dval.to_res_err result )
          | args ->
              fail args)
    ; preview_safety = Safe
    ; deprecated = false }
  ; { prefix_names = ["Result::withDefault"]
    ; infix_names = []
    ; parameters = [par "result" TResult; par "default" TAny]
    ; return_type = TAny
    ; description =
        "Turn a result into a normal value, using `default` if the result is Error."
    ; func =
        InProcess
          (function
          | _, [DResult o; default] ->
            (match o with ResOk dv -> dv | ResError _ -> default)
          | args ->
              fail args)
    ; preview_safety = Safe
    ; deprecated = false }
  ; { prefix_names = ["Result::fromOption"]
    ; infix_names = []
    ; parameters = [par "option" TOption; par "error" TStr]
    ; return_type = TResult
    ; description =
        "Turn an option into a result, using `error` as the error message for Error."
    ; func =
        InProcess
          (function
          | _, [DOption o; DStr error] ->
            ( match o with
            | OptJust dv ->
                DResult (ResOk dv)
            | OptNothing ->
                DResult (ResError (DStr error)) )
          | args ->
              fail args)
    ; preview_safety = Safe
    ; deprecated = true }
  ; { prefix_names = ["Result::fromOption_v1"]
    ; infix_names = []
    ; parameters = [par "option" TOption; par "error" TStr]
    ; return_type = TResult
    ; description =
        "Turn an option into a result, using `error` as the error message for Error."
    ; func =
        InProcess
          (function
          | _, [DOption o; DStr error] ->
            ( match o with
            | OptJust dv ->
                Dval.to_res_ok dv
                (* match (Dval.to_opt_just dv) with
                  | DOption (OptJust v) -> Dval.to_res_ok v
                  | DError s -> DError s
                  | _ -> Dval.to_res_err (DStr error)
                *)
            | OptNothing ->
                Dval.to_res_err (DStr error) )
          | args ->
              fail args)
    ; preview_safety = Safe
    ; deprecated = false }
  ; { prefix_names = ["Result::toOption"]
    ; infix_names = []
    ; parameters = [par "result" TResult]
    ; return_type = TAny
    ; description = "Turn a result into an option."
    ; func =
        InProcess
          (function
          | _, [DResult o] ->
            ( match o with
            | ResOk dv ->
                DOption (OptJust dv)
            | ResError _ ->
                DOption OptNothing )
          | args ->
              fail args)
    ; preview_safety = Safe
    ; deprecated = true }
  ; { prefix_names = ["Result::toOption_v1"]
    ; infix_names = []
    ; parameters = [par "result" TResult]
    ; return_type = TAny
    ; description = "Turn a result into an option."
    ; func =
        InProcess
          (function
          | _, [DResult o] ->
            ( match o with
            | ResOk dv ->
                Dval.to_opt_just dv
            | ResError _ ->
                DOption OptNothing )
          | args ->
              fail args)
    ; preview_safety = Safe
    ; deprecated = false }
  ; { prefix_names = ["Result::andThen"]
    ; infix_names = []
    ; parameters = [par "result" TResult; func ["val"]]
    ; return_type = TResult
    ; description =
        "Transform a Result using `f`, only if the Result is an Ok. If Error, doesn't nothing. Combines the result into a single Result, where if both the caller and the result are Error, the result is a single Error"
    ; func =
        InProcess
          (function
          | state, [DResult o; DBlock b] ->
            ( match o with
            | ResOk dv ->
                let result = Ast.execute_dblock ~state b [dv] in
                ( match result with
                | DResult result ->
                    DResult result
                | other ->
                    RT.error
                      ~actual:other
                      ~expected:"a result"
                      "Expected `f` to return a result" )
            | ResError msg ->
                DResult (ResError msg) )
          | args ->
              fail args)
    ; preview_safety = Safe
    ; deprecated = true }
  ; { prefix_names = ["Result::andThen_v1"]
    ; infix_names = []
    ; parameters = [par "result" TResult; func ["val"]]
    ; return_type = TResult
    ; description =
        "Transform a Result using `f`, only if the Result is an Ok. If Error, doesn't nothing. Combines the result into a single Result, where if both the caller and the result are Error, the result is a single Error"
    ; func =
        InProcess
          (function
          | state, [DResult o; DBlock b] ->
            ( match o with
            | ResOk dv ->
                let result = Ast.execute_dblock ~state b [dv] in
                ( match result with
                | DResult (ResOk res) ->
                    Dval.to_res_ok res
                | DResult (ResError res) ->
                    Dval.to_res_err res
                | other ->
                    RT.error
                      ~actual:other
                      ~expected:"a result"
                      "Expected `f` to return a result" )
            | ResError msg ->
                DResult (ResError msg) )
          | args ->
              fail args)
    ; preview_safety = Safe
    ; deprecated = false } ]
