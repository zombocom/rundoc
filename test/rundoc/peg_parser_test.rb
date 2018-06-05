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
    expected = {:string=>"hello world"}
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
    puts tree

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
    input = %Q{:::>> $ cat foo.rb}
    parser = Rundoc::PegParser.new.command
    tree = parser.parse_with_debug(input)

    puts tree.inspect
    actual = @transformer.apply(tree)
    assert_equal :"$", actual.keyword
    assert_equal("cat foo.rb", actual.original_args)
  end
end
