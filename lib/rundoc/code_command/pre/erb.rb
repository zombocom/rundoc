# frozen_string_literal: true

require_relative "../print/erb"

module Rundoc::CodeCommand
  class PreErbArgs
    attr_reader :line

    def initialize(line)
      @line = line
    end
  end

  class PreErbRunner
    attr_reader :io, :contents

    def initialize(user_args:, render_command:, render_result:, io:, contents: nil, **)
      @line = user_args.line
      @binding = RUNDOC_ERB_BINDINGS[RUNDOC_DEFAULT_ERB_BINDING]
      @code = nil
      @command = nil
      @template = nil
      @render_delegate_result = render_result
      @render_delegate_command = render_command
      @io = io
      @render_command = false
      @render_result = false
      @contents = contents.dup if contents && !contents.empty?
    end

    def render_command?
      @render_command
    end

    def render_result?
      @render_result
    end

    def code
      @code ||= begin
        vis = +""
        vis += @render_delegate_command ? ">" : "-"
        vis += @render_delegate_result ? ">" : "-"
        code = [@line, @contents]
          .compact
          .reject(&:empty?)
          .join("\n")
        @template = ":::#{vis} #{code}"

        io.puts "pre.erb: Applying ERB, template:\n#{@template}"
        result = ERB.new(@template).result(@binding)
        io.puts "pre.erb: ERB result:\n#{result}"
        io.puts "pre.erb: done, ready to delegate"
        result
      end
    end

    def command
      @command ||= Rundoc::FencedCodeBlock.parse_code_commands(code).first
    end

    def to_md(env = {})
      ""
    end

    def call(env = {})
      # Defer running ERB until as late as possible
      delegate = command
      # Delegate will be executed by the caller working through the stack
      env[:stack].push(delegate)
      ""
    end
  end
end
Rundoc.register_code_command(keyword: :"pre.erb", args_klass: Rundoc::CodeCommand::PreErbArgs, runner_klass: Rundoc::CodeCommand::PreErbRunner)
