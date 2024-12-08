require "fileutils"
require "pathname"
require "rundoc/version"

module Rundoc
  extend self

  def code_command_from_keyword(keyword, args)
    klass = code_command(keyword.to_sym) || Rundoc::CodeCommand::NoSuchCommand
    original_args = args.dup
    if args.is_a?(Array) && args.last.is_a?(Hash)
      kwargs = args.pop
      cc = klass.new(*args, **kwargs)
    elsif args.is_a?(Hash)
      cc = klass.new(**args)
    else
      cc = klass.new(*args)
    end

    cc.original_args = original_args
    cc.keyword = keyword
    cc
  rescue ArgumentError => e
    raise ArgumentError, "Wrong method signature for #{keyword} with arguments: #{original_args.inspect}, error:\n #{e.message}"
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

  def run_after_build(context)
    @after_build_block ||= []
    @after_build_block.each { |block| block.call(context) }
  end

  def after_build(&block)
    @after_build_block ||= []
    @after_build_block << block
  end

  def config
    yield self
  end

  def filter_sensitive(sensitive)
    raise "Expecting #{sensitive} to be a hash" unless sensitive.is_a?(Hash)
    @sensitive ||= {}
    @sensitive.merge!(sensitive)
  end

  def sanitize!(doc)
    return doc if @sensitive.nil?
    @sensitive.each do |sensitive, replace|
      doc.gsub!(sensitive.to_s, replace)
    end
    doc
  end

  attr_reader :project_root

  def project_root=(root)
    raise <<~MSG
      Setting Rundoc.project_root is now a no-op

      If you want to manipulate the directory structure, use `Rundoc.after_build` instead.
    MSG
  end
end

require "rundoc/parser"
require "rundoc/fenced_code_block"
require "rundoc/code_command"
require "rundoc/peg_parser"
require "rundoc/cli_argument_parser"
