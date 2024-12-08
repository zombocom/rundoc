require "test_helper"

class IntegrationPrintTest < Minitest::Test
  def test_erb_shared_binding_persists_values
    key = SecureRandom.hex
    contents = <<~RUBY
      ```
      :::-> print.erb
      one <% @variable = "#{key}" %>
      :::-> print.erb
      <%= @variable %>
      ```
    RUBY

    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        env = {}
        env[:before] = []
        expected = <<~EOF
          one
          #{key}
        EOF
        parsed = parse_contents(contents)
        actual = parsed.to_md.gsub(Rundoc::FencedCodeBlock::AUTOGEN_WARNING, "")
        assert_equal expected, actual
      end
    end

    key = SecureRandom.hex
    contents = <<~RUBY
      ```
      :::-> print.erb(binding: "one")
      one <% @variable = "#{key}" %>
      :::-> print.erb(binding: "different")
      <%= @variable %>
      ```
    RUBY

    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        env = {}
        env[:before] = []
        expected = <<~EOF
          one
        EOF
        parsed = parse_contents(contents)
        actual = parsed.to_md.gsub(Rundoc::FencedCodeBlock::AUTOGEN_WARNING, "")
        assert_equal expected, actual
      end
    end
  end

  def test_erb_in_block
    contents = <<~RUBY
      ```
      :::>> print.erb
      Hello
      there
      ```
    RUBY

    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        env = {}
        env[:before] = []
        expected = <<~EOF
          ```
          Hello
          there
          ```
        EOF
        parsed = parse_contents(contents)
        actual = parsed.to_md.gsub(Rundoc::FencedCodeBlock::AUTOGEN_WARNING, "")
        assert_equal expected, actual
      end
    end
  end

  def test_erb_with_default_binding
    contents = <<~RUBY
      ```
      :::-> print.erb
      Hello
      there
      ```
    RUBY

    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        env = {}
        env[:before] = []
        expected = <<~EOF
          Hello
          there
        EOF
        parsed = parse_contents(contents)
        actual = parsed.to_md.gsub(Rundoc::FencedCodeBlock::AUTOGEN_WARNING, "")
        assert_equal expected, actual
      end
    end
  end

  def test_erb_with_explicit_binding
    contents = <<~RUBY
      ```
      :::-> print.erb(binding: "yolo")
      Hello
      there
      ```
    RUBY

    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        env = {}
        env[:before] = []
        expected = <<~EOF
          Hello
          there
        EOF
        parsed = parse_contents(contents)
        actual = parsed.to_md.gsub(Rundoc::FencedCodeBlock::AUTOGEN_WARNING, "")
        assert_equal expected, actual
      end
    end
  end

  def test_print_text_stdin_contents
    contents = <<~RUBY
      ```
      :::-> print.text
      Hello
      there
      ```
    RUBY

    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        env = {}
        env[:before] = []
        expected = <<~EOF
          Hello
          there
        EOF
        parsed = parse_contents(contents)
        actual = parsed.to_md.gsub(Rundoc::FencedCodeBlock::AUTOGEN_WARNING, "")
        assert_equal expected, actual
      end
    end
  end

  def test_print_before
    contents = <<~RUBY
      ```
      :::-> print.text Hello there
      ```
    RUBY

    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        env = {}
        env[:before] = []
        expected = <<~EOF
          Hello there
        EOF
        parsed = parse_contents(contents)
        actual = parsed.to_md.gsub(Rundoc::FencedCodeBlock::AUTOGEN_WARNING, "")
        assert_equal expected, actual
      end
    end
  end

  def test_print_in_block
    contents = <<~RUBY
      ```
      :::>> print.text Hello there
      ```
    RUBY

    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        env = {}
        env[:before] = []
        expected = <<~EOF
          ```
          Hello there
          ```
        EOF
        parsed = parse_contents(contents)
        actual = parsed.to_md.gsub(Rundoc::FencedCodeBlock::AUTOGEN_WARNING, "")
        assert_equal expected, actual
      end
    end
  end
end
