class Rundoc::CodeCommand::Website
  class Navigate < Rundoc::CodeCommand
    def initialize(name:)
      @name = name
      @driver = Rundoc::CodeCommand::Website::Driver.find(name)
    end

    def to_md(env = {})
      ""
    end

    def call(env = {})
      puts "website.navigate [#{@name}]: #{contents}"
      @driver.safe_eval(contents)
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

Rundoc.register_code_command(:"website.nav", Rundoc::CodeCommand::Website::Navigate)
Rundoc.register_code_command(:"website.navigate", Rundoc::CodeCommand::Website::Navigate)
