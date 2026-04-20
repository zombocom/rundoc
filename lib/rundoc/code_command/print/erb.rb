# frozen_string_literal: true

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

  class PrintERBArgs
    attr_reader :line, :binding_name

    def initialize(line = nil, binding: RUNDOC_DEFAULT_ERB_BINDING)
      @line = line
      @binding_name = binding
    end
  end

  class PrintERBRunner < Rundoc::CodeCommand
    def initialize(user_args:, **)
      @line = user_args.line
      @binding = RUNDOC_ERB_BINDINGS[user_args.binding_name]
      super(**)
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
Rundoc.register_code_command(keyword: :"print.erb", args_klass: Rundoc::CodeCommand::PrintERBArgs, runner_klass: Rundoc::CodeCommand::PrintERBRunner)
