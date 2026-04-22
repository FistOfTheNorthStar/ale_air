# Changelog

All notable changes to this project will be documented in this file. Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [0.2.0] - 2026-04-22

### Added
- `lib/ale_air.rb` top-level entry point — `require 'ale_air'` now works as advertised.
- Error class hierarchy: `AleAir::Error`, `MissingTokenError`, `InvalidTokenError`, `ApiError`, `NetworkError`.
- Configurable `base_url`, `open_timeout`, `read_timeout` on `FetchJSON.new`.
- GitHub Actions CI matrix across Ruby 3.2, 3.3, 3.4, 4.0.
- `.rubocop.yml` with `rubocop-performance` and `rubocop-rspec`.
- `webmock` dev dependency — the test suite no longer hits the real WAQI API.

### Changed
- HTTP client swapped from `rest-client` (unmaintained) to Ruby stdlib `net/http` — no runtime dependencies.
- `#air_quality` now consistently returns `true`/`false` and always sets `status`/`message` (previously returned `nil` when the token was missing).
- Gemspec: added `metadata` (source_code_uri, changelog_uri, rubygems_mfa_required), removed deprecated `test_files`, dropped the unnecessary `bundler` dev dep.

### Removed
- `rest-client` runtime dependency.
- `attr_writer :secret_token` (token is now set only via the constructor).
- `config/key.yml` — no longer needed; tests use WebMock fixtures.

### Fixed
- `require 'cgi'` is now explicit (previously loaded transitively via rest-client).
- Typo in `.rspec`: `--order define` → `--order defined`.

## [0.1.0] - Initial release
