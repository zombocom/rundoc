# frozen_string_literal: true

module Rundoc
  class CodeCommand
    # Wraps lines inside a fenced code block that are not rundoc commands.
    # These are rendered as-is without executing any code.
    #
    # Example:
    #
    #   ```ruby
    #   gem 'sqlite3'       <- parsed as Raw
    #   :::>> $ echo "hi"   <- parsed as a code command
    #   ```
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
