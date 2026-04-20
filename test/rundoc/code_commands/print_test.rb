require "test_helper"

class PrintTest < Minitest::Test
  def test_plain_text_before_block
    env = {}
    env[:before] = []

    input = %($ rails new myapp # Not a command since it's missing the ":::>>")
    cmd = Rundoc::CodeCommand::PrintTextRunner.new(user_args: Rundoc::CodeCommand::PrintTextArgs.new(input), io: StringIO.new, render_command: false, render_result: true)

    assert_equal "", cmd.to_md(env)
    assert_equal "", cmd.call
    assert_equal ["$ rails new myapp # Not a command since it's missing the \":::>>\""], env[:before]
  end

  def test_plain_text_in_block
    env = {}
    env[:before] = []

    input = %($ rails new myapp # Not a command since it's missing the ":::>>")
    cmd = Rundoc::CodeCommand::PrintTextRunner.new(user_args: Rundoc::CodeCommand::PrintTextArgs.new(input), io: StringIO.new, render_command: true, render_result: true)

    assert_equal "", cmd.to_md(env)
    assert_equal input, cmd.call

    assert_equal [], env[:before]
  end

  def test_erb_before_block
    env = {}
    env[:before] = []

    input = %($ rails new <%= 'myapp' %> # Not a command since it's missing the ":::>>")
    cmd = Rundoc::CodeCommand::PrintERBRunner.new(user_args: Rundoc::CodeCommand::PrintERBArgs.new(input), io: StringIO.new, render_command: false, render_result: true)

    assert_equal "", cmd.to_md(env)
    assert_equal "", cmd.call
    assert_equal ["$ rails new myapp # Not a command since it's missing the \":::>>\""],
      env[:before]
  end

  def test_erb_in_block
    env = {}
    env[:before] = []

    cmd = Rundoc::CodeCommand::PrintERBRunner.new(user_args: Rundoc::CodeCommand::PrintERBArgs.new, io: StringIO.new, render_command: true, render_result: true, contents: %(<%= "foo" %>))

    assert_equal "", cmd.to_md(env)
    assert_equal "foo", cmd.call
    assert_equal [], env[:before]
  end

  def test_binding_is_preserved
    env = {}
    env[:before] = []
    cmd = Rundoc::CodeCommand::PrintERBRunner.new(
      user_args: Rundoc::CodeCommand::PrintERBArgs.new,
      io: StringIO.new,
      contents: %{<%= @foo = SecureRandom.hex(16) %>},
      render_command: true,
      render_result: true
    )

    assert_equal "", cmd.to_md(env)
    assert_equal [], env[:before]
    expected = cmd.call

    assert !expected.empty?

    cmd = Rundoc::CodeCommand::PrintERBRunner.new(user_args: Rundoc::CodeCommand::PrintERBArgs.new, io: StringIO.new, render_command: true, render_result: true, contents: %(<%= @foo %>))

    assert_equal "", cmd.to_md(env)
    assert_equal expected, cmd.call
    assert_equal [], env[:before]

    cmd = Rundoc::CodeCommand::PrintERBRunner.new(user_args: Rundoc::CodeCommand::PrintERBArgs.new(binding: "different"), io: StringIO.new, render_command: true, render_result: true, contents: %(<%= @foo %>))

    assert_equal "", cmd.to_md(env)
    assert_equal "", cmd.call
    assert_equal [], env[:before]
  end
end
