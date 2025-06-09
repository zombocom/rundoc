require "simplecov"
SimpleCov.start

require "bundler"

Bundler.require

require "rundoc"
require "minitest/autorun"
require "mocha/minitest"
require "tmpdir"
require "socket"
require "timeout"

class Minitest::Test
  SUCCESS_DIRNAME = Rundoc::CLI::DEFAULTS::ON_SUCCESS_DIR
  FAILURE_DIRNAME = Rundoc::CLI::DEFAULTS::ON_FAILURE_DIR

  def default_context(
    output_dir: nil,
    source_path: nil,
    screenshots_dirname: nil
  )
    Rundoc::Context::Execution.new(
      output_dir: output_dir || Pathname(File::NULL),
      source_path: source_path || Pathname(File::NULL),
      with_contents_dir: nil,
      screenshots_dirname: screenshots_dirname || Pathname(File::NULL)
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
    Rundoc::Document.new(
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

  # Yields port, exits unexpectedly
  def tcp_unexpected_exit(timeout: 30)
    Timeout::timeout(timeout) do
      threads = []
      server = TCPServer.new('127.0.0.1', 0)
      port = server.addr[1]
      threads << Thread.new do
        begin
          # Accept one connection, then raise an error to simulate unexpected close
          client = server.accept
          raise "Unexpected server error!"
        rescue => e
          # Simulate crash, but let ensure run
        end
      end.tap {|t| t.abort_on_exception = false }

      threads << Thread.new do
        yield port
      end

      while threads.all?(&:alive?)
        sleep 0.1
      end
    ensure
      server.close if server && !server.closed?
    end
  end
end
