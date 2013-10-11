module Rundoc
  class CodeCommand
    class Write < Rundoc::CodeCommand
      def initialize(filename)
        @filename = filename
      end

      def to_md(env)
        raise "must call write in its own code section" unless env[:commands].empty?
        before = env[:before]
        env[:before] = "In file `#{@filename}`:\n\n#{before}"
        nil
      end

      def call(env = {})
        puts "writing to: #{@filename}"

        dir = File.expand_path("../", @filename)
        FileUtils.mkdir_p(dir)
        File.open(@filename, "w") do |f|
          f.write(contents)
        end
        contents
      end
    end
  end
end


Rundoc.register_code_command(:write, Rundoc::CodeCommand::Write)
