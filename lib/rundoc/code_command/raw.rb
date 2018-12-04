module Rundoc
  class CodeCommand
    class Raw < CodeCommand
      def initialize(contents, visible: true)
        @contents = contents
        @render_result = visible
      end

      def call(env = {})
        contents.to_s
      end

      def to_md(env = {})
        contents.to_s
      end
    end
  end
end