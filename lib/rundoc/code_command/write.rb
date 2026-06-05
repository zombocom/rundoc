# frozen_string_literal: true

module Rundoc
  module CodeCommand
    module FileUtil
      def filename
        files = Dir.glob(@filename)
        if files.length > 1
          raise "Filename glob #{@filename.inspect} matched more than one file. Be more specific to only match one file. Matches:\n" + files.join("  \n")
        end
        files.first || @filename
      end

      def mkdir_p
        dir = File.expand_path("../", filename)
        FileUtils.mkdir_p(dir)
      end

      def self.resolve_match_line(doc:, match_str:, filename:, unique:)
        lines = doc.lines
        matching_indices = lines.each_index.select { |i| lines[i].include?(match_str) }

        if matching_indices.empty?
          raise "Could not find match #{match_str.inspect} in #{filename}"
        end

        if unique && matching_indices.length != 1
          raise "Expected 1 match for #{match_str.inspect} in #{filename} but found #{matching_indices.length}. Use match_first: if multiple matches are expected."
        end

        matching_indices.first + 1
      end

      def self.insert_contents_at_line(doc:, line_number:, contents:, filename:)
        lines = doc.lines
        if line_number > lines.count + 1
          raise "Expected #{filename} to have at least #{line_number - 1} lines but only has #{lines.count}"
        end

        result = []
        lines.each_with_index do |line, index|
          if index.next == line_number
            result << contents
            result << "\n" unless contents.end_with?("\n")
          end
          result << line
        end

        if line_number == lines.count + 1
          result << contents
          result << "\n" unless contents.end_with?("\n")
        end

        result.join("")
      end
    end

    class WriteArgs
      attr_reader :path

      def initialize(path)
        @path = Pathname(path)
      end
    end

    class WriteRunner
      NEWLINE = Object.new
      def NEWLINE.to_s
        ""
      end

      def NEWLINE.empty?
        false
      end

      include Rundoc::CodeCommand::FileUtil

      attr_reader :io, :contents

      def initialize(user_args:, render_command:, render_result:, io:, contents: nil)
        @filename = user_args.path.to_s
        @io = io
        @render_command = render_command
        @contents = contents.dup if contents && !contents.empty?
      end

      def render_command?
        @render_command
      end

      def to_md(env)
        if render_command?
          if env[:commands].any? { |c| c[:visibility].not_hidden? }
            raise "must call write in its own code section"
          end
          env[:before] << "In file `#{filename}` write:"
          env[:before] << NEWLINE
        end
        nil
      end

      def call(env = {})
        io.puts "Writing to: '#{filename}'"
        mkdir_p
        File.write(filename, contents)
        contents
      end
    end
  end
end

Rundoc.register_code_command(keyword: :write, args_klass: Rundoc::CodeCommand::WriteArgs, runner_klass: Rundoc::CodeCommand::WriteRunner)
Rundoc.register_code_command(keyword: :"file.write", args_klass: Rundoc::CodeCommand::WriteArgs, runner_klass: Rundoc::CodeCommand::WriteRunner)

require "rundoc/code_command/file_command/append"
require "rundoc/code_command/file_command/before"
require "rundoc/code_command/file_command/remove"
