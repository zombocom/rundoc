module Rundoc
  # Represents a single rundoc file on disk,
  #
  # Each document contains one or more fenced code blocks.
  # Those are parsed as `FencedCodeBlock` instances and then
  # executed.
  class Document
    GITHUB_BLOCK = '^(?<fence>(?<fence_char>~|`){3,})\s*?(?<lang>\w+)?\s*?\n(?<contents>.*?)^\g<fence>\g<fence_char>*\s*?\n?'
    CODEBLOCK_REGEX = /(#{GITHUB_BLOCK})/m
    PARTIAL_RESULT = []

    attr_reader :contents, :stack, :context

    def initialize(contents, context:)
      @context = context
      @contents = contents
      @original = contents.dup
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
      unfinished = FencedCodeBlock.partial_result_to_doc
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
          @stack << FencedCodeBlock.new(
            fence: match[:fence],
            lang: match[:lang],
            code: match[:contents],
            context: context
          )
        end
        @contents = tail
      end
    end
  end
end
