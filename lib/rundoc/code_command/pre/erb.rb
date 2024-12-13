require_relative "../print/erb"

class Rundoc::CodeCommand
  class PreErb < Rundoc::CodeCommand
    def initialize(line)
      @line = line
      @binding = RUNDOC_ERB_BINDINGS[RUNDOC_DEFAULT_ERB_BINDING]
      @code = nil
      @command = nil
      @template = nil
      @render_delegate_result = nil
      @render_delegate_command = nil
      # Hide self, pass visibility onto delegate
      @render_result = false
      @render_command = false
    end

    # Visibility is injected by the parser, capture it and pass it to the delegate
    def render_result=(value)
      @render_delegate_result = value
    end

    def render_command=(value)
      @render_delegate_command = value
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

        puts "pre.erb: Applying ERB, template:\n#{@template}"
        result = ERB.new(@template).result(@binding)
        puts "pre.erb: ERB result:\n#{result}"
        puts "pre.erb: done, ready to delegate"
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
Rundoc.register_code_command(:"pre.erb", Rundoc::CodeCommand::PreErb)
