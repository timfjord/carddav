# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'carddav/version'

Gem::Specification.new do |spec|
  spec.name          = 'carddav'
  spec.version       = Carddav::VERSION
  spec.authors       = ['Tim Maslyuchenko']
  spec.email         = ['insside@gmail.com']

  spec.summary       = 'CardDAV ruby implementation'
  spec.description   = 'CardDAV ruby implementation'
  spec.homepage      = 'https://github.com/timsly/carddav'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'curb'
  spec.add_dependency 'nokogiri'
  spec.add_dependency 'vcardigan'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'webmock'
end
