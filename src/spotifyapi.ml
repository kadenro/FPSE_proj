open Lwt
open Cohttp
open Cohttp_lwt_unix
open Core

(* Spotify library - handles all interaction with Spotify API and generation of playlists/tracks
*)

let playlist_size = 10 
type song = {id:string; name: string; oembed_src: string;}

(* App will maintain a current playlist at all times *)
type playlist = song list 

let generate_random_letter () : string = 
  65 + Random.int 26 |> 
  Char.of_int |> 
  Option.value_exn (* Should not be out of bounds ever *) |>
  Char.to_string

let get_random_element (list : 'a list) : 'a = 
  List.nth_exn list @@ Random.int @@ List.length list

let generic_request (base_uri : string) (headers : Header.t) (http_method : Cohttp.Code.meth) (body : Cohttp_lwt.Body.t) : string Lwt.t = 
  Client.call ~headers ~body http_method (base_uri |> Uri.of_string) >>= 
  fun (response, body) -> 
  let%lwt body = body |> Cohttp_lwt.Body.to_string in
  match (response |> Response.status |> Code.code_of_status) with 
  | 200 | 201 -> 
    return body
  (* Any non success code should log the error *)
  | _ -> 
    print_endline body;
    return body

let song_request (access_token : string) : string Lwt.t = 
  let limit = "50" in
  (* Generate two letter combos to maximize search possibilities *)
  let query = generate_random_letter () ^ generate_random_letter () in
  let base_uri = "https://api.spotify.com/v1/search/?q=" ^ query 
                 ^ "&type=track&limit=" ^ limit in 
  let headers = 
    let base = Header.init() in
    Header.add base "Authorization" ("Bearer " ^ access_token) in 
  generic_request base_uri headers `GET (Cohttp_lwt.Body.empty)

let recommendation_request (access_token : string) (playlist : song list) : string Lwt.t = 
  let extract_random_id (list_ : song list) : string = let rand_song = get_random_element list_ in rand_song.id in
  (* Max of 5 songs can go in recommendation *)
  let base_uri = "https://api.spotify.com/v1/recommendations/?limit=1&?seed_artists=&seed_genres=&seed_tracks=" ^ extract_random_id playlist ^ "," 
                 ^ extract_random_id playlist ^ "," ^ extract_random_id playlist ^ ","
                 ^ extract_random_id playlist ^ "," ^ extract_random_id playlist in 
  let headers = 
    let base = Header.init() in
    Header.add base "Authorization" ("Bearer " ^ access_token) in 
  generic_request base_uri headers `GET (Cohttp_lwt.Body.empty)


let user_id_request (access_token : string) : string Lwt.t = 
  let base_uri = "https://api.spotify.com/v1/me/?q=" in 
  let headers = 
    let base = Header.init() in
    Header.add base "Authorization" ("Bearer " ^ access_token) in 
  generic_request base_uri headers `GET (Cohttp_lwt.Body.empty)

let create_playlist_request (access_token : string) (user_id : string ): string Lwt.t = 
  let base_uri = "https://api.spotify.com/v1/users/" ^ user_id ^ "/playlists/" in 
  let headers = 
    let base = Header.init() in
    Header.add base "Authorization" ("Bearer " ^ access_token) in 
  let body = 
    Cohttp_lwt.Body.of_string "
    {
      \"name\": \"Random Playlist\",
      \"description\": \"A playlist of randomly generated songs\"
    }" in
  generic_request base_uri headers `POST body

let add_songs_to_playlist_request (access_token : string) (playlist_id : string ) (playlist_uris : string): string Lwt.t = 
  let base_uri = "https://api.spotify.com/v1/playlists/" ^ playlist_id ^ "/tracks/?uris=" ^ playlist_uris in 
  let headers = 
    let base = Header.init() in
    Header.add base "Authorization" ("Bearer " ^ access_token) in 
  generic_request base_uri headers `POST (Cohttp_lwt.Body.empty)

let get_track_list_from_response (response : string) : Yojson.Safe.t list =
  Yojson.Safe.from_string response |>
  Yojson.Safe.Util.member "tracks" |> 
  Yojson.Safe.Util.member "items" |>
  Yojson.Safe.Util.to_list

let get_field (field_name : string) (item : Yojson.Safe.t) : string =
  let quoted_field = item |> Yojson.Safe.Util.member field_name |> Yojson.Safe.to_string in
  (* Remove first and last quote from the field value *)
  String.sub quoted_field ~pos: 1 ~len: ((String.length quoted_field) - 2)

let json_item_to_song (item : Yojson.Safe.t) : song = 
  let id = get_field "id" item in 
  {id = id; name = get_field "name" item; 
   oembed_src = "https://open.spotify.com/embed/track/" ^ id ^ "?utm_source=oembed";}

let generate_random_song (access_token : string) : song Lwt.t = 
  let%lwt response = song_request access_token in
  let random_track = get_track_list_from_response response |> get_random_element |> json_item_to_song in
  return @@ random_track

let generate_random_playlist (access_token : string) : song list Lwt.t = 
  Lwt.all @@
  List.init playlist_size ~f: (fun _ ->  generate_random_song access_token) 

let get_track_list_from_recommendation_response (response : string) : Yojson.Safe.t list =
  Yojson.Safe.from_string response |>
  Yojson.Safe.Util.member "tracks" |> 
  Yojson.Safe.Util.to_list

let generate_song_from_curr_playlist (access_token : string) (playlist : song list) : song Lwt.t = 
  (* If no songs currently in users playlist generate a truly random song *)
  if ((List.length playlist) = 0) then generate_random_song access_token 
  (* Otherwise generate a recommended song from the current playlist *)
  else 
    let%lwt response = recommendation_request access_token playlist in  
    let track = get_track_list_from_recommendation_response response |> List.hd_exn |> json_item_to_song in
    return @@ track

let get_user_id (access_token : string) : string Lwt.t = 
  let%lwt response = user_id_request access_token in  
  let user_id = Yojson.Safe.from_string response |> get_field "id" in
  return @@ user_id

let create_playlist (access_token : string) (user_id : string): (string * string) Lwt.t = 
  let%lwt response = create_playlist_request access_token user_id in  
  let playlist_id = Yojson.Safe.from_string response |> get_field "id" in
  let playlist_link = Yojson.Safe.from_string response |> Yojson.Safe.Util.member "external_urls" |> get_field "spotify" in
  return @@ (playlist_id,playlist_link)

let add_songs_to_playlist (access_token : string) (playlist_id : string) (playlist : song list): unit Lwt.t = 
  let playlist_uris = 
    playlist |> 
    List.map ~f: (fun song -> "spotify:track:" ^ song.id) |>
    List.foldi ~init: "" ~f: (fun index curr_string curr_uri -> if (index = 0) then curr_uri else curr_string ^ "," ^  curr_uri) in
  let%lwt _ = add_songs_to_playlist_request access_token playlist_id playlist_uris in  
  return ()

let add_song (list : song list) (new_song : song): song list = 
  new_song :: list

let remove_song (list : song list) (id : string): song list = 
  List.filter list ~f: (fun x -> String.(x.id <> id))

