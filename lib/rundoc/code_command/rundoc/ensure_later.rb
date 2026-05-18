# frozen_string_literal: true

module ::Rundoc::CodeCommand
  class RundocCommand
    class EnsureLaterArgs
      VALID_DIRS = [:cwd, :rundoc_root].freeze

      attr_reader :dir

      def initialize(dir:)
        dir = dir.to_sym
        unless VALID_DIRS.include?(dir)
          raise ArgumentError, "Invalid dir: #{dir.inspect}, must be one of: #{VALID_DIRS.map(&:inspect).join(", ")}"
        end
        @dir = dir
      end
    end

    class EnsureLaterRunner
      attr_reader :io, :contents

      def initialize(user_args:, render_command:, render_result:, io:, contents: nil)
        @io = io
        @contents = contents.dup if contents && !contents.empty?
        @dir = user_args.dir
        @binding = RUNDOC_ERB_BINDINGS[RUNDOC_DEFAULT_ERB_BINDING]
      end

      def to_md(env = {})
        ""
      end

      def call(env = {})
        context = env[:context]
        resolved_dir = case @dir
        when :cwd
          Dir.pwd
        when :rundoc_root
          context.output_dir.to_s
        else
          raise "ensure_later: Unknown dir value #{@dir.inspect}, expected one of: #{EnsureLaterArgs::VALID_DIRS.map(&:inspect).join(", ")}"
        end

        io.puts "Registering ensure_later block (dir: #{@dir} => #{resolved_dir})"
        Rundoc.add_ensure_later(dir: resolved_dir, code: @contents, binding: @binding)
        ""
      end
    end
  end
end

Rundoc.register_code_command(
  keyword: :"rundoc.ensure_later",
  args_klass: Rundoc::CodeCommand::RundocCommand::EnsureLaterArgs,
  runner_klass: Rundoc::CodeCommand::RundocCommand::EnsureLaterRunner,
  always_hidden: true
)
