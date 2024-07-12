require "simplecov"
SimpleCov.start

require "bundler"

Bundler.require

require "rundoc"
require "minitest/autorun"
require "mocha/minitest"
require "tmpdir"

class Minitest::Test
  def default_context(
    output_dir: nil,
    source_path: nil,
    screenshots_dir: nil
  )

    Rundoc::Context::Execution.new(
      output_dir: output_dir || Pathname("/dev/null"),
      source_path: source_path || Pathname("/dev/null"),
      screenshots_dir: screenshots_dir || Pathname("/dev/null")
    )
  end

  def parse_contents(
    contents,
    output_dir: nil,
    source_path: nil,
    screenshots_dir: nil
  )
    context = default_context(
      output_dir: output_dir,
      source_path: source_path,
      screenshots_dir: screenshots_dir
    )
    Rundoc::Parser.new(
      contents,
      context: context
    )
  end

  def root_dir
    Pathname(__dir__).join("..").expand_path
  end

  def run!(cmd, raise_on_nonzero_exit: true)
    out = `#{cmd} 2>&1`
    raise "Command: #{cmd} failed: #{out}" if !$?.success? && raise_on_nonzero_exit
    out
  end

  def strip_autogen_warning(string)
    string.gsub!(Rundoc::CodeSection::AUTOGEN_WARNING, "")
    string.gsub!(/<!-- STOP.*STOP -->/m, "")
    string
  end
end
