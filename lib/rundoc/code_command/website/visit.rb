# frozen_string_literal: true

class Rundoc::CodeCommand::Website
  class Visit < Rundoc::CodeCommand
    def initialize(name:, url: nil, scroll: nil, height: 720, width: 1024, visible: false, max_attempts: 3)
      @name = name
      @url = url
      @scroll = scroll
      @height = height
      @width = width
      @visible = visible
      @max_attempts = max_attempts
    end

    def driver
      @driver ||= Driver.new(
        name: @name,
        url: @url,
        height: @height,
        width: @width,
        visible: @visible
      ).tap do |driver|
        Driver.add(@name, driver)
      end
    end

    def to_md(env = {})
      ""
    end

    def call(env = {})
      message = "Visting: #{@url}"
      message << "and executing:\n#{contents}" unless contents.nil? || contents.empty?

      puts message

      driver.visit(@url, max_attempts: @max_attempts) if @url
      driver.scroll(@scroll) if @scroll

      return "" if contents.nil? || contents.empty?
      driver.safe_eval(contents, env)

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
