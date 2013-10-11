Rundoc.config do |config|
  # config.proj_directory
  config.register_repl(:play) do |repl|
    repl.startup_timeout 60                # seconds to boot
    repl.return_char "\n"                  # the character that submits the command
  end
end

Rundoc.after_build  do
  puts "==============="
end
