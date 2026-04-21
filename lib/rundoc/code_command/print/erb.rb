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

module Rundoc::CodeCommand
  RUNDOC_ERB_BINDINGS = Hash.new { |h, k| h[k] = EmptyBinding.create }
  RUNDOC_DEFAULT_ERB_BINDING = "default"

  class PrintERBArgs
    attr_reader :line, :binding_name

    def initialize(line = nil, binding: RUNDOC_DEFAULT_ERB_BINDING)
      @line = line
      @binding_name = binding
    end
  end

  class PrintERBRunner
    attr_reader :contents

    def initialize(user_args:, render_command:, render_result:, io: nil, contents: nil)
      @line = user_args.line
      @binding = RUNDOC_ERB_BINDINGS[user_args.binding_name]
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
