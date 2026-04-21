# frozen_string_literal: true

module Rundoc
  # Generic CodeCommand class to be inherited
  #
  class CodeCommand
    attr_accessor :contents

    attr_reader :io

    def initialize(render_command:, render_result:, io:, contents: nil)
      @io = io
      @render_command = render_command
      @render_result = render_result
      @contents = contents.dup if contents && !contents.empty?
    end

    def render_result?
      @render_result
    end

    def render_command?
      @render_command
    end

    def hidden?
      !render_command? && !render_result?
    end

    def not_hidden?
      !hidden?
    end

    def push(contents)
      @contents ||= +""
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

require "rundoc/code_command/deferred"
require "rundoc/code_command/bash"
require "rundoc/code_command/pipe"
require "rundoc/code_command/write"
require "rundoc/code_command/rundoc_command"
require "rundoc/code_command/no_such_command"
require "rundoc/code_command/raw"
require "rundoc/code_command/background"
require "rundoc/code_command/website"
require "rundoc/code_command/print/text"
require "rundoc/code_command/print/erb"
require "rundoc/code_command/pre/erb"
