module Rundoc
  class CodeCommand
    class NoSuchCommand < Rundoc::CodeCommand
      def call(env = {})
        raise "No such command registered with rundoc: #{@keyword.inspect} for '#{@keyword} #{@original_args}'"
      end
    end
  end
end
