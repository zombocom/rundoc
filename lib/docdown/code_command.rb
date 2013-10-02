module Docdown
  class CodeCommand
    attr_accessor :hidden, :render_result, :command, :contents, :keyword

    alias :hidden? :hidden
    alias :render_result? :render_result

    # returns the markedup command
    # do not over-write unless you call super
    def render
      result = self.call
      return [to_md, result].join("\n")  if render_result?
      return "" if hidden?
      to_md
    end

    def push(contents)
      @contents ||= ""
      @contents << contents
    end
    alias :<< :push

    # executes command to build project
    def call
      raise "not implemented"
    end
  end
end

require 'docdown/code_commands/bash'
require 'docdown/code_commands/write'
require 'docdown/code_commands/repl'