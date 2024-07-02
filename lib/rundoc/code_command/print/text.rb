class Rundoc::CodeCommand
  class PrintText < Rundoc::CodeCommand
    def initialize(line)
      @line = line
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

Rundoc.register_code_command(:"print.text", Rundoc::CodeCommand::PrintText)
