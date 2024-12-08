module Rundoc
  # This poorly named class is responsible for taking in the raw markdown and running it
  #
  # It works by pulling out the code blocks (CodeSection), and putting them onto a stack.
  # It then executes each in turn and records the results.
  class Parser
    DEFAULT_KEYWORD = ":::"
    INDENT_BLOCK = '(?<before_indent>(^\s*$\n|\A)(^(?:[ ]{4}|\t))(?<indent_contents>.*)(?<after_indent>[^\s].*$\n?(?:(?:^\s*$\n?)*^(?:[ ]{4}|\t).*[^\s].*$\n?)*))'
    GITHUB_BLOCK = '^(?<fence>(?<fence_char>~|`){3,})\s*?(?<lang>\w+)?\s*?\n(?<contents>.*?)^\g<fence>\g<fence_char>*\s*?\n?'
    CODEBLOCK_REGEX = /(#{GITHUB_BLOCK})/m
    PARTIAL_RESULT = []

    attr_reader :contents, :keyword, :stack, :context

    def initialize(contents, context:, keyword: DEFAULT_KEYWORD)
      @context = context
      @contents = contents
      @original = contents.dup
      @keyword = keyword
      @stack = []
      partition
      PARTIAL_RESULT.clear
    end

    def to_md
      result = []
      @stack.each do |s|
        result << if s.respond_to?(:render)
          s.render
        else
          s
        end
        PARTIAL_RESULT.replace(result)
      end

      self.class.to_doc(result: result)
    rescue => e
      File.write("README.md", result.join(""))
      raise e
    end

    def self.partial_result_to_doc
      out = to_doc(result: PARTIAL_RESULT)
      unfinished = CodeSection.partial_result_to_doc
      out << unfinished if unfinished
      out
    end

    def self.to_doc(result:)
      result.join("")
    end

    # split into [before_code, code, after_code], process code, and re-run until tail is empty
    def partition
      until contents.empty?
        head, code, tail = contents.partition(CODEBLOCK_REGEX)
        @stack << head unless head.empty?
        unless code.empty?
          match = code.match(CODEBLOCK_REGEX)
          @stack << CodeSection.new(
            match,
            context: context
          )
        end
        @contents = tail
      end
    end
  end
end

# convert string of markdown to array of strings and code_command
