# frozen_string_literal: true

require "erb"

class EmptyBinding
  def self.create
    new.empty_binding
  end

  def empty_binding
    binding
  end
end

module Rundoc::CodeCommand
  RUNDOC_ERB_BINDINGS = Hash.new { |h, k| h[k] = EmptyBinding.create }
  RUNDOC_DEFAULT_ERB_BINDING = "default"
end
