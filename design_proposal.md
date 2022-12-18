Project Design Proposal

1. An overview of the purpose of the project

- Allow for easier discovery of truly new music on spotify that isn’t based on user preferences. App will generate 5 random songs on user load. The user can dynamically remove songs from the playlist. At any moment, the current remaining songs are used as the current user’s preference. When a new song is added, it is generated using the current user’s preference. The app gives the user the option to generate a final playlist in their account whenever they are ready.

2. A list of libraries you plan on using

- Spotify-web-api (potentially if it makes sending requests easier)
- Lwt
- Cohttp
- Dream

3. Commented module type declarations (.mli files) which will provide you with an initial specification to code to

- spotifyapi.mli, webserver.mli, authentication.mli

4. Include a mock of a use of your application, along the lines of the Minesweeper example above but showing the complete protocol.

- wireframe.png

5. Make sure you have installed and verified any extra libraries will in fact work on your computer setup, by running their tutorial examples.

- done

6. Also include a brief list of what order you will implement features.

   - Generate and present 5 random songs to the user
   - Implement ability to remove or add new songs. Initially new songs added will be completely random
   - Build state of song preferences from remaining songs and allow for logic which dynamically modifies the preference based on songs removed or added.
   - Initially just provide the name of the song to the user for each random song, then create an embedded song player so the user can get a sample of the song immediately without having to look it up themselves.
   - If time: Allow for the user to login to their spotify so the app can create the playlist for them
   - If time: Add ability to parameterize the added songs more (give user ability to input genre, popularity of songs, etc.)

7. If your project is an OCaml version of some other app in another language or a projust you did in another course etc please cite this other project. In general any code that inspired your code needs to be cited in your submissions.

   - No code from a similar project

8. You may also include any other information which will make it easier to understand your project.

   - NA
