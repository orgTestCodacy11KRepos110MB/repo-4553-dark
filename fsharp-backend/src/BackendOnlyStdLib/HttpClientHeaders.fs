module BackendOnlyStdLib.HttpClientHeaders

// Header utility functions for HttpClient and LibHttpClient*. Might need to be split
// into per-client versions in the future. Deliberately kept separate from the Http
// Middleware, as we want to be able to change them separately.

open Prelude

let hasFormHeader (headers : HttpHeaders.T) : bool =
  headers
  |> HttpHeaders.get "content-type"
  |> Option.map Tablecloth.String.toLowercase = Some
                                                  "application/x-www-form-urlencoded"

let hasJsonHeader (headers : HttpHeaders.T) : bool =
  // CLEANUP: don't use contains for this
  HttpHeaders.get "content-type" headers
  |> Option.map (fun s -> s.Contains "application/json")
  |> Option.defaultValue false

let hasTextHeader (headers : HttpHeaders.T) : bool =
  // CLEANUP: don't use contains for this
  HttpHeaders.get "content-type" headers
  |> Option.map (fun s -> s.Contains "text/plain")
  |> Option.defaultValue false
