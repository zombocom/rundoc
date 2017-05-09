# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rundoc/version'

Gem::Specification.new do |gem|
  gem.name          = "rundoc"
  gem.version       = Rundoc::VERSION
  gem.authors       = ["Richard Schneeman"]
  gem.email         = ["richard.schneeman+rubygems@gmail.com"]
  gem.description   = %q{runDOC turns docs to runable code}
  gem.summary       = %q{runDOC generates runable code from docs}
  gem.homepage      = "https://github.com/schneems/rundoc"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "thor"
  gem.add_dependency "repl_runner"

  gem.add_development_dependency "test-unit"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "mocha"
  gem.add_development_dependency "test-unit"
end

