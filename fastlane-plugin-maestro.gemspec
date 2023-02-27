# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/maestro/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-maestro'
  spec.version       = Fastlane::Maestro::VERSION
  spec.author        = 'Marc Bormeth'
  spec.email         = 'marc.bormeth@icloud.com'

  spec.summary       = 'Running maestro test commands from fastlane'
  spec.homepage      = 'https://github.com/inf2381/fastlane-plugin-maestro'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*'] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  spec.add_development_dependency('pry')
  spec.add_development_dependency('bundler')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rspec_junit_formatter')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rubocop')
  spec.add_development_dependency('rubocop-require_tools')
  spec.add_development_dependency('simplecov')
  spec.add_development_dependency('fastlane')

  spec.add_dependency('simctl')
end
