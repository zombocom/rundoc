require "test_helper"

class IntegrationRequireTest < Minitest::Test
  def test_lol
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do

        dir = Pathname(dir)
        source_path = dir.join("RUNDOC.md")
        source_path.write <<~EOF
          ```
          :::-- rundoc.require "./day_one/rundoc.md"
          ```
        EOF

        dir.join("day_one").tap(&:mkpath).join("rundoc.md").write <<~EOF
          ```
          :::-> print.text Hello World!
          ```
        EOF

        parsed = parse_contents(
          source_path.read,
          source_path: source_path,
        )
        actual = parsed.to_md.gsub(Rundoc::CodeSection::AUTOGEN_WARNING, "")
        assert_equal "Hello World!", actual.strip
      end
    end
  end
end
