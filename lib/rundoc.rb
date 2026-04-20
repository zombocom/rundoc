require "fileutils"
require "pathname"
require "rundoc/version"

module Rundoc
  extend self

  def code_command_from_keyword(keyword, args)
    args_klass = code_command(keyword.to_sym)
    original_args = args&.dup

    if args_klass
      runner_klass = user_args_runner[keyword]

      if args.is_a?(Array) && args.last.is_a?(Hash)
        kwargs = args.pop
        user_args = args_klass.new(*args, **kwargs)
      elsif args.is_a?(Hash)
        user_args = args_klass.new(**args)
      else
        user_args = args_klass.new(*args)
      end
    else
      runner_klass = Rundoc::CodeCommand::NoSuchCommand
      user_args = nil
    end

    deferred = CodeCommand::Deferred.new(
      args_instance: user_args,
      runner_klass: runner_klass
    )
    deferred.original_args = original_args
    deferred.keyword = keyword
    deferred
  rescue ArgumentError => e
    raise ArgumentError, "Wrong method signature for #{keyword} with arguments: #{original_args.inspect}, error:\n #{e.message}"
  end

  def user_code_runner_klass
    @user_code_runner_klass ||= {}
  end

  def parser_options
    @parser_options ||= {}
  end

  def user_args_runner
    @user_args_runner ||= {}
  end

  def user_args
    @user_args ||= {}
  end

  def code_command(keyword)
    user_args[:"#{keyword}"]
  end

  def known_commands
    user_args.keys
  end

  def register_code_command(keyword:, args_klass:, runner_klass:)
    user_args[keyword] = args_klass
    user_args_runner[keyword] = runner_klass
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

require "rundoc/document"
require "rundoc/fenced_code_block"
require "rundoc/code_command"
require "rundoc/peg_parser"
require "rundoc/cli_argument_parser"
