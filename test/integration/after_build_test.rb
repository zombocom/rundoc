require "test_helper"

class IntegrationAfterBuildTest < Minitest::Test

  def test_modifies_directory_structure
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        dir = Pathname(dir)

        source_path = dir.join("RUNDOC.md")
        source_path.write <<~EOF
          ```
          :::>> $ mkdir lol
          :::>> $ touch lol/rofl.txt
          ```
        EOF

        io = StringIO.new

        Rundoc::CLI.new(
          io: io,
          source_path: source_path,
          on_success_dir: dir.join(SUCCESS_DIRNAME)
        ).call

        assert dir.join(SUCCESS_DIRNAME).join("lol").exist?
        assert dir.join(SUCCESS_DIRNAME).join("lol").join("rofl.txt").exist?

        FileUtils.remove_entry_secure(dir.join(SUCCESS_DIRNAME))

        source_path.write <<~EOF
          ```
          :::-- rundoc.configure
          Rundoc.configure do |config|
            config.after_build do |context|
              Dir.glob(context.output_dir.join("lol").join("*")).each do |item|
                FileUtils.mv(item, context.output_dir)
              end

              FileUtils.rm_rf(context.output_dir.join("lol"))
            end
          end
          ```

          ```
          :::>> $ mkdir lol
          :::>> $ touch lol/rofl.txt
          ```
        EOF

        io = StringIO.new

        Rundoc::CLI.new(
          io: io,
          source_path: source_path,
          on_success_dir: dir.join(SUCCESS_DIRNAME)
        ).call

        assert dir.join(SUCCESS_DIRNAME).join("rofl.txt").exist?
      end
    end
  end
end
