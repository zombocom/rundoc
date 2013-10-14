class Rundoc::CodeCommand::FileCommand
  class Append < Rundoc::CodeCommand

    def initialize(filename)
      @filename = filename
    end

    def to_md(env)
      raise "must call write in its own code section" unless env[:commands].empty?
      before = env[:before]
      env[:before] = "At the end of `#{@filename}` add:\n\n#{before}"
      nil
    end

    def call(env = {})
      puts "writing to: #{@filename}"

      dir = File.expand_path("../", @filename)
      FileUtils.mkdir_p(dir)
      File.open(@filename, "a") do |f|
        f.write(contents)
        f.write("\n") unless contents[-1, 1] == "\n"
      end
      contents
    end
  end
end


Rundoc.register_code_command(:'file.append',  Rundoc::CodeCommand::FileCommand::Append)
