require "test_helper"

class BeforeFileTest < Minitest::Test
  def test_before_match_inserts_content_before_matched_line
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        file = "app.js"
        File.write(file, <<~CONTENTS)
          server.close()
          // Cleanup after server close
          })
        CONTENTS

        cc = Rundoc::CodeCommand::FileCommand::BeforeRunner.new(
          render_command: false,
          render_result: false,
          io: StringIO.new,
          user_args: Rundoc::CodeCommand::FileCommand::InsertArgs.new(file, match: "// Cleanup after server close"),
          contents: "pool.end()"
        )
        cc.call

        expected = <<~EXPECTED
          server.close()
          pool.end()
          // Cleanup after server close
          })
        EXPECTED
        assert_equal expected, File.read(file)
      end
    end
  end

  def test_before_match_raises_when_multiple_matches
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        file = "app.txt"
        File.write(file, "line one\nmarker\nline three\nmarker\n")

        error = assert_raises(RuntimeError) do
          cc = Rundoc::CodeCommand::FileCommand::BeforeRunner.new(
            render_command: false,
            render_result: false,
            io: StringIO.new,
            user_args: Rundoc::CodeCommand::FileCommand::InsertArgs.new(file, match: "marker"),
            contents: "inserted"
          )
          cc.call
        end
        assert_match(/Expected 1 match/, error.message)
        assert_match(/but found 2/, error.message)
      end
    end
  end

  def test_before_match_first_inserts_before_first_of_multiple
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        file = "app.py"
        File.write(file, "import os\nimport sys\nprint('hello')\n")

        cc = Rundoc::CodeCommand::FileCommand::BeforeRunner.new(
          render_command: false,
          render_result: false,
          io: StringIO.new,
          user_args: Rundoc::CodeCommand::FileCommand::InsertArgs.new(file, match_first: "import"),
          contents: "import json"
        )
        cc.call

        expected = "import json\nimport os\nimport sys\nprint('hello')\n"
        assert_equal expected, File.read(file)
      end
    end
  end

  def test_before_raises_when_match_not_found
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        file = "app.txt"
        File.write(file, "line one\nline two\n")

        error = assert_raises(RuntimeError) do
          cc = Rundoc::CodeCommand::FileCommand::BeforeRunner.new(
            render_command: false,
            render_result: false,
            io: StringIO.new,
            user_args: Rundoc::CodeCommand::FileCommand::InsertArgs.new(file, match: "not here"),
            contents: "inserted"
          )
          cc.call
        end
        assert_match(/Could not find match/, error.message)
      end
    end
  end

  def test_before_raises_when_match_value_is_empty_string
    error = assert_raises(RuntimeError) do
      Rundoc::CodeCommand::FileCommand::InsertArgs.new("file.txt", match: "")
    end
    assert_match(/match value cannot be empty/, error.message)
  end

  def test_before_raises_when_both_match_and_match_first
    error = assert_raises(RuntimeError) do
      Rundoc::CodeCommand::FileCommand::InsertArgs.new("file.txt", match: "a", match_first: "b")
    end
    assert_match(/Cannot use both match: and match_first:/, error.message)
  end

  def test_before_prepends_to_head_when_no_match_or_line
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        file = "app.txt"
        File.write(file, "line one\nline two\n")

        cc = Rundoc::CodeCommand::FileCommand::BeforeRunner.new(
          render_command: false,
          render_result: false,
          io: StringIO.new,
          user_args: Rundoc::CodeCommand::FileCommand::InsertArgs.new(file),
          contents: "line zero"
        )
        cc.call

        expected = "line zero\nline one\nline two\n"
        assert_equal expected, File.read(file)
      end
    end
  end

  def test_before_to_md_output
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        file = "app.txt"
        File.write(file, "marker\n")

        cc = Rundoc::CodeCommand::FileCommand::BeforeRunner.new(
          render_command: true,
          render_result: false,
          io: StringIO.new,
          user_args: Rundoc::CodeCommand::FileCommand::InsertArgs.new(file, match: "marker"),
          contents: "inserted"
        )

        env = {}
        env[:commands] = []
        env[:before] = []
        env[:fence_start] = "```"
        cc.to_md(env)

        assert_equal "In file `app.txt`, before `marker`, add:", env[:before].first
      end
    end
  end
end
