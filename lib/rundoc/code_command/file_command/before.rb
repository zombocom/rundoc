# frozen_string_literal: true

class Rundoc::CodeCommand::FileCommand
  class BeforeRunner
    NEWLINE = Rundoc::CodeCommand::WriteRunner::NEWLINE

    include Rundoc::CodeCommand::FileUtil

    attr_reader :io, :contents

    def initialize(user_args:, render_command:, render_result:, io:, contents: nil)
      @filename = user_args.filename
      @match = user_args.match
      @match_first = user_args.match_first
      @line_number = user_args.line_number
      @io = io
      @render_command = render_command
      @contents = contents.dup if contents && !contents.empty?
    end

    def match_string
      @match || @match_first
    end

    def render_command?
      @render_command
    end

    def to_md(env)
      return unless render_command?

      if env[:commands].any? { |c| c[:visibility].not_hidden? }
        raise "Must call file.before in its own code section"
      end

      env[:before] << if match_string
        "In file `#{filename}`, before `#{match_string}`, add:"
      elsif @line_number
        "In file `#{filename}`, before line #{@line_number}, add:"
      else
        "At the beginning of `#{filename}` add:"
      end
      env[:before] << NEWLINE
      nil
    end

    def call(env = {})
      mkdir_p
      doc = File.read(filename)
      if match_string
        line = Rundoc::CodeCommand::FileUtil.resolve_match_line(
          doc: doc, match_str: match_string, filename: filename, unique: !!@match
        )
        io.puts "Inserting at line #{line} before #{match_string.inspect} in '#{filename}' with: #{contents.inspect}"
      elsif @line_number
        line = @line_number
        io.puts "Writing to: '#{filename}' before line #{line} with: #{contents.inspect}"
      else
        line = 1
        io.puts "Prepending to file: '#{filename}' with: #{contents.inspect}"
      end
      doc = Rundoc::CodeCommand::FileUtil.insert_contents_at_line(
        doc: doc, line_number: line, contents: contents, filename: filename
      )
      File.write(filename, doc)
      contents
    end
  end
end

Rundoc.register_code_command(keyword: :"file.before", args_klass: Rundoc::CodeCommand::FileCommand::InsertArgs, runner_klass: Rundoc::CodeCommand::FileCommand::BeforeRunner)
