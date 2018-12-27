require 'capybara'

Capybara::Selenium::Driver.load_selenium

class Rundoc::CodeCommand::Website
  class Driver
    attr_reader :session

    def initialize(name: , url: , width: 1024, height: 720)
      browser_options = ::Selenium::WebDriver::Chrome::Options.new
      browser_options.args << '--headless'
      browser_options.args << '--disable-gpu' if Gem.win_platform?
      browser_options.args << '--hide-scrollbars'
      # browser_options.args << "--window-size=#{width},#{height}"
      @width = width
      @height = height

      @session = Capybara::Selenium::Driver.new(nil, browser: :chrome, options: browser_options)
    end

    def visit(url)
      @session.visit(url)
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

    def self.tasks
      @tasks
    end

    def screenshot(upload: false)
      session.resize_window_to(session.current_window_handle, @width, @height)
      FileUtils.mkdir_p("tmp/rundoc_screenshots")
      file_name = self.class.next_screenshot_name
      file_path = "tmp/rundoc_screenshots/#{file_name}"
      session.save_screenshot(file_path)

      return file_path unless upload

      case upload
      when 's3', 'aws'
        puts "Uploading screenshot to S3"
        require 'aws-sdk-s3'
        ENV.fetch('AWS_ACCESS_KEY_ID')
        s3 = Aws::S3::Resource.new(region: ENV.fetch('AWS_REGION'))

        key = "#{timestamp}/#{file_name}"
        obj = s3.bucket(ENV.fetch('AWS_BUCKET_NAME')).object(key)
        obj.upload_file(file_path)

        obj.client.put_object_acl(
          acl: 'public-read' ,
          bucket: ENV.fetch('AWS_BUCKET_NAME'),
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
      return "screenshot_#{@count}.png"
    end
  end
end
