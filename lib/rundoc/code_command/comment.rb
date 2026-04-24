# frozen_string_literal: true

class Rundoc::CodeCommand::CommentArgs
  def initialize(line = nil)
    @line = line
  end
end

class Rundoc::CodeCommand::CommentRunner
  def initialize(user_args:, render_command:, render_result:, io:, contents: nil)
  end

  def call(env = {})
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
