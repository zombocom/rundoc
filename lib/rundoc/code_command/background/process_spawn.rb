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

    attr_reader :log, :pid

    def initialize(command, timeout: 5, log: Tempfile.new("log"), out: "2>&1")
      @command = command
      @timeout_value = timeout
      @log_reference = log # https://twitter.com/schneems/status/1285289971083907075

      @log = Pathname.new(log)
      @log.dirname.mkpath
      FileUtils.touch(@log)

      @command = "/usr/bin/env bash -c #{@command.shellescape} >> #{@log} #{out}"
      @pid = nil
    end

    def wait(wait_value = nil, timeout_value = @timeout_value)
      call
      return unless wait_value

      Timeout.timeout(Integer(timeout_value)) do
        until @log.read.match(wait_value)
          sleep 0.01
        end
      end
    rescue Timeout::Error
      raise "Timeout waiting for #{@command.inspect} to find a match using #{wait_value.inspect} in \n'#{log.read}'"
    end

    def alive?
      return false unless @pid
      Process.kill(0, @pid)
    rescue Errno::ESRCH, Errno::EPERM
      false
    end

    def stop
      return unless alive?
      Process.kill("TERM", -Process.getpgid(@pid))
      Process.wait(@pid)
    end

    def check_alive!
      raise "#{@original_command} has exited unexpectedly: #{@log.read}" unless alive?
    end

    private def call
      @pid ||= Process.spawn(@command, pgroup: true)
    end
  end
end
