(* open Tc *)

module Cmd = Tea.Cmd
module Attr = Tea.Html2.Attributes
module Events = Tea.Html2.Events
module Html = Tea_html_extended
open FullstoryTypes

module FullstoryJs = struct
  external _setConsent : bool -> unit = "setConsent"
    [@@bs.val] [@@bs.scope "window", "Dark", "fullstory"]

  external _pause : unit -> unit = "pause"
    [@@bs.val] [@@bs.scope "window", "Dark", "fullstory"]

  external _record : unit -> unit = "record"
    [@@bs.val] [@@bs.scope "window", "Dark", "fullstory"]

  let setConsent (allow : bool) : Types.msg Cmd.t =
    Cmd.call (fun _ -> _setConsent allow)


  let pause () : Types.msg Cmd.t = Cmd.call (fun _ -> _pause ())

  let record () : Types.msg Cmd.t = Cmd.call (fun _ -> _record ())
end

module SetConsent = struct
  let decode =
    let open Tea.Json.Decoder in
    field "detail" (Decoders.wrapDecoder Decoders.optBool)


  let listen ~key tagger =
    BrowserListeners.registerGlobal "FullstoryConsent" key tagger decode
end

let update (msg : msg) : Types.modification =
  match msg with
  | InitConsent consent ->
      ReplaceAllModificationsWithThisOne
        (fun m ->
          ({m with fullstory = {consent}}, Cmd.none))
  | SetConsent allow ->
      ReplaceAllModificationsWithThisOne
        (fun m ->
          let consent = Some allow in
          ( {m with fullstory = {consent}}
          , FullstoryJs.setConsent allow ))


let disableOmniOpen = ViewUtils.nothingMouseEvent "mousedown"

let html (t : t) : Types.msg Html.html =
  let radio value label msg =
    let key = "fs-consent-" ^ value in
    Html.div
      [Html.class' "choice"; disableOmniOpen]
      [ Html.input'
          [ Html.type' "radio"
          ; Html.id key
          ; Html.name "fs-consent"
          ; Html.value value
          ; ViewUtils.eventNoPropagation ~key "click" (fun _ ->
                FullstoryMsg msg) ]
          []
      ; Html.label [Html.for' key] [Html.text label] ]
  in
  let content =
    [ Html.p
              []
              [ Html.text
                  "Hi! While we're in private beta, we're really interested in peoples' experience learning Dark, and videos are the best way to see."
              ]
          ; Html.p
              []
              [ Html.text
                  "Are you willing to help us out and let us see your session after this? We'll never share it with anyone else."
              ]
          ; Html.div
              [Html.class' "consent"]
              [ radio "yes" "Yes! Record me using Dark." (SetConsent true)
              ; radio "no" "No. Don't me using Dark." (SetConsent false) ] ]
  in
  let cls = if t.consent = None then "ask" else "hide" in
  Html.div [Html.class' ("fullstory-modal " ^ cls)] content
