module Rundoc
  class CodeCommand
    attr_accessor :hidden, :render_result, :command, :contents, :keyword
    alias :hidden? :hidden
    alias :render_result? :render_result

    def initialize(arg)
    end

    def not_hidden?
      !hidden?
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

require 'rundoc/code_command/bash'
require 'rundoc/code_command/pipe'
require 'rundoc/code_command/write'
require 'rundoc/code_command/repl'
require 'rundoc/code_command/no_such_command'