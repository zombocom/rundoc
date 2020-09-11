class Rundoc::CodeCommand::Bash < Rundoc::CodeCommand

  # line = "cd ..""
  # line = "pwd"
  # line = "ls"
  def initialize(line)
    @line     = line
    @contents = ""
    @delegate = case @line.split(' ').first.downcase
    when 'cd'
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
    input.gsub(/\e\[(\d+)m/, '')
  end

  def shell(cmd, stdin = nil)
    cmd = "(#{cmd}) 2>&1"
    msg  = "Running: $ '#{cmd}'"
    msg  << " with stdin: '#{stdin.inspect}'" if stdin && !stdin.empty?
    puts msg

    result = ""
    IO.popen(cmd, "w+") do |io|
      io << stdin if stdin
      io.close_write
      result = sanitize_escape_chars io.read
    end
    unless $?.success?
      raise "Command `#{@line}` exited with non zero status: #{result}" unless keyword.to_s.include?("fail")
    end
    return result
  end
end


Rundoc.register_code_command(:bash, Rundoc::CodeCommand::Bash)
Rundoc.register_code_command(:'$',  Rundoc::CodeCommand::Bash)
Rundoc.register_code_command(:'fail.$',  Rundoc::CodeCommand::Bash)

require 'rundoc/code_command/bash/cd'
