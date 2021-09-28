# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'omniauth/fortnox_oauth2/version'

Gem::Specification.new do |gem|
  gem.name        = 'omniauth-fortnox-oauth2'
  gem.version     = Omniauth::FortnoxOAuth2::VERSION
  gem.authors     = ['svenne87']
  gem.email       = ['devops@standout.se']
  gem.homepage    = 'https://github.com/standout/omniauth-fortnox-oauth2'
  gem.description = 'OmniAuth OAuth2 strategy for Fortnox'
  gem.summary     = gem.description
  gem.licenses    = ['MIT']

  gem.metadata['homepage_uri'] = gem.homepage
  gem.metadata['source_code_uri'] = gem.homepage
  gem.metadata['changelog_uri'] = gem.homepage

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.required_ruby_version = '~> 3.0'

  gem.add_dependency 'omniauth-oauth2'

  gem.add_development_dependency 'pry-byebug'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec', '> 3'
  gem.add_development_dependency 'webmock'
end
