require 'fileutils'

require 'docdown/version'

module Docdown
  extend self

  def code_command_from_keyword(keyword, *args)
    klass      = code_command(keyword.to_sym)
    cc         = klass.new(*args)
    cc.keyword = keyword
    cc
  end

  def code_lookup
    @code_lookup ||= {}
  end

  def code_command(keyword)
    code_lookup[:"#{keyword}"] || Docdown::CodeCommands::NoSuchCommand
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
end

require 'docdown/parser'
require 'docdown/code_command'
