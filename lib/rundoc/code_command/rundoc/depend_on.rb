class ::Rundoc::CodeCommand
  class RundocCommand
    class DependOnArgs
      def initialize(path)
        raise "rundoc.depend_on has been removed, use `:::-- rundoc.require` instead"
      end
    end
  end
end

Rundoc.register_code_command(keyword: :"rundoc.depend_on", args_klass: ::Rundoc::CodeCommand::RundocCommand::DependOnArgs)
