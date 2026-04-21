# frozen_string_literal: true

module Rundoc
  module CodeCommand
    class PipeArgs
      attr_reader :line

      def initialize(line)
        @line = line
      end
    end

    class PipeRunner
      attr_reader :io

      def initialize(user_args:, render_command:, render_result:, io:, contents: nil, **)
        @io = io
        @render_command = render_command
        @render_result = render_result
        @delegate = parse(user_args.line)
      end

      # before: "",
      # after:  "",
      # commands:
      #   [[cmd, output], [cmd, output]]
      def call(env = {})
        last_command = env[:commands].last
        io.puts "Piping: results of '#{last_command[:command]}' to '#{@delegate}'"

        @delegate.push(last_command[:output])
        @delegate.build(io: io).call(env)
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

      private def parse(code)
        parser = Rundoc::PegParser.new.method_call
        tree = parser.parse(code)
        actual = Rundoc::PegTransformer.new.apply(tree)

        actual = actual.first if actual.is_a?(Array)

        if actual.runner_klass == Rundoc::CodeCommand::NoSuchCommand
          bash_deferred(code)
        else
          actual
        end
      rescue Parslet::ParseFailed
        bash_deferred(code)
      end

      private def bash_deferred(code)
        deferred = Rundoc::CodeCommand::Deferred.new(
          args_instance: Rundoc::CodeCommand::BashArgs.new(code),
          runner_klass: Rundoc::CodeCommand::BashRunner
        )
        deferred.render_command = false
        deferred.render_result = false
        deferred
      end
    end
  end
end

Rundoc.register_code_command(keyword: :pipe, args_klass: Rundoc::CodeCommand::PipeArgs, runner_klass: Rundoc::CodeCommand::PipeRunner)
Rundoc.register_code_command(keyword: :|, args_klass: Rundoc::CodeCommand::PipeArgs, runner_klass: Rundoc::CodeCommand::PipeRunner)
