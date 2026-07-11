# CineFlow

A beautiful movie-browsing app built with Flutter on the TMDB API. Dark-first Material 3
design, hero poster transitions between every screen, and details pages that re-theme
themselves from each movie's poster colors.

<p align="center">
  <img src="docs/demo.gif" width="300" alt="CineFlow demo — carousel, hero flights, per-movie dynamic theming, search, and favorites"/>
</p>

## Features

- **Home** — featured trending carousel (backdrops, gradient scrim, page indicator) over
  Now Playing / Popular / Top Rated rails with staggered entrance animations and
  pull-to-refresh
- **Details** — hero flight from any poster, collapsing backdrop, and a color scheme
  extracted live from the poster (`ColorScheme.fromImageProvider`), with genre chips,
  cast rail, trailer launch, and a "More like this" rail that hero-links onward
- **Search** — debounced-as-you-type with infinite-scroll pagination
- **Favorites** — local-first heart toggle persisted on device
- Designed loading states everywhere: skeletons, not spinners; error states with retry

## Stack

| | |
|---|---|
| State management | Riverpod 3 (`flutter_riverpod`, no codegen) |
| Navigation | [`back_stack`](https://pub.dev/packages/back_stack) — typed list-based back stack |
| Images | `cached_network_image_ce` |
| Loading UI | `skeletonizer` |
| Motion | `Hero` + `flutter_animate` |
| Data | TMDB API v3, Bearer-token auth |

## Architecture

Follows the [official Flutter architecture guide](https://docs.flutter.dev/app-architecture):
feature-first UI layer (`lib/ui/<feature>/`), layer-first data layer
(`lib/data/services/`, `lib/data/repositories/`), immutable domain models, and
unidirectional data flow — with Riverpod providers filling the ViewModel and DI roles.

The house rules this codebase follows — every rule cited to official sources — live in
[`docs/flutter_rules.md`](docs/flutter_rules.md).

## Run

Get a free "API Read Access Token" at themoviedb.org → Settings → API, then:

```sh
flutter run --dart-define=TMDB_TOKEN=<your token>
```

The token is injected at build time and never committed.

## Test

```sh
flutter analyze
flutter test
```

---

This product uses the TMDB API but is not endorsed or certified by TMDB.
