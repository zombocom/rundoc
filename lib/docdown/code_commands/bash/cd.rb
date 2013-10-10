class Docdown::CodeCommands::Bash
  # special purpose class to persist cd behavior across the entire program
  # we change the directory of the parent program (docdown) rather than
  # changing the directory of a spawned child (via exec, ``, system, etc.)
  class Cd < Docdown::CodeCommands::Bash
    def call(env)
      line = @line.sub('cd', '').strip
      puts "running $ cd #{line}"
      Dir.chdir(line)
      nil
    end
  end
end
