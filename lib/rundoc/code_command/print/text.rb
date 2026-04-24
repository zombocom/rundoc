# frozen_string_literal: true

module Rundoc::CodeCommand
  class PrintTextArgs
    attr_reader :line

    def initialize(line = nil)
      @line = line
    end
  end

  class PrintTextRunner
    attr_reader :contents

    def initialize(user_args:, render_command:, render_result:, io: nil, contents: nil)
      @line = user_args.line
      @render_command = render_command
      @render_result = render_result
      @contents = contents.dup if contents && !contents.empty?
    end

    def render_command?
      @render_command
    end

    def render_result?
      @render_result
    end

    def to_md(env)
      if render_before?
        env[:before] << [@line, contents].compact.join("\n")
      end

      ""
    end

    def call(env = {})
      if render_before?
        ""
      else
        [@line, contents].compact.join("\n")
      end
    end

    def render_before?
      !render_command? && render_result?
    end
  end
end

Rundoc.register_code_command(keyword: :"print.text", args_klass: Rundoc::CodeCommand::PrintTextArgs, runner_klass: Rundoc::CodeCommand::PrintTextRunner)
