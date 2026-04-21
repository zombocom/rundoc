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

      def initialize(user_args:, render_command:, render_result:, io:, contents: nil, **)
        @io = io
        @render_command = render_command
        @render_result = render_result
        @contents = contents.dup if contents && !contents.empty?
        @contents = user_args.code + (@contents || +"")
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
