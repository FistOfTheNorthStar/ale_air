# frozen_string_literal: true

require_relative 'lib/ale_air/version'

Gem::Specification.new do |s|
  s.name        = 'ale_air'
  s.version     = AleAir::VERSION
  s.required_ruby_version = '>= 3.2'
  s.summary     = 'Air Quality of Major Cities'
  s.description = 'Easy to use air quality of major cities. Everything has been parsed for you and ready to use.'
  s.authors     = ['FistOfTheNorthStar']
  s.email       = ['k.kulvik@gmail.com']
  s.homepage    = 'https://github.com/FistOfTheNorthStar/ale_air'
  s.license     = 'MIT'

  s.files = Dir['lib/**/*.rb'] + %w[README.md LICENSE.txt CHANGELOG.md]
  s.require_paths = ['lib']

  s.metadata = {
    'homepage_uri' => s.homepage,
    'source_code_uri' => s.homepage,
    'bug_tracker_uri' => "#{s.homepage}/issues",
    'changelog_uri' => "#{s.homepage}/blob/master/CHANGELOG.md",
    'rubygems_mfa_required' => 'true'
  }

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rubocop-performance'
  s.add_development_dependency 'rubocop-rspec'
  s.add_development_dependency 'webmock'
end
