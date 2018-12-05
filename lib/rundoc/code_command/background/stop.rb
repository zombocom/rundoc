class Rundoc::CodeCommand::Background
  class Stop < Rundoc::CodeCommand
    def initialize(name: )
      @spawn = Rundoc::CodeCommand::Background::ProcessSpawn.find(name)
    end

    def to_md(env = {})
      ""
    end

    def call(env = {})
      @spawn.stop
      ""
    end
  end
end
Rundoc.register_code_command(:"background.stop", Rundoc::CodeCommand::Background::Stop)
