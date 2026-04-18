class Rundoc::CodeCommand::Background::Log
  class ClearArgs
    attr_reader :name

    def initialize(name:)
      @name = name
    end
  end

  class ClearRunner < Rundoc::CodeCommand
    def initialize(user_args:)
      @name = user_args.name
      @background = nil
    end

    def background
      @background ||= Rundoc::CodeCommand::Background::ProcessSpawn.find(@name)
    end

    def to_md(env = {})
      ""
    end

    def call(env = {})
      background.log.truncate(0)
      ""
    end
  end
end
Rundoc.register_code_command(:"background.log.clear", Rundoc::CodeCommand::Background::Log::ClearArgs, runner: Rundoc::CodeCommand::Background::Log::ClearRunner)
