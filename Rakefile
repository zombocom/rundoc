require "bundler/gem_tasks"

require "rundoc"

require "rake"
require "rake/testtask"

task default: [:test]

Rake::TestTask.new(:test) do |t|
  t.libs << "lib"
  t.libs << "test"
  t.pattern = [
    "test/rundoc/**/*_test.rb",
    "test/system/**/*_test.rb",
    "test/integration/**/*_test.rb"
  ]
  t.verbose = false
end
