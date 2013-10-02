module Docdown
  module CodeCommands
    class Bash < Docdown::CodeCommand
      def initialize(command)
        @command     = command
        @contents = ""
      end

      def call
        `#{@command + contents}`
      end

      def to_md
        "$ #{@command} #{contents}"
      end
    end
  end
end


Docdown.register_code_command(:bash, Docdown::CodeCommands::Bash)
Docdown.register_code_command(:'$',  Docdown::CodeCommands::Bash)