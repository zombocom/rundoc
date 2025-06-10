require "test_helper"

class BackgroundStdinTest < Minitest::Test
  def test_background_stdin_write
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        dir = Pathname(dir)
        script = dir.join("script.rb")
        script.write loop_script

        source_path = dir.join("RUNDOC.md")
        source_path.write <<~EOF
          ```
          :::>- background.start("ruby #{script}",
            name: "script",
            wait: ">",
            timeout: 15
          )
          :::-- background.stdin_write("hello", name: "script", wait: "hello")
          :::-- background.stdin_write("exit", name: "script", wait: "exit")
          :::>> background.stop(name: "script")
          ```
        EOF

        io = StringIO.new
        Rundoc::CLI.new(
          io: io,
          source_path: source_path,
          on_success_dir: dir.join(SUCCESS_DIRNAME)
        ).call

        readme = dir.join(SUCCESS_DIRNAME).join("README.md").read
        expected = <<~EOF
          > hello
          You said: hello
          > exit
          Bye
        EOF
        assert readme.include?(expected)
      end
    end
  end

  def test_print_output_on_exit
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        dir = Pathname(dir)
        script = dir.join("script.rb")
        script.write loop_script

        source_path = dir.join("RUNDOC.md")
        source_path.write <<~EOF
          ```
          :::-- background.start("ruby #{script}",
            name: "background_ungraceful_exit",
            wait: ">",
            timeout: 15
          )
          :::-- background.stdin_write("hello", name: "background_ungraceful_exit", wait: "hello")
          ```
        EOF

        io = StringIO.new
        Rundoc::CLI.new(
          io: io,
          source_path: source_path,
          on_success_dir: dir.join(SUCCESS_DIRNAME)
        ).call

        logs = io.string

        match_after = partition_match_after(actual: logs, include_str: "Warning background task is still running, cleaning up: `background_ungraceful_exit`")
        match_after = partition_match_after(actual: match_after, include_str: "Log contents for `/usr/bin/env bash -c")
        partition_match_after(actual: match_after, include_str: "> hello")
      end
    end
  end

  # Finds the include_str if it exists or raises an error
  # Returns the contents of that string and everything after it
  #
  # Used to handle the case where output might be in the logs twice and we want to verify the order
  def partition_match_after(actual:, include_str:)
    _before, match, after = actual.partition(include_str)
    found = match && !match.empty?
    assert found, "Expected to find `#{include_str}` in output, but did not. Output:\n#{actual}"
    [match, after].join
  end

  def loop_script
    <<~'EOF'
      $stdout.sync = true

      print "> "
      while line = gets
        puts line
        if line.strip == "exit"
          puts "Bye"
          return
        else
          puts "You said: #{line}"
        end
        print "> "
      end
    EOF
  end
end
