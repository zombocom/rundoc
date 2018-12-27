class Rundoc::CodeCommand::Website
  class Screenshot < Rundoc::CodeCommand
    def initialize(name: , width: 640, height: 480)
      @driver = Rundoc::CodeCommand::Website::Driver.find(name)
    end

    def to_md(env = {})
      ""
    end

    def call(env = {})
      puts "Taking screenshot: #{@driver.current_url}"
      filename = @driver.screenshot
      env[:replace] = "![Screenshot of #{@driver.current_url}](#{filename})"
      ""
    end

    # def hidden?
    #   true
    # end

    # def not_hidden?
    #   !hidden?
    # end
  end
end
Rundoc.register_code_command(:"website.screenshot", Rundoc::CodeCommand::Website::Screenshot)
