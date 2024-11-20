require "test_helper"

class IntegrationFailureTest < Minitest::Test
  def test_writes_to_dir_on_failure_two_block
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        dir = Pathname(dir)

        source_path = dir.join("RUNDOC.md")
        source_path.write <<~EOF
          ```
          :::>> $ mkdir one
          :::>> $ touch one/rofl.txt
          ```

          ```
          :::>> $ mkdir two
          :::>> $ touch two/rofl.txt
          :::>> $ touch does/not/exist.txt
          ```
        EOF

        io = StringIO.new

        error = nil
        begin
          Rundoc::CLI.new(
            io: io,
            source_path: source_path,
            on_success_dir: dir.join(SUCCESS_DIRNAME)
          ).call
        rescue => e
          error = e
        end

        assert error
        assert_includes error.message, "exited with non zero status"

        refute dir.join(SUCCESS_DIRNAME).join("two").exist?
        refute dir.join(SUCCESS_DIRNAME).join("two").join("rofl.txt").exist?

        assert dir.join(FAILURE_DIRNAME).join("two").exist?
        assert dir.join(FAILURE_DIRNAME).join("two").join("rofl.txt").exist?

        doc = dir.join(FAILURE_DIRNAME).join("RUNDOC_FAILED.md").read
        assert_includes doc, "$ mkdir one"
        assert_includes doc, "$ touch one/rofl.txt"

        assert_includes doc, "$ mkdir two"
        assert_includes doc, "$ touch two/rofl.txt"
      end
    end
  end

  def test_writes_to_dir_on_failure_one_block
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        dir = Pathname(dir)

        source_path = dir.join("RUNDOC.md")
        source_path.write <<~EOF
          ```
          :::>> $ mkdir lol
          :::>> $ touch lol/rofl.txt
          :::>> $ touch does/not/exist.txt
          ```
        EOF

        io = StringIO.new

        error = nil
        begin
          Rundoc::CLI.new(
            io: io,
            source_path: source_path,
            on_success_dir: dir.join(SUCCESS_DIRNAME)
          ).call
        rescue => e
          error = e
        end

        assert error
        assert_includes error.message, "exited with non zero status"

        refute dir.join(SUCCESS_DIRNAME).join("lol").exist?
        refute dir.join(SUCCESS_DIRNAME).join("lol").join("rofl.txt").exist?

        assert dir.join(FAILURE_DIRNAME).join("lol").exist?
        assert dir.join(FAILURE_DIRNAME).join("lol").join("rofl.txt").exist?

        doc = dir.join(FAILURE_DIRNAME).join("RUNDOC_FAILED.md").read
        assert_includes doc, "$ mkdir lol"
        assert_includes doc, "$ touch lol/rofl.txt"
      end
    end
  end
end
