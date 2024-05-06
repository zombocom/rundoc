require "test_helper"

class PrintTest < Minitest::Test
  def test_plain_text_before_block
    env = {}
    env[:before] = []

    input = %Q{$ rails new myapp # Not a command since it's missing the ":::>>"}
    cmd = Rundoc::CodeCommand::PrintText.new(input)
    cmd.render_command = false
    cmd.render_result = true

    assert_equal "", cmd.to_md(env)
    assert_equal "", cmd.call
    assert_equal ["$ rails new myapp # Not a command since it's missing the \":::>>\""], env[:before]
  end

  def test_plain_text_in_block
    env = {}
    env[:before] = []

    input = %Q{$ rails new myapp # Not a command since it's missing the ":::>>"}
    cmd = Rundoc::CodeCommand::PrintText.new(input)
    cmd.render_command = true
    cmd.render_result = true

    assert_equal "", cmd.to_md(env)
    assert_equal input, cmd.call

    assert_equal [], env[:before]
  end

  def test_erb_before_block
    env = {}
    env[:before] = []

    input = %Q{$ rails new <%= 'myapp' %> # Not a command since it's missing the ":::>>"}
    cmd = Rundoc::CodeCommand::PrintERB.new(input)
    cmd.render_command = false
    cmd.render_result = true

    assert_equal "", cmd.to_md(env)
    assert_equal "", cmd.call
    assert_equal ["$ rails new myapp # Not a command since it's missing the \":::>>\""],
      env[:before]
  end

  def test_erb_in_block
    env = {}
    env[:before] = []

    cmd = Rundoc::CodeCommand::PrintERB.new()
    cmd.contents = %Q{<%= "foo" %>}
    cmd.render_command = true
    cmd.render_result = true

    assert_equal "", cmd.to_md(env)
    assert_equal "foo", cmd.call
    assert_equal [], env[:before]
  end

  def test_binding_is_preserved
    env = {}
    env[:before] = []
    cmd = Rundoc::CodeCommand::PrintERB.new()
    cmd.contents = %Q{<%= @foo = SecureRandom.hex(16) %>}
    cmd.render_command = true
    cmd.render_result = true

    assert_equal "", cmd.to_md(env)
    assert_equal [], env[:before]
    expected = cmd.call

    assert !expected.empty?

    cmd = Rundoc::CodeCommand::PrintERB.new()
    cmd.contents = %Q{<%= @foo %>}
    cmd.render_command = true
    cmd.render_result = true

    assert_equal "", cmd.to_md(env)
    assert_equal expected, cmd.call
    assert_equal [], env[:before]

    cmd = Rundoc::CodeCommand::PrintERB.new(binding: "different")
    cmd.contents = %Q{<%= @foo %>}
    cmd.render_command = true
    cmd.render_result = true

    assert_equal "", cmd.to_md(env)
    assert_equal "", cmd.call
    assert_equal [], env[:before]
  end
end
