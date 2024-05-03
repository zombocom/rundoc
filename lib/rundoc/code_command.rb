module Rundoc
  # Generic CodeCommand class to be inherited
  #
  class CodeCommand

    # Newlines are stripped and re-added, this tells the project that
    # we're intentionally wanting an extra newline
    NEWLINE = Object.new
    def NEWLINE.to_s
      ""
    end

    def NEWLINE.empty?
      false
    end

    attr_accessor :render_result, :render_command,
      :command, :contents, :keyword,
      :original_args

    alias_method :render_result?, :render_result
    alias_method :render_command?, :render_command

    def initialize(*args)
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
    alias_method :<<, :push

    # Executes command to build project
    # Is expected to return the result of the command
    def call(env = {})
      raise "not implemented on #{inspect}"
    end

    # the output of the command, i.e. `$ cat foo.txt`
    def to_md(env = {})
      raise "not implemented on #{inspect}"
    end
  end
end

require "rundoc/code_command/bash"
require "rundoc/code_command/pipe"
require "rundoc/code_command/write"
require "rundoc/code_command/rundoc_command"
require "rundoc/code_command/no_such_command"
require "rundoc/code_command/raw"
require "rundoc/code_command/background"
require "rundoc/code_command/website"
