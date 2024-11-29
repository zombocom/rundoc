require "shellwords"
require "timeout"
require "fileutils"

class Rundoc::CodeCommand::Background
  # This class is responsible for running processes in the background
  #
  # By default it logs output to a file. This can be used to "wait" for a
  # specific output before continuing:
  #
  #   server = ProcessSpawn("rails server")
  #   server.wait("Use Ctrl-C to stop")
  #
  # The process can be queried for it's status to check if it is still booted or not.
  # the process can also be manually stopped:
  #
  #   server = ProcessSpawn("rails server")
  #   server.alive? # => true
  #   server.stop
  #   server.alive? # => false
  #
  # There are class level methods that can be used to "name" and record
  # background processes. They can be used like this:
  #
  #   server = ProcessSpawn("rails server")
  #   ProcessSpawn.add("muh_server", server)
  #   ProcessSpawn.find("muh_server") # => <# ProcessSpawn instance >
  #   ProcessSpawn.find("foo") # => RuntimeError "Could not find task with name 'foo', ..."
  class ProcessSpawn
    class << self
      attr_reader :tasks
    end

    @tasks = {}
    def self.add(name, value)
      raise "Task named #{name.inspect} is already started, choose a different name" if @tasks[name]
      @tasks[name] = value
    end

    def self.find(name)
      raise "Could not find task with name #{name.inspect}, known task names: #{@tasks.keys.inspect}" unless @tasks[name]
      @tasks[name]
    end

    attr_reader :log, :pid, :command

    def initialize(command, timeout: 5, log: Tempfile.new("log"), out: "2>&1")
      @command = command
      @timeout_value = timeout
      @log_reference = log # https://twitter.com/schneems/status/1285289971083907075

      @log = Pathname.new(log)
      @log.dirname.mkpath
      FileUtils.touch(@log)
      @pipe_output, @pipe_input = IO.pipe

      @command = "/usr/bin/env bash -c #{@command.shellescape} >> #{@log} #{out}"
      @pid = nil
    end

    # Wait until a given string is found in the logs
    #
    # If the string is not found within the timeout, a Timeout::Error is raised
    #
    # Caution: The logs will not be cleared before waiting, so if the string is
    # already present from a prior operation, then it will not wait at all.
    #
    # To ensure you're waiting for a brand new string, call `log.truncate(0)` first.
    # which is accessible via `:::-- background.log.clear` in rundoc syntax.
    #
    # @param wait_value [String] the string to wait for
    # @param timeout_value [Integer] the number of seconds to wait before raising a Timeout::Error
    # @param file [Pathname] the file to read from, default is the log file
    def wait(wait_value = nil, timeout_value = @timeout_value, file: @log)
      call
      return unless wait_value

      Timeout.timeout(Integer(timeout_value)) do
        until file.read.include?(wait_value)
          sleep 0.01
        end
      end
    rescue Timeout::Error
      raise "Timeout (#{timeout_value}s) waiting for #{@command.inspect} to find a match using #{wait_value.inspect} in \n'#{log.read}'"
    end

    def alive?
      return false unless @pid
      Process.kill(0, @pid)
    rescue Errno::ESRCH, Errno::EPERM
      false
    end

    # Writes the contents along with an optional ending character to the STDIN of the backtround process
    #
    # @param contents [String] the contents to write to the STDIN of the background process
    # @param ending [String] an optional string to append to the contents before writing default is a newline
    #                if you don't want an ending, pass `""`
    # @param timeout [Integer] the number of seconds to wait before raising a Timeout::Error when writing to STDIN
    #                or waiting for a string to appear in the logs. That means that the process can wait for a maximum
    #                of `timeout * 2` seconds before raising a Timeout::Error.
    # @param wait [String] the string to wait for in the logs before continuing. There's a race condition
    #             if the process is in the middle of printing out something to the logs, then the output
    #             you're waiting form might not come as a result of the stdin_write.
    def stdin_write(contents, ending: $/, timeout: timeout_value, wait: nil)
      log_file = File.new(@log)
      before_write_bytes = log_file.size
      begin
        Timeout.timeout(Integer(timeout)) do
          @pipe_input.print(contents + ending)
          @pipe_input.flush
        end
      rescue Timeout::Error
        raise "Timeout (#{timeout}s) waiting to write #{contents} to stdin. Log contents:\n'#{log.read}'"
      end

      # Ignore bytes written before we sent the STDIN message
      log_file.seek(before_write_bytes)
      wait(wait, timeout, file: log_file)
      contents
    end

    def stop
      return unless alive?
      @pipe_input.close
      Process.kill("TERM", -Process.getpgid(@pid))
      Process.wait(@pid)
    end

    def check_alive!
      raise "#{@original_command} has exited unexpectedly: #{@log.read}" unless alive?
    end

    private def call
      @pid ||= Process.spawn(@command, pgroup: true, in: @pipe_output)
    end
  end
end
