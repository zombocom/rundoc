require "test_helper"

class AppendFileTest < Minitest::Test
  def test_appends_to_a_file
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        file = "foo.rb"
        `echo 'foo' >> #{file}`

        cc = Rundoc::CodeCommand::FileCommand::AppendRunner.new(
          render_command: false,
          render_result: false,
          io: StringIO.new,
          user_args: Rundoc::CodeCommand::FileCommand::InsertArgs.new(file),
          contents: "bar"
        )
        cc.call

        result = File.read(file)

        assert_match(/foo/, result)
        assert_match(/bar/, result)

        cc = Rundoc::CodeCommand::FileCommand::AppendRunner.new(
          render_command: false,
          render_result: false,
          io: StringIO.new,
          user_args: Rundoc::CodeCommand::FileCommand::InsertArgs.new(file),
          contents: "baz"
        )
        cc.call

        actual = File.read(file)
        expected = "foo\nbar\nbaz\n"
        assert_equal expected, actual
      end
    end
  end

  def test_appends_to_a_file_at_line_number
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        contents = <<~CONTENTS
          source 'https://rubygems.org'
          gem 'rails', '4.0.0'
        CONTENTS

        file = "foo.rb"
        line = 2
        `echo '#{contents}' >> #{file}`

        cc = Rundoc::CodeCommand::FileCommand::AppendRunner.new(
          render_command: false,
          render_result: false,
          io: StringIO.new,
          user_args: Rundoc::CodeCommand::FileCommand::InsertArgs.new("#{file}##{line}"),
          contents: "gem 'pg'"
        )
        cc.call

        expected = "source https://rubygems.org\ngem 'pg'\ngem rails, 4.0.0\n\n"
        assert_equal expected, File.read(file)
      end
    end
  end

  def test_globs_filenames
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        filename = "file-#{Time.now.utc.strftime("%Y%m%d%H%M%S")}.txt"
        FileUtils.touch(filename)
        cc = Rundoc::CodeCommand::FileCommand::AppendRunner.new(
          render_command: false,
          render_result: false,
          io: StringIO.new,
          user_args: Rundoc::CodeCommand::FileCommand::InsertArgs.new("file-*.txt"),
          contents: "some text"
        )
        cc.call

        assert_equal "\nsome text\n", File.read(filename)
      end
    end
  end

  def test_glob_multiple_matches_raises
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        FileUtils.touch("file-1234.txt")
        FileUtils.touch("file-5678.txt")
        assert_raises do
          cc = Rundoc::CodeCommand::FileCommand::AppendRunner.new(
            render_command: false,
            render_result: false,
            io: StringIO.new,
            user_args: Rundoc::CodeCommand::FileCommand::InsertArgs.new("file-*.txt"),
            contents: "some text"
          )
          cc.call
        end
      end
    end
  end

  def test_appends_to_a_file_at_match
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        file = "Gemfile"
        File.write(file, "source 'https://rubygems.org'\ngem 'rails', '4.0.0'\n")

        cc = Rundoc::CodeCommand::FileCommand::AppendRunner.new(
          render_command: false,
          render_result: false,
          io: StringIO.new,
          user_args: Rundoc::CodeCommand::FileCommand::InsertArgs.new(file, match: "gem 'rails'"),
          contents: "gem 'pg'"
        )
        cc.call

        expected = "source 'https://rubygems.org'\ngem 'rails', '4.0.0'\ngem 'pg'\n"
        assert_equal expected, File.read(file)
      end
    end
  end

  def test_appends_to_a_file_at_match_first
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        file = "app.py"
        File.write(file, "import os\nimport sys\nprint('hello')\n")

        cc = Rundoc::CodeCommand::FileCommand::AppendRunner.new(
          render_command: false,
          render_result: false,
          io: StringIO.new,
          user_args: Rundoc::CodeCommand::FileCommand::InsertArgs.new(file, match_first: "import"),
          contents: "import json"
        )
        cc.call

        expected = "import os\nimport json\nimport sys\nprint('hello')\n"
        assert_equal expected, File.read(file)
      end
    end
  end

  def test_appends_to_a_file_at_match_raises_when_not_found
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        file = "Gemfile"
        File.write(file, "source 'https://rubygems.org'\n")

        error = assert_raises(RuntimeError) do
          cc = Rundoc::CodeCommand::FileCommand::AppendRunner.new(
            render_command: false,
            render_result: false,
            io: StringIO.new,
            user_args: Rundoc::CodeCommand::FileCommand::InsertArgs.new(file, match: "gem 'rails'"),
            contents: "gem 'pg'"
          )
          cc.call
        end
        assert_match(/Could not find match/, error.message)
      end
    end
  end

  def test_appends_raises_when_match_and_line_number_both_used
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        file = "foo.rb"
        File.write(file, "line one\nline two\n")

        error = assert_raises(RuntimeError) do
          Rundoc::CodeCommand::FileCommand::AppendRunner.new(
            render_command: false,
            render_result: false,
            io: StringIO.new,
            user_args: Rundoc::CodeCommand::FileCommand::InsertArgs.new("#{file}#2", match: "line two"),
            contents: "inserted"
          )
        end
        assert_match(/Cannot use both match: and #line_number/, error.message)
      end
    end
  end
end
