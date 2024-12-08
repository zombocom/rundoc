class ::Rundoc::CodeCommand
  class RundocCommand
    class Require < ::Rundoc::CodeCommand
      # Pass in the relative path of another rundoc document in order to
      # run all of it's commands. Resulting contents will be displayed
      # in current document
      def initialize(path)
        raise "Path must be relative (i.e. start with `.` or `..`. #{path.inspect} does not" unless path.start_with?(".")
        @path = Pathname.new(path)
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
          )
        ).to_md

        if render_result?
          puts "rundoc.require: Done executing #{@path.to_s.inspect}, putting contents into document"
          env[:before] << output
        else
          puts "rundoc.require: Done executing #{@path.to_s.inspect}, quietly"
        end

        ""
      end

      def hidden?
        !render_result?
      end

      def not_hidden?
        !hidden?
      end
    end
  end
end

Rundoc.register_code_command(:"rundoc.require", ::Rundoc::CodeCommand::RundocCommand::Require)
