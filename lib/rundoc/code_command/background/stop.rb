class Rundoc::CodeCommand::Background
  class StopArgs
    attr_reader :name

    def initialize(name:)
      @name = name
    end
  end

  class StopRunner < Rundoc::CodeCommand
    def initialize(user_args:, **)
      @name = user_args.name
      @background = nil
      super(**)
    end

    def background
      @background ||= Rundoc::CodeCommand::Background::ProcessSpawn.find(@name)
    end

    def to_md(env = {})
      ""
    end

    def call(env = {})
      background.stop
      background.log.read
    end
  end
end
Rundoc.register_code_command(keyword: :"background.stop", args_klass: Rundoc::CodeCommand::Background::StopArgs, runner_klass: Rundoc::CodeCommand::Background::StopRunner)
