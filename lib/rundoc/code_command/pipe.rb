module Rundoc
  class CodeCommand
    class Pipe < Rundoc::CodeCommand

      # ::: ls
      # ::: | tail -n 2
      # => "test\ntmp.file\n"
      def initialize(line)
        @first    = line.split(" ").first.strip
        klass     = Rundoc.code_command(@first)
        klass     ||= Rundoc::CodeCommand::Bash
        @delegate = klass.new(line)
      end

      # before: "",
      # after:  "",
      # commands:
      #   [[cmd, output], [cmd, output]]
      def call(env = {})
        last_command = env[:commands].last
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

