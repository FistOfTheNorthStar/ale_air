# AleAir — Air Quality for Major Cities

[![CI](https://github.com/FistOfTheNorthStar/ale_air/actions/workflows/ci.yml/badge.svg)](https://github.com/FistOfTheNorthStar/ale_air/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/ale_air.svg)](https://rubygems.org/gems/ale_air)

A small Ruby gem that wraps the [World Air Quality Index](https://aqicn.org) (WAQI) public API and returns parsed, ready-to-use air-quality data for a given city. No external dependencies — just Ruby standard library.

## Installation

Add to your `Gemfile`:

```ruby
gem 'ale_air'
```

Then:

```sh
bundle install
```

Or install directly:

```sh
gem install ale_air
```

## Configuration

You need a free WAQI API token. Request one at <https://aqicn.org/data-platform/token/>.

## Usage

```ruby
require 'ale_air'

client = AleAir::FetchJSON.new('YOUR_TOKEN')

if client.air_quality('Helsinki')
  puts client.descriptive_text
  # => "Air quality: 42 AQI Good @ Kallio 12:00 +02:00"
else
  warn "Lookup failed: #{client.message}"
end
```

### Accessors

After a call to `#air_quality`, the client exposes:

| Method               | Description                                                          |
|----------------------|----------------------------------------------------------------------|
| `status`             | `"ok"` or `"error"`                                                  |
| `message`            | Human-readable status message or error detail                        |
| `location`           | Name of the measurement station                                      |
| `quality`            | Air Quality Index (US-EPA 2016 scale)                                |
| `time_measured`      | Measurement timestamp with timezone                                  |
| `danger_level`       | One of: Good, Moderate, Unhealthy for Sensitive Groups, Unhealthy, Very Unhealthy, Hazardous |
| `descriptive_text`   | Pre-formatted single-line summary                                    |

### Options

```ruby
AleAir::FetchJSON.new(
  'YOUR_TOKEN',
  base_url: 'https://api.waqi.info', # override for testing
  open_timeout: 5,                   # seconds
  read_timeout: 10                   # seconds
)
```

### Error handling

`#air_quality` always returns `true` or `false`. On failure, `status` is set to `"error"` and `message` contains the reason:

```ruby
client = AleAir::FetchJSON.new('bad-token')
client.air_quality('Helsinki') # => false
client.status                  # => "error"
client.message                 # => "Invalid key"
```

Error classes are also defined under `AleAir::` for callers that prefer to raise:
`AleAir::Error`, `AleAir::MissingTokenError`, `AleAir::InvalidTokenError`, `AleAir::ApiError`, `AleAir::NetworkError`.

## Development

```sh
bundle install
bundle exec rspec       # run the test suite
bundle exec rubocop     # run the linter
bundle exec rake        # run both (default task)
```

Tests use [WebMock](https://github.com/bblimke/webmock) to stub the WAQI API — no real network access is required.

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/FistOfTheNorthStar/ale_air>.

1. Fork the repo
2. Create a feature branch
3. Add tests for your change
4. Ensure `bundle exec rake` is green
5. Open a pull request

## License

Released under the [MIT License](LICENSE.txt).
