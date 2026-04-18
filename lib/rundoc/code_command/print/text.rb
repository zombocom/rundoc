class Rundoc::CodeCommand
  class PrintTextArgs
    attr_reader :line

    def initialize(line)
      @line = line
    end
  end

  class PrintTextRunner < Rundoc::CodeCommand
    def initialize(user_args:)
      @line = user_args.line
    end

    def to_md(env)
      if render_before?
        env[:before] << [@line, contents].compact.join("\n")
      end

      ""
    end

    def hidden?
      !render_result?
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
