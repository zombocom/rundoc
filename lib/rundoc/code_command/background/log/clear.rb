class Rundoc::CodeCommand::Background::Log
  class Clear < Rundoc::CodeCommand
    def initialize(name:)
      @name = name
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
Rundoc.register_code_command(:"background.log.clear", Rundoc::CodeCommand::Background::Log::Clear)
