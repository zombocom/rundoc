module Rundoc
  # Generic CodeCommand class to be inherited
  #
  class CodeCommand
    attr_accessor :render_result, :render_command,
                  :command, :contents, :keyword,
                  :original_args

    alias :render_result? :render_result
    alias :render_command? :render_command

    def initialize(arg)
    end

    def hidden?
      !render_command? && !render_result?
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
require 'rundoc/code_command/rundoc_command'
require 'rundoc/code_command/no_such_command'
