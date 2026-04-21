# frozen_string_literal: true

module ::Rundoc
  class CodeCommand
    class RundocCommandArgs
      attr_reader :code

      def initialize(code = "")
        @code = code
      end
    end

    class RundocCommandRunner < ::Rundoc::CodeCommand
      def initialize(user_args:, **)
        super(**)
        @contents = user_args.code + @contents
      end

      def to_md(env = {})
        ""
      end

      def call(env = {})
        io.puts "Running: #{contents}"
        eval(contents) # rubocop:disable Security/Eval
        ""
      end
    end
  end
end

Rundoc.register_code_command(keyword: :rundoc, args_klass: Rundoc::CodeCommand::RundocCommandArgs, runner_klass: Rundoc::CodeCommand::RundocCommandRunner)
Rundoc.register_code_command(keyword: :"rundoc.configure", args_klass: Rundoc::CodeCommand::RundocCommandArgs, runner_klass: Rundoc::CodeCommand::RundocCommandRunner)

require "rundoc/code_command/rundoc/require"
