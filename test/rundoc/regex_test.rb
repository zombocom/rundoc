require "test_helper"

class RegexTest < Minitest::Test
  def setup
  end

  def test_indent_regex
    contents = <<~RUBY
      foo
      
          $ cd
          yo
          sup
      
      bar
    RUBY

    regex = Rundoc::Parser::INDENT_BLOCK
    parsed = contents.match(/#{regex}/).to_s
    assert_equal "\n    $ cd\n    yo\n    sup\n", parsed
  end

  def test_github_regex
    contents = <<~RUBY
      foo
      
      ```
      $ cd
      yo
      sup
      ```
      
      bar
    RUBY

    regex = Rundoc::Parser::GITHUB_BLOCK
    parsed = contents.match(/#{regex}/m).to_s
    assert_equal "```\n$ cd\nyo\nsup\n```\n", parsed
  end

  def test_github_tagged_regex
    contents = <<~RUBY
      foo
      
      ```ruby
      $ cd
      yo
      sup
      ```
      
      bar
    RUBY

    regex = Rundoc::Parser::GITHUB_BLOCK
    parsed = contents.match(/#{regex}/m).to_s
    assert_equal "```ruby\n$ cd\nyo\nsup\n```\n", parsed
  end

  def test_command_regex
    regex = Rundoc::Parser::COMMAND_REGEX.call(":::")

    contents = ":::$ mkdir schneems"
    match = contents.match(regex)
    assert_equal "", match[:tag]
    assert_equal "$", match[:command]
    assert_equal "mkdir schneems", match[:statement]

    contents = ":::=$ mkdir schneems"
    match = contents.match(regex)
    assert_equal "=", match[:tag]
    assert_equal "$", match[:command]
    assert_equal "mkdir schneems", match[:statement]

    contents = ":::=       $ mkdir schneems"
    match = contents.match(regex)
    assert_equal "=", match[:tag]
    assert_equal "$", match[:command]
    assert_equal "mkdir schneems", match[:statement]

    contents = ":::-$ mkdir schneems"
    match = contents.match(regex)
    assert_equal "-", match[:tag]
    assert_equal "$", match[:command]
    assert_equal "mkdir schneems", match[:statement]

    contents = ":::- $ mkdir schneems"
    match = contents.match(regex)
    assert_equal "-", match[:tag]
    assert_equal "$", match[:command]
    assert_equal "mkdir schneems", match[:statement]
  end

  def test_codeblock_regex
    contents = <<~RUBY
      foo
      
      ```
      :::>$ mkdir
      ```
      
      zoo
      
      ```
      :::>$ cd ..
      something
      ```
      
      bar
    RUBY

    regex = Rundoc::Parser::CODEBLOCK_REGEX

    actual = contents.partition(regex)
    expected = ["foo\n\n",
      "```\n:::>$ mkdir\n```\n",
      "\nzoo\n\n```\n:::>$ cd ..\nsomething\n```\n\nbar\n"]

    assert_equal expected, actual

    str = "```\n:::$ mkdir\n```\n"
    match = str.match(regex)
    assert_equal ":::$ mkdir\n", match[:contents]

    str = "\n\n```\n:::$ cd ..\nsomething\n```\n\nbar\n"
    match = str.match(regex)
    assert_equal ":::$ cd ..\nsomething\n", match[:contents]

    # partition, shift, codebloc,
  end

  def test_complex_regex
    contents = <<~RUBY
      ```java
      :::>> write app/controllers/Application.java
      package controllers;
      
      import static java.util.concurrent.TimeUnit.SECONDS;
      import models.Pinger;
      import play.libs.Akka;
      import play.libs.F.Callback0;
      import play.mvc.Controller;
      import play.mvc.Result;
      import play.mvc.WebSocket;
      import scala.concurrent.duration.Duration;
      import views.html.index;
      import akka.actor.ActorRef;
      import akka.actor.Cancellable;
      import akka.actor.Props;
      
      public class Application extends Controller {
          public static WebSocket<String> pingWs() {
              return new WebSocket<String>() {
                  public void onReady(WebSocket.In<String> in, WebSocket.Out<String> out) {
                      final ActorRef pingActor = Akka.system().actorOf(Props.create(Pinger.class, in, out));
                      final Cancellable cancellable = Akka.system().scheduler().schedule(Duration.create(1, SECONDS),
                                                         Duration.create(1, SECONDS),
                                                         pingActor,
                                                         "Tick",
                                                         Akka.system().dispatcher(),
                                                         null
                                                         );
      
                      in.onClose(new Callback0() {
                        @Override
                        public void invoke() throws Throwable {
                          cancellable.cancel();
                        }
                      });
                  }
      
              };
          }
      
          public static Result pingJs() {
              return ok(views.js.ping.render());
          }
      
          public static Result index() {
              return ok(index.render());
          }
      }
      ```
    RUBY

    regex = Rundoc::Parser::CODEBLOCK_REGEX
    match = contents.match(regex)
    assert_equal "java", match[:lang]
    assert_equal "```", match[:fence]
    assert_equal "`", match[:fence_char]

    assert_equal contents.strip, match.to_s.strip
  end

  def test_codeblock_optional_newline_regex
    code_block_with_newline = <<~MD
      hi
      ```
      :::>> $ echo "hello"
      ```
    MD
    code_block_without_newline = code_block_with_newline.strip

    expected = <<~MD.strip
      ```
      :::>> $ echo "hello"
      ```
    MD
    regex = Rundoc::Parser::CODEBLOCK_REGEX
    match = code_block_with_newline.match(regex)
    assert_equal expected, match.to_s.strip

    match = code_block_without_newline.match(regex)
    assert_equal expected, match.to_s.strip
  end
end
