module Rundoc
  # holds code, parses and creates CodeCommand
  class CodeSection
    class ParseError < StandardError
      def initialize(options = {})
        keyword     = options[:keyword]
        command     = options[:command]
        line_number = options[:line_number]
        block = options[:block].lines.map do |line|
          if line == command
            "    > #{line}"
          else
            "      #{line}"
          end
        end.join("")

        msg =  "Error parsing (line:#{line_number}):\n"
        msg << ">  '#{command.strip}'\n"
        msg << "No such registered command: '#{keyword}'\n"
        msg << "registered commands: #{Rundoc.known_commands.inspect}\n\n"
        msg << block
        msg << "\n"
        super msg
      end
    end

    COMMAND_REGEX   = Rundoc::Parser::COMMAND_REGEX # todo: move whole thing
    attr_accessor :original, :fence, :lang, :code, :commands, :keyword

    def initialize(match, options = {})
      @original = match.to_s
      @commands = []
      @stack    = []
      @keyword  = options[:keyword] or raise "keyword is required"
      @fence    = match[:fence]
      @lang     = match[:lang]
      @code     = match[:contents]
      parse_code_command
    end

    def render
      result = []
      env = {}
      env[:commands] = []
      env[:before]   = "#{fence}#{lang}"
      env[:after]    = "#{fence}"

      @stack.each do |s|
        unless s.respond_to?(:call)
          result << s
          next
        end

        code_command = s
        code_output  = code_command.call(env)  || ""
        code_line    = code_command.to_md(env) || ""

        env[:commands] << { object: code_command, output: code_output, command: code_line}

        if code_command.render_result?
          result << [code_line, code_output]
        else
          result << code_line unless code_command.hidden?
        end
      end

      return "" if hidden?

      array = [env[:before], result, env[:after]]
      return array.flatten.compact.map(&:rstrip).reject(&:empty?).join("\n") << "\n"
    end

    # all of the commands are hidden
    def hidden?
      !not_hidden?
    end

    # one or more of the commands are not hidden
    def not_hidden?
      return true if commands.empty?
      commands.map(&:not_hidden?).detect {|c| c }
    end

    def command_regex
      COMMAND_REGEX.call(keyword)
    end

    def add_code(match, line)
      add_match_to_code_command(match, commands)
      check_parse_error(line, code)
    end

    def add_contents(line)
      if commands.empty?
        @stack << line
      else
        commands.last << line
      end
    end

    def parse_code_command
      code.lines.each do |line|
        if match = line.match(command_regex)
          add_code(match, line)
        else
          add_contents(line)
        end
      end
    end

    def add_match_to_code_command(match, commands)
      command      = match[:command]
      tag          = match[:tag]
      statement    = match[:statement]

      code_command = Rundoc.code_command_from_keyword(command, statement)

      case tag
      when /\-/
        code_command.hidden        = true
      when /\=/
        code_command.render_result = true
      when /\s/
        # default do nothing
      end

      @stack   << "\n" if commands.last.is_a?(Rundoc::CodeCommand)
      @stack   << code_command
      commands << code_command
      code_command
    end

    def check_parse_error(command, code_block)
      return unless code_command = @stack.last
      return unless code_command.is_a?(Rundoc::CodeCommand::NoSuchCommand)
      @original.lines.each_with_index do |line, index|
        next unless line == command
        raise ParseError.new(keyword:     code_command.keyword,
                             block:       code_block,
                             command:     command,
                             line_number: index.next)
      end
    end
  end
end