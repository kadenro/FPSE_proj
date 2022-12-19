open Core
open OUnit2;;

(* 
  DISCLAIMER: It is impossible to test any any interaction with the spotify API (authentication, track, etc. requests)
  All API requests require an access_code which can only be obtained through a user interacting with the website and logging into their spotify 
  You can test that the app actually works using dune exec -- src/main.exe and signing into a spotify account and 10 random songs will be generated
  Given this, the only functionality which can be tested are the helper functions below
*)


(* Tests functionality which is used to generate random track queries *)
let test_generate_random_letter _ = 
  let test_size = 100 in 
  List.init test_size ~f: (fun _ -> Lib.Spotifyapi.generate_random_letter()) |> 
  List.iter ~f: (fun s -> match String.get s 0 with 
      |  'A'..'Z'-> assert_equal true true
      | _ -> assert_equal true false )

let track_query_response = 
  "{
        \"tracks\": {
          \"items\": [
            {
              \"i_am\" : \"a track object\" 
            }
          ]
        },
        \"useless_field\": 1
    }"

let recommendation_query_response = 
  "{
        \"tracks\": [
            {
              \"i_am\" : \"a track object\" 
            }
          ],
        \"useless_field\": 1
    }"

(* Ensures the responses from Spotify API are properly parsed into a list of track items *)
let test_get_track_list_from_response _ =
  (* Checks that track query responses parse properly *)
  assert_equal (Lib.Spotifyapi.get_track_list_from_response track_query_response true) [Yojson.Safe.from_string "{ \"i_am\" : \"a track object\"}"];
  (* Checks that recommendation query responses parse properly *)
  assert_equal (Lib.Spotifyapi.get_track_list_from_response recommendation_query_response false) [Yojson.Safe.from_string "{ \"i_am\" : \"a track object\"}"]

let test_track_response_1 = 
  "{
  \"album\": {
    \"images\": [
      {
        \"height\": 640,
        \"url\": \"image\",
        \"width\": 640
      }
    ]
  },
  \"disc_number\": 1,
  \"name\": \"song\",
  \"id\":\"1\"
  }"

let test_track_response_2 = 
  "{
    \"album\": {
      \"images\": [
        {
          \"height\": 640,
          \"url\": \"https://i.scdn.co/image/ab67616d0000b2730791bb1aebd5bf70a8362555\",
          \"width\": 640
        }
      ]
    },
    \"disc_number\": 1,
    \"name\": \"School Tale\",
    \"id\":\"2Wh1LB47kn57th0GsEc0uV\"
    }"

(* Tests that the track items received from the api in the form of strings can be converted into SpotifyApi.song objects *)
let test_json_item_to_song _ = 
  let test_track_1 = test_track_response_1 |> Yojson.Safe.from_string in 
  assert_equal (Lib.Spotifyapi.json_item_to_song test_track_1) {id="1"; name= "song"; oembed_src="https://open.spotify.com/embed/track/1?utm_source=oembed"};
  let test_track_2 = test_track_response_2 |> Yojson.Safe.from_string in 
  assert_equal (Lib.Spotifyapi.json_item_to_song test_track_2) {id ="2Wh1LB47kn57th0GsEc0uV"; name= "School Tale"; oembed_src="https://open.spotify.com/embed/track/2Wh1LB47kn57th0GsEc0uV?utm_source=oembed"}

(* Tests modification of current users playlists *)
let test_add_song _ = 
  let test_playlist = Lib.Spotifyapi.([{id="1"; name="song1"; oembed_src=""}; {id="2"; name="song2"; oembed_src=""}; {id="3"; name="song3"; oembed_src=""}]) in 
  let new_song = Lib.Spotifyapi.({id="4"; name="song4"; oembed_src=""}) in 
  (* Should always append new song to the front of the playlist *)
  assert_equal (Lib.Spotifyapi.add_song test_playlist new_song) [{id="4"; name="song4"; oembed_src=""}; {id="1"; name="song1"; oembed_src=""}; {id="2"; name="song2"; oembed_src=""}; {id="3"; name="song3"; oembed_src=""}];
  (* Should also be able to add to an empty playlist in the case the user has removed all songs from the playlist *)
  assert_equal (Lib.Spotifyapi.add_song [] new_song) [{id="4"; name="song4"; oembed_src=""};]

let test_remove_song _ = 
  let test_playlist_1 = Lib.Spotifyapi.([{id="1"; name="song1"; oembed_src=""}; {id="2"; name="song2"; oembed_src=""}; {id="3"; name="song3"; oembed_src=""}]) in 
  let test_playlist_2 = Lib.Spotifyapi.([{id="1"; name="song1"; oembed_src=""}]) in 

  assert_equal (Lib.Spotifyapi.remove_song test_playlist_1 "1") [{id="2"; name="song2"; oembed_src=""}; {id="3"; name="song3"; oembed_src=""}];
  assert_equal (Lib.Spotifyapi.remove_song test_playlist_1 "2") [{id="1"; name="song1"; oembed_src=""}; {id="3"; name="song3"; oembed_src=""}];
  assert_equal (Lib.Spotifyapi.remove_song test_playlist_2 "1") []


let spotify_api_tests = "Spotify Api tests" >: test_list [
    "generate random letter" >:: test_generate_random_letter;
    "get track list from response" >:: test_get_track_list_from_response;
    "json item to song" >:: test_json_item_to_song;
    "add song" >:: test_add_song;
    "remove song" >:: test_remove_song;
  ]

let series = "Assignment2 Tests" >::: [
    spotify_api_tests;
  ]

let () = 
  run_test_tt_main series