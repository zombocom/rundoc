require 'repl_runner'

module Rundoc
  class CodeCommand
    class Repl < Rundoc::CodeCommand
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
        repl    = ReplRunner.new(:"#{keyword}", @command)
        @result = repl.zip(contents.strip).flatten.join("\n")
        return @result
      end

      def to_md(env = {})
        return "$ #{@command}"
      end
    end
  end
end


Rundoc.register_code_command(:repl, Rundoc::CodeCommand::Repl)
Rundoc.register_code_command(:irb,  Rundoc::CodeCommand::Repl)