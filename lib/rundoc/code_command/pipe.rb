module Rundoc
  class CodeCommand
    class Pipe < Rundoc::CodeCommand

      # ::: ls
      # ::: | tail -n 2
      # => "test\ntmp.file\n"
      def initialize(line)
        line_array = line.split(" ")
        @first     = line_array.shift.strip
        @delegate  = Rundoc.code_command_from_keyword(@first, line_array.join(" "))
        @delegate  = Rundoc::CodeCommand::Bash.new(line) if @delegate.kind_of?(Rundoc::CodeCommand::NoSuchCommand)
      end

      # before: "",
      # after:  "",
      # commands:
      #   [[cmd, output], [cmd, output]]
      def call(env = {})
        last_command = env[:commands].last
        puts "Piping: results of '#{last_command[:command]}' to '#{@delegate}'"

        @delegate.push(last_command[:output])
        @delegate.call(env)
      end

      def to_md(env = {})
        ""
      end
    end
  end
end


Rundoc.register_code_command(:pipe, Rundoc::CodeCommand::Pipe)
Rundoc.register_code_command(:|,    Rundoc::CodeCommand::Pipe)

