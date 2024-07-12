require "test_helper"

class SystemsCliTest < Minitest::Test
  def exe_path
    root_dir.join("bin").join("rundoc")
  end

  def test_simple_file
    Dir.mktmpdir do |dir|
      dir = Pathname(dir)
      rundoc = dir.join("RUNDOC.md")
      rundoc.write <<~EOF
        ```
        :::>> $ echo "hello world"
        ```
      EOF

      run!("#{exe_path} #{rundoc}")

      readme = dir.join("project").join("README.md")
      actual = strip_autogen_warning(readme.read)
      expected = <<~EOF
        ```
        $ echo "hello world"
        hello world
        ```
      EOF

      assert_equal expected.strip, actual.strip
    end
  end
end
