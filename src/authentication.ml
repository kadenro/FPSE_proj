open Lwt
open Cohttp
open Cohttp_lwt_unix
open Core


let redirect_uri = "http://localhost:8080/authenticate/"  
let client_id = "ff69dc4240204112b58c368e2b9d37b3" 
let client_secret = "8c4a2e83174949ef82e30d259f774285"

let send_token_request (access_code : string) : string Lwt.t= 
  let token_uri = "https://accounts.spotify.com/api/token?" ^ "grant_type=authorization_code" ^ 
                  "&code=" ^ access_code ^ "&redirect_uri=" ^ redirect_uri ^ "&client_id=" ^ client_id 
                  ^ "&client_secret=" ^ client_secret |> Uri.of_string
  in 
  let headers = 
    let base = Header.init() in
    Header.add base "Content-Type" "application/x-www-form-urlencoded" in 
  Client.call ~headers `POST token_uri >>= 
  fun (response, body) -> 
  match (response |> Response.status |> Code.code_of_status) with 
  | 200 -> 
    body |> Cohttp_lwt.Body.to_string
  | _ -> 
    body |> Cohttp_lwt.Body.to_string 

let get_field_from_response (field_name : string) (response : string) : string =
  Yojson.Safe.from_string response |>
  Yojson.Safe.Util.member field_name |> 
  Yojson.Safe.to_string |> 
  String.filter ~f: (fun c -> not @@ Char.(=) c '"')

let generate_access_token (access_code : string) : string Lwt.t = 
  let%lwt response = send_token_request access_code in 
  let access_token = get_field_from_response "access_token" response in 
  Lwt.return access_token

let get_user_auth_request : string = 
  (* Potentially add state header to increase security?? *)
  let auth_uri = "https://accounts.spotify.com/authorize?" in 
  auth_uri ^ "client_id=" ^ client_id ^ "&response_type=code" ^ "&redirect_uri=" ^ redirect_uri 
  ^ "&scope=playlist-modify-public"
