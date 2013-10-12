## Rundoc

## What

Don't just write your docs, run them. Add dynamic content to your docs and build projects all from one source.

## Why

I wrote a Rails course, that required I build an app and write
documentation for building said app. I dreamed of a system where the docs and the
code could automatically stay in sync. One where if I had a typo in my tutorials, I could get a computer
to tell me about it. One where I couldn't accidentally cheat or skip over critical sections.

This is that project.

Write docs that build software.

Why docs to code and not code to docs? Code is hard, cold and machine runnable. Docs are soft, consumed by people, and need high flexability. It's easier to explicitly tell the machine what code you want generated, then to go the other way.

## Install

For now this software is distributed as a rubygem. Install it manually:

```
$ gem install rundoc
```

or add it to your Gemfile:

```
gem 'rundoc`
```

## Use It

Run the `rundoc build` command on any makdown file

```sh
  $ rundoc build my_file.md
```

This will generate a project folder with your project in it, and a markdown README.md with the parsed output of the markdown docs.

## Write it

Rundoc uses github flavored markdown and the html-pipeline behind
the scenes. This means you write like normal but in your code sections
you can add special annotations that when run through rundoc can
generate a project.

All rundoc commands are prefixed with three colons `:::` and are inclosed in a code block a
command such as `$` which is an alias for `bash` commands like this:

    ```
    ::: $ git init .
    ```

Nothing before the three colons matters. The space between the colons
and the command is optional.

If you don't want the command to output to your markdown document you
can add a minus symbol `-` to the end to prevent it from being
rendered.

    ```
    :::- $ git init .
    ```

Note: If all commands inside of a code block are hidden, the entire codeblock will not be rendered.

If you want the output of the actual command to be rendered to
the screen you can use an equal sign so that

    ```
    :::= $ ls
    ```

This code block might generate an output something like this to your markdown doc:

    ```
    $ ls
        Gemfile   README.rdoc app   config.ru doc   log   script    tmp
        Gemfile.lock  Rakefile  config    db    lib   public    test    vendor
    ```

That's how you manipulate the shell with rundoc, let's take a look at manipulating files.


## Files

Right now you can only write to files. Use the `write` keyword followed by a filename, on the next line(s) put the contents of the file

    ```
    ::: write config/routes.rb

    Example::Application.routes.draw do
      root        :to => "pages#index"

      namespace :users do
        resources :after_signup
      end
    end
    ```

If you wanted to change `users` to `products` you would write to the same file again.

    ```
    ::: write config/routes.rb
    Example::Application.routes.draw do
      root        :to => "pages#index"

      namespace :products do
        resources :after_signup
      end
    end
    ```

To delete files use bash `$` command.


## Configure

You can configure your docs in your docs use the `rundoc` command

    ```
    :::- rundoc

    ```

Note: Make sure you run this as a hidden command (with `-`).

This will eval any code you put under that line (in Ruby). If you want to run some code after you're done building your docs you could use `Rundoc.configure` block and call the `after_build` method like this:


    ```
    :::- rundoc
    Rundoc.configure do |config|
      config.after_build do
        puts "you could push to github here"
        puts "You could do anything here"
        puts "This code will run after the docs are done building"
      end
    end
    ```

To set the root of your project (defaults to './project') to something else like `./project/myapp` you can use `config.project_root`.


    ```
    :::- rundoc
    Rundoc.configure do |config|
      config.project_root = "myapp"
    end
    ```

Now when your `README.md` and `source.md` get written they will go into `project/myapp/README.md` and `project/myapp/source.md`. This will also be the root directory that the `after_build` is executed in.

## TODO

- Debug output
- Fail and exit on non zero exit code
- Breakpoints?
- Bash commands with side effects (cd; pwd; on different lines should actually change working directory)
- Better line matching for backtrace
- `-=` command (only shows output)