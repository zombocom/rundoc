module Rundoc
  class Parser
    DEFAULT_KEYWORD    = ":::"
    INDENT_BLOCK       = '(?<before_indent>(^\s*$\n|\A)(^(?:[ ]{4}|\t))(?<indent_contents>.*)(?<after_indent>[^\s].*$\n?(?:(?:^\s*$\n?)*^(?:[ ]{4}|\t).*[^\s].*$\n?)*))'
    GITHUB_BLOCK       = '^(?<fence>(?<fence_char>~|`){3,})\s*?(?<lang>\w+)?\s*?\n(?<contents>.*?)^\g<fence>\g<fence_char>*\s*?\n'
    CODEBLOCK_REGEX    = /(#{GITHUB_BLOCK})/m
    COMMAND_REGEX      = ->(keyword) {
                             /^#{keyword}(?<tag>(\s|=|-|>)?(=|-|>)?)\s*(?<command>(\S)+)\s+(?<statement>.*)$/
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
      result = []
      @stack.each do |s|
        if s.respond_to?(:render)
          result << s.render
        else
          result << s
        end
      end
      return result.join("")
    rescue Exception => e
      File.open("README.md", "w") do |f|
        f.write(result.join(""))
      end
      raise e
    end

    # split into [before_code, code, after_code], process code, and re-run until tail is empty
    def partition
      until contents.empty?
        head, code, tail = contents.partition(CODEBLOCK_REGEX)
        @stack << head                  unless head.empty?
        unless code.empty?
          match = code.match(CODEBLOCK_REGEX)
          @stack << CodeSection.new(match, keyword: keyword)
        end
        @contents = tail
      end
    end
  end
end

# convert string of markdown to array of strings and code_command