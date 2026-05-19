# frozen_string_literal: true

require "test_helper"

class IntegrationEnsureLaterTest < Minitest::Test
  def test_runs_on_success
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        dir = Pathname(dir)
        marker = dir.join("ensure_ran.txt")

        source_path = dir.join("RUNDOC.md")
        source_path.write <<~EOF
          ```
          :::-- rundoc.ensure_later(dir: :cwd)
          File.write("#{marker}", "yes")
          ```

          ```
          :::>> $ echo "hello"
          ```
        EOF

        Rundoc::CLI.new(
          io: StringIO.new,
          source_path: source_path,
          on_success_dir: dir.join(SUCCESS_DIRNAME)
        ).call

        assert marker.exist?, "ensure_later block should have run on success"
        assert_equal "yes", marker.read
      end
    end
  end

  def test_runs_on_failure
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        dir = Pathname(dir)
        marker = dir.join("ensure_ran.txt")

        source_path = dir.join("RUNDOC.md")
        source_path.write <<~EOF
          ```
          :::-- rundoc.ensure_later(dir: :cwd)
          File.write("#{marker}", "cleaned")
          ```

          ```
          :::>> $ exit 1
          ```
        EOF

        assert_raises do
          Rundoc::CLI.new(
            io: StringIO.new,
            source_path: source_path,
            on_success_dir: dir.join(SUCCESS_DIRNAME),
            on_failure_dir: dir.join(FAILURE_DIRNAME)
          ).call
        end

        assert marker.exist?, "ensure_later block should have run on failure"
        assert_equal "cleaned", marker.read
      end
    end
  end

  def test_multiple_blocks_run_in_order
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        dir = Pathname(dir)
        marker = dir.join("order.txt")

        source_path = dir.join("RUNDOC.md")
        source_path.write <<~EOF
          ```
          :::-- rundoc.ensure_later(dir: :cwd)
          File.write("#{marker}", "first")
          ```

          ```
          :::-- rundoc.ensure_later(dir: :cwd)
          File.write("#{marker}", File.read("#{marker}") + ",second")
          ```

          ```
          :::>> $ echo "hello"
          ```
        EOF

        Rundoc::CLI.new(
          io: StringIO.new,
          source_path: source_path,
          on_success_dir: dir.join(SUCCESS_DIRNAME)
        ).call

        assert_equal "first,second", marker.read
      end
    end
  end

  def test_one_failure_does_not_stop_others
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        dir = Pathname(dir)
        marker = dir.join("second_ran.txt")

        source_path = dir.join("RUNDOC.md")
        source_path.write <<~EOF
          ```
          :::-- rundoc.ensure_later(dir: :cwd)
          raise "intentional failure"
          ```

          ```
          :::-- rundoc.ensure_later(dir: :cwd)
          File.write("#{marker}", "yes")
          ```

          ```
          :::>> $ echo "hello"
          ```
        EOF

        error = assert_raises(RuntimeError) do
          Rundoc::CLI.new(
            io: StringIO.new,
            source_path: source_path,
            on_success_dir: dir.join(SUCCESS_DIRNAME)
          ).call
        end
        assert_match(/intentional failure/, error.message)

        assert marker.exist?, "second ensure_later should still run after first fails"
      end
    end
  end

  def test_success_plus_ensure_failure_is_overall_failure
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        dir = Pathname(dir)

        source_path = dir.join("RUNDOC.md")
        source_path.write <<~EOF
          ```
          :::-- rundoc.ensure_later(dir: :cwd)
          raise "cleanup failed"
          ```

          ```
          :::>> $ echo "hello"
          ```
        EOF

        error = assert_raises(RuntimeError) do
          Rundoc::CLI.new(
            io: StringIO.new,
            source_path: source_path,
            on_success_dir: dir.join(SUCCESS_DIRNAME)
          ).call
        end

        assert_match(/cleanup failed/, error.message)
      end
    end
  end

  def test_dir_rundoc_root
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        dir = Pathname(dir)
        marker = dir.join("root_marker.txt")

        source_path = dir.join("RUNDOC.md")
        source_path.write <<~EOF
          ```
          :::>> $ mkdir subdir
          :::>> $ cd subdir
          ```

          ```
          :::-- rundoc.ensure_later(dir: :rundoc_root)
          File.write("#{marker}", Dir.pwd)
          ```

          ```
          :::>> $ echo "hello"
          ```
        EOF

        cli = Rundoc::CLI.new(
          io: StringIO.new,
          source_path: source_path,
          on_success_dir: dir.join(SUCCESS_DIRNAME)
        )
        output_dir = cli.execution_context.output_dir.realpath.to_s

        cli.call

        assert marker.exist?, "ensure_later with dir: :rundoc_root should run"
        assert_equal output_dir, marker.read
      end
    end
  end

  def test_output_not_in_document
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        dir = Pathname(dir)

        source_path = dir.join("RUNDOC.md")
        source_path.write <<~EOF
          ```
          :::-- rundoc.ensure_later(dir: :cwd)
          puts "THIS SHOULD NOT APPEAR"
          ```

          ```
          :::>> $ echo "visible"
          ```
        EOF

        Rundoc::CLI.new(
          io: StringIO.new,
          source_path: source_path,
          on_success_dir: dir.join(SUCCESS_DIRNAME)
        ).call

        readme = dir.join(SUCCESS_DIRNAME).join("README.md").read
        refute_match(/THIS SHOULD NOT APPEAR/, readme)
        assert_match(/visible/, readme)
      end
    end
  end

  def test_invalid_dir_raises
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        dir = Pathname(dir)

        source_path = dir.join("RUNDOC.md")
        source_path.write <<~EOF
          ```
          :::-- rundoc.ensure_later(dir: :invalid)
          puts "should not run"
          ```
        EOF

        assert_raises(ArgumentError) do
          Rundoc::CLI.new(
            io: StringIO.new,
            source_path: source_path,
            on_success_dir: dir.join(SUCCESS_DIRNAME)
          ).call
        end
      end
    end
  end

  def test_shared_binding_with_rundoc
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        dir = Pathname(dir)
        marker = dir.join("binding_test.txt")

        source_path = dir.join("RUNDOC.md")
        source_path.write <<~EOF
          ```
          :::-- rundoc
          def my_helper
            "from_rundoc"
          end
          ```

          ```
          :::-- rundoc.ensure_later(dir: :cwd)
          File.write("#{marker}", my_helper)
          ```

          ```
          :::>> $ echo "hello"
          ```
        EOF

        Rundoc::CLI.new(
          io: StringIO.new,
          source_path: source_path,
          on_success_dir: dir.join(SUCCESS_DIRNAME)
        ).call

        assert_equal "from_rundoc", marker.read
      end
    end
  end

  def test_runs_on_failure_from_subdirectory
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        dir = Pathname(dir)
        marker = dir.join("ensure_ran.txt")

        source_path = dir.join("RUNDOC.md")
        source_path.write <<~EOF
          ```
          :::>> $ mkdir myapp
          :::>> $ cd myapp
          ```

          ```
          :::-- rundoc.ensure_later(dir: :cwd)
          File.write("#{marker}", "cleaned")
          ```

          ```
          :::>> $ exit 1
          ```
        EOF

        assert_raises do
          Rundoc::CLI.new(
            io: StringIO.new,
            source_path: source_path,
            on_success_dir: dir.join(SUCCESS_DIRNAME),
            on_failure_dir: dir.join(FAILURE_DIRNAME)
          ).call
        end

        assert marker.exist?, "ensure_later from subdirectory should run even on failure"
        assert_equal "cleaned", marker.read
      end
    end
  end
end
