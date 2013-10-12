module ::Rundoc
  class CodeCommand
    class ::RundocCommand < ::Rundoc::CodeCommand

      def initialize(line)
      end

      def to_md(env = {})
        ""
      end

      def call(env = {})
        puts "Running: #{contents}"
        eval(contents)
        ""
      end
    end
  end
end


Rundoc.register_code_command(:rundoc, ::Rundoc::CodeCommand::RundocCommand)
