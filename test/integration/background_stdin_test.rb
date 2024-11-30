require "test_helper"

class BackgroundStdinTest < Minitest::Test
  def test_background_stdin_write
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        dir = Pathname(dir)
        script = dir.join("script.rb")
        script.write <<~'EOF'
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
end
