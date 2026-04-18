class Rundoc::CodeCommand::Website
  class NavigateArgs
    attr_reader :name

    def initialize(name:)
      @name = name
    end
  end

  class NavigateRunner < Rundoc::CodeCommand
    def initialize(user_args:)
      @name = user_args.name
      @driver = nil
    end

    def driver
      @driver ||= Rundoc::CodeCommand::Website::Driver.find(@name)
    end

    def to_md(env = {})
      ""
    end

    def call(env = {})
      puts "website.navigate [#{@name}]: #{contents}"
      driver.safe_eval(contents, env)
      ""
    end

    def hidden?
      true
    end

    def not_hidden?
      !hidden?
    end
  end
end

Rundoc.register_code_command(keyword: :"website.nav", args_klass: Rundoc::CodeCommand::Website::NavigateArgs, runner_klass: Rundoc::CodeCommand::Website::NavigateRunner)
Rundoc.register_code_command(keyword: :"website.navigate", args_klass: Rundoc::CodeCommand::Website::NavigateArgs, runner_klass: Rundoc::CodeCommand::Website::NavigateRunner)
