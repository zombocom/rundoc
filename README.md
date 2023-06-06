# RunDOC

![](https://www.dropbox.com/s/u354td51brynr4h/Screenshot%202017-05-09%2009.36.33.png?raw=1)

## What

This library allows you to "run" your docs and embed the code as well as results back into the documentation. Here's a quick example:

Write documentation:

    Install by running:

    ```
    :::>> $ gem install rails --no-document
    ```

Now if you "run" this document you'll get this output:

    Install by running:

    ```
    $ gem install rails --no-document
    Successfully installed rails-5.2.2
    1 gem installed
    ```

The idea is that as your documentation "runs" it builds a working tutorial. It also acts as tests since if your docs become incorrect due to a typo or bit-rot then when you try to generate them, the process will fail.

Think of RunDOC as your ever-vigilant tech editor and writing partner.

## Install

This software is distributed as a Rubygem. Install it manually:

```
$ gem install rundoc
```

or add it to your Gemfile:

```
gem 'rundoc'
```

## Use It

Run the `rundoc build` command on any markdown file

```sh
$ bin/rundoc build --path <test/fixtures/rails_7/rundoc.md>
```

> Note: This command will create and manipulate directories in the working directory of your source markdown file. Best practice is to have your source markdown file in its own empty directory.

This will generate a project folder with your project in it, and a markdown README.md with the parsed output of the markdown docs, and a copy of the source.

## Quick docs

- [Understanding the Syntax](#rundoc-syntax)
- [Dotenv support](#dotenv-support)
- [Rendering cheat sheet](#rendering-cheat-sheet)

### Commands

- Execute Bash Commands
  - [$](#shell-commands)
  - [fail.$](#shell-commands)
- Chain commands
  - [pipe](#pipe)
  - [|](#pipe)
- Manipulate Files
  - [file.write](#file-commands)
  - [file.append](#file-commands)
  - [file.remove](#file-commands)
- Boot background processes such as a local server
  - [background.start](#background)
  - [background.stop](#background)
  - [background.log.read](#background)
  - [background.log.clear](#background)
- Take screenshots
  - [website.visit](#screenshots)
  - [website.nav](#screenshots)
  - [website.screenshot](#screenshots)
- Configure RunDOC
  - [rundoc.configure](#configure)
- Import and compose documents
  - [rundoc.depend_on](#compose-multiple-rundoc-documents)
  - [rundoc.require](#compose-multiple-rundoc-documents)

## RunDOC Syntax

RunDOC uses GitHub flavored markdown. This means you write like normal but in your code sections
you can add special annotations that when run through RunDOC can
generate a project.

All RunDOC commands are prefixed with three colons `:::` and are inclosed in a code block a
command such as `$` which is an alias for `bash` commands like this:

    ```
    :::>- $ git init .
    ```

Nothing before the three colons matters. The space between the colons
and the command is optional.

If you don't want the command to output to your markdown document you
can add a minus symbol `-` to the end to prevent it from being
rendered.

    ```
    :::-- $ git init .
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

Any items below the command will be passed into the stdin of the command. For example using a `$` command you can effectively pipe contents to stdin:

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

This STDIN feature could be useful if you are running an interactive command such as `play new` which requires user input.

Different commands will do different things with this input. For example the `rundoc` command executes Ruby configuration code:

    ```
    :::-- rundoc
    Rundoc.configure do |config|
      config.after_build do
        puts "you could push to GitHub here"
        puts "You could do anything here"
        puts "This code will run after the docs are done building"
      end
    end
    ```


And the `website.visit` command allows you to navigate and manipulate a webpage via a Capybara API:

    ```
    :::>> website.visit(name: "localhost", url: "http://localhost:3000", scroll: 100)
    session.execute_script "window.scrollBy(0,100)"
    session.click("sign up")
    ```

### Exact output

RunDOC only cares about things that come after a `:::` section. If you have a "regular" code section, it will be rendered as as normal:

    ```
    $ echo "I won't run since i'm missing the :::>> at the front"
    ```

You can mix non-command code and commands, as long as the things that aren't rendering come first. This can be used to "fake" a command, for example:

```
$ rails new myapp # Not a command since it's missing the ":::>>""
:::-> $ rails new myapp --skip-test --skip-yarn --skip-sprockets
:::>> | $ head -n 5
```

This will render as:

```
$ rails new myapp # Not a command since it's missing the ":::>>""
      create
      create  README.md
      create  Rakefile
      create  .ruby-version
      create  config.ru
```

It looks like the command was run without any flags, but in reality `rails new myapp --skip-test --skip-yarn --skip-sprockets | head -n 5` was executed.

## Rendering Cheat Sheet

An arrow `>` is shorthand for "render this" and a dash `-` is shorthand for skip this section. The two positions are **command** first and **result** second.


- `:::>-` (YES command output, not result output)
- `:::>>` (YES command output, YES result output)
- `:::--` (not command output, not result output)
- `:::->` (not command output, YES result output)

## Shell Commands

Current Commands:

- `$`
- `fail.$`

Anything you pass to `$` will be run in a shell. If a shell command returns a non-zero exit status an error will be raised. If you expect a non-zero exit status use `fail.$` instead:


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
    :::>> $ cd myapp && cat config/database.yml
    :::>> $ rails g scaffold users # <=== This command would be in the wrong directory, not `myapp`
    ```

These custom commands are kept to a minimum, and for the most part behave as you would expect them to. Write your docs as you normally would and check the output frequently.

Running shell commands like this can be very powerful, you'll likely want more control of how you manipulate files in your project. To do this you can use the `file.` namespace:

## File Commands

Current Commands:

- `file.write`
- `file.append`
- `file.remove`

Use the `file.write` keyword followed by a filename, on the next line(s) put the contents of the file:

    ```
    :::>- file.write config/routes.rb

    Example::Application.routes.draw do
      root        :to => "pages#index"

      namespace :users do
        resources :after_signup
      end
    end
    ```

> If the exact filename is not known you can use a [file glob (\*)](https://GitHub.com/schneems/rundoc/pull/6).

If you wanted to change `users` to `products` you could write to the same file again.

    ```
    :::>- file.write config/routes.rb
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

## Background

Sometimes you want to start a long lived process like a server in the background. In that case, the `background` namespace has your, well, back.

To start a process, pass in the command as the first arg, and give it a name (so it can be referenced later):

```
:::>> background.start("rails server", name: "server")
```

You can make the background process wait until it receives a certain string in the logs. For instance to make sure that the server is fully booted:

```
:::>> background.start("rails server", name: "server", wait: "Listening on")
```

You can stop the process by referencing the name:

```
:::-- background.stop(name: "server")
```

You can also get the log contents:

```
:::>> background.log.read(name: "server")
```

You can also truncate the logs:

```
:::>> background.log.clear(name: "server")
```

## Screenshots

You'll need selenium and `chromedriver` installed on your system to make screenshots work. On a mac you can run:

```
$ brew cask install chromedriver
```

To take a screenshot first "visit" a website. The values you pass in to stdin can be used to further navigate. For more information see the [Capybara DSL](https://www.rubydoc.info/GitHub/teamcapybara/capybara/master#the-dsl). Use the keyword `session`

Once you're on the page you want to capture you can execute `website.screenshot`:

```
:::>> website.visit(name: "localhost", url: "http://localhost:3000", scroll: 100)
session.execute_script "window.scrollBy(0,100)"
session.first(:link, "sign up").click

:::>> website.screenshot(name: "localhost")
```

The result of the screenshot command will be to replace the code section with a markdown link to a relative path of the screenshot.

Once you've visited a website you can further navigate using `website.nav` or `website.navigate`:


```
:::>> website.visit(name: "localhost", url: "http://localhost:3000")
:::>> website.navigate(name: "localhost")
session.execute_script "window.scrollBy(0,100)"
session.first(:link, "sign up").click

:::>> website.screenshot(name: "localhost")
```

## Upload Screenshots

You can specify that you want to upload files to S3 instead of hosting them locally by passing in `upload: "s3"` to the screenshot command:

```
:::>> website.visit(name: "localhost", url: "http://localhost:3000", scroll: 100)
:::>> website.screenshot(name: "localhost", upload: "s3")
```

To authorize, you'll need to set these environment variables:

```
AWS_ACCESS_KEY_ID
AWS_REGION
AWS_SECRET_ACCESS_KEY
AWS_BUCKET_NAME
```

The bucketeer addon on Heroku is supported out of the box. To specify project specific environment variables see the "dotenv" section below.

## Compose multiple RunDOC documents

If you're writing multiple tutorials that all are used together to build one larger project then you can declare dependencies inside of your RunDOC document.

For example on day two (`day_two/rundoc.md`) of the tutorials you could:

```
:::-- rundoc.depend_on "../day_one/rundoc.md"
```

Now when you build `day_two/rundoc.md` it will also run the steps in `day_one/rundoc.md` first. This way you don't have to copy and paste previous commands.

You can also break up your document into smaller components:


```
:::>> rundoc.require "../shared/rails_new.md"
```

This will replace the code section with the generated contents of `rundoc.require`.


## Dotenv support

If you need to specify project specific environment variables create a file called `.env` at the same directory as your `rundoc.md` and it will be imported. Add this file to your `.gitignore` so you don't accidentally share with the world

## Configure

You can configure your docs in your docs use the `RunDOC` command

    ```
    :::-- rundoc.configure
    ```

Note: Make sure you run this as a hidden command (with `-`).

**After Build**

This will eval any code you put under that line (in Ruby). If you want to run some code after you're done building your docs you could use `Rundoc.configure` block and call the `after_build` method like this:


    ```
    :::-- rundoc.configure
    Rundoc.configure do |config|
      config.after_build do
        puts "you could push to GitHub here"
        puts "You could do anything here"
        puts "This code will run after the docs are done building"
      end
    end
    ```


**Project Root**

By default your app builds in a `tmp` directory. If any failures occur the results will remain in `tmp`. On a successful build the contents are copied over to `project`. If you are generating a new rails project in your code `$ rails new myapp`. Then the finished directory would be in `project/myapp`. If you don't like the `./project` prefix you could tell RunDOC to output contents in `./myapp` instead.

    ```
    :::-- rundoc.configure
    Rundoc.configure do |config|
      config.project_root = "myapp"
    end
    ```

This will also be the root directory that the `after_build` is executed in.

**Filter Sensitive Info**

Sometimes sensitive info like usernames, email addresses, or passwords may be introduced to the output readme. Let's say that your email address was `schneems@example.com` you could filter this out of your final document and replace it with `developer@example.com` instead like this:

    ```
    :::-- rundoc.configure
    Rundoc.configure do |config|
      config.filter_sensitive("schneems@example.com" => "developer@example.com")
    end
    ```

This command `filter_sensitive` can be called multiple times with different values. Since the config is in Ruby you could iterate over an array of sensitive data

## Copyright

All content Copyright Richard Schneeman © 2020
