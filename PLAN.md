# CineFlow — Plan

A beautiful TMDB movie-browsing app in Flutter. Every technical decision below was researched
against official/credible sources (July 2026) — see `docs/flutter_rules.md` for the rules and
citations this plan follows.

## Decisions (researched, not guessed)

| Decision | Choice | Why (source) |
|---|---|---|
| Architecture | Official Flutter MVVM layering: UI (feature-first) + data (repositories/services, layer-first) | Official architecture guide + Compass case study — docs.flutter.dev/app-architecture |
| State management | **Riverpod 3** (`flutter_riverpod`), no codegen | Flutter Favorite, active (3.3.x), `AsyncValue`/auto-retry fit an API-driven app; Provider is in maintenance mode; GetX rejected (quality audits + Apr 2026 repo deletion). Runner-up: flutter_bloc 9 |
| Navigation | `go_router` | Official recommendation ("preferred way for 90% of apps"), Flutter-team maintained |
| HTTP | `http` package | Minimal-deps; service layer is a thin stateless wrapper (official guide) |
| Images | `cached_network_image` | 6.9k likes, Baseflow, standard caching solution |
| Loading states | `skeletonizer` | Actively maintained (2.x, 2026); `shimmer` is dormant (~3 y) |
| Motion polish | `flutter_animate` + built-in `Hero` | gskinner Flutter Favorite; Hero per official docs |
| Lints | `flutter_lints` | The official Flutter-team lint set |
| Theme | Material 3, dark-first, single seed color (indigo — no red accents) | M3 default since Flutter 3.16 |
| API auth | TMDB v4 Read Access Token via `Authorization: Bearer`, injected with `--dart-define=TMDB_TOKEN` | TMDB-recommended scheme; token never committed |

## Phases

### Phase 0 — Foundation ✅ (this commit)
- [x] `flutter create` (iOS + Android), `dev.androidpoet.cineflow`
- [x] `docs/flutter_rules.md` house rules (compose-rules style, fully cited)
- [x] Folder skeleton per official structure (`config/ routing/ domain/ data/ ui/`)
- [x] Dependencies added; `flutter analyze` clean
- [x] Domain models (`Movie`, `MovieDetails`, `CastMember`) + `fromJson` tests
- [x] `TmdbApiService` (Bearer auth, typed `TmdbException`)
- [x] `MovieRepository` + Riverpod providers
- [x] Dark-first M3 theme, go_router with root-level detail route
- [x] Home screen (trending/now-playing/top-rated rails, skeleton loading)
- [x] Details screen with Hero poster flight + backdrop

### Phase 1 — Home experience ✅
- [x] Featured "trending" header carousel (backdrop `w780`, gradient scrim, page indicator)
- [x] Pull-to-refresh (`RefreshIndicator` invalidating providers)
- [x] Staggered rail entrance animations (`flutter_animate`)
- [x] Error state with retry button per rail (STATE-3)

### Phase 2 — Details polish ✅
- [x] `SliverAppBar` collapsing backdrop with gradient scrim
- [x] Cast rail (circular `w185` profiles), genre chips, runtime/year/rating row
- [x] "Similar movies" rail (from `append_to_response`) → hero-links onward
- [x] Trailer button (YouTube key from `videos`) via `url_launcher`
- [x] Custom fade `CustomTransitionPage` so the hero flight reads clean (ANIM-4)
- [x] Instant header while details load (Movie passed via route `extra`) + skeleton rest

### Phase 3 — Search ✅
- [x] `/search` route, debounced query notifier (350 ms)
- [x] Empty/idle/no-results/error states designed (UI-4)
- [x] Infinite scroll pagination (page-tracking `AsyncNotifier`)

### Phase 4 — Beautiful extras
- [x] Dominant-color accent on details screen (`ColorScheme.fromImageProvider`, built into
      Flutter — `palette_generator` is discontinued, don't use it)
- [x] Predictive back on Android (NAV-4)
- [x] Favorites (local `shared_preferences`, heart toggle + grid screen) — local-first, no backend
- [ ] App icon + splash

### Phase 5 — Ship-readiness
- [x] TMDB attribution line on the About screen (API-6) — logo image still to add before release
- [x] Widget tests for home rail states; search notifier + favorites repository tests
- [ ] DevTools pass on scroll perf (PERF-7), image sizes audit (PERF-8)
- [ ] Run verified on device/simulator with a real TMDB token

## API surface used

Base `https://api.themoviedb.org/3`, images `https://image.tmdb.org/t/p/{size}{path}`:

- `GET /trending/movie/day` — home hero carousel + trending rail
- `GET /movie/now_playing`, `/movie/popular`, `/movie/top_rated` — rails
- `GET /movie/{id}?append_to_response=credits,videos,similar` — details in one call (API-3)
- `GET /search/movie?query=&page=` — search
- Poster sizes `w342`/`w500`, backdrops `w780`/`w1280`, profiles `w185` (PERF-8)

## Running

```sh
flutter run --dart-define=TMDB_TOKEN=<your v4 read access token>
```

Get the token at themoviedb.org → Settings → API → "API Read Access Token".
