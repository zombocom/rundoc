require "tempfile"

class Rundoc::CodeCommand::Background
  class Start < Rundoc::CodeCommand
    def initialize(command, name:, wait: nil, timeout: 5, log: Tempfile.new("log"), out: "2>&1", allow_fail: false)
      @timeout = timeout
      @command = command
      @name = name
      @wait = wait
      @allow_fail = allow_fail
      @log = log
      @redirect = out
      FileUtils.touch(@log)

      @background = nil
    end

    def background
      @background ||= ProcessSpawn.new(
        @command,
        timeout: @timeout,
        log: @log,
        out: @redirect
      ).tap do |spawn|
        puts "Spawning commmand: `#{spawn.command}`"
        ProcessSpawn.add(@name, spawn)
      end
    end

    def to_md(env = {})
      "$ #{@command}"
    end

    def call(env = {})
      background.wait(@wait)
      background.check_alive! unless @allow_fail

      background.log.read
    end

    def alive?
      !!background.alive?
    end
  end
end

Rundoc.register_code_command(:"background.start", Rundoc::CodeCommand::Background::Start)
