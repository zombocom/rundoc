class Rundoc::CodeCommand::Background
  class Wait < Rundoc::CodeCommand
    def initialize(name:, wait:, timeout: 5)
      @spawn = Rundoc::CodeCommand::Background::ProcessSpawn.find(name)
      @wait = wait
      @timeout_value = Integer(timeout)
    end

    def to_md(env = {})
      ""
    end

    def call(env = {})
      @spawn.wait(@wait, @timeout_value)
      ""
    end
  end
end
Rundoc.register_code_command(:"background.wait", Rundoc::CodeCommand::Background::Wait)
