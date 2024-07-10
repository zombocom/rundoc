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

        document_path = @path.expand_path(env[:context].source_dir)

        puts "rundoc.require: Start executing #{@path.to_s.inspect}"
        output = Rundoc::Parser.new(
          document_path.read,
          context: env[:context]
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
