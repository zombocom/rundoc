require 'test_helper'

class RegexTest < Test::Unit::TestCase

  def setup
  end

  def test_indent_regex

    contents =  <<-RUBY
foo

    $ cd
    yo
    sup

bar
RUBY

    regex  = Docdown::Parser::INDENT_BLOCK
    parsed = contents.match(/#{regex}/).to_s
    assert_equal "\n    $ cd\n    yo\n    sup\n", parsed
  end

  def test_github_regex

    contents =  <<-RUBY
foo

```
$ cd
yo
sup
```

bar
RUBY

    regex  = Docdown::Parser::GITHUB_BLOCK
    parsed = contents.match(/#{regex}/m).to_s
    assert_equal "```\n$ cd\nyo\nsup\n```\n", parsed
  end

  def test_github_tagged_regex
    contents =  <<-RUBY
foo

```ruby
$ cd
yo
sup
```

bar
RUBY

    regex  = Docdown::Parser::GITHUB_BLOCK
    parsed = contents.match(/#{regex}/m).to_s
    assert_equal "```ruby\n$ cd\nyo\nsup\n```\n", parsed
  end

  def test_command_regex
    regex    = Docdown::Parser::COMMAND_REGEX.call(":::")

    contents = ":::$ mkdir schneems"
    match    = contents.match(regex)
    assert_equal "",  match[:tag]
    assert_equal "$", match[:command]
    assert_equal "mkdir schneems", match[:statement]

    contents = ":::=$ mkdir schneems"
    match    = contents.match(regex)
    assert_equal "=", match[:tag]
    assert_equal "$", match[:command]
    assert_equal "mkdir schneems", match[:statement]

    contents = ":::-$ mkdir schneems"
    match    = contents.match(regex)
    assert_equal "-", match[:tag]
    assert_equal "$", match[:command]
    assert_equal "mkdir schneems", match[:statement]

    contents = ":::- $ mkdir schneems"
    match    = contents.match(regex)
    assert_equal "-", match[:tag]
    assert_equal "$", match[:command]
    assert_equal "mkdir schneems", match[:statement]
  end


  def test_codeblock_regex

    contents =  <<-RUBY
foo

```
:::$ mkdir
```

zoo

```
:::$ cd ..
something
```

bar
RUBY

    regex    = Docdown::Parser::CODEBLOCK_REGEX

    actual   = contents.split(regex)
    expected = ["foo\n\n",
                 "```",
                 "",
                 ":::$ mkdir\n",
                 "\nzoo\n\n",
                 "```",
                 "",
                 ":::$ cd ..\nsomething\n",
                 "\nbar\n"]
    assert_equal expected, actual

    actual   = contents.partition(regex)
    expected = ["foo\n\n",
                "```\n:::$ mkdir\n```\n",
                "\nzoo\n\n```\n:::$ cd ..\nsomething\n```\n\nbar\n"]

    assert_equal  expected, actual

    str = "```\n:::$ mkdir\n```\n"
    match = str.match(regex)
    assert_equal ":::$ mkdir\n", match[:contents]

    str = "\n\n```\n:::$ cd ..\nsomething\n```\n\nbar\n"
    match = str.match(regex)
    assert_equal ":::$ cd ..\nsomething\n", match[:contents]

    # partition, shift, codebloc,
  end

end
