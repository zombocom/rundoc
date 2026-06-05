# frozen_string_literal: true

class Rundoc::CodeCommand::FileCommand
  class InsertArgs
    attr_reader :filename, :match, :match_first, :line_number

    def initialize(filename, match: nil, match_first: nil)
      @filename, line = filename.split("#")
      @line_number = Integer(line) if line
      @match = match
      @match_first = match_first

      if @match && @match_first
        raise "Cannot use both match: and match_first:"
      end

      if (@match || @match_first)&.empty?
        raise "match value cannot be empty"
      end

      if match_string && @line_number
        raise "Cannot use both match: and #line_number"
      end
    end

    def match_string
      @match || @match_first
    end
  end

  class AppendRunner
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
        raise "Must call append in its own code section"
      end

      env[:before] << if match_string
        "In file `#{filename}`, after `#{match_string}`, add:"
      elsif @line_number
        "In file `#{filename}`, on line #{@line_number} add:"
      else
        "At the end of `#{filename}` add:"
      end
      env[:before] << NEWLINE
      nil
    end

    def concat_with_newline(str1, str2)
      result = +""
      result << str1
      result << "\n" unless str1.end_with?("\n")
      result << str2
      result << "\n" unless str2.end_with?("\n")
      result
    end

    def call(env = {})
      mkdir_p
      doc = File.read(filename)
      if match_string
        line = Rundoc::CodeCommand::FileUtil.resolve_match_line(
          doc: doc, match_str: match_string, filename: filename, unique: !!@match
        )
        line += 1
        io.puts "Inserting at line #{line} after #{match_string.inspect} in '#{filename}' with: #{contents.inspect}"
        doc = Rundoc::CodeCommand::FileUtil.insert_contents_at_line(
          doc: doc, line_number: line, contents: contents, filename: filename
        )
      elsif @line_number
        io.puts "Writing to: '#{filename}' line #{@line_number} with: #{contents.inspect}"
        doc = Rundoc::CodeCommand::FileUtil.insert_contents_at_line(
          doc: doc, line_number: @line_number, contents: contents, filename: filename
        )
      else
        io.puts "Appending to file: '#{filename}' with: #{contents.inspect}"
        doc = concat_with_newline(doc, contents)
      end

      File.write(filename, doc)
      contents
    end
  end
end

Rundoc.register_code_command(keyword: :"file.append", args_klass: Rundoc::CodeCommand::FileCommand::InsertArgs, runner_klass: Rundoc::CodeCommand::FileCommand::AppendRunner)
