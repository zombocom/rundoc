require 'test_helper'

class PipeTest < Test::Unit::TestCase

  def test_pipe
    pipe_cmd = "tail -n 2"
    cmd      = "ls"
    out      = `#{cmd}`
    pipe     = Docdown::CodeCommands::Pipe.new(pipe_cmd)
    actual   = pipe.call(commands: [[cmd, out]])

    expected = `#{cmd} | #{pipe_cmd}`
    assert_equal expected, actual
  end
end
