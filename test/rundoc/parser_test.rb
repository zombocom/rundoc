require "test_helper"

class ParserTest < Minitest::Test
  def test_parse_bash
    contents = <<~RUBY
      sup

      ```
      :::>-  $ mkdir foo
      :::>> $ ls
      ```

      yo
    RUBY

    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        expected = "sup\n\n```\n$ mkdir foo\n$ ls\nfoo\n```\n\nyo\n"
        parsed = parse_contents(contents)
        actual = parsed.to_md.gsub(Rundoc::CodeSection::AUTOGEN_WARNING, "")
        assert_equal expected, actual
      end
    end
  end

  def test_parse_write_commands
    contents = <<~RUBY
      sup

      ```
      :::>> write foo/code.rb
      a = 1 + 1
      b = a * 2
      ```
      yo
    RUBY

    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        expected = "sup\n\nIn file `foo/code.rb` write:\n\n```\na = 1 + 1\nb = a * 2\n```\nyo\n"
        parsed = parse_contents(contents)
        actual = parsed.to_md.gsub(Rundoc::CodeSection::AUTOGEN_WARNING, "")
        assert_equal expected, actual
      end
    end

    contents = <<~RUBY

      ```
      :::>> write foo/newb.rb
      puts 'hello world'
      :::>> $ cat foo/newb.rb
      ```
    RUBY

    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        expected = "\nIn file `foo/newb.rb` write:\n\n```\nputs 'hello world'\n$ cat foo/newb.rb\nputs 'hello world'\n```\n"
        parsed = parse_contents(contents)
        actual = parsed.to_md.gsub(Rundoc::CodeSection::AUTOGEN_WARNING, "")
        assert_equal expected, actual
      end
    end
  end
end
