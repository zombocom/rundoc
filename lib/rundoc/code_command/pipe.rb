module Rundoc
  class CodeCommand
    class PipeArgs
      attr_reader :line

      def initialize(line)
        @line = line
      end
    end

    class PipeRunner < Rundoc::CodeCommand
      def initialize(user_args:, **)
        super(**)
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

        # Unregistered keywords (e.g. `| tail -n 2`) aren't rundoc commands — treat them as bash
        if actual.runner_klass == Rundoc::CodeCommand::NoSuchCommand
          Rundoc::CodeCommand::BashRunner.new(user_args: Rundoc::CodeCommand::BashArgs.new(code), render_command: false, render_result: false, io: io)
        else
          actual.build(io: io)
        end

      # Since `| tail -n 2` does not start with a `$` assume any "naked" commands
      # are bash
      rescue Parslet::ParseFailed
        Rundoc::CodeCommand::BashRunner.new(user_args: Rundoc::CodeCommand::BashArgs.new(code), render_command: false, render_result: false, io: io)
      end
    end
  end
end

Rundoc.register_code_command(keyword: :pipe, args_klass: Rundoc::CodeCommand::PipeArgs, runner_klass: Rundoc::CodeCommand::PipeRunner)
Rundoc.register_code_command(keyword: :|, args_klass: Rundoc::CodeCommand::PipeArgs, runner_klass: Rundoc::CodeCommand::PipeRunner)
