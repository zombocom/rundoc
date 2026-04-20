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

    class WriteArgs
      attr_reader :path

      def initialize(path)
        @path = Pathname(path)
      end
    end

    class WriteRunner < Rundoc::CodeCommand
      include FileUtil

      def initialize(user_args:, **)
        @filename = user_args.path.to_s
        super(**)
      end

      def to_md(env)
        if render_command?
          if env[:commands].any? { |c| c[:object].not_hidden? }
            raise "must call write in its own code section"
          end
          env[:before] << "In file `#{filename}` write:"
          env[:before] << NEWLINE
        end
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

Rundoc.register_code_command(keyword: :write, args_klass: Rundoc::CodeCommand::WriteArgs, runner_klass: Rundoc::CodeCommand::WriteRunner)
Rundoc.register_code_command(keyword: :"file.write", args_klass: Rundoc::CodeCommand::WriteArgs, runner_klass: Rundoc::CodeCommand::WriteRunner)

require "rundoc/code_command/file_command/append"
require "rundoc/code_command/file_command/remove"
