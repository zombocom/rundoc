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

    def screenshot
      session.resize_window_to(session.current_window_handle, @width, @height)
      FileUtils.mkdir_p("tmp/rundoc_screenshots")
      filename = "tmp/rundoc_screenshots/#{self.class.next_screenshot_name}"
      session.save_screenshot(filename)
      filename
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
