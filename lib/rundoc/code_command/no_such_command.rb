# frozen_string_literal: true

module Rundoc
  module CodeCommand
    class NoSuchCommand
      def initialize(user_args: nil, render_command: false, render_result: false, io: nil, contents: nil)
      end

      def call(env = {})
        raise UnknownCommand
      end
    end
  end
end
