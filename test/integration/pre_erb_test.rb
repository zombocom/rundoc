require "test_helper"

class IntegrationPreErb < Minitest::Test
  def test_file_write
    key = SecureRandom.hex
    contents = <<~RUBY
      ```
      :::>> pre.erb file.write "lol.txt"
      Multi line
      <%= "#{key}" %>
      ```
    RUBY

    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        env = {}
        expected = <<~EOF
          In file `lol.txt` write:

          ```
          Multi line
          #{key}
          ```
        EOF

        parsed = parse_contents(contents)
        actual = parsed.to_md.gsub(Rundoc::FencedCodeBlock::AUTOGEN_WARNING, "").strip
        assert_equal expected.strip, actual.strip
      end
    end
  end

  def test_erb_shared_binding_persists_values
    key = SecureRandom.hex
    contents = <<~RUBY
      ```
      :::-- print.erb <% secret = "#{key}" %>
      :::>> pre.erb $ echo <%= secret %>
      ```
    RUBY

    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        env = {}
        expected = <<~EOF
          ```
          $ echo #{key}
          #{key}
          ```
        EOF

        parsed = parse_contents(contents)
        actual = parsed.to_md.gsub(Rundoc::FencedCodeBlock::AUTOGEN_WARNING, "").strip
        assert_equal expected.strip, actual.strip
      end
    end
  end
end