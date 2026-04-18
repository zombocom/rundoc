module ::Rundoc
  class CodeCommand
    class RundocCommandArgs
      attr_reader :contents

      def initialize(contents = "")
        @contents = contents
      end
    end

    class RundocCommandRunner < ::Rundoc::CodeCommand
      def initialize(user_args:)
        @contents = user_args.contents
      end

      def to_md(env = {})
        ""
      end

      def call(env = {})
        puts "Running: #{contents}"
        eval(contents) # rubocop:disable Security/Eval
        ""
      end
    end
  end
end

Rundoc.register_code_command(keyword: :rundoc, args_klass: Rundoc::CodeCommand::RundocCommandArgs, runner_klass: Rundoc::CodeCommand::RundocCommandRunner)
Rundoc.register_code_command(keyword: :"rundoc.configure", args_klass: Rundoc::CodeCommand::RundocCommandArgs, runner_klass: Rundoc::CodeCommand::RundocCommandRunner)

require "rundoc/code_command/rundoc/depend_on"
require "rundoc/code_command/rundoc/require"
