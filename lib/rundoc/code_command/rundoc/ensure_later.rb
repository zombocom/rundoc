# frozen_string_literal: true

module ::Rundoc::CodeCommand
  class RundocCommand
    class EnsureLaterArgs
      MAPPING = {
        cwd: ->(context:) {
          Dir.pwd
        },
        rundoc_root: ->(context:) {
          context.output_dir.to_s
        }
      }.freeze

      def initialize(dir:)
        @dir = dir
        @logic = MAPPING[dir] or raise ArgumentError, "Invalid argument dir: #{dir} must be one of #{MAPPING.keys}"
      end

      def call(context:)
        @logic.call(context: context)
      end

      def to_s
        @dir.to_s
      end
    end

    class EnsureLaterRunner
      attr_reader :io, :contents

      def initialize(user_args:, render_command:, render_result:, io:, contents: nil)
        @io = io
        @contents = contents.dup if contents && !contents.empty?
        @dir = user_args
        @binding = RUNDOC_ERB_BINDINGS[RUNDOC_DEFAULT_ERB_BINDING]
      end

      def to_md(env = {})
        ""
      end

      def call(env = {})
        resolved_dir = @dir.call(context: env[:context])

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
