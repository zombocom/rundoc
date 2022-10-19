class Rundoc::CodeCommand::Bash
  # special purpose class to persist cd behavior across the entire program
  # we change the directory of the parent program (rundoc) rather than
  # changing the directory of a spawned child (via exec, ``, system, etc.)
  class Cd < Rundoc::CodeCommand::Bash
    def initialize(line)
      @line = line
    end

    # Ignore duplicate chdir warnings "warning: conflicting chdir during another chdir block"
    def supress_chdir_warning
      old_stderr = $stderr
      capture_stderr = StringIO.new
      $stderr = capture_stderr
      yield
    ensure
      if old_stderr
        $stderr = old_stderr
        capture_string = capture_stderr.string
        warn capture_string if capture_string.each_line.count > 1 || !capture_string.include?("conflicting chdir")
      end
    end

    def call(env)
      line = @line.sub("cd", "").strip
      puts "running $ cd #{line}"

      supress_chdir_warning do
        Dir.chdir(line)
      end

      nil
    end
  end
end
