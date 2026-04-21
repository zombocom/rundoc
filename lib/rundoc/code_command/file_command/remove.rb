# frozen_string_literal: true

class Rundoc::CodeCommand::FileCommand
  class RemoveArgs
    attr_reader :filename

    def initialize(filename)
      @filename = filename
    end
  end

  class RemoveRunner
    NEWLINE = Object.new
    def NEWLINE.to_s
      ""
    end

    def NEWLINE.empty?
      false
    end
    include Rundoc::CodeCommand::FileUtil

    attr_reader :io, :contents

    def initialize(user_args:, render_command:, render_result:, io:, contents: nil, **)
      @filename = user_args.filename
      @io = io
      @render_command = render_command
      @render_result = render_result
      @contents = contents.dup if contents && !contents.empty?
    end

    def render_command?
      @render_command
    end

    def render_result?
      @render_result
    end

    def to_md(env)
      if env[:commands].any? { |c| c[:visibility].not_hidden? }
        raise "Must call remove in its own code section"
      end

      env[:before] << "In file `#{filename}` remove:"
      env[:before] << NEWLINE
      nil
    end

    def call(env = {})
      io.puts "Deleting '#{contents.strip}' from #{filename}"
      raise "#{filename} does not exist" unless File.exist?(filename)

      regex = /^\s*#{Regexp.quote(contents)}/
      doc = File.read(filename)
      doc.sub!(regex, "")

      File.write(filename, doc)
      contents
    end
  end
end

Rundoc.register_code_command(keyword: :"file.remove", args_klass: Rundoc::CodeCommand::FileCommand::RemoveArgs, runner_klass: Rundoc::CodeCommand::FileCommand::RemoveRunner)
