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
          @keyword      = command_array.first
        else
          @command = "#{keyword} #{@command}"
        end
      end

      def call(env = {})
        puts "Running #{@command} with repl: #{keyword}"
        zip = ReplRunner.new(:"#{keyword}", @command).zip(contents.strip)
        @result = zip.flatten.join("\n")
      end

      def to_md(env = {})
        "$ #{@command}"
      end
    end
  end
end


Docdown.register_code_command(:repl, Docdown::CodeCommands::Repl)
Docdown.register_code_command(:irb,  Docdown::CodeCommands::Repl)