require "test_helper"

class SystemsCliTest < Minitest::Test
  def exe_path
    root_dir.join("bin").join("rundoc")
  end

  def test_help
    output = run!("#{exe_path} --help")
    assert output.include?("Usage:")
  end

  def test_force_fail_dir_protection
    Dir.mktmpdir do |dir|
      dir = Pathname(dir)
      rundoc = dir.join("RUNDOC.md")
      rundoc.write "Done"

      not_empty = dir.join("tmp").tap(&:mkpath).join("not_empty.txt")
      not_empty.write("Not empty")

      run!("#{exe_path} #{rundoc}", raise_on_nonzero_exit: false)
      assert !$?.success?

      assert not_empty.exist?

      run!("#{exe_path} #{rundoc} --force", raise_on_nonzero_exit: false)
      assert $?.success?
      assert !not_empty.exist?
    end
  end

  def test_force_success_dir_protection
    Dir.mktmpdir do |dir|
      dir = Pathname(dir)

      rundoc = dir.join("RUNDOC.md")
      rundoc.write "Done"

      not_empty = dir.join("project").tap(&:mkpath).join("not_empty.txt")
      not_empty.write("Not empty")

      run!("#{exe_path} #{rundoc}", raise_on_nonzero_exit: false)
      assert !$?.success?

      assert not_empty.exist?

      run!("#{exe_path} #{rundoc} --force", raise_on_nonzero_exit: false)
      assert $?.success?
      assert !not_empty.exist?
    end
  end

  def test_dotenv
    Dir.mktmpdir do |dir|
      key = SecureRandom.hex
      dir = Pathname(dir)
      dotenv = dir.join("another").join("directory").tap(&:mkpath).join(".env")

      dotenv.write <<~EOF
        FLORP="#{key}"
      EOF

      rundoc = dir.join("RUNDOC.md")
      rundoc.write <<~EOF
        ```
        :::>> $ echo $FLORP
        ```
      EOF

      run!("#{exe_path} #{rundoc} --dotenv-path #{dotenv}")

      readme = dir.join("project")
        .tap { |p| assert p.exist? }
        .join("README.md")
        .tap { |p| assert p.exist? }

      actual = strip_autogen_warning(readme.read)
      expected = <<~EOF
        ```
        $ echo $FLORP
        #{key}
        ```
      EOF
      assert_equal expected.strip, actual.strip
    end
  end

  def test_screenshots_dir
    Dir.mktmpdir do |dir|
      dir = Pathname(dir)
      rundoc = dir.join("RUNDOC.md")
      screenshots_dirname = "lol_screenshots"
      rundoc.write <<~EOF
        ```
        :::>> website.visit(name: "example", url: "http://example.com")
        :::>> website.screenshot(name: "example")
        ```
      EOF

      run!("#{exe_path} #{rundoc} --screenshots-dir #{screenshots_dirname}")

      dir.join("project")
        .tap { |p| assert p.exist? }
        .join(screenshots_dirname)
        .tap { |p| assert p.exist? }

      readme = dir.join("project").join("README.md").read
      actual = strip_autogen_warning(readme)

      expected = "![Screenshot of http://example.com/](#{screenshots_dirname}/screenshot_1.png)"
      assert_equal expected, actual.strip
    end
  end

  def test_output_filename
    Dir.mktmpdir do |dir|
      dir = Pathname(dir)
      rundoc = dir.join("RUNDOC.md")
      failure_dir = dir.join("lol")
      rundoc.write "Done"

      assert !failure_dir.exist?

      run!("#{exe_path} #{rundoc} --output-filename tutorial.md")

      tutorial_md = dir.join("project")
        .tap { |p| assert p.exist? }
        .join("tutorial.md")
        .tap { |p| assert p.exist? }

      actual = strip_autogen_warning(tutorial_md.read)
      expected = "Done"

      assert_equal expected.strip, actual.strip
    end
  end

  def test_on_failure_dir
    Dir.mktmpdir do |dir|
      dir = Pathname(dir)
      rundoc = dir.join("RUNDOC.md")
      failure_dir = dir.join("lol")
      rundoc.write <<~EOF
        ```
        :::>> $ touch lol.txt
        :::>> $ echo "hello world" && exit 1
        ```
      EOF

      assert !failure_dir.exist?

      run!("#{exe_path} #{rundoc} --on-failure-dir #{failure_dir}", raise_on_nonzero_exit: false)
      assert !$?.success?

      assert failure_dir.exist?
      assert !Dir.exist?(dir.join("tmp"))
      assert failure_dir.join("lol.txt").exist?
    end
  end

  def test_on_success_dir
    Dir.mktmpdir do |dir|
      dir = Pathname(dir)
      rundoc = dir.join("RUNDOC.md")
      success_dir = dir.join("lol")
      rundoc.write "Done"

      assert !success_dir.exist?
      run!("#{exe_path} #{rundoc} --on-success-dir #{success_dir}")

      assert success_dir.exist?
      assert !Dir.exist?(dir.join("project"))

      readme = success_dir.join("README.md")
      actual = strip_autogen_warning(readme.read)
      expected = "Done"

      assert_equal expected.strip, actual.strip
    end
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
