module Rundoc
  class CodeCommand
    class Pipe < Rundoc::CodeCommand
      # ::: ls
      # ::: | tail -n 2
      # => "test\ntmp.file\n"
      def initialize(line)
        @delegate = parse(line)
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

      private def parse(code)
        parser = Rundoc::PegParser.new.method_call
        tree = parser.parse(code)
        actual = Rundoc::PegTransformer.new.apply(tree)

        actual = actual.first if actual.is_a?(Array)

        actual = Rundoc::CodeCommand::Bash.new(code) if actual.is_a?(Rundoc::CodeCommand::NoSuchCommand)
        actual

      # Since `| tail -n 2` does not start with a `$` assume any "naked" commands
      # are bash
      rescue Parslet::ParseFailed
        Rundoc::CodeCommand::Bash.new(code)
      end
    end
  end
end

Rundoc.register_code_command(:pipe, Rundoc::CodeCommand::Pipe)
Rundoc.register_code_command(:|, Rundoc::CodeCommand::Pipe)
