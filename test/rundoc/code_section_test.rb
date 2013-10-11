require 'test_helper'

class ParserTest < Test::Unit::TestCase

  def setup
  end

  def test_does_not_render_if_all_contents_hidden
    contents =  <<-RUBY
sup

```
:::-  $ mkdir foo
```

yo
RUBY


    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        match = contents.match(Rundoc::Parser::CODEBLOCK_REGEX)
        result = Rundoc::CodeSection.new(match, keyword: ":::").render
        assert_equal "", result
        # expected = "sup\n\n```\n$ mkdir foo\n$ ls\nfoo\n```\n\nyo\n"
        # parsed = Rundoc::Parser.new(contents)
        # actual = parsed.to_md
        # assert_equal expected, actual

        # parsed = Rundoc::Parser.new("\n```\n:::= $ ls\n```\n")
        # actual = parsed.to_md
        # expected = "\n```\n$ ls\nfoo\n```\n"
        # assert_equal expected, actual
      end
    end
  end

end
