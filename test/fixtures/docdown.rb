puts "========================"

ReplRunner.register_commands(:play)  do |config|
  config.terminate_command "exit"          # the command you use to end the 'rails console'
  config.startup_timeout 60                # seconds to boot
  config.return_char "\n"                  # the character that submits the command
  # config.sync_stdout "STDOUT.sync = true"  # force REPL to not buffer standard out
end
