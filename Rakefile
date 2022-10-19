require "bundler/gem_tasks"

require "rundoc"

require "rake"
require "rake/testtask"

task default: [:test]

test_task = Rake::TestTask.new(:test) do |t|
  t.libs << "lib"
  t.libs << "test"
  t.pattern = "test/rundoc/**/*_test.rb"
  t.verbose = false
end
