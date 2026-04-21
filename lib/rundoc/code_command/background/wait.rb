# frozen_string_literal: true

class Rundoc::CodeCommand::Background
  class WaitArgs
    attr_reader :name, :wait, :timeout

    def initialize(name:, wait:, timeout: 5)
      @name = name
      @wait = wait
      @timeout = Integer(timeout)
    end
  end

  class WaitRunner
    def initialize(user_args:, render_command:, render_result:, io: nil, contents: nil)
      @name = user_args.name
      @wait = user_args.wait
      @timeout_value = user_args.timeout
      @background = nil
      @render_command = render_command
      @render_result = render_result
    end

    def background
      @background ||= Rundoc::CodeCommand::Background::ProcessSpawn.find(@name)
    end

    def render_command?
      @render_command
    end

    def render_result?
      @render_result
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
Rundoc.register_code_command(keyword: :"background.wait", args_klass: Rundoc::CodeCommand::Background::WaitArgs, runner_klass: Rundoc::CodeCommand::Background::WaitRunner)
