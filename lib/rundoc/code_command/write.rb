module Rundoc
  class CodeCommand
    module FileUtil
      def filename
        files = Dir.glob(@filename)
        if files.length > 1
          raise "Filename glob #{@filename.inspect} matched more than one file. Be more specific to only match one file. Matches:\n" + files.join("  \n")
        end
        files.first || @filename
      end

      def mkdir_p
        dir = File.expand_path("../", filename)
        FileUtils.mkdir_p(dir)
      end
    end

    class Write < Rundoc::CodeCommand
      include FileUtil

      def initialize(filename)
        @filename = filename
      end

      def to_md(env)
        raise "must call write in its own code section" unless env[:commands].empty?
        before = env[:before]
        env[:before] = "In file `#{filename}` write:\n\n#{before}"
        nil
      end

      def call(env = {})
        puts "Writing to: '#{filename}'"
        mkdir_p
        File.write(filename, contents)
        contents
      end
    end
  end
end

Rundoc.register_code_command(:write, Rundoc::CodeCommand::Write)
Rundoc.register_code_command(:"file.write", Rundoc::CodeCommand::Write)

require "rundoc/code_command/file_command/append"
require "rundoc/code_command/file_command/remove"
