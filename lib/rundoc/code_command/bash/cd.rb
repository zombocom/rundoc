class Rundoc::CodeCommand::Bash
  # special purpose class to persist cd behavior across the entire program
  # we change the directory of the parent program (rundoc) rather than
  # changing the directory of a spawned child (via exec, ``, system, etc.)
  class Cd < Rundoc::CodeCommand::Bash

    def initialize(line)
      @line     = line
    end

    def call(env)
      line = @line.sub('cd', '').strip
      puts "running $ cd #{line}"
      Dir.chdir(line)
      nil
    end
  end
end
