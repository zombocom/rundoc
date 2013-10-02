## Docdown

## What

Write your code/docs once, don't repeat yourself. Changes/updates to docs are guaranteed to match your project

## Why

I wrote a Rails course, that required I build an app and write
documentation for building said app. Wouldn't it be cool if instead
while I write the documentation I could automate the building of my
app?

Totally! That's this, this is that thing.

Write docs that build software.

Why docs to code and not code to docs? Code is hard, cold and machine runnable. Docs are soft, consumed by people, and need high flexability. It's easier to explicitly tell the machine what code you want generated, then to go the other way.

## Install

For now this software is distributed as a rubygem. Install it manually:

```
$ gem install docdown
```

or add it to your Gemfile:

```
gem 'docdown`
```

## Use It

Run the docdown command on any makdown file

```sh
  $ docdown build my_file.md
```

This will generate a project folder with your project in it, and a markdown README.md with the parsed output of the markdown docs.

## Write it

Docdown uses github flavored markdown and the html-pipeline behind
the scenes. This means you write like normal but in your code sections
you can add special annotations that when run through docdown can
generate a project.

All docdown commands are prefixed with three colons `:::` and are inclosed in a code block a
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

If you want the output of the actual command to be rendered to
the screen you can use an equal sign so that

    ```
    :::= $ ls
    ```

Might generate an output something like this to your markdown doc:

    ```
    $ ls
        Gemfile   README.rdoc app   config.ru doc   log   script    tmp
        Gemfile.lock  Rakefile  config    db    lib   public    test    vendor
    ```

That's how you manipulate the shell with docdown, let's take a look at manipulating code.


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



