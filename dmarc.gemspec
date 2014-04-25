# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dmarc/version'

Gem::Specification.new do |gem|
  gem.name          = "dmarc"
  gem.version       = DMARC::VERSION
  gem.license       = 'MIT'
  gem.authors       = ["Davis Gallinghouse"]
  gem.email         = ["davis@trailofbits.com"]
  gem.description   = %q{DMARC Record Parser}
  gem.summary       = %q{DMARC Record Parser}
  gem.homepage      = "https://github.com/trailofbits/dmarc#readme"

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'parslet', '~> 1.5'
end