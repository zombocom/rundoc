require 'fileutils'

require 'rundoc/version'

module Rundoc
  extend self

  def code_command_from_keyword(keyword, args)
    klass      = code_command(keyword.to_sym) || Rundoc::CodeCommand::NoSuchCommand
    cc         = klass.new(args)
    cc.keyword = keyword
    cc
  end

  def code_lookup
    @code_lookup ||= {}
  end

  def code_command(keyword)
    code_lookup[:"#{keyword}"]
  end

  def known_commands
    code_lookup.keys
  end

  def register_code_command(keyword, klass)
    code_lookup[keyword] = klass
  end

  def configure(&block)
    yield self
  end

  def run_after_build
    @after_build_block.call if @after_build_block
  end

  def after_build(&block)
    @after_build_block = block
  end

  def config
    yield self
  end

  def register_repl(*args, &block)
    ReplRunner.register_commands(*args, &block)
  end
end

require 'rundoc/parser'
require 'rundoc/code_section'
require 'rundoc/code_command'
