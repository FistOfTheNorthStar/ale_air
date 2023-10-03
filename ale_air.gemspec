# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ale_air/version'

Gem::Specification.new do |s|
  s.name        = 'ale_air'
  s.version     = AleAir::VERSION
  s.required_ruby_version = '>= 3.2.2'
  s.summary     = "Air Quality of Major Cities"
  s.description = "Easy to use air quality of major cities. Everything has been parsed for you and ready to use."
  s.authors     = ["FistOfTheNorthStar"]
  s.email       = ["k.kulvik@gmail.com"]
  s.homepage    =
    'https://github.com/FistOfTheNorthStar/ale_air'
  s.license     = 'MIT'

  s.files       = `git ls-files -z`.split("\x0")
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files  = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_dependency "rest-client"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"
  s.add_development_dependency "bundler"
end
