class ::Rundoc::CodeCommand
  class RundocCommand
    class DependOn < ::Rundoc::CodeCommand
      # Pass in the relative path of another rundoc document in order to
      # run all of it's commands (but not to )
      def initialize(path)
        raise "rundoc.depend_on has been removed, use `:::-- rundoc.require` instead"
      end
    end
  end
end

Rundoc.register_code_command(:"rundoc.depend_on", ::Rundoc::CodeCommand::RundocCommand::DependOn)
