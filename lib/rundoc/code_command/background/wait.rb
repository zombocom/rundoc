class Rundoc::CodeCommand::Background
  class Wait < Rundoc::CodeCommand
    def initialize(name:, wait:, timeout: 5)
      @name = name
      @wait = wait
      @timeout_value = Integer(timeout)
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
Rundoc.register_code_command(:"background.wait", Rundoc::CodeCommand::Background::Wait)
