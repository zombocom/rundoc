module Docdown
  class Parser
    class ParseError < StandardError
      def initialize(options = {})
        keyword     = options[:keyword]
        command     = options[:command]
        line_number = options[:line_number]
        block       = options[:block].lines.map do |line|
          if line == command
            "    > #{line}"
          else
            "      #{line}"
          end
        end.join("")

        msg =  "Error parsing (line:#{line_number}):\n"
        msg << ">  '#{command.strip}'\n"
        msg << "No such registered command: '#{keyword}'\n"
        msg << "registered commands: #{Docdown.known_commands.inspect}\n\n"
        msg << block
        msg << "\n"
        super msg
      end

    end

    DEFAULT_KEYWORD    = ":::"
    INDENT_BLOCK       = '(?<before_indent>(^\s*$\n|\A)(^(?:[ ]{4}|\t))(?<indent_contents>.*)(?<after_indent>[^\s].*$\n?(?:(?:^\s*$\n?)*^(?:[ ]{4}|\t).*[^\s].*$\n?)*))'
    GITHUB_BLOCK       = '^(?<fence>(?<fence_char>~|`){3,})\s*?(?<lang>\w+)?\s*?\n(?<contents>.*?)^\g<fence>\g<fence_char>*\s*?\n'
    CODEBLOCK_REGEX    = /(#{GITHUB_BLOCK})/m
    COMMAND_REGEX      = ->(keyword) {
                             /^#{keyword}(?<tag>(\s|=|-)?)\s*(?<command>(\S)+)\s+(?<statement>.*)$/
                            }

    attr_reader :contents, :keyword, :stack

    def initialize(contents, options = {})
      @contents = contents
      @original = contents.dup
      @keyword  = options[:keyword] || DEFAULT_KEYWORD
      @stack    = []
      partition
    end


    def to_md
      @stack.map do |s|
        if s.respond_to?(:render)
          s.render
        else
          s
        end
      end.join("")
    end

    # split into [before_code, code, after_code], process code, and re-run until tail is empty
    def partition
      until contents.empty?
        head, code, tail = contents.partition(CODEBLOCK_REGEX)
        @stack << head        unless head.empty?
        add_fenced_code(code) unless code.empty?
        @contents = tail
      end
    end

    def add_fenced_code(fenced_code_str)
      fenced_code_str.match(CODEBLOCK_REGEX) do |m|
        fence = m[:fence]
        lang  = m[:lang]
        code  = m[:contents]
        @stack << "#{fence}#{lang}\n"
        add_code_commands(code)
        @stack << "#{fence}\n"
      end
    end

    def add_match_to_code_commands(match, commands)
      command      = match[:command]
      tag          = match[:tag]
      statement    = match[:statement]

      code_command = Docdown.code_command_from_keyword(command, statement)

      case tag
      when /\-/
        code_command.hidden        = true
      when /\=/
        code_command.render_result = true
      when /\s/
        # default do nothing
      end

      @stack   << "\n" if commands.last.is_a?(Docdown::CodeCommand)
      @stack   << code_command
      commands << code_command
      code_command
    end

    def check_parse_error(command, code_block)
      return unless code_command = @stack.last
      return unless code_command.is_a?(Docdown::CodeCommands::NoSuchCommand)
      @original.lines.each_with_index do |line, index|
        next unless line == command
        raise ParseError.new(keyword:     code_command.keyword,
                             block:       code_block,
                             command:     command,
                             line_number: index.next)
      end
    end

    def add_code_commands(code)
      commands = []
      code.lines.each do |line|
        if match = line.match(command_regex)
          add_match_to_code_commands(match, commands)
          check_parse_error(line, code)
        else
          unless commands.empty?
            commands.last << line
            next
          end
          @stack << line
        end
      end
    end

    def contents_to_array
      partition
    end

    def command_regex
      COMMAND_REGEX.call(keyword)
    end
  end
end


# convert string of markdown to array of strings and code_commands