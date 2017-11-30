# RunDOC

![](https://www.dropbox.com/s/u354td51brynr4h/Screenshot%202017-05-09%2009.36.33.png?raw=1)

## What

This library allows you to "run" your docs and embed the code as well as results back into the documentation.

Write in a runDOC compatible markdown format, then run your docs to generate matching projects. Instead of writing a tutorial and then building an example separately, your documentation can build the example app for you. Not only does this keep your doc writing DRY, it also enforces consistency and accuracy. If you make a typo in your docs your project won't build...you'll get early warning and be able to fix it before it has the opportunity to confuse your reader.

Think of runDOC as your ever-vigilant tech editor and writing partner.

Once docs are run, they output a project and fully valid markdown doc (without any of the special runDOC tags). You could configure your project to be automatically pushed to github or anything else you want afterwards, check out the config section.

Write more technical content, faster and with a better consistency by using runDOC.

## Why

I wrote a [Rails course for the University of Texas](http://schneems.com), that required I build an app and write
documentation at the same time. I enjoyed the experience but having to do both essentially doubled my work load, worse than the time wasted copying snippets between the two was my docs were prone to paste errors, keyboard slips, or me just forgetting to add sections that I had implemented in the app. The only way for me to find these errors was to give the docs to someone to actually follow them and build the project. This method of manually checking is extremely time consuming, prone to errors (the developer may work around problems instead of reporting them to you), and makes making minor edits a major pain. Instead of writing your docs once and iterating, I found adding sections required me to start from scratch.


While I was writing the course I dreamed of a system where the docs and the
code could automatically stay in sync. One where if I had a typo in my tutorials, an automatic tech-editor would know and tell me. One where I couldn't accidentally skip over critical sections leaving true novices confused.

Dream no more, because runDOC does just that:

Write docs, build software.

## Isn't this Overkill?

No. Many new doc writers skip steps accidentally, or omit lines of code with `...` and assume their readers can follow along. Even if this is true for 80% of your users, 20% of people will become frustrated and may give up as a result. I found by including [check steps](http://schneems.com/post/60359275700/prepare-do-test-make-your-technical-writing-shine) such as running `ls` to ensure directory contents were the difference between good docs and great ones. The only problem: the output of `ls` on a Rails 4.0.0 and 4.0.1 project may be different. So the only way to ensure output is to actually run the command and copy it into your docs. With runDOC you don't need to do that. Rundoc runs the command then it can insert the output for you.

If you don't intend on updating or revising your content, then this project is overkill. On the other hand if you're writing docs without the intent of revising them, you probably shouldn't be writing technical docs.

## Install

This software is distributed as a Rubygem. Install it manually:

```
$ gem install rundoc
```

or add it to your Gemfile:

```
gem 'rundoc`
```

## Use It

Run the `rundoc build` command on any markdown file

```sh
$ rundoc build --path runDOC.md
```

Note: This command will create and manipulate directories in the working directory of your source markdown file. Best practice is to have your source markdown file in its own empty directory.

This will generate a project folder with your project in it, and a markdown README.md with the parsed output of the markdown docs, and a copy of the source.

## Write it:

Rundoc uses github flavored markdown. This means you write like normal but in your code sections
you can add special annotations that when run through runDOC can
generate a project.

All runDOC commands are prefixed with three colons `:::` and are inclosed in a code block a
command such as `$` which is an alias for `bash` commands like this:

    ```
    :::> $ git init .
    ```

Nothing before the three colons matters. The space between the colons
and the command is optional.

If you don't want the command to output to your markdown document you
can add a minus symbol `-` to the end to prevent it from being
rendered.

    ```
    :::- $ git init .
    ```

> Note: If all commands inside of a code block are hidden, the entire codeblock will not be rendered.

If you want the output of the actual command to be rendered to
the screen you can use two arrows so that:

    ```
    :::>> $ ls
    ```

This code block might generate an output something like this to your markdown doc:

    ```
    $ ls
        Gemfile   README.rdoc app   config.ru doc   log   script    tmp
        Gemfile.lock  Rakefile  config    db    lib   public    test    vendor
    ```

That's the syntax, let's look at different runDOC commands

## Rendering Cheat Sheet

An arrow `>` is shorthand for "render this" and a dash `-` is shorthand for skip this section. The posions two positions are command first and result second. You can skip a trailing `-`.


- `:::>`  (yes command, not result)
- `:::>>` (yes command, yes result)
- `:::-`  (not command, not result)
- `:::->` (not command, yes result)

## Shell Commands

Current Commands:

- `$`
- `fail.$`

Anything you pass to `$` will be run in a shell. Any items below the command will be passed into the stdin of the bash command so:

    ```
    :::>> $ tail -n 2
    foo
    bar
    baz
    bahz
    ```

Would output:

   ```
   $ tail -n 2
   baz
   bahz
   ```

This STDIN feature could be useful if you are running an interactive command such as `play new` which requires user input. For more fine grained input you'll need to use a custom repl object (will be covered later).

If a shell command returns a non-zero exit status an error will be raised, if you expect a command to fail you can run it with `fail.$` keyword

    ```
    :::>> fail.$ cat /dev/null/foo
    ```

Even though this command returns a non zero exit status, the contents of the command will be written since we're stating that we don't care if the command fails. This would be the output:


    ```
    $ cat /dev/null/foo
    cat: /dev/null/foo: Not a directory
    ```

Some commands may be custom, for example when running `cd` you likely want to change the working directory that your script is running in. To do this we need to run `Dir.chdir` instead of shelling out. So this works as you would expect:


    ```
    :::>> $ cd myapp/config
    :::>> $ cat database.yml
    ```

However this command would fall on its face:

    ```
    :::>> $ cd myapp/config && cat database.yml
    ```

These custom commands are kept to a minimum, and for the most part behave as you would expect them to. Write your docs as you normally would and check the output frequently.

Running shell commands like this can be very powerful, you'll likely want more control of how you manipulate files in your project. To do this you can use the `file.` namespace:

## File Commands

Current Commands:

- `file.write`
- `file.append`
- `file.remove`

Use the `file.write` keyword followed by a filename, on the next line(s) put the contents of the file

    ```
    :::> file.write config/routes.rb

    Example::Application.routes.draw do
      root        :to => "pages#index"

      namespace :users do
        resources :after_signup
      end
    end
    ```

If you wanted to change `users` to `products` you could write to the same file again.

    ```
    :::> file.write config/routes.rb
    Example::Application.routes.draw do
      root        :to => "pages#index"

      namespace :products do
        resources :after_signup
      end
    end
    ```

To fully delete files use bash `$` command such as `::: $ rm foo.rb`.

To add contents to a file you can use `file.append`

    ```
    :::>> file.append myapp/Gemfile
    gem 'pg'
    gem 'sextant', group: :development
    gem 'wicked'
    gem 'opro'
    ```

The contents of the file (in this example a file named `Gemfile`) will remain unchanged, but the contents of the `file.append` block will now appear in the bottom of the file. If you want to append the contents to a specific part of the file instead of the end of the file you can specify line number by putting a hash (`#`) then a number following it.

    ```
    :::>> file.append myapp/Gemfile#22
    gem 'rails_12factor'
    ```
This will add the `gem 'rails_12factor'` on line 22 of the file `myapp/Gemfile`. If line 22 has existing contents, they will be bumped down to line 23.

Some times you may want to remove a small amount of text from an existing file. You can do this using `file.remove`, you pass in the contents you want removed:

    ```
    :::>> file.remove myapp/Gemfile
    gem 'sqlite3'
    ```

When this is run, the file `Gemfile` will be modified to not include `gem 'sqlite3'`.

Note: `file.remove` currently requires a very explicit match so things like double versus single quotes, whitespace, and letter case all matter. Current best practice is to only use it for single line removals.

## Pipe

Commands:
- `|`
- `pipe` (aliased `|`)

Sometimes you need to need to pass data from one command to another. To do this there is a provided pipe command `|`.

Let's say you want to output the first 23 lines of a file but you don't want to confuse your users with an additional pipe command in your shell line you could write something like this:

```sh
:::>  $ cat config/database.yml
:::>> | $ head -n 23
```

Anything after the pipe `|` will generate a new command with the output of the previous command passed to it. The pipe command will only ouput its result, so the user will not know it was even executed.

This command is currently hacked together, and needs a refactor. Use it, but if something does not behave as you would expected open an issue and explain it.


## Configure

You can configure your docs in your docs use the `runDOC` command

    ```
    :::- rundoc
    ```

Note: Make sure you run this as a hidden command (with `-`).

** After Build**

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


**Project Root**

By default your app builds in a `tmp` directory. If any failures occur the results will remain in `tmp`. On a successful build the contents are copied over to `project`. If you are generating a new rails project in your code `$ rails new myapp`. Then the finished directory would be in `project/myapp`. If you don't like the `./project` prefix you could tell runDOC to output contents in `./myapp` instead.

    ```
    :::- rundoc
    Rundoc.configure do |config|
      config.project_root = "myapp"
    end
    ```

This will also be the root directory that the `after_build` is executed in.

**Filter Sensitive Info**

Sometimes sensitive info like usernames, email addresses, or passwords may be introduced to the output readme. Let's say that your email address was `schneems@example.com` you could filter this out of your final document and replace it with `developer@example.com` instead like this:

    ```
    :::- rundoc
    Rundoc.configure do |config|
      config.filter_sensitive("schneems@exmaple.com" => "developer@example.com")
    end
    ```

This command `filter_sensitive` can be called multiple times with different values. Since the config is in Ruby you could iterate over an array of sensitive data

## TODO

This is a section for brainstorming. If it's here it's not guaranteed to get worked on, but it will be considered.

- Seperate parsing from running. This will help for easier linting of syntax etc.
- Cache SHAs and output of each code block. If one sha changes, re-generate all code blocks, otherwise allow a re-render without code execution. Configure a check sum for busting the cache for instance a new version of Rails is released.


- A way to run background processes indefinitely such as `rails server`
  - Maybe a way to truncate them after only a period of time such as grab a few lines of `heroku local`.


    ```
    :::> background.start(command: "rails server")
    ```

    ```
    :::>> background.read("rails server")
    :::> | $ head -n 23
    :::> background.clear
    ```


  - Breakpoints?
- Better line matching for backtrace
- `-=` command (runs command, only shows output, does not show command) ?
- An easy test syntax?
- Screenshot tool(s) ?!?!?!?!?!?! :)
