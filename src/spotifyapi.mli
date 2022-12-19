(* Spotify library - handles all interaction with Spotify API and generation of playlists/tracks
*)

(* Id is used for accurate spotify api queries, name for easy identification of songs, 
   oembed_src in order to embed a track player for the song into the frontend *)
type song = {id:string; name: string; oembed_src: string;}

(* App will maintain a current playlist at all times *)
type playlist = song list 

(* Generate a playlist of random songs using function above *)
val generate_random_playlist : string -> song list Lwt.t

(* Generate a new song based on the current playlist the user has *)
val generate_song_from_curr_playlist : string -> song list -> song Lwt.t

(* Adds a new song to the playlist *)
val add_song : song list -> song -> song list

(* Remove a song from the playlist *)
val remove_song : song list -> string -> song list

(* Returns the user id of the logged in user *)
val get_user_id : string -> string Lwt.t 

(* Receives the user id of the logged in user and creates an empty playlist on their behalf *)
val create_playlist : string -> string -> (string * string) Lwt.t

(* Receives the playlist id just created and the current list of songs the user has selected in order to generate a final playlist *)
val add_songs_to_playlist : string -> string -> song list -> unit Lwt.t


(* Helper functions exposed for testing purposes only *)

val generate_random_letter : unit -> string 

val get_track_list_from_response : string -> bool -> Yojson.Safe.t list

val json_item_to_song : Yojson.Safe.t -> song
