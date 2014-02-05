Gem::Specification.new do |gem|
  gem.name          = "dmarc"
  gem.version       = "0.1.0"
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

