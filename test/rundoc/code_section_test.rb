require 'test_helper'

class CodeSectionTest < Test::Unit::TestCase

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
      end
    end
  end


  def test_no_code
    contents = <<-RUBY
```ruby
gem 'sqlite3'
```
RUBY

    match = contents.match(Rundoc::Parser::CODEBLOCK_REGEX)
    result = Rundoc::CodeSection.new(match, keyword: ":::").render
    assert_equal contents, result
  end

end
