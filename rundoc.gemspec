lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rundoc/version"

Gem::Specification.new do |gem|
  gem.name = "rundoc"
  gem.version = Rundoc::VERSION
  gem.authors = ["Richard Schneeman"]
  gem.email = ["richard.schneeman+rubygems@gmail.com"]
  gem.description = "RunDOC turns docs to runable code"
  gem.summary = "RunDOC generates runable code from docs"
  gem.homepage = "https://github.com/schneems/rundoc"
  gem.license = "MIT"

  gem.files = `git ls-files`.split($/)
  gem.executables = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_dependency "thor"
  gem.add_dependency "parslet", "~> 2"
  gem.add_dependency "capybara", "~> 3"
  gem.add_dependency "selenium-webdriver", "~> 4"
  gem.add_dependency "base64", "~> 0"

  gem.add_dependency "aws-sdk-s3", "~> 1"
  gem.add_dependency "dotenv"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "mocha"
  gem.add_development_dependency "minitest"
  gem.add_development_dependency "standard"
end
