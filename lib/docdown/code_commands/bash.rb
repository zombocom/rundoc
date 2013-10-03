module Docdown
  module CodeCommands
    class Bash < Docdown::CodeCommand
      def initialize(command)
        @command     = command
        @contents = ""
      end

      def call
        puts "Executing: #{to_md.inspect}"
        `#{@command} #{contents} 2>&1`
      end

      def to_md
        "$ #{@command} #{contents}"
      end
    end
  end
end


Docdown.register_code_command(:bash, Docdown::CodeCommands::Bash)
Docdown.register_code_command(:'$',  Docdown::CodeCommands::Bash)
