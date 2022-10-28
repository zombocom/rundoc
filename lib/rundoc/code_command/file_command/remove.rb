class Rundoc::CodeCommand::FileCommand
  class Remove < Rundoc::CodeCommand
    include FileUtil

    def initialize(filename)
      @filename = filename
    end

    def to_md(env)
      raise "must call write in its own code section" unless env[:commands].empty?
      before = env[:before]
      env[:before] = "In file `#{filename}` remove:\n\n#{before}"
      nil
    end

    def call(env = {})
      puts "Deleting '#{contents.strip}' from #{filename}"
      raise "#{filename} does not exist" unless File.exist?(filename)

      regex = /^\s*#{Regexp.quote(contents)}/
      doc = File.read(filename)
      doc.sub!(regex, "")

      File.write(filename, doc)
      contents
    end
  end
end

Rundoc.register_code_command(:"file.remove", Rundoc::CodeCommand::FileCommand::Remove)
