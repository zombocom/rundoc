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

  def shell(cmd, stdin = nil)
    msg  = "running: $ '#{cmd}'"
    msg  << " with stdin: #{stdin}" if stdin && !stdin.empty?
    puts msg

    result = ""
    IO.popen("#{cmd} 2>&1", "w+") do |io|
      io << stdin if stdin
      io.close_write
      result = io.read
    end
    raise "Command #{@line} exited with non zero status" unless $?.success?
    return result
  end
end


Rundoc.register_code_command(:bash, Rundoc::CodeCommand::Bash)
Rundoc.register_code_command(:'$',  Rundoc::CodeCommand::Bash)

require 'rundoc/code_command/bash/cd'