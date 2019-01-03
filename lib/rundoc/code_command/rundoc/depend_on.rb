class ::Rundoc::CodeCommand
  class RundocCommand
    class DependOn < ::Rundoc::CodeCommand

      # Pass in the relative path of another rundoc document in order to
      # run all of it's commands (but not to )
      def initialize(path)
        raise "Path must be relative (i.e. start with `.` or `..`. #{path.inspect} does not" unless path.start_with?(".")
        @path = Pathname.new(path)
      end

      def to_md(env = {})
        ""
      end

      def call(env = {})
        current_path = Pathname.new(env[:document_path]).dirname
        document_path = @path.expand_path(current_path)
        # Run the commands, but do not
        puts "rundoc.depend_on: Start executing #{@path.to_s.inspect}"
        output = Rundoc::Parser.new(document_path.read, document_path: document_path.to_s).to_md
        puts "rundoc.depend_on: Done executing #{@path.to_s.inspect}, discarding intermediate document"
        output
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

Rundoc.register_code_command(:"rundoc.depend_on", ::Rundoc::CodeCommand::RundocCommand::DependOn)
