module Docdown
  module CodeCommands
    class Write < Docdown::CodeCommand
      def initialize(filename)
        @filename = filename
        @dir      = File.expand_path("../", @filename)
      end

      # todo diff file if it already exists
      def to_md
        puts "~~~~~~~~~~~"
        "In file `#{@filename}` add:\n#{contents}"
      end

      def call
        FileUtils.mkdir_p(@dir)
        File.open(@filename, "w") do |f|
          f.write(contents)
        end
      end
    end
  end
end


Docdown.register_code_command(:write, Docdown::CodeCommands::Write)
