# frozen_string_literal: true

module Rundoc
  module CodeCommand
    # Wraps lines inside a fenced code block that are not rundoc commands.
    # These are rendered as-is without executing any code.
    #
    # Example:
    #
    #   ```ruby
    #   gem 'sqlite3'       <- parsed as Raw
    #   :::>> $ echo "hi"   <- parsed as a code command
    #   ```
    class Raw
      attr_reader :contents

      def initialize(user_args: nil, render_command: true, render_result: true, io: nil, contents: nil, **)
        @render_command = render_command
        @render_result = render_result
        @contents = contents.dup if contents && !contents.empty?
      end

      def render_command?
        @render_command
      end

      def render_result?
        @render_result
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
