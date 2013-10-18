require 'test_helper'

class RemoveContentsTest < Test::Unit::TestCase

  def setup
    @gemfile = <<-RUBY

    source 'https://rubygems.org'

    # Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
    gem 'rails', '4.0.0'

    gem 'sqlite3'
    RUBY
  end

  def test_appends_to_a_file
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do

        @file = "foo.rb"
        `echo "#{@gemfile}" >> #{@file}`

        assert_match /sqlite3/, File.read(@file)

        cc = Rundoc::CodeCommand::FileCommand::Remove.new(@file)
        cc << "gem 'sqlite3'"
        cc.call

        result = File.read(@file)
        refute_match /sqlite3/, File.read(@file)

        env = {}
        env[:commands] = []
        env[:before]   = "```ruby"
        cc.to_md(env)

        assert_equal "In file `foo.rb` remove:\n\n```ruby", env[:before]
      end
    end
  end
end
