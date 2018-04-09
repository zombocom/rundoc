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

end