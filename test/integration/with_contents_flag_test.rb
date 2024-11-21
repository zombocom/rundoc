require "test_helper"

class WithContentsFlagTest < Minitest::Test
  def test_with_contents_flag
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        dir = Pathname(dir)

        contents_dir = dir.join("contents").tap { |p| p.mkpath }
        FileUtils.touch(contents_dir.join("file1.txt"))

        source_path = dir.join("RUNDOC.md")
        source_path.write <<~EOF
          ```
          :::>> $ ls
          ```
        EOF

        refute dir.join(SUCCESS_DIRNAME).join("file1.txt").exist?

        io = StringIO.new
        Rundoc::CLI.new(
          io: io,
          source_path: source_path,
          on_success_dir: dir.join(SUCCESS_DIRNAME),
          with_contents_dir: contents_dir
        ).call

        doc = dir.join(SUCCESS_DIRNAME).join("README.md").read
        assert_includes doc, "$ ls"
        assert_includes doc, "file1.txt"
      end
    end
  end
end
