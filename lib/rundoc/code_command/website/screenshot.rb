class Rundoc::CodeCommand::Website
  class ScreenshotArgs
    attr_reader :name, :upload

    def initialize(name:, upload: false)
      @name = name
      @upload = upload
    end
  end

  class ScreenshotRunner < Rundoc::CodeCommand
    def initialize(user_args:, **)
      @name = user_args.name
      @upload = user_args.upload
      @driver = nil
      super(**)
    end

    def driver
      @driver ||= Rundoc::CodeCommand::Website::Driver.find(@name)
    end

    def to_md(env = {})
      ""
    end

    def call(env = {})
      io.puts "Taking screenshot: #{driver.current_url}"
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
Rundoc.register_code_command(keyword: :"website.screenshot", args_klass: Rundoc::CodeCommand::Website::ScreenshotArgs, runner_klass: Rundoc::CodeCommand::Website::ScreenshotRunner)
