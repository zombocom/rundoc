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

  def test_retry_client_closed_early
    tcp_unexpected_exit do |port|
      io = StringIO.new
      driver = Rundoc::CodeCommand::Website::Driver.new(name: SecureRandom.hex, url: nil, read_timeout: 0.1, io: io)
      assert_raises(Net::ReadTimeout) do
        driver.visit("http://localhost:#{port}", max_attempts: 3, delay: 0)
      end

      logs = io.string
      assert_logs_include(logs: logs, include_str: "Error visiting url (1/3)")
      assert_logs_include(logs: logs, include_str: "Error visiting url (2/3)")
      assert_logs_include(logs: logs, include_str: "Error visiting url (3/3)")
    end
  end

  def assert_logs_include(logs: , include_str: )
    assert logs.include?(include_str), "Expected logs to include #{include_str} but they didnt. Logs:\n#{logs}"
  end
end
