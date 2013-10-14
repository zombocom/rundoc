require 'test_helper'

class AppendFileTest < Test::Unit::TestCase

  def test_appends_to_a_file
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do

        file = "foo.rb"
        `echo 'foo' >> #{file}`

        cc = Rundoc::CodeCommand::FileCommand::Append.new(file)
        cc << "bar"
        cc.call

        result = File.read(file)

        assert_match /foo/, result
        assert_match /bar/, result

        cc = Rundoc::CodeCommand::FileCommand::Append.new(file)
        cc << "baz"
        cc.call

        actual   = File.read(file)
        expected = "foo\nbar\nbaz\n"
        assert_equal expected, actual
      end
    end
  end

end
