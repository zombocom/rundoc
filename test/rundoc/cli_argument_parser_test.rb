require "test_helper"

class CliArgumentParserTest < Minitest::Test

  def test_help
    io = StringIO.new
    exit_obj = FakeExit.new
    parser = Rundoc::CLIArgumentParser.new(
      io: io,
      argv: ["--help"],
      env: {},
      exit_obj: exit_obj
    )
    parser.call
    output = io.string

    assert output.include?("Prints this help output")
  end

  def test_help_no_flag
    io = StringIO.new
    exit_obj = FakeExit.new
    parser = Rundoc::CLIArgumentParser.new(
      io: io,
      argv: ["help"],
      env: {},
      exit_obj: exit_obj
    )
    parser.call
    output = io.string

    assert output.include?("Prints this help output")
  end

  def test_no_such_file
    io = StringIO.new
    exit_obj = FakeExit.new
    parser = Rundoc::CLIArgumentParser.new(
      io: io,
      argv: ["fileDoesNotExist.txt"],
      env: {},
      exit_obj: exit_obj
    )
    parser.call
    output = io.string

    assert exit_obj.value == 1
    assert_includes output, "No such file"
  end

  def test_dir_not_file
    Dir.mktmpdir do |dir|
      io = StringIO.new
      exit_obj = FakeExit.new
      parser = Rundoc::CLIArgumentParser.new(
        io: io,
        argv: [dir],
        env: {},
        exit_obj: exit_obj
      )
      parser.call
      output = io.string

      assert exit_obj.value == 1
      assert_includes output, "Path is not a file"
    end
  end

  def test_valid_inputs
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        tmp = Pathname(dir)
        rundoc = tmp.join("rundoc.md")
        rundoc.write("")

        io = StringIO.new
        exit_obj = FakeExit.new
        parser = Rundoc::CLIArgumentParser.new(
          io: io,
          argv: [
            rundoc,
            "--on-success-dir=./success",
            "--on-failure-dir=./failure",
            "--dotenv-path=./lol/.env",
            "--screenshots-dirname=pics",
            "--output-filename=OUTPUT.md",
            "--force",
          ],
          env: {},
          exit_obj: exit_obj
        )
        parser.call
        output = io.string

        assert !exit_obj.called?
        assert output.empty?

        assert_equal "./success", parser.options[:on_success_dir]
        assert_equal "./failure", parser.options[:on_failure_dir]
        assert_equal "./lol/.env", parser.options[:dotenv_path]
        assert_equal "pics", parser.options[:screenshots_dirname]
        assert_equal "OUTPUT.md", parser.options[:output_filename]
        assert_equal true, parser.options[:force]

        expected = [
          :on_success_dir,
          :on_failure_dir,
          :dotenv_path,
          :screenshots_dirname,
          :output_filename,
          :force,
          :io,
          :source_path
        ]
        assert_equal expected.sort, parser.options.keys.sort
      end
    end
  end
end
