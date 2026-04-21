# frozen_string_literal: true

class Rundoc::CodeCommand::Website
  class NavigateArgs
    attr_reader :name

    def initialize(name:)
      @name = name
    end
  end

  class NavigateRunner
    attr_reader :io, :contents

    def initialize(user_args:, render_command:, render_result:, io:, contents: nil)
      @name = user_args.name
      @driver = nil
      @io = io
      @contents = contents.dup if contents && !contents.empty?
    end

    def driver
      @driver ||= Rundoc::CodeCommand::Website::Driver.find(@name)
    end

    def to_md(env = {})
      ""
    end

    def call(env = {})
      io.puts "website.navigate [#{@name}]: #{contents}"
      driver.safe_eval(contents, env)
      ""
    end
  end
end

Rundoc.register_code_command(keyword: :"website.nav", args_klass: Rundoc::CodeCommand::Website::NavigateArgs, runner_klass: Rundoc::CodeCommand::Website::NavigateRunner)
Rundoc.register_code_command(keyword: :"website.navigate", args_klass: Rundoc::CodeCommand::Website::NavigateArgs, runner_klass: Rundoc::CodeCommand::Website::NavigateRunner)
