module Rundoc
  class CLI
    module DEFAULTS
      ON_FAILURE_DIR = # <path/to/rundoc.md/..> +
        "rundoc_failure"
      ON_SUCCESS_DIR = # <path/to/rundoc.md/..> +
        "rundoc_output"
      DOTENV_PATH = # <path/to/rundoc.md/..> +
        ".env"
      OUTPUT_FILENAME = "README.md"
      SCREENSHOTS_DIR = "screenshots"
    end

    attr_reader :io, :on_success_dir, :on_failure_dir, :dotenv_path, :cli_cmd, :cli_args, :force
    attr_reader :execution_context, :after_build_context

    def initialize(
      source_path:,
      io: $stderr,
      cli_cmd: $0,
      cli_args: $*,
      force: false,
      dotenv_path: nil,
      on_success_dir: nil,
      on_failure_dir: nil,
      output_filename: nil,
      screenshots_dir: nil
    )
      @io = io
      @force = force
      @cli_cmd = cli_cmd
      @cli_args = cli_args

      screenshots_dir = check_relative_path(screenshots_dir || DEFAULTS::SCREENSHOTS_DIR)
      output_filename = check_relative_path(output_filename || DEFAULTS::OUTPUT_FILENAME)

      @execution_context = Rundoc::Context::Execution.new(
        output_dir: Dir.mktmpdir,
        source_path: source_path,
        screenshots_dir: screenshots_dir
      )

      @after_build_context = Context::AfterBuild.new(
        output_dir: execution_context.output_dir,
        screenshots_dir: execution_context.screenshots_dir,
        output_markdown_path: @execution_context.output_dir.join(output_filename)
      )

      @dotenv_path = if dotenv_path
        Pathname(dotenv_path)
      else
        @execution_context.source_dir.join(DEFAULTS::DOTENV_PATH)
      end

      @on_success_dir = if on_success_dir
        Pathname(on_success_dir)
      else
        @execution_context.source_dir.join(DEFAULTS::ON_SUCCESS_DIR)
      end

      @on_failure_dir = if on_failure_dir
        Pathname(on_failure_dir)
      else
        @execution_context.source_dir.join(DEFAULTS::ON_FAILURE_DIR)
      end
    end

    def force?
      force
    end

    # Ensures that the value passed in cannot escape the current directory
    #
    # Examples:
    #
    # - `/tmp/whatever` is invalid
    # - `whatever/../..` is invalid
    #
    private def check_relative_path(path)
      path = Pathname(path)
      if path.absolute?
        raise "Path must be relative but it is not: #{path}"
      end

      if path.each_filename.any? { |part| part == ".." }
        raise "path cannot contain `..` but it does: #{path}"
      end
      path
    end

    def load_dotenv
      if File.exist?(dotenv_path)
        io.puts("Found .env file #{dotenv_path}, loading")
        require "dotenv"
        Dotenv.load(dotenv_path)
        ENV["AWS_REGION"] ||= ENV["BUCKETEER_AWS_REGION"]
        ENV["AWS_BUCKET_NAME"] ||= ENV["BUCKETEER_BUCKET_NAME"]
        ENV["AWS_ACCESS_KEY_ID"] ||= ENV["BUCKETEER_AWS_ACCESS_KEY_ID"]
        ENV["AWS_SECRET_ACCESS_KEY"] ||= ENV["BUCKETEER_AWS_SECRET_ACCESS_KEY"]
      else
        io.puts("## No .env file found #{dotenv_path}, skipping dotenv loading")
      end
    end

    def prepend_cli_banner(contents)
      <<~HEREDOC
        <!-- STOP
          This file was generated by a rundoc script, do not modify it.

          Instead modify the rundoc script and re-run it.

          Command: #{cli_cmd} #{cli_args.join(" ")}
        STOP -->
        #{contents}
      HEREDOC
    end

    def check_directories_empty!
      [on_success_dir, on_failure_dir].each do |dir|
        dir.mkpath

        next if Dir.empty?(dir)

        if force?
          io.puts "## WARNING: #{dir} is not empty, it may be cleared due to running with the `--force` flag"
        else
          raise "## ABORTING: #{dir} is not empty, clear it or re-run with `--force` flag"
        end
      end
    end

    def call
      io.puts "## Running your docs"
      load_dotenv
      check_directories_empty!

      source_contents = execution_context.source_path.read
      if on_failure_dir.exist? && !Dir.empty?(on_failure_dir)
        io.puts "## Clearing on failure directory #{on_failure_dir}"
        FileUtils.remove_entry_secure(on_failure_dir)
      end

      io.puts "## Working dir is #{execution_context.output_dir}"
      Dir.chdir(execution_context.output_dir) do
        parser = Rundoc::Parser.new(
          source_contents,
          context: execution_context
        )
        output = begin
          parser.to_md
        rescue => e
          on_fail
          raise e
        end

        on_success(output)
      end
    ensure
      # Stop any hanging background tasks
      Rundoc::CodeCommand::Background::ProcessSpawn.tasks.each do |name, task|
        next unless task.alive?

        io.puts "Warning background task is still running, cleaning up: name: #{name}"
        task.stop
      end

      if execution_context.output_dir.exist?
        io.puts "## Cleaning working directory #{execution_context.output_dir}"
        FileUtils.remove_entry_secure(execution_context.output_dir) if on_failure_dir.exist?
      end
    end

    private def on_fail
      io.puts "## Failed, debug contents are in #{on_failure_dir}"
      on_failure_dir.mkpath

      copy_dir_contents(
        from: execution_context.output_dir,
        to: on_failure_dir
      )
    end

    private def on_success(output)
      io.puts "## Success! sanitizing output"
      Rundoc.sanitize!(output)
      output = prepend_cli_banner(output)

      io.puts "## Writing RUNdoc output to #{after_build_context.output_markdown_path}"
      after_build_context.output_markdown_path.write(output)

      begin
        io.puts "## Running after build scripts "
        Rundoc.run_after_build(after_build_context)
      rescue => e
        on_fail
        raise e
      end

      io.puts "## Saving to #{on_success_dir}"
      if on_success_dir.exist?
        FileUtils.remove_entry_secure(on_success_dir)
      end
      on_success_dir.mkpath

      FileUtils.cp_r(File.join(execution_context.output_dir, "."), on_success_dir)
      copy_dir_contents(
        from: execution_context.output_dir,
        to: on_success_dir
      )

      io.puts "## Finished"
    end

    def copy_dir_contents(from:, to:)
      # Cannot use Pathname.join(".")
      FileUtils.cp_r(File.join(from, "."), to)
    end
  end
end

require_relative "context/execution"
require_relative "context/after_build"
