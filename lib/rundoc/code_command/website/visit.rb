class Rundoc::CodeCommand::Website
  class Visit < Rundoc::CodeCommand
    def initialize(name:, url: nil, scroll: nil, height: 720, width: 1024, visible: false)
      @name = name
      @url = url
      @scroll = scroll
      @driver = Driver.new(
        name: name,
        url: url,
        height: height,
        width: width,
        visible: visible
      )
      Driver.add(@name, @driver)
    end

    def to_md(env = {})
      ""
    end

    def call(env = {})
      message = +"Visting: #{@url}"
      message << "and executing:\n#{contents}" unless contents.nil? || contents.empty?

      puts message

      @driver.visit(@url) if @url
      @driver.scroll(@scroll) if @scroll

      return "" if contents.nil? || contents.empty?
      @driver.safe_eval(contents, env)

      ""
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
