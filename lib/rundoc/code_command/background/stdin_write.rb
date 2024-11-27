class Rundoc::CodeCommand::Background
  # Will send contents to the background process via STDIN along with a newline
  #
  #
  class StdinWrite < Rundoc::CodeCommand
    def initialize(contents, name:, wait:, timeout: 5, ending: $/)
      @contents = contents
      @ending = ending
      @spawn = Rundoc::CodeCommand::Background::ProcessSpawn.find(name)
      @wait = wait
      @timeout_value = Integer(timeout)
      @contents_written = nil
    end

    # The command is rendered (`:::>-`) by the output of the `def call` method.
    def to_md(env = {})
      writecontents
    end

    # The contents produced by the command (`:::->`) are rendered by the `def to_md` method.
    def call(env = {})
      writecontents
      @spawn.log.read
    end

    def writecontents
      @contents_written ||= @spawn.stdin_write(
        contents,
        wait: @wait,
        ending: @ending,
        timeout: @timeout_value
      )
    end
  end
end
Rundoc.register_code_command(:"background.writeln", Rundoc::CodeCommand::Background::Wait)
