require "simplecov"
SimpleCov.start

require "bundler"

Bundler.require

require "rundoc"
require "minitest/autorun"
require "mocha/minitest"
require "tmpdir"


class Minitest::Test
  def parse_contents(
      contents,
      output_dir: Pathname("/dev/null"),
      source_path: Pathname("/dev/null"),
      screenshots_dir: Pathname("/dev/null")
    )
      context = Rundoc::Context::Execution.new(
        output_dir: output_dir,
        source_path: source_path,
        screenshots_dir: screenshots_dir
      )
      Rundoc::Parser.new(
        contents,
        context: context
      )
  end
end
