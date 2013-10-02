require 'fileutils'

require 'docdown/version'

module Docdown
  extend self

  CODE_COMMAND_LOOKUP = {}

  def code_command_from_keyword(keyword, *args)
    cc = code_command(keyword).new(*args)
    cc.keyword = keyword
    cc
  end

  def code_command(keyword)
    CODE_COMMAND_LOOKUP[:"#{keyword}"]
  end

  def register_code_command(keyword, klass)
    CODE_COMMAND_LOOKUP[keyword] = klass
  end

  def configure(&block)
    yield self
  end

end

require 'docdown/parser'
require 'docdown/code_command'
