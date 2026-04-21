# frozen_string_literal: true

class Rundoc::CodeCommand::FileCommand
  class AppendArgs
    attr_reader :filename

    def initialize(filename)
      @filename = filename
    end
  end

  class AppendRunner
    NEWLINE = Rundoc::CodeCommand::WriteRunner::NEWLINE

    include Rundoc::CodeCommand::FileUtil

    attr_reader :io, :contents

    def initialize(user_args:, render_command:, render_result:, io:, contents: nil, **)
      @filename, line = user_args.filename.split("#")
      @line_number = if line
        Integer(line)
      end
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
      return unless render_command?

      if env[:commands].any? { |c| c[:visibility].not_hidden? }
        raise "Must call append in its own code section"
      end

      env[:before] << if @line_number
        "In file `#{filename}`, on line #{@line_number} add:"
      else
        "At the end of `#{filename}` add:"
      end
      env[:before] << NEWLINE
      nil
    end

    def last_char_of(string)
      string[-1, 1]
    end

    def ends_in_newline?(string)
      last_char_of(string) == "\n"
    end

    def concat_with_newline(str1, str2)
      result = +""
      result << str1
      result << "\n" unless ends_in_newline?(result)
      result << str2
      result << "\n" unless ends_in_newline?(result)
      result
    end

    def insert_contents_into_at_line(doc)
      lines = doc.lines
      raise "Expected #{filename} to have at least #{@line_number} but only has #{lines.count}" if lines.count < @line_number
      result = []
      lines.each_with_index do |line, index|
        line_number = index.next
        if line_number == @line_number
          result << contents
          result << "\n" unless ends_in_newline?(contents)
        end
        result << line
      end
      result.flatten.join("")
    end

    def call(env = {})
      mkdir_p
      doc = File.read(filename)
      if @line_number
        io.puts "Writing to: '#{filename}' line #{@line_number} with: #{contents.inspect}"
        doc = insert_contents_into_at_line(doc)
      else
        io.puts "Appending to file: '#{filename}' with: #{contents.inspect}"
        doc = concat_with_newline(doc, contents)
      end

      File.write(filename, doc)
      contents
    end
  end
end

Rundoc.register_code_command(keyword: :"file.append", args_klass: Rundoc::CodeCommand::FileCommand::AppendArgs, runner_klass: Rundoc::CodeCommand::FileCommand::AppendRunner)
