
(* 
Uses an access code to generate an access token which can be used to make requests
to the Spotify API on the users behalf
*)
val generate_access_token : string -> string Lwt.t

(* Constant url which will auto direct the user to login into their Spotify *)
val get_user_auth_request : string


