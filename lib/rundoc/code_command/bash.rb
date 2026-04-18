class Rundoc::CodeCommand::BashArgs
  attr_reader :line

  def initialize(line)
    @line = line
  end
end

class Rundoc::CodeCommand::BashRunner < Rundoc::CodeCommand
  def initialize(user_args:)
    @line = user_args.line
    @contents = ""
    @delegate = case @line.split(" ").first.downcase
    when "cd"
      Cd.new(@line)
    else
      false
    end
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
    puts msg

    result = ""
    IO.popen(cmd, "w+") do |io|
      io << stdin if stdin
      io.close_write

      until io.eof?
        buffer = io.gets
        puts "    #{buffer}"

        result << sanitize_escape_chars(buffer)
      end
    end

    unless $?.success?
      raise "Command `#{@line}` exited with non zero status: #{result}" unless keyword.to_s.include?("fail")
    end
    result
  end
end

Rundoc.register_code_command(keyword: :bash, args_klass: Rundoc::CodeCommand::BashArgs, runner_klass: Rundoc::CodeCommand::BashRunner)
Rundoc.register_code_command(keyword: :"$", args_klass: Rundoc::CodeCommand::BashArgs, runner_klass: Rundoc::CodeCommand::BashRunner)
Rundoc.register_code_command(keyword: :"fail.$", args_klass: Rundoc::CodeCommand::BashArgs, runner_klass: Rundoc::CodeCommand::BashRunner)

require "rundoc/code_command/bash/cd"
