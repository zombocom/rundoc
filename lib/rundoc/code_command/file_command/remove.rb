class Rundoc::CodeCommand::FileCommand
  class Remove < Rundoc::CodeCommand

    def initialize(filename)
      @filename = filename
    end

    def to_md(env)
      raise "must call write in its own code section" unless env[:commands].empty?
      before = env[:before]
      env[:before] = "In file `#{@filename}` remove:\n\n#{before}#{contents}\n\n"
      nil
    end

    def call(env = {})
      puts "deleting #{contents} from #{@filename}"
      raise "#{@filename} does not exist" unless File.exist?(@filename)

      regex = /#{Regexp.quote(contents)}/
      doc   = File.read(@filename)
      doc.sub!(regex, '')

      File.open(@filename, "w") do |f|
        f.write(doc)
      end
      contents
    end
  end
end


Rundoc.register_code_command(:'file.append',  Rundoc::CodeCommand::FileCommand::Remove)
