require "erb"

class EmptyBinding
  def self.create
    new.empty_binding
  end

  def empty_binding
    binding
  end
end

class Rundoc::CodeCommand
  RUNDOC_ERB_BINDINGS = Hash.new { |h, k| h[k] = EmptyBinding.create }
  RUNDOC_DEFAULT_ERB_BINDING = "default"

  class PrintERB < Rundoc::CodeCommand
    def initialize(line = nil, binding: RUNDOC_DEFAULT_ERB_BINDING)
      @line = line
      @binding = RUNDOC_ERB_BINDINGS[binding]
    end

    def to_md(env)
      if render_before?
        env[:before] << render
      end

      ""
    end

    def render
      @render ||= ERB.new([@line, contents].compact.join("\n")).result(@binding)
    end

    def call(env = {})
      if render_before?
        ""
      else
        render
      end
    end

    def render_before?
      !render_command? && render_result?
    end
  end
end
Rundoc.register_code_command(:"print.erb", Rundoc::CodeCommand::PrintERB)
