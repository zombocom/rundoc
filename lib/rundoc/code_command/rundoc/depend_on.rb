class ::Rundoc::CodeCommand
  class RundocCommand
    class DependOnArgs
      def initialize(path)
        raise "rundoc.depend_on has been removed, use `:::-- rundoc.require` instead"
      end
    end
  end
end

Rundoc.register_code_command(:"rundoc.depend_on", ::Rundoc::CodeCommand::RundocCommand::DependOnArgs)
