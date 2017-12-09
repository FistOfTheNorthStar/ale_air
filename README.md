# Easy Air Quality Ruby Gem for Major Cities

This is an easy to use Gem for your Ruby projects when you wish to add air quality parameters. It uses World Air Quality Projects open api and parses the responses for ease of use. To use it go to [Air Quality Project](aqicn.org) and apply for a token (you will need it).

## Installation

Add this to Gemfile:

```ruby
gem 'ale_air'
```

And then execute:

    $ bundle install
 
Or

    $ gem install ale_air

## Usage

Just initialize first with your token

    air_results = AleAir::FetchJSON.new('YOUR_TOKEN')

Now you can get the air quality where you wish. This will return true if succesful and false if some error occured

    air_results.air_quality('Helsinki')

Then you can just use the results

    air_results.status -- will return "ok" or "error"
    air_results.message -- what kind of error occured
    air_results.location -- the measurement station location
    air_results.quality -- Air Quality Index scale as defined by the US-EPA 2016
    air_results.time_measured -- time of measurement
    air_results.danger_level -- level

## Development

Install on locally and start developing. 

## License

MIT License.

## Contributing

Report bugs and pull requests on GitHub at https://github.com/FistOfTheNorthStar/ale_air 

