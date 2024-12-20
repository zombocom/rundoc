require "test_helper"

class CodeSectionTest < Minitest::Test
  def test_does_not_render_if_all_contents_hidden
    contents = <<~RUBY
      sup

      ```
      :::--  $ mkdir foo
      ```

      yo
    RUBY

    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        match = contents.match(Rundoc::Document::CODEBLOCK_REGEX)
        result = Rundoc::FencedCodeBlock.new(
          fence: match[:fence],
          lang: match[:lang],
          code: match[:contents],
          context: default_context
        ).render
        assert_equal "", result
      end
    end
  end

  def test_no_code
    contents = <<~RUBY
      ```ruby
      gem 'sqlite3'
      ```

    RUBY

    match = contents.match(Rundoc::Document::CODEBLOCK_REGEX)
    result = Rundoc::FencedCodeBlock.new(
      fence: match[:fence],
      lang: match[:lang],
      code: match[:contents],
      context: default_context
    ).render
    assert_equal contents, result.gsub(Rundoc::FencedCodeBlock::AUTOGEN_WARNING, "\n")
  end

  def test_show_command_hide_render
    contents = <<~RUBY
      ```
      :::>- $ echo "foo"
      ```
    RUBY

    match = contents.match(Rundoc::Document::CODEBLOCK_REGEX)
    code_section = Rundoc::FencedCodeBlock.new(
      fence: match[:fence],
      lang: match[:lang],
      code: match[:contents],
      context: default_context
    )
    code_section.render

    code_command = code_section.executed_commands.first
    assert_equal true, code_command.render_command
    assert_equal false, code_command.render_result

    contents = <<~RUBY
      ```
      :::>- $ echo "foo"
      ```
    RUBY

    match = contents.match(Rundoc::Document::CODEBLOCK_REGEX)
    code_section = Rundoc::FencedCodeBlock.new(
      fence: match[:fence],
      lang: match[:lang],
      code: match[:contents],
      context: default_context
    )
    code_section.render

    code_command = code_section.executed_commands.first
    assert_equal true, code_command.render_command
    assert_equal false, code_command.render_result
  end

  def test_show_command_show_render
    contents = <<~RUBY
      ```
      :::>> $ echo "foo"
      ```
    RUBY

    match = contents.match(Rundoc::Document::CODEBLOCK_REGEX)
    code_section = Rundoc::FencedCodeBlock.new(
      fence: match[:fence],
      lang: match[:lang],
      code: match[:contents],
      context: default_context
    )
    code_section.render

    puts code_section.executed_commands.inspect
    code_command = code_section.executed_commands.first
    assert_equal true, code_command.render_command
    assert_equal true, code_command.render_result
  end

  def test_hide_command_hide_render
    contents = <<~RUBY
      ```
      :::-- $ echo "foo"
      ```
    RUBY

    match = contents.match(Rundoc::Document::CODEBLOCK_REGEX)
    code_section = Rundoc::FencedCodeBlock.new(
      fence: match[:fence],
      lang: match[:lang],
      code: match[:contents],
      context: default_context
    )
    code_section.render

    code_command = code_section.executed_commands.first
    assert_equal false, code_command.render_command
    assert_equal false, code_command.render_result

    contents = <<~RUBY
      ```
      :::-- $ echo "foo"
      ```
    RUBY

    match = contents.match(Rundoc::Document::CODEBLOCK_REGEX)
    code_section = Rundoc::FencedCodeBlock.new(
      fence: match[:fence],
      lang: match[:lang],
      code: match[:contents],
      context: default_context
    )
    code_section.render

    code_command = code_section.executed_commands.first
    assert_equal false, code_command.render_command
    assert_equal false, code_command.render_result
  end

  def test_hide_command_show_render
    contents = <<~RUBY
      ```
      :::-> $ echo "foo"
      ```
    RUBY

    match = contents.match(Rundoc::Document::CODEBLOCK_REGEX)
    code_section = Rundoc::FencedCodeBlock.new(
      fence: match[:fence],
      lang: match[:lang],
      code: match[:contents],
      context: default_context
    )
    code_section.render

    code_command = code_section.executed_commands.first
    assert_equal false, code_command.render_command
    assert_equal true, code_command.render_result
  end
end
