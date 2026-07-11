# CineFlow Flutter Rules

House rules for this codebase, in the spirit of [mrmans0n/compose-rules](https://mrmans0n.github.io/compose-rules/) for Jetpack Compose.
Every rule cites the official or credible source it comes from — nothing here is guessed.
When a PR violates a rule, link the rule ID in review.

Primary sources:

- Official Flutter architecture guide — <https://docs.flutter.dev/app-architecture> (guide, case study, recommendations)
- Effective Dart — <https://dart.dev/effective-dart>
- Flutter performance best practices — <https://docs.flutter.dev/perf/best-practices>
- Riverpod docs — <https://riverpod.dev>
- Hero animations — <https://docs.flutter.dev/ui/animations/hero-animations>
- TMDB API docs — <https://developer.themoviedb.org/docs>

---

## 1. Architecture (ARCH)

Follows the official Flutter architecture guide's MVVM layering, with Riverpod filling the
ViewModel + dependency-injection roles (the case study itself says a robust third-party solution
such as `package:riverpod` may replace its plain `ChangeNotifier` setup —
<https://docs.flutter.dev/app-architecture/case-study/ui-layer>).

- **ARCH-1 — Two layers, strict direction.** UI layer (screens + providers/notifiers) and data
  layer (repositories + services). Data flows data → UI; user events flow UI → data
  (unidirectional data flow, "strongly recommend" —
  <https://docs.flutter.dev/app-architecture/recommendations>).
- **ARCH-2 — Allowed dependencies only.** Widgets → providers/notifiers → repositories → services.
  Forbidden: widget → repository/service directly, notifier → notifier, repository → repository,
  service → anything above it (<https://docs.flutter.dev/app-architecture/guide>).
- **ARCH-3 — No logic in widgets.** Widgets may contain only: conditional rendering, animation
  logic, layout logic (size/orientation), and simple routing. Everything else lives in a
  notifier/provider or lower ("strongly recommend" — recommendations page).
- **ARCH-4 — Repository per data type.** A repository is the single source of truth for one domain
  type; it transforms raw API payloads into domain models and owns caching/retry/error handling
  (<https://docs.flutter.dev/app-architecture/guide>).
- **ARCH-5 — Services are stateless.** One service class per external data source (here: the TMDB
  REST API). Services hold no state and return `Future`/`Stream`
  (<https://docs.flutter.dev/app-architecture/guide>).
- **ARCH-6 — Immutable domain models.** Domain models are `@immutable` with `final` fields and
  `const` constructors ("strongly recommend" — recommendations page). Add `freezed` only if/when
  model count justifies the build cost (the guide's own caveat).
- **ARCH-7 — Name classes for their architectural role.** `HomeScreen`, `MovieRepository`,
  `TmdbApiService`, `trendingMoviesProvider` — the role must be readable from the name
  (recommendations page).
- **ARCH-8 — No domain/use-case layer yet.** The official guide says to add use-cases only when
  notifiers become overly complex, logic merges multiple repositories, or logic is reused across
  notifiers. Add incrementally, never preemptively (<https://docs.flutter.dev/app-architecture/guide>).
- **ARCH-9 — Errors are values at the UI boundary.** The official guide recommends the `Result`
  pattern (<https://docs.flutter.dev/app-architecture/design-patterns/result>); in Riverpod,
  `AsyncValue<T>` is that pattern — loading/error/data are enumerated states the UI must handle
  exhaustively. Services throw typed exceptions (`TmdbException`); nothing above a service
  catches-and-ignores.

## 2. State management (STATE)

Decision: **Riverpod 3 (`flutter_riverpod`)**. Verified rationale (July 2026):

- The official docs are package-agnostic but name riverpod, flutter_bloc, and signals as the
  robust third-party options (<https://docs.flutter.dev/app-architecture/case-study/ui-layer>).
- Riverpod 3.x is current and actively maintained (Flutter Favorite, ~4k likes, ~2.5M monthly
  downloads — <https://pub.dev/packages/riverpod>); 3.0 added auto-retry, mutations, offline
  persistence (<https://riverpod.dev/docs/whats_new>).
- Provider is in maintenance mode; its own author directs new projects to Riverpod.
- GetX is excluded: independent audits flag ~43% test coverage and god-object design
  (<https://clementbeal.github.io/post/humble-opinion-about-getx/>), and its repo was briefly
  deleted outright in April 2026 — unacceptable long-term risk.
- Runner-up was flutter_bloc 9 (best for enforced structure in large rotating teams); Riverpod
  wins here because this app's core problem is fetching/caching remote API data, which
  `AsyncValue` + auto-retry solve out of the box.

Rules:

- **STATE-1 — `ProviderScope` at the root, `ConsumerWidget`/`ConsumerStatefulWidget` in the tree.**
  No global mutable singletons; all shared state lives in providers.
- **STATE-2 — `ref.watch` in `build`, `ref.read` in callbacks.** Never `ref.read` inside `build`
  and never `ref.watch` inside a callback (<https://riverpod.dev/docs/concepts/reading>).
- **STATE-3 — Async data uses `FutureProvider`/`AsyncNotifier`; UI branches on `AsyncValue`.**
  Every `AsyncValue` consumer handles all three states (data/loading/error) — no `requireValue`
  in widgets outside guaranteed-loaded contexts.
- **STATE-4 — `autoDispose` by default** for screen-scoped providers; keep-alive is an explicit,
  justified exception (Riverpod 3 default guidance).
- **STATE-5 — Dependency injection through providers.** Services and repositories are exposed as
  plain `Provider`s and consumed via `ref` — the official guide's "use dependency injection"
  strong recommendation, with Riverpod instead of `package:provider`.
- **STATE-6 — Codegen is optional and currently off.** Riverpod's docs say codegen is entirely
  optional (<https://riverpod.dev/docs/concepts/about_code_generation>); adopt
  `riverpod_generator` only if we adopt build_runner for models (freezed/json_serializable) too.
- **STATE-7 — Notifiers never import Flutter widgets.** Keeps them unit-testable with
  `ProviderContainer` alone.

## 3. Project structure (STRUCT)

Official hybrid from the Compass case study (<https://docs.flutter.dev/app-architecture/case-study>):
UI is feature-first, data is layer-first.

```
lib/
  main.dart                 # entry point
  app.dart                  # root MaterialApp.router
  config/                   # environment, TMDB constants
  routing/                  # GoRouter setup
  domain/models/            # immutable domain models (shared by both layers)
  data/
    services/               # TmdbApiService (stateless HTTP)
    repositories/           # MovieRepository (+ its provider)
  ui/
    core/
      themes/               # ThemeData, ColorSchemes
      widgets/              # shared widgets (official: use ui/core/, never lib/widgets/)
    home/                   # feature: providers + widgets
    details/
    search/
test/                       # mirrors lib/ (test/domain, test/data, test/ui)
```

- **STRUCT-1 — One feature = one folder under `lib/ui/`** containing that feature's screen,
  feature-local widgets, and feature-local providers.
- **STRUCT-2 — Shared widgets go in `lib/ui/core/widgets/`, never a top-level `lib/widgets/`**
  (recommendations page).
- **STRUCT-3 — `test/` mirrors `lib/`** so every file's tests are findable by path (case study).

## 4. Dart style & lints (DART)

- **DART-1 — `flutter_lints` is the baseline** — the official Flutter-team lint set
  (<https://pub.dev/packages/flutter_lints>). `flutter analyze` must be clean before every commit;
  no `// ignore:` without a linked reason.
- **DART-2 — Effective Dart naming.** Types `UpperCamelCase`; files/directories
  `lowercase_with_underscores`; members and constants `lowerCamelCase` (no `SCREAMING_CAPS`);
  acronyms >2 letters treated as words (`TmdbApiService`, not `TMDBAPIService`)
  (<https://dart.dev/effective-dart/style>).
- **DART-3 — `dart format` everything;** curly braces on all flow control (Effective Dart style).
- **DART-4 — Prefer `final`; prefer private.** Fields, locals, and top-levels are `final` unless
  they must mutate; declarations are library-private unless needed publicly
  (<https://dart.dev/effective-dart/design>).
- **DART-5 — `async`/`await` over raw future chaining; `isEmpty`/`isNotEmpty` over `.length`
  checks; collection literals over constructors** (<https://dart.dev/effective-dart/usage>).
- **DART-6 — Annotate public return and parameter types.** Type inference is for locals.

## 5. Performance (PERF)

All from <https://docs.flutter.dev/perf/best-practices>:

- **PERF-1 — `const` constructors everywhere possible** — the single highest-leverage rebuild
  short-circuit (also enforced by `prefer_const_constructors`).
- **PERF-2 — Split big widgets into small widget *classes*, not helper methods.** Prefer
  `StatelessWidget` subclasses over functions returning widgets; push `setState`/rebuild scope as
  low in the tree as possible.
- **PERF-3 — Lazy lists only.** `ListView.builder`/`GridView.builder`/slivers for anything
  scrollable; never a concrete `children:` list for API results.
- **PERF-4 — No work in `build()`.** `build` must be pure and cheap; network/JSON/compute lives in
  providers.
- **PERF-5 — Avoid `Opacity` widget in animations** — use `FadeTransition`/`AnimatedOpacity`,
  or bake opacity into the color/image. Avoid clipping where `borderRadius` works.
- **PERF-6 — Never override `operator ==` on a widget** (documented O(N²) hazard).
- **PERF-7 — Frame budget: build ≤ 8 ms, raster ≤ 8 ms** (60 Hz); verify janky screens in DevTools
  before and after fixing.
- **PERF-8 — Size network images.** Request the smallest sufficient TMDB size (`w342`/`w500` for
  posters, `w780`/`w1280` for backdrops) instead of `original`.

## 6. Navigation (NAV)

- **NAV-1 — `go_router` for all navigation** — the official recommendation ("preferred way to
  write 90% of Flutter applications" — <https://docs.flutter.dev/app-architecture/recommendations>),
  maintained by the Flutter team (<https://pub.dev/packages/go_router>).
- **NAV-2 — Routes are the app's URL scheme.** Every screen has a path (`/movie/:id`); screens
  take IDs, not whole objects, so deep links always work.
- **NAV-3 — Hero-crossing routes live on the root navigator.** Heroes do not fly into/out of a
  `ShellRoute`'s nested navigator (<https://github.com/flutter/flutter/issues/112095>). The movie
  detail route stays top-level even after a bottom-nav shell is added.
- **NAV-4 — Predictive back on Android:** `android:enableOnBackInvokedCallback="true"` +
  `PredictiveBackPageTransitionsBuilder`, and `PopScope` (never `WillPopScope`)
  (<https://docs.flutter.dev/platform-integration/android/predictive-back>).

## 7. Hero animations & motion (ANIM)

From <https://docs.flutter.dev/ui/animations/hero-animations>:

- **ANIM-1 — Hero tags are data-derived and route-unique:** `'poster-${movie.id}'`. The same tag
  must exist on exactly one widget per route, on both ends of the flight.
- **ANIM-2 — Both heroes render the same visual.** Same image URL, same `BoxFit`, same border
  radius — mismatches cause mid-flight distortion. Use `flightShuttleBuilder` when the two ends
  legitimately differ (e.g. text style flicker).
- **ANIM-3 — Wrap tappable hero content in `Material(color: Colors.transparent)`** when using
  `InkWell` inside a Hero (missing-Material pitfall from the official doc).
- **ANIM-4 — Pair hero flights with fade route transitions** (`CustomTransitionPage` +
  `FadeTransition`); the hero flight runs concurrently with the route animation
  (<https://docs.flutter.dev/cookbook/animation/page-route-animation>).
- **ANIM-5 — Entrance/stagger polish uses `flutter_animate`** (gskinner, Flutter Favorite —
  <https://pub.dev/packages/flutter_animate>); loading states use `skeletonizer`
  (actively maintained — <https://pub.dev/packages/skeletonizer>), not the dormant `shimmer`.
- **ANIM-6 — Debug hero issues with `timeDilation`,** not by adding delays.

## 8. Theming & imagery (UI)

- **UI-1 — Material 3 (the default since Flutter 3.16 —
  <https://docs.flutter.dev/release/breaking-changes/material-3-default>); never set
  `useMaterial3: false`.**
- **UI-2 — Both themes from one seed:** `ColorScheme.fromSeed(...)` for light and dark; the app is
  dark-first (movie-viewing context). No red/crimson accents.
- **UI-3 — All network images through `cached_network_image`**
  (<https://pub.dev/packages/cached_network_image>) with a placeholder and an `errorWidget` —
  never a bare `Image.network` for TMDB content.
- **UI-4 — Every loading state is designed.** Skeletons (`skeletonizer`) for lists/details, never
  a bare centered spinner on content screens.

## 9. TMDB API (API)

- **API-1 — Auth via the v4 Read Access Token as `Authorization: Bearer` header** on
  `https://api.themoviedb.org/3/...` — the recommended scheme; keeps credentials out of URLs
  (<https://developer.themoviedb.org/docs/authentication-application>).
- **API-2 — The token is never committed.** It enters via
  `--dart-define=TMDB_TOKEN=...` / `String.fromEnvironment`.
- **API-3 — One details request:** `/movie/{id}?append_to_response=credits,videos,similar`
  (<https://developer.themoviedb.org/docs/append-to-response>), not three round trips.
- **API-4 — Image URLs built centrally** from `https://image.tmdb.org/t/p/{size}{path}`
  (<https://developer.themoviedb.org/docs/image-basics>); size constants live in one place.
- **API-5 — Respect HTTP 429** (current CDN ceiling ≈ 50 req/s —
  <https://developer.themoviedb.org/docs/rate-limiting>); no unbounded parallel fan-out of
  requests.
- **API-6 — Attribution is mandatory before any release:** the TMDB logo plus the exact sentence
  "This product uses the TMDB API but is not endorsed or certified by TMDB."
  (<https://www.themoviedb.org/about/logos-attribution>).

## 10. Testing (TEST)

Official stance: unit-test every service, repository, and notifier; widget-test views; use fakes
("strongly recommend" — <https://docs.flutter.dev/app-architecture/recommendations>).

- **TEST-1 — Every repository and notifier has unit tests** using `ProviderContainer` with
  overridden service providers — no network in tests.
- **TEST-2 — Models have `fromJson` round-trip tests** against captured real TMDB payloads.
- **TEST-3 — Key screens have widget tests** for the three `AsyncValue` states.
- **TEST-4 — Fakes over mocks** where practical (official recommendation); fakes live under
  `test/` mirrors of the code they fake.
