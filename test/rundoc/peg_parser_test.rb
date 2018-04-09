require 'test_helper'
require 'parslet/convenience'

class PegParserTest < Minitest::Test
  def setup
    @transformer = Rundoc::PegTransformer.new
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
  end

  def test_method_unquoted_string

  end
end