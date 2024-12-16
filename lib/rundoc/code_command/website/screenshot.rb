class Rundoc::CodeCommand::Website
  class Screenshot < Rundoc::CodeCommand
    def initialize(name:, upload: false)
      @name = name
      @upload = upload
      @driver = nil
    end

    def driver
      @driver ||= Rundoc::CodeCommand::Website::Driver.find(@name)
    end

    def to_md(env = {})
      ""
    end

    def call(env = {})
      puts "Taking screenshot: #{driver.current_url}"
      filename = driver.screenshot(
        upload: @upload,
        screenshots_dir: env[:context].screenshots_dir
      )

      relative_filename = filename.relative_path_from(env[:context].output_dir)
      env[:before] << "![Screenshot of #{driver.current_url}](#{relative_filename})"
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
