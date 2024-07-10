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
        raise "rundoc.depend_on has been removed, use `:::-- rundoc.require` instead"
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
