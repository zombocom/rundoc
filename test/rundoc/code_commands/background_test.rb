require "test_helper"

class BackgroundTest < Minitest::Test
  def test_stdin_with_cat_echo
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        # Intentionally out of order, should not raise an error as long as "cat"
        # command exists at execution time
        stdin_write = Rundoc::CodeCommand::Background::StdinWrite.new(
          "hello there",
          name: "cat",
          wait: "hello"
        )

        background_start = Rundoc::CodeCommand::Background::Start.new("cat",
          name: "cat")

        background_start.call
        output = stdin_write.call
        assert_equal("hello there" + $/, output)

        Rundoc::CodeCommand::Background::Wait.new(
          name: "cat",
          wait: "hello"
        ).call

        Rundoc::CodeCommand::Background::Log::Clear.new(
          name: "cat"
        ).call

        output = Rundoc::CodeCommand::Background::StdinWrite.new(
          "general kenobi",
          name: "cat",
          wait: "general"
        ).call
        assert_equal("general kenobi" + $/, output)
      end
    end
  end

  def test_process_spawn_gc
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        file = "foo.txt"
        run!("echo 'foo' >> #{file}")

        background_start = Rundoc::CodeCommand::Background::Start.new("tail -f #{file}",
          name: "tail2",
          wait: "f")

        GC.start

        output = background_start.call

        assert_match("foo", output)
        assert_equal(true, background_start.alive?)

        background_stop = Rundoc::CodeCommand::Background::Stop.new(name: "tail2")
        background_stop.call

        assert_equal(false, background_start.alive?)
      end
    end
  end

  def test_background_start
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        file = "foo.txt"
        run!("echo 'foo' >> #{file}")

        background_start = Rundoc::CodeCommand::Background::Start.new("tail -f #{file}",
          name: "tail",
          wait: "f")
        output = background_start.call

        assert_match("foo", output)
        assert_equal(true, background_start.alive?)

        log_read = Rundoc::CodeCommand::Background::Log::Read.new(name: "tail")
        output = log_read.call

        assert_equal("foo", output.chomp)

        log_clear = Rundoc::CodeCommand::Background::Log::Clear.new(name: "tail")
        output = log_clear.call
        assert_equal("", output)

        run!("echo 'bar' >> #{file}")

        background_start.background.wait("bar")

        log_read = Rundoc::CodeCommand::Background::Log::Read.new(name: "tail")
        output = log_read.call

        assert_equal("bar", output.chomp)

        background_stop = Rundoc::CodeCommand::Background::Stop.new(name: "tail")
        background_stop.call

        assert_equal(false, background_start.alive?)
      end
    end
  end
end
