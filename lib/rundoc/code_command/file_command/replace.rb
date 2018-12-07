class Rundoc::CodeCommand::FileCommand
  class Replace < Append
    include FileUtil

    def initialize(filename)
      @filename, lines = filename.split('#')
      if lines
        @line_number = Integer(lines.split(',')[0])
        @end_line_number = Integer(lines.split(',')[0])
      else
        raise "start and end line numbers are required in the form #S,E"
      end
    end

    def insert_contents_into_at_line(doc)
      lines = doc.lines
      raise "Expected #{filename} to have at least #{@end_line_number} but only has #{lines.count}" if lines.count < @end_line_number
      result = []
      lines.each_with_index do |line, index|
        line_number = index.next
        if line_number == @line_number
          result << contents
          result << "\n" unless ends_in_newline?(contents)
        elsif line_number < @line_number || line_number > @end_line_number
          result << line
        end
      end
      doc = result.flatten.join("")
    end
  end
end


Rundoc.register_code_command(:'file.replace',  Rundoc::CodeCommand::FileCommand::Replace)
