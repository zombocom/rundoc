# frozen_string_literal: true

class Rundoc::CodeCommand::FileCommand
  class RemoveArgs
    attr_reader :filename

    def initialize(filename)
      @filename = filename
    end
  end

  class RemoveRunner < Rundoc::CodeCommand
    # Newlines are stripped and re-added, this tells the project that
    # we're intentionally wanting an extra newline
    NEWLINE = Object.new
    def NEWLINE.to_s
      ""
    end

    def NEWLINE.empty?
      false
    end
    include FileUtil

    def initialize(user_args:, **)
      @filename = user_args.filename
      super(**)
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
