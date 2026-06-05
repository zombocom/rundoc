# frozen_string_literal: true

class Rundoc::CodeCommand::FileCommand
  class AppendArgs
    attr_reader :filename, :match, :match_first

    def initialize(filename, match: nil, match_first: nil)
      @filename = filename
      @match = match
      @match_first = match_first

      if @match && @match_first
        raise "Cannot use both match: and match_first:"
      end

      if (@match || @match_first)&.empty?
        raise "match value cannot be empty"
      end
    end
  end

  class AppendRunner
    NEWLINE = Rundoc::CodeCommand::WriteRunner::NEWLINE

    include Rundoc::CodeCommand::FileUtil

    attr_reader :io, :contents

    def initialize(user_args:, render_command:, render_result:, io:, contents: nil)
      @match = user_args.match
      @match_first = user_args.match_first

      @filename, line = user_args.filename.split("#")
      @line_number = if line
        Integer(line)
      end

      if match_string && @line_number
        raise "Cannot use both match: and #line_number"
      end

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
        "In file `#{filename}`, on line matching `#{match_string}`, add:"
      elsif @line_number
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

    def insert_contents_before_match(doc)
      lines = doc.lines
      matching_indices = lines.each_index.select { |i| lines[i].include?(match_string) }

      if matching_indices.empty?
        raise "Could not find match #{match_string.inspect} in #{filename}"
      end

      if @match && matching_indices.length != 1
        raise "Expected 1 match for #{match_string.inspect} in #{filename} but found #{matching_indices.length}. Use match_first: if multiple matches are expected."
      end

      target = matching_indices.first
      io.puts "Inserting at line #{target + 1} before #{match_string.inspect} in '#{filename}' with: #{contents.inspect}"
      result = []
      lines.each_with_index do |line, index|
        if index == target
          result << contents
          result << "\n" unless ends_in_newline?(contents)
        end
        result << line
      end
      result.join("")
    end

    def call(env = {})
      mkdir_p
      doc = File.read(filename)
      if match_string
        doc = insert_contents_before_match(doc)
      elsif @line_number
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
