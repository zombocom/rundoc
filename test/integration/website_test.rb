require "test_helper"

class IntegrationWebsiteTest < Minitest::Test
  def test_screenshot_command
    contents = <<~RUBY
      ```
      :::>> website.visit(name: "example", url: "http://example.com")
      :::>> website.screenshot(name: "example")
      :::>> website.navigate(name: "example")
      session.execute_script "window.scrollBy(0,10)"
      ```
    RUBY

    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        env = {}
        env[:before] = []

        screenshots_dirname = "screenshots"
        screenshots_dir = Pathname(dir).join(screenshots_dirname)
        screenshot_1_path = screenshots_dir.join("screenshot_1.png")

        parsed = parse_contents(
          contents,
          output_dir: screenshots_dir.parent,
          screenshots_dirname: screenshots_dirname
        )
        actual = parsed.to_md.gsub(Rundoc::FencedCodeBlock::AUTOGEN_WARNING, "")

        expected = "![Screenshot of https://example.com/](screenshots/screenshot_1.png)"
        assert_equal expected, actual.strip

        assert screenshot_1_path.exist?
      end
    end
  end
end
