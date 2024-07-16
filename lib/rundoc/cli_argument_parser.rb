# frozen_string_literal: true

require "pathname"
require "optparse"

module Rundoc
  # This class is responsible for parsing the command line arguments and generating a Cli instance
  #
  # Example:
  #
  #   cli = CLIArgumentParser.new(argv: ARGV).to_cli
  #   cli.call
  #
  class CLIArgumentParser
    attr_reader :io, :env, :exit_obj, :options, :argv

    def initialize(
      argv:,
      io: $stderr,
      env: ENV,
      exit_obj: Kernel
    )
      @io = io
      @env = env
      @argv = argv
      @options = {}
      @exit_obj = exit_obj
    end

    def call
      source_file = argv.first
      if source_file.nil? || source_file == "help"
        parser.parse! ["--help"]
        return
      else
        parser.parse! argv
        return if options[:exit]
      end

      source_path = Pathname(source_file)
      if !source_path.exist?
        @io.puts "No such file `#{source_path.expand_path}`"
        exit_obj.exit(1)
        return
      elsif !source_path.file?
        @io.puts "Path is not a file. Expected `#{source_path.expand_path}` to be a file, but it was not."
        exit_obj.exit(1)
        return
      end

      options[:io] = io
      options[:source_path] = source_path

      self
    end

    private def parser
      @parser ||= OptionParser.new do |opts|
        opts.banner = <<~EOF
          Usage: $ rundoc [options] <path/to/RUNDOC.md>

          Reads a custom markdown file and executes the code blocks within it to produce a tutorial with real world outputs embedded.

          Produces:

            - A directory with any generated files
            - A #{CLI::DEFAULTS::OUTPUT_FILENAME} file with the generated output
            - A screenshots directory with any screenshots taken

          ## Example

          A rundoc file:

            ~$ cat path/to/RUNDOC.md
            ```
            :::>> $ echo "hello world"
            :::>> $ touch grass.txt
            ```

          Is executed with the rundoc command

            ~$ rundoc path/to/RUNDOC.md
            # ...

          Produces files on disk:

            ~$ ls path/to/#{CLI::DEFAULTS::ON_SUCCESS_DIR}
            #{CLI::DEFAULTS::OUTPUT_FILENAME}
            grass.txt

          And replaces the rundoc syntax with the result of the real output:

            ~$ cat path/to/#{CLI::DEFAULTS::ON_SUCCESS_DIR}/#{CLI::DEFAULTS::OUTPUT_FILENAME}
            ```
            $ echo "hello world"
            hello world
            $ touch grass.txt
            ```

          ## Options

          > Note: Current working directory is abbreviated CWD

        EOF

        opts.on("--help", "Prints this help output.") do |_|
          @io.puts opts
          options[:exit] = true
          @exit_obj.exit(0)
        end

        opts.on("--on-success-dir <dir>", "Success dir, relative to CWD. i.e. `<rundoc.md/dir>/#{CLI::DEFAULTS::ON_SUCCESS_DIR}/`.") do |v|
          options[:on_success_dir] = v
        end

        opts.on("--on-failure-dir <dir>", "Failure dir, relative to CWD i.e. `<rundoc.md/dir>/#{CLI::DEFAULTS::ON_FAILURE_DIR}/`.") do |v|
          options[:on_failure_dir] = v
        end

        opts.on("--dotenv-path <path>", "Environment variable file, relative to CWD. i.e. `<rundoc.md/dir>/.env`.") do |v|
          options[:dotenv_path] = v
        end

        opts.on("--output-filename <name>", "Name of the generated markdown file i.e. `#{CLI::DEFAULTS::OUTPUT_FILENAME}`.") do |v|
          options[:output_filename] = v
        end

        opts.on("--screenshots-dirname <name>", "Name of screenshot dir i.e. `#{CLI::DEFAULTS::SCREENSHOTS_DIR}`.") do |v|
          options[:screenshots_dirname] = v
        end

        opts.on("--force", "Delete contents of the success/failure dirs even if they're not empty.") do |v|
          options[:force] = v
        end
      end
    end
  end
end

require_relative "cli"
