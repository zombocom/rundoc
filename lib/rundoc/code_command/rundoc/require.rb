# frozen_string_literal: true

module ::Rundoc::CodeCommand
  class RundocCommand
    class RequireArgs
      attr_reader :path

      def initialize(path)
        raise "Path must be relative (i.e. start with `.` or `..`. #{path.inspect} does not" unless path.start_with?(".")
        @path = Pathname.new(path)
      end
    end

    class RequireRunner
      attr_reader :io

      def initialize(user_args:, render_command:, render_result:, io:, contents: nil)
        @path = user_args.path
        @io = io
        @render_result = render_result
      end

      def render_result?
        @render_result
      end

      def to_md(env = {})
        ""
      end

      def call(env = {})
        execution_context = env[:context]
        document_path = @path.expand_path(execution_context.source_dir)

        output = Rundoc::Document.new(
          document_path.read,
          context: Rundoc::Context::Execution.new(
            source_path: document_path,
            output_dir: execution_context.output_dir,
            screenshots_dirname: execution_context.screenshots_dir,
            with_contents_dir: execution_context.with_contents_dir
          ),
          io: io
        ).to_md

        if render_result?
          io.puts "rundoc.require: Done executing #{@path.to_s.inspect}, putting contents into document"
          env[:before] << output
        else
          io.puts "rundoc.require: Done executing #{@path.to_s.inspect}, quietly"
        end

        ""
      end
    end
  end
end

Rundoc.register_code_command(keyword: :"rundoc.require", args_klass: ::Rundoc::CodeCommand::RundocCommand::RequireArgs, runner_klass: ::Rundoc::CodeCommand::RundocCommand::RequireRunner)
