module Docdown
  class CodeCommand
    attr_accessor :hidden, :render_result, :command, :contents, :keyword
    alias :hidden? :hidden
    alias :render_result? :render_result

    def initialize(arg)
    end

    def push(contents)
      @contents ||= ""
      @contents << contents
    end
    alias :<< :push

    # executes command to build project
    def call(env = {})
      raise "not implemented"
    end
  end
end

require 'docdown/code_commands/bash'
require 'docdown/code_commands/pipe'
require 'docdown/code_commands/write'
require 'docdown/code_commands/repl'
require 'docdown/code_commands/no_such_command'