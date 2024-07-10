require "test_helper"

class IntegrationWebsiteTest < Minitest::Test
  def test_screenshot_command
    key = SecureRandom.hex
    contents = <<~RUBY
      ```
      :::>> website.visit(name: "example", url: "http://example.com")
      :::>> website.screenshot(name: "example")
      ```
    RUBY

    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        env = {}
        env[:before] = []

        screenshots_dir = Pathname(dir).join("screenshots")
        screenshot_1_path = screenshots_dir.join("screenshot_1.png")

        parsed = parse_contents(contents, screenshots_dir: screenshots_dir, output_dir: screenshots_dir.parent)
        actual = parsed.to_md.gsub(Rundoc::CodeSection::AUTOGEN_WARNING, "")

        expected = "![Screenshot of http://example.com/](screenshots/screenshot_1.png)"
        assert_equal expected, actual

        assert screenshot_1_path.exist?
      end
    end
  end
end
