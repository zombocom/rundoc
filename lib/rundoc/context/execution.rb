module Rundoc
  module Context
    # Holds configuration for the currently executing script
    class Execution
      # The path to the source file
      attr_reader :source_path,
        # The directory containing the source file
        :source_dir,
        # The directory we are actively manipulating
        :output_dir,
        # Directory to store screenshots, relative to output_dir
        :screenshots_dir

      def initialize(source_path:, output_dir:, screenshots_dirname:)
        @source_path = Pathname(source_path).expand_path
        @source_dir = @source_path.parent
        @output_dir = Pathname(output_dir).expand_path
        @screenshots_dir = @output_dir.join(screenshots_dirname).expand_path
      end
    end
  end
end
