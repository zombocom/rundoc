module ::Rundoc
  class CodeCommand
    class ::RundocCommand < ::Rundoc::CodeCommand
      def initialize(contents = "")
        @contents = contents
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

Rundoc.register_code_command(:rundoc, RundocCommand)
Rundoc.register_code_command(:"rundoc.configure", RundocCommand)

require "rundoc/code_command/rundoc/depend_on"
require "rundoc/code_command/rundoc/require"
