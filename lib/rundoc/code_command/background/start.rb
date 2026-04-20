require "tempfile"

class Rundoc::CodeCommand::Background
  class StartArgs
    attr_reader :command, :name, :wait, :timeout, :log, :out, :allow_fail

    def initialize(command, name:, wait: nil, timeout: 5, log: Tempfile.new("log"), out: "2>&1", allow_fail: false)
      @command = command
      @name = name
      @wait = wait
      @timeout = timeout
      @log = log
      @out = out
      @allow_fail = allow_fail
    end
  end

  class StartRunner < Rundoc::CodeCommand
    def initialize(user_args:, **)
      @timeout = user_args.timeout
      @command = user_args.command
      @name = user_args.name
      @wait = user_args.wait
      @allow_fail = user_args.allow_fail
      @log = user_args.log
      @redirect = user_args.out
      FileUtils.touch(@log)

      @background = nil
      super(**)
    end

    def background
      @background ||= ProcessSpawn.new(
        @command,
        timeout: @timeout,
        log: @log,
        out: @redirect
      ).tap do |spawn|
        io.puts "Spawning commmand: `#{spawn.command}`"
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

Rundoc.register_code_command(keyword: :"background.start", args_klass: Rundoc::CodeCommand::Background::StartArgs, runner_klass: Rundoc::CodeCommand::Background::StartRunner)
