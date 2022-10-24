module Rundoc
  # holds code, parses and creates CodeCommand
  class CodeSection
    class ParseError < StandardError
      def initialize(options = {})
        keyword = options[:keyword]
        command = options[:command]
        line_number = options[:line_number]
        block = options[:block].lines.map do |line|
          if line == command
            "    > #{line}"
          else
            "      #{line}"
          end
        end.join("")

        msg = "Error parsing (line:#{line_number}):\n"
        msg << ">  '#{command.strip}'\n"
        msg << "No such registered command: '#{keyword}'\n"
        msg << "registered commands: #{Rundoc.known_commands.inspect}\n\n"
        msg << block
        msg << "\n"
        super msg
      end
    end

    COMMAND_REGEX = Rundoc::Parser::COMMAND_REGEX # todo: move whole thing
    attr_accessor :original, :fence, :lang, :code, :commands, :keyword

    def initialize(match, options = {})
      @original = match.to_s
      @commands = []
      @stack = []
      @keyword = options[:keyword] or raise "keyword is required"
      @document_path = options[:document_path]
      @fence = match[:fence]
      @lang = match[:lang]
      @code = match[:contents]
      parse_code_command
    end

    def render
      result = []
      env = {}
      env[:commands] = []
      env[:before] = +"#{fence}#{lang}"
      env[:after] = String.new(fence)
      env[:document_path] = @document_path

      @stack.each do |s|
        unless s.respond_to?(:call)
          result << s
          next
        end

        code_command = s
        code_output = code_command.call(env) || ""
        code_line = code_command.to_md(env) || ""

        env[:commands] << {object: code_command, output: code_output, command: code_line}

        tmp_result = []
        tmp_result << code_line if code_command.render_command?
        tmp_result << code_output if code_command.render_result?

        result << tmp_result unless code_command.hidden?
      end

      return env[:replace] if env[:replace]

      return "" if hidden?

      array = [env[:before], result, env[:after]]
      array.flatten!
      array.compact!
      array.map!(&:rstrip)
      array.reject!(&:empty?)

      array.join("\n") << "\n"
    end

    # all of the commands are hidden
    def hidden?
      !not_hidden?
    end

    # one or more of the commands are not hidden
    def not_hidden?
      return true if commands.empty?
      commands.map(&:not_hidden?).detect { |c| c }
    end

    def parse_code_command
      parser = Rundoc::PegParser.new.code_block
      tree = parser.parse(@code)
      actual = Rundoc::PegTransformer.new.apply(tree)
      actual = [actual] unless actual.is_a?(Array)
      actual.each do |code_command|
        @stack << "\n" if commands.last.is_a?(Rundoc::CodeCommand)
        @stack << code_command
        commands << code_command
      end
    rescue ::Parslet::ParseFailed => e
      raise "Could not compile code:\n#{@code}\nReason: #{e.message}"
    end

    # def check_parse_error(command, code_block)
    #   return unless code_command = @stack.last
    #   return unless code_command.is_a?(Rundoc::CodeCommand::NoSuchCommand)
    #   @original.lines.each_with_index do |line, index|
    #     next unless line == command
    #     raise ParseError.new(keyword:     code_command.keyword,
    #                          block:       code_block,
    #                          command:     command,
    #                          line_number: index.next)
    #   end
    # end
  end
end
