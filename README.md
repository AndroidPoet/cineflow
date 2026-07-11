# CineFlow

A beautiful Flutter movie-browsing app on the TMDB API — Riverpod 3, go_router, Material 3
dark-first design, Hero poster transitions.

- **Rules**: `docs/flutter_rules.md` — the house rules this codebase follows (compose-rules style,
  every rule cited to official/credible sources).
- **Plan**: `PLAN.md` — decisions and phased roadmap.

## Run

Get a free "API Read Access Token" at themoviedb.org → Settings → API, then:

```sh
flutter run --dart-define=TMDB_TOKEN=<your token>
```

## Test / analyze

```sh
flutter analyze
flutter test
```

This product uses the TMDB API but is not endorsed or certified by TMDB.
