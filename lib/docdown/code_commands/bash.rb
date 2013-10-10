module Docdown
  module CodeCommands
    class Bash < Docdown::CodeCommand

      # line = "cd ..""
      # line = "pwd"
      # line = "ls"
      def initialize(line)
        @line     = line
        @first    = @line.split(' ').first.downcase
        @contents = ""
      end

      def to_md(env = {})
        "$ #{@line}"
      end

      def call(env = {})
        case @first
        when 'cd'
          Cd.new(@line).call(env)
        else
          shell(@line, @contents)
        end
      end

      def shell(cmd, stdin = nil)
        msg  = "running: $ '#{cmd}'"
        msg  << " with stdin: #{stdin}" if stdin && !stdin.empty?
        puts msg

        IO.popen("#{cmd} 2>&1", "w+") do |io|
          io << stdin if stdin
          io.close_write
          return io.read
        end
      end
    end
  end
end


Docdown.register_code_command(:bash, Docdown::CodeCommands::Bash)
Docdown.register_code_command(:'$',  Docdown::CodeCommands::Bash)

require 'docdown/code_commands/bash/cd'