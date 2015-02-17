# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dune/balanced/creditcard/version'

Gem::Specification.new do |spec|
  spec.name          = 'dune-balanced-creditcard'
  spec.version       = Dune::Balanced::Creditcard::VERSION
  spec.authors       = ['Legrand Pierre']
  spec.email         = %w(legrand.work@gmail.com)
  spec.summary       = 'dune-investissement integration with Credit Card Balanced Payments.'
  spec.description   = 'Integration with Balanced Payments on dune-investissement specifically with Credit Cards.'
  spec.homepage      = 'https://github.com/FromUte/dune-balanced-creditcard'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'dune-balanced', '~> 1.0'

  spec.add_dependency 'rails', '~> 4.0'
  spec.add_dependency 'slim', '~> 2.0'
  spec.add_development_dependency 'rspec-rails', '~> 2.14'
  spec.add_development_dependency 'sqlite3', '~> 1.3'
end
