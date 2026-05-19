# frozen_string_literal: true

class Rundoc::CodeCommand::BashRunner
  class Cd < Rundoc::CodeCommand::BashRunner
    def initialize(line, io: $stdout)
      @io = io
      @line = line
    end

    def suppress_chdir_warning
      old_verbose = $VERBOSE
      $VERBOSE = nil
      yield
    ensure
      $VERBOSE = old_verbose
    end

    def call(env)
      line = @line.sub("cd", "").strip
      @io.puts "running $ cd #{line}"

      suppress_chdir_warning do
        Dir.chdir(line)
      end

      nil
    end
  end
end
