class Rundoc::CodeCommand::FileCommand
  class Append < Rundoc::CodeCommand
    include FileUtil

    def initialize(filename)
      @filename, line = filename.split('#')
      if line
        @line_number = Integer(line)
      else
        @line_number = nil
      end
    end

    def to_md(env)
      return unless render_command?

      raise "must call write in its own code section" unless env[:commands].empty?
      before = env[:before]
      if @line_number
        env[:before] = "In file `#{filename}`, on line #{@line_number} add:\n\n#{before}"
      else
        env[:before] = "At the end of `#{filename}` add:\n\n#{before}"
      end
      nil
    end

    def last_char_of(string)
      string[-1,1]
    end

    def ends_in_newline?(string)
      last_char_of(string) == "\n"
    end

    def concat_with_newline(str1, str2)
      result = ""
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
      doc = result.flatten.join("")
    end

    def call(env = {})
      mkdir_p
      doc = File.read(filename)
      if @line_number
        puts "Writing to: '#{filename}' line #{@line_number} with: #{contents.inspect}"
        doc = insert_contents_into_at_line(doc)
      else
        puts "Appending to file: '#{filename}' with: #{contents.inspect}"
        doc = concat_with_newline(doc, contents)
      end

      File.open(filename, "w") do |f|
        f.write(doc)
      end
      contents
    end
  end
end


Rundoc.register_code_command(:'file.append',  Rundoc::CodeCommand::FileCommand::Append)
