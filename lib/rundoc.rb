require 'fileutils'
require 'pathname'
require 'rundoc/version'

module Rundoc
  extend self

  def code_command_from_keyword(keyword, args)
    klass      = code_command(keyword.to_sym) || Rundoc::CodeCommand::NoSuchCommand
    cc         = klass.new(args)
    cc.keyword = keyword
    cc.original_args = args
    cc
  end

  def parser_options
    @parser_options ||= {}
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
    @after_build_block ||= []
    @after_build_block.each(&:call)
  end

  def after_build(&block)
    @after_build_block ||= []
    @after_build_block << block
  end

  def config
    yield self
  end

  def register_repl(*args, &block)
    ReplRunner.register_commands(*args, &block)
  end

  def filter_sensitive(sensitive)
    raise "Expecting #{sensitive} to be a hash" unless sensitive.is_a?(Hash)
    @sensitive ||= {}
    @sensitive.merge!(sensitive)
  end

  def sanitize(doc)
    return doc if @sensitive.nil?
    @sensitive.each do |sensitive, replace|
      doc.gsub!(sensitive.to_s, replace)
    end
    return doc
  end

  attr_accessor :project_root
end

require 'rundoc/parser'
require 'rundoc/code_section'
require 'rundoc/code_command'
require 'rundoc/peg_parser'
