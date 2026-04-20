module Rundoc
  class CodeCommand
    class NoSuchCommand < Rundoc::CodeCommand
      def initialize(user_args: nil, **)
        super(**)
      end

      def call(env = {})
        raise UnknownCommand
      end
    end
  end
end
