class Rundoc::CodeCommand::Background
  class WaitArgs
    attr_reader :name, :wait, :timeout

    def initialize(name:, wait:, timeout: 5)
      @name = name
      @wait = wait
      @timeout = Integer(timeout)
    end
  end

  class WaitRunner < Rundoc::CodeCommand
    def initialize(user_args:)
      @name = user_args.name
      @wait = user_args.wait
      @timeout_value = user_args.timeout
      @background = nil
    end

    def background
      @background ||= Rundoc::CodeCommand::Background::ProcessSpawn.find(@name)
    end

    def to_md(env = {})
      ""
    end

    def call(env = {})
      background.wait(@wait, @timeout_value)
      ""
    end
  end
end
Rundoc.register_code_command(:"background.wait", Rundoc::CodeCommand::Background::WaitArgs, runner: Rundoc::CodeCommand::Background::WaitRunner)
