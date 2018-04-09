require 'test_helper'

class PipeTest < Minitest::Test

  def test_pipe
    pipe_cmd = "tail -n 2"
    cmd      = "ls"
    out      = `#{cmd}`
    pipe     = Rundoc::CodeCommand::Pipe.new(pipe_cmd)
    actual   = pipe.call(commands: [{command: cmd, output: out}])

    expected = `#{cmd} | #{pipe_cmd}`
    assert_equal expected, actual
  end
end
