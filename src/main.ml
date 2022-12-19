(* Stores the current authentication state and the access token which will be used to make requests *)
type authentication_state = {mutable access_token: string; mutable playlist: Lib.Spotifyapi.song list}

let current_state = ref {access_token =  ""; playlist = []}

let get_access_token () : string = 
  !current_state.access_token
let get_playlist () : Lib.Spotifyapi.song list = 
  !current_state.playlist

let () = 
  Dream.run
  @@ Dream.router [
    Dream.get "/" (fun req -> 
        (* Redirects the user to log in with their spotify account *)
        Dream.redirect req (Lib.Authentication.get_user_auth_request)
      );  
    (* Callback from spotify login will go here to finish auth process *)
    Dream.get "/authenticate/" (fun req -> 
        match (Dream.query req "code") with 
        | Some(access_code) -> 
          (* Generates access token and stores this as global state which will be used for calls to spotify api *)
          let%lwt access_token = Lib.Authentication.generate_access_token access_code in
          !current_state.access_token <- access_token;
          Dream.redirect req "/playlist/" ~code:301
        | None -> Dream.empty `Bad_Request
      ); 
    Dream.get "/playlist/" (fun _ -> 
        let%lwt song_list = Lib.Spotifyapi.generate_random_playlist @@ get_access_token () in 
        !current_state.playlist <- song_list;
        Dream.html @@ Template.display_initial_playlist (get_playlist())
      );
    Dream.delete "/playlist/:id" (fun req -> 
        !current_state.playlist <- Lib.Spotifyapi.remove_song (get_playlist ()) (Dream.param req "id");
        Dream.respond ~code: 200 "success"
      );
    Dream.post "/playlist/" (fun _ -> 
        let%lwt new_song = Lib.Spotifyapi.generate_song_from_curr_playlist (get_access_token ()) (get_playlist ()) in 
        let new_playlist = Lib.Spotifyapi.add_song (get_playlist()) new_song in
        !current_state.playlist <- new_playlist;
        Dream.respond ~code: 200 "success"
      ); 
    Dream.get "/playlist/frontend/**" @@ Dream.static "./frontend";
    Dream.post "/playlist/create" (fun _ -> 
        let%lwt user_id = Lib.Spotifyapi.get_user_id (get_access_token ()) in 
        let%lwt playlist_id, playlist_link = Lib.Spotifyapi.create_playlist (get_access_token ()) (user_id) in 
        let%lwt _ = Lib.Spotifyapi.add_songs_to_playlist (get_access_token ()) (playlist_id) (!current_state.playlist) in 
        (* Pass the playlist_link back in the response body so javascript can redirect to it *)
        Dream.respond ~code: 200 playlist_link
      );
  ]