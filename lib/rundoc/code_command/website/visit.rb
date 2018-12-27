class Rundoc::CodeCommand::Website
  class Visit < Rundoc::CodeCommand
    def initialize(name: , url: , scroll: nil, height: 720, width: 1024)
      @name = name
      @url  = url
      @scroll = scroll
      @driver = Driver.new(
        name: name,
        url: url,
        height: height,
        width: width
      )
      Driver.add(@name, @driver)
    end

    def to_md(env = {})
      ""
    end

    def call(env = {})
      message = String.new("Visting: #{@url}")
      message << "and executing:\n#{contents}" unless contents.nil? || contents.empty?

      puts message

      @driver.visit(@url)
      @driver.scroll(@scroll) if @scroll


      return "" if contents.nil? || contents.empty?
      @driver.send(:eval, contents)

      return ""
    end

    def hidden?
      true
    end

    def not_hidden?
      !hidden?
    end
  end
end

Rundoc.register_code_command(:"website.visit", Rundoc::CodeCommand::Website::Visit)
