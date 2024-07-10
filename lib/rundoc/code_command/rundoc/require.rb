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
        env[:replace] ||= +""
        current_path = Pathname.new(env[:document_path]).dirname
        document_path = @path.expand_path(current_path)

        puts "rundoc.require: Start executing #{@path.to_s.inspect}"
        output = Rundoc::Parser.new(
          document_path.read,
          output_dir: env[:output_dir],
          document_path: document_path.to_s,
          screenshots_path: env[:screenshots_path]
        ).to_md
        puts "rundoc.require: Done executing #{@path.to_s.inspect}, putting contents into document"

        env[:replace] << output
        ""
      end

      def hidden?
        true
      end

      def not_hidden?
        !hidden?
      end
    end
  end
end

Rundoc.register_code_command(:"rundoc.require", ::Rundoc::CodeCommand::RundocCommand::Require)
