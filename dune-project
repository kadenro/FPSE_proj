(lang dune 3.4)

(generate_opam_files true)
(authors "Kaden Rosenblatt")
(maintainers "krosen23@jh.edu")
(package
 (name random_spotify_playlist) ; put in your own project name here
 (synopsis "Generation of random spotify playlists")
 (description "An executable which generates 10 random songs from Spotify, allows the user to remove and add new songs, and export the final playlist to Spotify")
 (depends
  (ounit2 (>= 2.2.6))
  (core (>= 0.15.0)) ; `opam list core` will display which version of core you have
  (cohttp-lwt-unix (>= 5.0.0))
  (lwt (>= 5.6.1))
  (dream (>= 1.0.0~alpha4))
  (yojson (>= 2.0.2))     
))