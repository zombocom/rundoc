require "test_helper"

class CommentTest < Minitest::Test
  def test_comment_runner_call_returns_empty_string
    io = StringIO.new
    runner = Rundoc::CodeCommand::CommentRunner.new(
      render_command: false,
      render_result: false,
      io: io,
      user_args: Rundoc::CodeCommand::CommentArgs.new("$ cat hello")
    )
    assert_equal "", runner.call
    assert_equal "", runner.to_md
    assert_equal "Skipping command (commented out): # $ cat hello\n", io.string
  end

  def test_comment_with_contents
    io = StringIO.new
    runner = Rundoc::CodeCommand::CommentRunner.new(
      render_command: false,
      render_result: false,
      io: io,
      user_args: Rundoc::CodeCommand::CommentArgs.new("$ tail -n 2"),
      contents: "foo\nbar\nbaz\n"
    )
    assert_equal "", runner.call
    expected = <<~EOF
      Skipping command (commented out): # $ tail -n 2
      foo
      bar
      baz
    EOF
    assert_equal expected.strip, io.string.strip
  end

  def test_comment_is_noop_in_document
    contents = <<~EOF
      before

      ```
      :::>> # $ cat hello
      ```

      after
    EOF

    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        parsed = parse_contents(contents)
        actual = strip_autogen_warning(parsed.to_md)
        assert_equal "before\n\n\nafter\n", actual
      end
    end
  end

  def test_smudged_comment
    contents = <<~EOF
      before

      ```
      :::>> #$ cat hello
      ```

      after
    EOF

    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        parsed = parse_contents(contents)
        actual = strip_autogen_warning(parsed.to_md)
        assert_equal "before\n\n\nafter\n", actual
      end
    end
  end

  def test_bare_comment_is_noop
    contents = <<~EOF
      before

      ```
      :::>> #
      ```

      after
    EOF

    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        parsed = parse_contents(contents)
        actual = strip_autogen_warning(parsed.to_md)
        assert_equal "before\n\n\nafter\n", actual
      end
    end
  end

  def test_comment_does_not_affect_other_commands
    contents = <<~EOF
      before

      ```
      :::>> # this is commented out
      :::>> $ echo "hello"
      ```

      after
    EOF

    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        parsed = parse_contents(contents)
        actual = strip_autogen_warning(parsed.to_md)
        assert_equal "before\n\n```\n$ echo \"hello\"\nhello\n```\n\nafter\n", actual
      end
    end
  end
end
