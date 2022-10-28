require "tempfile"

class Rundoc::CodeCommand::Background
  class Start < Rundoc::CodeCommand
    def initialize(command, name:, wait: nil, timeout: 5, log: Tempfile.new("log"), out: "2>&1", allow_fail: false)
      @command = command
      @name = name
      @wait = wait
      @allow_fail = allow_fail
      FileUtils.touch(log)

      @spawn = ProcessSpawn.new(
        @command,
        timeout: timeout,
        log: log,
        out: out
      )
      ProcessSpawn.add(@name, @spawn)
    end

    def to_md(env = {})
      "$ #{@command}"
    end

    def call(env = {})
      @spawn.wait(@wait)
      @spawn.check_alive! unless @allow_fail

      @spawn.log.read
    end

    def alive?
      !!@spawn.alive?
    end
  end
end

Rundoc.register_code_command(:"background.start", Rundoc::CodeCommand::Background::Start)
