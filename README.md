Features
Trending GIFs and keyword search with GIPHY REST API.

Infinite scroll with limit/offset pagination.

Clean repository layer and simple model parsing.

Search field in AppBar with submission and reset handling.

Safe defaults: rating=g, language=en, optional bundle=messaging_non_clips.

Tech stack
Flutter (Material 3 UI, GridView, ScrollController).

HTTP for REST calls.

Simple repo pattern with JSON model parsing.

Optional GIPHY picker packages (future enhancement).

Project structure
lib/

data/

gif_model.dart – DTO/model for GIF items parsed from GIPHY JSON.

repository.dart – GifRepo with search/trending and pagination.

ui/

giphy_page.dart – UI grid, search field, infinite scroll.

This keeps API, models, and UI separated for easier testing and updates.

Prerequisites
Flutter SDK installed and on PATH.

A GIPHY API key from the GIPHY Developers portal.

Android Studio or Xcode for platform builds.

Getting a GIPHY API key
Visit developers.giphy.com and sign in.

Create an app to obtain an API key (free tier OK for dev).

Keep the key private; avoid committing it to source.

Configuration
Add the API key in a safe way. For local development, a simple approach is to use a top-level const (do not commit real keys), or better, load from an env file or runtime secret provider.

Example quick local approach:

lib/config.dart

const giphyApiKey = 'YOUR_API_KEY';

Then inject into the repository when bootstrapping the app:

final repo = GifRepo(apiKey: giphyApiKey);

For production, prefer secure key handling (e.g., a lightweight proxy or remote config) instead of baking keys into the client.

Install and run
Clone the repo.

flutter pub get

Put the API key in lib/config.dart as shown above.

Run on a device/emulator:

flutter run

Build an APK
flutter build apk --release

The APK will be at build/app/outputs/flutter-apk/app-release.apk.

How it works
Endpoints: /v1/gifs/trending and /v1/gifs/search with query params q, limit, offset, rating, lang, bundle.

Pagination: The response includes pagination.total_count; the app increments offset by the page size until offset >= total_count.

UI: GridView.builder + ScrollController to detect nearing the bottom and trigger the next page.

Key params:

q: user search text; empty q uses trending.

limit: page size (e.g., 24–30).

offset: 0, limit, 2×limit, …

rating, lang: optional filters; defaults shown above.

Usage
Launch app to see Trending GIFs; scroll to load more.

Use the search field to submit a keyword; results replace the grid.

Scroll to fetch additional pages.

Code highlights
Repository (simplified):

class GifRepo { … trending(offset, limit, rating, bundle) … search(q, offset, limit, rating, lang, bundle) … }

Uses Uri.replace to build URLs safely and _fetch to parse JSON and return items + total_count.

UI:

Search TextField in AppBar bottom with onSubmitted calling _onSubmit.

GridView.builder to lazily render cells; on reaching the end, triggers _load for next page.

Performance notes
Keep page size reasonable (e.g., 24–30) to balance smooth scrolling and network overhead.

Consider image caching using packages like CachedNetworkImage if the same images are revisited often.

Heavy animated GIFs can tax memory/CPU; consider using lighter renditions (bundle=messaging_non_clips) or static thumbnails where appropriate.

Roadmap
Add GIPHY picker UI (giphy_get) as an alternate selection flow.

Add debounced live search (onChanged + debounce) and empty state UI.

Add tests for repository and model parsing.

Add badges and CI to README for build/format/test.

Demo video
Drive link: https://drive.google.com/file/d/1tOwELp8QQzSbG0vkfxo_rTjT2lhGfz9x/view?usp=drive_link

License
Add your preferred OSS license (MIT/Apache-2.0). Clear licensing helps users and contributors.

Credits
GIPHY API and docs for endpoints and parameters.

Flutter framework and docs for AppBar, PreferredSize, TextField, and GridView usage patterns.



