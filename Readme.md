# Final FPSE project: Random Spotify Playlist Generator

Description:

- Program presents the user 10 random songs from Spotify through a front end.
- User can choose to remove any song(s) they wish.
- User can choose to add as many songs as they want. The program will use the current playlist of songs as inspiration for the new song generated.
- User can optionally export the playlist to Spotify in their account, the program will redirect them to the newly created playlist in Spotify.

Usage:

- Run opam install . in the project root directory to install the required dependencies
- Run dune build to build the project
- Run dune test to test the project
- To run the executable, use the command "dune exec -- src/main.exe"
