require "simplecov"
SimpleCov.start

require "bundler"

Bundler.require

require "rundoc"
require "minitest/autorun"
require "mocha/minitest"
require "tmpdir"

class Minitest::Test
  SUCCESS_DIRNAME = Rundoc::CLI::DEFAULTS::ON_SUCCESS_DIR
  FAILURE_DIRNAME = Rundoc::CLI::DEFAULTS::ON_FAILURE_DIR

  def default_context(
    output_dir: nil,
    source_path: nil,
    screenshots_dirname: nil
  )

    Rundoc::Context::Execution.new(
      output_dir: output_dir || Pathname("/dev/null"),
      source_path: source_path || Pathname("/dev/null"),
      with_contents_dir: nil,
      screenshots_dirname: screenshots_dirname || Pathname("/dev/null")
    )
  end

  def parse_contents(
    contents,
    output_dir: nil,
    source_path: nil,
    screenshots_dirname: nil
  )
    context = default_context(
      output_dir: output_dir,
      source_path: source_path,
      screenshots_dirname: screenshots_dirname
    )
    Rundoc::Parser.new(
      contents,
      context: context
    )
  end

  def root_dir
    Pathname(__dir__).join("..").expand_path
  end

  def fixture_path(dir = "")
    root_dir.join("test").join("fixtures").join(dir)
  end

  def run!(cmd, raise_on_nonzero_exit: true)
    out = `#{cmd} 2>&1`
    raise "Command: #{cmd} failed: #{out}" if !$?.success? && raise_on_nonzero_exit
    out
  end

  def strip_autogen_warning(string)
    string.gsub!(Rundoc::FencedCodeBlock::AUTOGEN_WARNING, "")
    string.gsub!(/<!-- STOP.*STOP -->/m, "")
    string
  end

  class FakeExit
    def initialize
      @called = false
      @value = nil
    end

    def exit(value = nil)
      @called = true
      @value = value
    end

    def called?
      @called
    end

    attr_reader :value
  end
end
