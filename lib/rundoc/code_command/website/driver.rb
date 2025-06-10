require "capybara"

Capybara::Selenium::Driver.load_selenium

class Rundoc::CodeCommand::Website
  class Driver
    attr_reader :session

    def initialize(name:, url:, width: 1024, height: 720, visible: false, io: $stdout, read_timeout: 60)
      @io = io
      browser_options = ::Selenium::WebDriver::Chrome::Options.new
      browser_options.args << "--headless" unless visible
      browser_options.args << "--disable-gpu" if Gem.win_platform?
      browser_options.args << "--hide-scrollbars"
      # browser_options.args << "--window-size=#{width},#{height}"
      @width = width
      @height = height

      client = Selenium::WebDriver::Remote::Http::Default.new
      client.read_timeout = read_timeout

      @driver = Capybara::Selenium::Driver.new(nil, browser: :chrome, options: browser_options, http_client: client)
      driver_name = :"rundoc_driver_#{name}"
      Capybara.register_driver(driver_name) do |app|
        @driver
      end

      @session = Capybara::Session.new(driver_name)
    end

    def visit(url, max_attempts: 3, delay: 1)
      attempts = 0
      begin
        @session.visit(url)
      rescue ::Net::ReadTimeout => e
        attempts += 1
        if attempts > max_attempts
          raise e
        else
          @io.puts "Error visiting url (#{attempts}/#{max_attempts}) `#{url}`:\n#{e}"
          sleep delay
          retry
        end
      end
    end

    def timestamp
      Time.now.utc.strftime("%Y%m%d%H%M%S%L%N")
    end

    def current_url
      session.current_url
    end

    def scroll(value = 100)
      session.execute_script "window.scrollBy(0,#{value})"
    end

    def teardown
      session.reset_session!
    end

    class << self
      attr_reader :tasks
    end

    def safe_eval(code, env = {})
      @driver.send(:eval, code)
    rescue => e
      msg = +""
      msg << "Error running code #{code.inspect} at #{current_url.inspect}\n"
      msg << "saving a screenshot to: `tmp/error.png`"
      @io.puts msg
      error_path = env[:context].screenshots_dir.join("error.png")
      session.save_screenshot(error_path)
      raise e
    end

    def screenshot(screenshots_dir:, upload: false)
      @driver.resize_window_to(@driver.current_window_handle, @width, @height)
      FileUtils.mkdir_p(screenshots_dir)
      file_name = self.class.next_screenshot_name
      file_path = screenshots_dir.join(file_name)
      session.save_screenshot(file_path)
      @io.puts "Screenshot saved to #{file_path}"

      return file_path unless upload

      case upload
      when "s3", "aws"
        @io.puts "Uploading screenshot to S3"
        require "aws-sdk-s3"
        ENV.fetch("AWS_ACCESS_KEY_ID")
        s3 = Aws::S3::Resource.new(region: ENV.fetch("AWS_REGION"))

        key = "#{timestamp}/#{file_name}"
        obj = s3.bucket(ENV.fetch("AWS_BUCKET_NAME")).object(key)
        obj.upload_file(file_path)

        obj.client.put_object_acl(
          acl: "public-read",
          bucket: ENV.fetch("AWS_BUCKET_NAME"),
          key: key
        )

        obj.public_url
      else
        raise "Upload #{upload.inspect} is not valid, use 's3' instead"
      end
    end

    @tasks = {}
    def self.add(name, value)
      raise "Task named #{name.inspect} is already started, choose a different name" if @tasks[name]
      @tasks[name] = value
    end

    def self.find(name)
      raise "Could not find task with name #{name.inspect}, known task names: #{@tasks.keys.inspect}" unless @tasks[name]
      @tasks[name]
    end

    def self.next_screenshot_name
      @count ||= 0
      @count += 1
      "screenshot_#{@count}.png"
    end
  end
end
