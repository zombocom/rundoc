class Rundoc::CodeCommand::BashRunner
  class Cd < Rundoc::CodeCommand::BashRunner
    def initialize(line, io: $stdout)
      @io = io
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
      @io.puts "running $ cd #{line}"

      supress_chdir_warning do
        Dir.chdir(line)
      end

      nil
    end
  end
end
