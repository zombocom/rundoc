class Rundoc::CodeCommand::Bash
  # special purpose class to persist cd behavior across the entire program
  # we change the directory of the parent program (rundoc) rather than
  # changing the directory of a spawned child (via exec, ``, system, etc.)
  class Append < Rundoc::CodeCommand::Write

    def initialize(line)
      @line     = line
    end

    def to_md(env)
      raise "must call write in its own code section" unless env[:commands].empty?
      before = env[:before]
      env[:before] = "Att the end of `#{@filename}` add:\n\n#{before}"
      nil
    end

    def call(env)
      puts "writing to: #{@filename}"

      dir = File.expand_path("../", @filename)
      FileUtils.mkdir_p(dir)
      File.open(@filename, "a") do |f|
        f.write(contents)
      end
      contents
    end
  end
end


Rundoc.register_code_command(:'file.append',  Rundoc::CodeCommand::Bash)
