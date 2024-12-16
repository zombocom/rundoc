class Rundoc::CodeCommand::Background
  class Stop < Rundoc::CodeCommand
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
      background.stop
      background.log.read
    end
  end
end
Rundoc.register_code_command(:"background.stop", Rundoc::CodeCommand::Background::Stop)
