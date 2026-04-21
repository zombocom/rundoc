# frozen_string_literal: true

class Rundoc::CodeCommand::Background::Log
  class ClearArgs
    attr_reader :name

    def initialize(name:)
      @name = name
    end
  end

  class ClearRunner
    def initialize(user_args:, render_command:, render_result:, io: nil, contents: nil)
      @name = user_args.name
      @background = nil
    end

    def background
      @background ||= Rundoc::CodeCommand::Background::ProcessSpawn.find(@name)
    end

    def to_md(env = {})
      ""
    end

    def call(env = {})
      background.log.truncate(0)
      ""
    end
  end
end
Rundoc.register_code_command(keyword: :"background.log.clear", args_klass: Rundoc::CodeCommand::Background::Log::ClearArgs, runner_klass: Rundoc::CodeCommand::Background::Log::ClearRunner)
