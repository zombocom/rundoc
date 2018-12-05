require 'test_helper'
require 'parslet/convenience'

class PegParserTest < Minitest::Test
  def setup
    @transformer = Rundoc::PegTransformer.new
  end

  def test_string
    input = %Q{"hello world"}
    parser = Rundoc::PegParser.new.string
    tree = parser.parse_with_debug(input)
    expected = {:string => "hello world"}
    assert_equal expected, tree

    actual = @transformer.apply(tree)
    assert_equal "hello world", actual
  end

  def test_keyword_args
    input = %Q{foo: 'bar', baz: "boo"}
    parser = Rundoc::PegParser.new.named_args
    tree = parser.parse_with_debug(input)
    actual = @transformer.apply(tree)
    expected = {foo: 'bar', baz: "boo"}
    assert_equal expected, actual
  end

  def test_method_call
    input = %Q{sup(foo: 'bar')}
    parser = Rundoc::PegParser.new.method_call
    tree = parser.parse_with_debug(input)

    actual = @transformer.apply(tree)
    assert_equal :sup, actual.keyword
    assert_equal({foo: 'bar'}, actual.original_args)

    # seattle style
    input = %Q{sup foo: 'bar' }
    parser = Rundoc::PegParser.new.method_call
    tree = parser.parse_with_debug(input)
    actual = @transformer.apply(tree)
    assert_equal :sup, actual.keyword
    assert_equal({foo: 'bar'}, actual.original_args)

    # with a dot
    input = %Q{sup.you foo: 'bar' }
    parser = Rundoc::PegParser.new.method_call
    tree = parser.parse_with_debug(input)
    actual = @transformer.apply(tree)
    assert_equal :"sup.you", actual.keyword
    assert_equal({foo: 'bar'}, actual.original_args)
  end

  def test_with_string_arg
    input = %Q{sup("hey") }
    parser = Rundoc::PegParser.new.method_call
    tree = parser.parse_with_debug(input)

    actual = @transformer.apply(tree)
    assert_equal :sup, actual.keyword
    assert_equal("hey", actual.original_args)

    input = %Q{sup "hey" }
    parser = Rundoc::PegParser.new.method_call
    tree = parser.parse_with_debug(input)

    actual = @transformer.apply(tree)
    assert_equal :sup, actual.keyword
    assert_equal("hey", actual.original_args)

    input = %Q{sup hey}
    parser = Rundoc::PegParser.new.method_call
    tree = parser.parse_with_debug(input)

    actual = @transformer.apply(tree)
    assert_equal :sup, actual.keyword
    assert_equal("hey", actual.original_args)

    input = %Q{ $ cat foo.rb}
    parser = Rundoc::PegParser.new.method_call
    tree = parser.parse_with_debug(input)

    actual = @transformer.apply(tree)
    assert_equal :"$", actual.keyword
    assert_equal("cat foo.rb", actual.original_args)
  end

  def test_visability
    input = %Q{>>}
    parser = Rundoc::PegParser.new.visability
    tree = parser.parse_with_debug(input)
    actual = @transformer.apply(tree)
    assert_equal true, actual.command?
    assert_equal true, actual.result?

    input = %Q{->}
    parser = Rundoc::PegParser.new.visability
    tree = parser.parse_with_debug(input)
    actual = @transformer.apply(tree)
    assert_equal false, actual.command?
    assert_equal true, actual.result?

    input = %Q{--}
    parser = Rundoc::PegParser.new.visability
    tree = parser.parse_with_debug(input)
    actual = @transformer.apply(tree)
    assert_equal false, actual.command?
    assert_equal false, actual.result?

    input = %Q{>-}
    parser = Rundoc::PegParser.new.visability
    tree = parser.parse_with_debug(input)
    actual = @transformer.apply(tree)
    assert_equal true, actual.command?
    assert_equal false, actual.result?
  end

  def test_command
    input = %Q{:::>> $ cat foo.rb\n}
    parser = Rundoc::PegParser.new.command
    tree = parser.parse_with_debug(input)

    actual = @transformer.apply(tree)
    assert_equal :"$", actual.keyword
    assert_equal("cat foo.rb", actual.original_args)
  end

  def test_command_with_stdin
    input = String.new
    input << ":::>> file.write hello.txt\n"
    input << "world\n"

    parser = Rundoc::PegParser.new.command_with_stdin
    tree = parser.parse_with_debug(input)

    actual = @transformer.apply(tree)
    assert_equal :"file.write", actual.keyword
    assert_equal("hello.txt", actual.original_args)
    assert_equal("world\n", actual.contents)
  end

  def test_command_with_stdin_no_string
    input = String.new
    input << ":::>> file.write hello.txt\n"

    parser = Rundoc::PegParser.new.command_with_stdin
    tree = parser.parse_with_debug(input)

    actual = @transformer.apply(tree)

    assert_equal :"file.write", actual.keyword
    assert_equal("hello.txt", actual.original_args)
  end

  def test_multiple_commands_stdin
    input = String.new
    input << ":::>> file.write hello.txt\n"
    input << "world\n"
    input << ":::>> file.write cinco.txt\n"
    input << "\n\n\n"
    input << "  river\n"

    parser = Rundoc::PegParser.new.multiple_commands
    tree = parser.parse_with_debug(input)

    actual = @transformer.apply(tree)

    assert_equal :"file.write", actual.first.keyword
    assert_equal("hello.txt", actual.first.original_args)
    assert_equal("world\n", actual.first.contents)

    assert_equal :"file.write", actual.last.keyword
    assert_equal("cinco.txt", actual.last.original_args)
    assert_equal("\n\n\n  river\n", actual.last.contents)
  end

  def test_multiple_commands_with_fence
    input = String.new
    input << "```\n"
    input << ":::>> file.write hello.txt\n"
    input << "world\n"
    input << "```\n"

    parser = Rundoc::PegParser.new.fenced_commands
    tree = parser.parse_with_debug(input)

    actual = @transformer.apply(tree)

    assert_equal :"file.write", actual.first.keyword
    assert_equal("hello.txt", actual.first.original_args)
    assert_equal("world\n", actual.first.contents)
  end

  def test_raw
    input = String.new
    input << "hello.txt\n"
    input << "world\n"
    input << ":::>> $ cd foo\n"

    parser = Rundoc::PegParser.new.raw_code
    tree = parser.parse_with_debug(input)

    actual = @transformer.apply(tree)

    assert_equal "hello.txt\nworld\n", actual.first.contents
    assert_equal :"$", actual.last.keyword
    assert_equal("cd foo", actual.last.original_args)
  end


  def test_quotes_in_shell_commands
    input = %Q{:::>- $ git commit -m "init"\n}
    parser = Rundoc::PegParser.new.code_block
    tree = parser.parse_with_debug(input)

    actual = @transformer.apply(tree)

    assert_equal :"$", actual.last.keyword
    assert_equal('git commit -m "init"', actual.last.original_args)
  end

  def test_raises_on_syntax
    input = %Q{:::> $ git commit -m "init"\n}
    assert_raises(Rundoc::PegTransformer::TransformError) do
      parser = Rundoc::PegParser.new.code_block
      tree = parser.parse_with_debug(input)

      actual = @transformer.apply(tree)
    end
  end


  def test_no_args
    # input = String.new
    # input << %Q{rundoc}
    # parser = Rundoc::PegParser.new.no_args_method
    # tree = parser.parse_with_debug(input)
    # actual = @transformer.apply(tree)
    # assert_equal("rundoc", actual.to_s)

    # input = String.new
    # input << %Q{:::-- rundoc\n}
    # parser = Rundoc::PegParser.new.command
    # tree = parser.parse_with_debug(input)

    # actual = @transformer.apply(tree)
    # assert_equal :rundoc, actual.keyword
    # assert_nil(actual.original_args)


    input = String.new
    input << %Q{:::-- rundoc\n}
    input << %Q{email = ENV['HEROKU_EMAIL'] || `heroku auth:whoami`\n}

    parser = Rundoc::PegParser.new.command_with_stdin
    tree = parser.parse_with_debug(input)

    actual = @transformer.apply(tree)
    assert_equal :rundoc, actual.keyword
    assert_equal("email = ENV['HEROKU_EMAIL'] || `heroku auth:whoami`", actual.original_args)
  end


  def test_foo
    input = +""
    input << %Q{call("foo", "bar", biz: "baz")}

    parser = Rundoc::PegParser.new.method_call
    tree = parser.parse_with_debug(input)

    # =====================================
    #
    # Handles more than one value, but not only one value
    actual = @transformer.apply(tree)
    assert_equal ["foo", "bar", { biz: "baz"}], actual.original_args

    input = +""
    input << %Q{call("foo", biz: "baz")}

    parser = Rundoc::PegParser.new.method_call
    tree = parser.parse_with_debug(input)

    actual = @transformer.apply(tree)
    assert_equal ["foo", { biz: "baz"}], actual.original_args

    input = +""
    input << %Q{call("rails server", name: "server")}

    parser = Rundoc::PegParser.new.method_call
    tree = parser.parse_with_debug(input)

    actual = @transformer.apply(tree)
    assert_equal ["rails server", {name: "server"}], actual.original_args

    # input = +""
    # input << %Q{background.start("rails server", name: "server")}
    # parser = Rundoc::PegParser.new.method_call

    # tree = parser.parse_with_debug(input)

    # puts tree.inspect

    # actual = @transformer.apply(tree)
    # assert_equal :"background.start", actual.keyword

    # ================

    input = +""
    input << %Q{call("foo", "bar")}

    parser = Rundoc::PegParser.new.method_call
    tree = parser.parse_with_debug(input)

    # puts tree.inspect

    actual = @transformer.apply(tree)
    assert_equal ["foo", "bar"], actual.original_args

    # ======================

    input = +""
    input << %Q{call("foo", "bar", biz: "baz")}

    parser = Rundoc::PegParser.new.method_call
    tree = parser.parse_with_debug(input)

    actual = @transformer.apply(tree)
    assert_equal ["foo", "bar", { biz: "baz"}], actual.original_args

    # input = +""
    # input << %Q{:::>> background.start("rails server", name: "server")\n}
    # # input << %Q{:::-- background.stop(name: "server")\n}

    # parser = Rundoc::PegParser.new.code_block

    # tree = parser.parse_with_debug(input)

    # puts tree.inspect

    # assert_nil tree

    # actual = @transformer.apply(tree)
    # assert_equal :rundoc, actual.keyword
  end
end
