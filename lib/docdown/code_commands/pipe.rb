module Docdown
  module CodeCommands
    class Pipe < Docdown::CodeCommand

      # ::: ls
      # ::: | tail -n 2
      # => "test\ntmp.file\n"
      def initialize(line)
        @first    = line.split(" ").first.strip
        klass     = Docdown.code_command(@first)
        klass     ||= Docdown::CodeCommands::Bash
        @delegate = klass.new(line)
      end

      # before: "",
      # after:  "",
      # commands:
      #   [[cmd, output], [cmd, output]]
      def call(env = {})
        cmd, output = env[:commands].last
        @delegate.push(output)
        @delegate.call(env)
      end

      def to_md(env = {})
        ""
      end
    end
  end
end


Docdown.register_code_command(:pipe, Docdown::CodeCommands::Pipe)
Docdown.register_code_command(:|,    Docdown::CodeCommands::Pipe)

