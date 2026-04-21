# frozen_string_literal: true

class Rundoc::CodeCommand::Background
  class StdinWriteArgs
    attr_reader :contents, :name, :wait, :timeout, :ending

    def initialize(contents, name:, wait:, timeout: 5, ending: $/)
      @contents = contents
      @name = name
      @wait = wait
      @timeout = Integer(timeout)
      @ending = ending
    end
  end

  class StdinWriteRunner
    attr_reader :contents

    def initialize(user_args:, render_command:, render_result:, io: nil, contents: nil, **)
      @contents = user_args.contents
      @ending = user_args.ending
      @wait = user_args.wait
      @name = user_args.name
      @timeout_value = user_args.timeout
      @contents_written = nil
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

    # The command is rendered (`:::>-`) by the output of the `def call` method.
    def to_md(env = {})
      writecontents
    end

    # The contents produced by the command (`:::->`) are rendered by the `def to_md` method.
    def call(env = {})
      writecontents
      background.log.read
    end

    def writecontents
      @contents_written ||= background.stdin_write(
        contents,
        wait: @wait,
        ending: @ending,
        timeout: @timeout_value
      )
    end
  end
end
Rundoc.register_code_command(keyword: :"background.stdin_write", args_klass: Rundoc::CodeCommand::Background::StdinWriteArgs, runner_klass: Rundoc::CodeCommand::Background::StdinWriteRunner)
