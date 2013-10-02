# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'docdown/version'

Gem::Specification.new do |gem|
  gem.name          = "heroku_docdown"
  gem.version       = Docdown::VERSION
  gem.authors       = ["Richard Schneeman"]
  gem.email         = ["richard.schneeman+rubygems@gmail.com"]
  gem.description   = %q{docdown turns docs to runable code}
  gem.summary       = %q{docdown generates runable code from docs}
  gem.homepage      = "https://github.com/schneems/docdown"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]


  gem.add_dependency "kramdown"
  gem.add_dependency "thor"
  gem.add_dependency "repl_runner"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "mocha"
end

