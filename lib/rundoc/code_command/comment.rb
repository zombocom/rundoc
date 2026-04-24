# frozen_string_literal: true

class Rundoc::CodeCommand::CommentArgs
  attr_reader :line

  def initialize(line = nil)
    @line = line
  end
end

class Rundoc::CodeCommand::CommentRunner
  def initialize(user_args:, render_command:, render_result:, io:, contents: nil)
    @io = io
    @line = user_args&.line
    @contents = contents
  end

  def call(env = {})
    @io.puts "Skipping command (commented out): # #{@line}\n#{@contents}".strip
    ""
  end

  def to_md(env = {})
    ""
  end
end

Rundoc.register_code_command(
  keyword: :"#",
  args_klass: Rundoc::CodeCommand::CommentArgs,
  runner_klass: Rundoc::CodeCommand::CommentRunner,
  always_hidden: true
)
