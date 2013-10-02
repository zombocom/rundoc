require 'repl_runner'

module Docdown
  module CodeCommands
    class Repl < Docdown::CodeCommand
      def initialize(command)
        @command     = command
        @contents = ""
      end

      def keyword=(keyword)
        @keyword = keyword

        if keyword.to_s == "repl"
          command_array = @command.split(" ")
          @keyword      = command_array.shift
          @command      = command_array.join(" ")
        end

        @command = "#{keyword} #{@command}"
      end

      def call
        zip = ReplRunner.new(:"#{keyword}", @command).zip(contents.strip)
        @result = zip.flatten.join("\n")
      end

      def to_md
        "$ #{@command}"
      end
    end
  end
end


Docdown.register_code_command(:repl, Docdown::CodeCommands::Repl)
Docdown.register_code_command(:irb,  Docdown::CodeCommands::Repl)