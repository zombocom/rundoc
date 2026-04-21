# frozen_string_literal: true

class Rundoc::CodeCommand::BashArgs
  attr_reader :line

  def initialize(line)
    @line = line
  end
end

class Rundoc::CodeCommand::BashRunner
  attr_reader :io, :contents

  def initialize(user_args:, render_command:, render_result:, io:, contents: nil)
    @io = io
    @contents = contents.dup if contents && !contents.empty?
    @line = user_args.line
    @delegate = case @line.split(" ").first.downcase
    when "cd"
      Cd.new(@line, io: io)
    else
      false
    end
  end

  def raise_on_error?
    true
  end

  def to_md(env = {})
    return @delegate.to_md(env) if @delegate

    "$ #{@line}"
  end

  def call(env = {})
    return @delegate.call(env) if @delegate

    shell(@line, @contents)
  end

  # markdown doesn't understand bash color codes
  def sanitize_escape_chars(input)
    input.gsub(/\e\[(\d+)m/, "")
  end

  def shell(cmd, stdin = nil)
    cmd = "(#{cmd}) 2>&1"
    msg = "Running: $ '#{cmd}'"
    msg << " with stdin: '#{stdin.inspect}'" if stdin && !stdin.empty?
    io.puts msg

    result = +""
    IO.popen(cmd, "w+") do |pipe|
      pipe << stdin if stdin
      pipe.close_write

      until pipe.eof?
        buffer = pipe.gets
        io.puts "    #{buffer}"

        result << sanitize_escape_chars(buffer)
      end
    end

    if raise_on_error? && !$?.success?
      raise "Command `#{@line}` exited with non zero status: #{result}"
    end
    result
  end
end

class Rundoc::CodeCommand::BashRunnerFailOk < Rundoc::CodeCommand::BashRunner
  def raise_on_error?
    false
  end
end

Rundoc.register_code_command(keyword: :bash, args_klass: Rundoc::CodeCommand::BashArgs, runner_klass: Rundoc::CodeCommand::BashRunner)
Rundoc.register_code_command(keyword: :"$", args_klass: Rundoc::CodeCommand::BashArgs, runner_klass: Rundoc::CodeCommand::BashRunner)
Rundoc.register_code_command(
  keyword: :"fail.$",
  args_klass: Rundoc::CodeCommand::BashArgs,
  runner_klass: Rundoc::CodeCommand::BashRunnerFailOk
)

require "rundoc/code_command/bash/cd"
