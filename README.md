# Monday Night 16/05/22

This is the sample project for the Monday Night iOS presentation.

Repo structure:

```
├── Presentation -> Files used in the presentation, including the Keynote file.
├── Server -> The final Vapor app.
├── Server-Starter -> The initial Vapor app, used in the live demo.
├── Shared -> Shared files between the iOS and the Vapor app.
├── Web -> A VueJS app for registering goals
└── iOS -> An iOS app that displays a summary of the goals, ranking, and more.
```

## Running the Vapor app (Server)

### Preparing Redis and Postgres

From the repository root, making sure that Docker is installed and running first, run:

`docker compose run --rm start_dependencies`

### Running the Server

To run the Server, either open the app in Xcode by launching the **Package.swift** file, build and run the Run target (after SPM finishes fetching the dependencies). Alternatively, from the **Server** directory, run the following command in Terminal:

`swift run Run serve --hostname 0.0.0.0 --port 8080`

The server will start and listen to connections in the 8080 port. To test it out, call:

`curl http://localhost:8080/hello`

## Running the iOS App

Make sure that the Server app isn't currently open in Xcode - otherwise SPM will fail to load the Shared package. Open the app, build and run for the Simulator.

## Running the Web App

From the **Web** directory, first install the NPM dependencies, running `npm install`.

Then, open the `Web/src/components/StrikerApp.vue` file, and uncomment the localhost lines in the `httpBaseURL` and `wsBaseURL`, while commenting the other URLs.

Back to the command line, run `npm run serve` and access the browser in `localhost:8090`.