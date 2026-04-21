# frozen_string_literal: true

module Rundoc
  module CodeCommand
    # Hold enough information to construct commands, but don't yet
    #
    # Allows us to separate parse time constructs from runtime injectables
    # (such as IO). Which gives us a cleaner running model.
    class Deferred
      attr_accessor :render_result, :render_command,
        :contents, :keyword, :original_args

      alias_method :render_result?, :render_result
      alias_method :render_command?, :render_command

      attr_reader :runner_klass

      def initialize(args_instance:, runner_klass:, always_hidden: false)
        @args_instance = args_instance
        @runner_klass = runner_klass
        @always_hidden = always_hidden
      end

      def hidden?
        !render_command? && !render_result?
      end

      def not_hidden?
        !hidden?
      end

      def push(contents)
        @contents ||= +""
        @contents << contents
      end
      alias_method :<<, :push

      def build(io: $stdout)
        @built ||= begin
          runner = @runner_klass.new(
            user_args: @args_instance,
            render_command: render_command,
            render_result: render_result,
            contents: @contents,
            io: io
          )
          if @always_hidden
            @render_command = false
            @render_result = false
          end
          runner
        end
      rescue UnknownCommand
        raise "No such command registered with rundoc #{keyword.inspect} for `#{keyword} #{original_args}`"
      end

      def call(env = {})
        build.call(env)
      end

      def to_md(env = {})
        build.to_md(env)
      end
    end
  end
end
