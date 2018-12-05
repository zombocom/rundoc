require 'test_helper'

class AppendFileTest < Minitest::Test

  def test_background_start
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do

        file = "foo.txt"
        `echo 'foo' >> #{file}`

        background_start = Rundoc::CodeCommand::Background::Start.new("tail -f #{file}",
          name: "tail",
          wait: "f"
        )
        output = background_start.call

        assert_match("foo", output)
        assert_equal(true, background_start.alive?)

        log_read = Rundoc::CodeCommand::Background::Log::Read.new(name: "tail")
        output = log_read.call

        assert_equal("foo", output.chomp)

        log_clear = Rundoc::CodeCommand::Background::Log::Clear.new(name: "tail")
        output = log_clear.call
        assert_equal("", output)

        `echo 'bar' >> #{file}`

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
