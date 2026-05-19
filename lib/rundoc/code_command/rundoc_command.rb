# frozen_string_literal: true

module ::Rundoc
  module CodeCommand
    class RundocCommandArgs
      attr_reader :code

      def initialize(code = "")
        @code = code
      end
    end

    class RundocCommandRunner
      attr_reader :io, :contents

      def initialize(user_args:, render_command:, render_result:, io:, contents: nil)
        @io = io
        @contents = contents.dup if contents && !contents.empty?
        @contents = user_args.code + (@contents || +"")
        @binding = RUNDOC_ERB_BINDINGS[RUNDOC_DEFAULT_ERB_BINDING]
      end

      def to_md(env = {})
        ""
      end

      def call(env = {})
        io.puts "Running: #{contents}"
        Rundoc.capture_stdout_stderr(io) do
          eval(contents, @binding) # rubocop:disable Security/Eval
        end
        ""
      end
    end
  end
end

Rundoc.register_code_command(keyword: :rundoc, args_klass: Rundoc::CodeCommand::RundocCommandArgs, runner_klass: Rundoc::CodeCommand::RundocCommandRunner)
Rundoc.register_code_command(keyword: :"rundoc.configure", args_klass: Rundoc::CodeCommand::RundocCommandArgs, runner_klass: Rundoc::CodeCommand::RundocCommandRunner)

require "rundoc/code_command/rundoc/require"
require "rundoc/code_command/rundoc/ensure_later"
