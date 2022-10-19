class Rundoc::CodeCommand::Background::Log
  class Read < Rundoc::CodeCommand
    def initialize(name:)
      @spawn = Rundoc::CodeCommand::Background::ProcessSpawn.find(name)
    end

    def to_md(env = {})
      ""
    end

    def call(env = {})
      @spawn.log.read
    end
  end
end
Rundoc.register_code_command(:"background.log.read", Rundoc::CodeCommand::Background::Log::Read)
