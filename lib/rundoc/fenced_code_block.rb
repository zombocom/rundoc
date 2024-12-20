# frozen_string_literal: true

module Rundoc
  # A code secttion respesents a block of fenced code
  #
  # A document can have multiple code sections
  class FencedCodeBlock
    AUTOGEN_WARNING = "\n<!-- STOP. This document is autogenerated. Do not manually modify. See the top of the doc for more details. -->"
    attr_accessor :fence, :lang, :code

    PARTIAL_RESULT = []
    PARTIAL_ENV = {}

    # Used for tests to inspect the command that was executed
    def executed_commands
      raise "Nothing executed" unless @env[:commands].any?

      @env[:commands].map { |c| c[:object] }
    end

    # @param fence [String] the fence used to start the code block like "```".
    # @param lang [String] any extra string after the fence like for example
    #        a fence of "```ruby" the lang would be "ruby".
    # @param code [String] the code block contents inside the fence.
    # @param context [Context::Execution] The details about where
    #        the code block came from.
    def initialize(fence:, lang:, code:, context:)
      @fence = fence
      @lang = lang
      @code = code
      @executed = false
      @env = {}
      @stack = []
      @context = context
      @rendered = ""
      self.class.parse_code_commands(@code).each do |code_command|
        @stack.unshift(code_command)
      end

      PARTIAL_RESULT.clear
      PARTIAL_ENV.clear
    end

    def call
      return self if @executed
      @executed = true

      result = []
      env = @env
      env[:commands] = []
      env[:fence_start] = "#{fence}#{lang}"
      env[:fence_end] = "#{fence}#{AUTOGEN_WARNING}"
      env[:before] = []
      env[:after] = []
      env[:context] = @context
      env[:stack] = @stack

      while (code_command = @stack.pop)
        code_output = code_command.call(env) || ""
        code_line = code_command.to_md(env) || ""
        result << code_line if code_command.render_command?
        result << code_output if code_command.render_result?

        PARTIAL_RESULT.replace(result)
        PARTIAL_ENV.replace(env)

        env[:commands] << {
          object: code_command,
          output: code_output,
          command: code_line
        }
      end

      if env[:commands].any? { |c| c[:object].not_hidden? }
        @rendered = self.class.to_doc(result: result, env: env)
      end
      self
    end

    def render
      call
      @rendered
    end

    def self.partial_result_to_doc
      to_doc(result: PARTIAL_RESULT, env: PARTIAL_ENV)
    end

    def self.to_doc(result:, env:)
      array = [env[:before]]

      result.flatten!
      result.compact!
      result.map! { |s| s.respond_to?(:rstrip) ? s.rstrip : s }
      result.reject!(&:empty?)
      result.map!(&:to_s)

      if !result.empty?
        array << env[:fence_start]
        array << result
        array << env[:fence_end]
      end
      array << env[:after]

      array.flatten!
      array.compact!
      array.map! { |s| s.respond_to?(:rstrip) ? s.rstrip : s }
      array.reject!(&:empty?)
      array.map!(&:to_s)

      array.join("\n") << "\n"
    end

    def self.parse_code_commands(code)
      parser = Rundoc::PegParser.new.code_block
      tree = parser.parse(code)
      commands = Rundoc::PegTransformer.new.apply(tree)
      commands = [commands] unless commands.is_a?(Array)
      commands
    rescue ::Parslet::ParseFailed => e
      raise "Could not compile code:\n#{code}\nReason: #{e.message}"
    end
  end
end
