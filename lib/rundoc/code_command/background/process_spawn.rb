require 'shellwords'
require 'timeout'

class Rundoc::CodeCommand::Background
  class ProcessSpawn
    def self.tasks
      @tasks
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

    def initialize(command , timeout: 5, log: Tempfile.new("log"), out: "2>&1")
      @command = command
      @timeout_value = timeout
      @log           = log

      @log = Pathname.new(@log)
      @log.dirname.mkpath

      @command = "/usr/bin/env bash -c #{@command.shellescape} >> #{@log} #{out}"
      @pid = nil
    end

    def wait(wait_value = nil, timeout_value = @timeout_value)
      call
      return unless wait_value

      Timeout.timeout(Integer(timeout_value)) do
        sleep 1
        until @log.read.match(wait_value)
          sleep 0.01
        end
      end
    rescue Timeout::Error
      raise "Timeout waiting for #{@command.inspect} to find a match using #{ wait_value.inspect } in \n'#{ log.read }'"
      false
    end

    def alive?
      return false unless @pid
      Process.kill(0, @pid)
    rescue Errno::ESRCH, Errno::EPERM
      false
    end

    def stop
      return unless alive?
      Process.kill('TERM', -Process.getpgid(@pid))
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
