module Rundoc
  class CodeCommand
    class PipeArgs
      attr_reader :line

      def initialize(line)
        @line = line
      end
    end

    class PipeRunner < Rundoc::CodeCommand
      def initialize(user_args:)
        @delegate = parse(user_args.line)
      end

      # before: "",
      # after:  "",
      # commands:
      #   [[cmd, output], [cmd, output]]
      def call(env = {})
        last_command = env[:commands].last
        puts "Piping: results of '#{last_command[:command]}' to '#{@delegate}'"

        @delegate.push(last_command[:output])
        @delegate.call(env)
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
          actual = Rundoc::CodeCommand::BashRunner.new(user_args: Rundoc::CodeCommand::BashArgs.new(code))
        end
        actual

      # Since `| tail -n 2` does not start with a `$` assume any "naked" commands
      # are bash
      rescue Parslet::ParseFailed
        Rundoc::CodeCommand::BashRunner.new(user_args: Rundoc::CodeCommand::BashArgs.new(code))
      end
    end
  end
end

Rundoc.register_code_command(keyword: :pipe, args_klass: Rundoc::CodeCommand::PipeArgs, runner_klass: Rundoc::CodeCommand::PipeRunner)
Rundoc.register_code_command(keyword: :|, args_klass: Rundoc::CodeCommand::PipeArgs, runner_klass: Rundoc::CodeCommand::PipeRunner)
