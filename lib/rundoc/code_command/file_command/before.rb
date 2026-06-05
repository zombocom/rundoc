# frozen_string_literal: true

class Rundoc::CodeCommand::FileCommand
  class BeforeArgs
    attr_reader :filename, :match, :match_first

    def initialize(filename, match: nil, match_first: nil)
      @filename = filename
      @match = match
      @match_first = match_first

      if @match && @match_first
        raise "Cannot use both match: and match_first:"
      end

      if @match.nil? && @match_first.nil?
        raise "file.before requires match: or match_first:"
      end

      if (@match || @match_first)&.empty?
        raise "match value cannot be empty"
      end
    end
  end

  class BeforeRunner
    NEWLINE = Rundoc::CodeCommand::WriteRunner::NEWLINE

    include Rundoc::CodeCommand::FileUtil

    attr_reader :io, :contents

    def initialize(user_args:, render_command:, render_result:, io:, contents: nil)
      @filename = user_args.filename
      @match = user_args.match
      @match_first = user_args.match_first
      @io = io
      @render_command = render_command
      @contents = contents.dup if contents && !contents.empty?
    end

    def render_command?
      @render_command
    end

    def match_string
      @match || @match_first
    end

    def to_md(env)
      return unless render_command?

      if env[:commands].any? { |c| c[:visibility].not_hidden? }
        raise "Must call file.before in its own code section"
      end

      env[:before] << "In file `#{filename}`, before `#{match_string}`, add:"
      env[:before] << NEWLINE
      nil
    end

    def ends_in_newline?(string)
      string[-1, 1] == "\n"
    end

    def insert_contents_before_match(doc)
      lines = doc.lines
      matching_indices = lines.each_index.select { |i| lines[i].include?(match_string) }

      if matching_indices.empty?
        raise "Could not find match #{match_string.inspect} in #{filename}"
      end

      if @match && matching_indices.length != 1
        raise "Expected 1 match for #{match_string.inspect} in #{filename} but found #{matching_indices.length}. Use match_first: if multiple matches are expected."
      end

      target = matching_indices.first
      io.puts "Inserting at line #{target + 1} before #{match_string.inspect} in '#{filename}' with: #{contents.inspect}"
      result = []
      lines.each_with_index do |line, index|
        if index == target
          result << contents
          result << "\n" unless ends_in_newline?(contents)
        end
        result << line
      end
      result.join("")
    end

    def call(env = {})
      mkdir_p
      doc = File.read(filename)
      doc = insert_contents_before_match(doc)
      File.write(filename, doc)
      contents
    end
  end
end

Rundoc.register_code_command(keyword: :"file.before", args_klass: Rundoc::CodeCommand::FileCommand::BeforeArgs, runner_klass: Rundoc::CodeCommand::FileCommand::BeforeRunner)
