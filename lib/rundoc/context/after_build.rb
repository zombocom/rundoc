module Rundoc
  module Context
    # Public interface for the `Rundoc.after_build` proc
    class AfterBuild
      attr_reader :output_markdown_path, :screenshots_dir, :output_dir

      def initialize(output_markdown_path:, screenshots_dir:, output_dir: )
        @output_dir = output_dir
        @screenshots_dir = screenshots_dir
        @output_markdown_path = output_markdown_path
      end
    end
  end
end
