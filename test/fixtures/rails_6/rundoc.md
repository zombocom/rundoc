```
:::-- rundoc
email = ENV['HEROKU_EMAIL'] || `heroku auth:whoami`

Rundoc.configure do |config|
  config.project_root = "myapp"
  config.filter_sensitive(email => "developer@example.com")
end
```

<!--
  rundoc src:
  https://github.com/schneems/rundoc/blob/master/test/fixtures/rails_6/rundoc.md

  Command:
  $ bin/rundoc build --path test/fixtures/rails_6/rundoc.md
-->

Ruby on Rails is a popular web framework written in [Ruby](http://www.ruby-lang.org/). This guide covers using Rails 6 on Heroku. For information on running previous versions of Rails on Heroku, see the tutorial for [Rails 5.x](getting-started-with-rails5) or [Rails 4.x](getting-started-with-rails4).

```
:::-- $ ruby -e "exit 1 unless RUBY_VERSION == '2.6.5'"
```

For this guide you will need:

- Basic familiarity with Ruby/Rails and Git
- A locally installed version of Ruby 2.5.0+, Rubygems, Bundler, and Rails 6+
- A Heroku user account: [Signup is free and instant](https://signup.heroku.com/devcenter).

## Local setup

Install the [Heroku CLI](heroku-cli#download-and-install) on your development machine.

Once installed, the `heroku` command is available from your terminal. Log in using your Heroku account's email address and password:

```term
$ heroku login
heroku: Enter your Heroku credentials
Email: schneems@example.com
Password:
Could not find an existing public key.
Would you like to generate one? [Yn]
Generating new SSH public key.
Uploading ssh public key /Users/adam/.ssh/id_rsa.pub
```

Press Enter at the prompt to upload your existing `ssh` key or create a new one, used for pushing code later on.

## Create a new Rails app (or upgrade an existing one)

To create a new app, first make sure that you're using Rails 6.x by running `rails -v`. If necessary, you can get the new version of rails by running the following:

```term
:::>> $ gem install rails --no-document
```

Then create a new app and move into its root directory:

```term
:::>- $ rails new myapp --database=postgresql
```

Then move into your application directory.

```term
:::>- $ cd myapp
```

## Add the pg gem

If you're using an existing app that was created without specifying `--database=postgresql`, you need to add the `pg` gem to your Rails project. Edit your `Gemfile` and change this line:

```ruby
gem 'sqlite3'
```

To this:

```ruby
gem 'pg'
```

> callout We highly recommend using PostgreSQL during development. Maintaining [parity between your development](http://www.12factor.net/dev-prod-parity) and deployment environments prevents subtle bugs from being introduced because of differences between your environments. [Install Postgres locally](heroku-postgresql#local-setup) now if it is not already on your system.

Now re-install your dependencies (to generate a new `Gemfile.lock`):

```ruby
$ bundle install
```

For more information on why Postgres is recommended instead of Sqlite3, see [why you cannot use Sqlite3 on Heroku](sqlite3).

In addition to using the `pg` gem, ensure that your `config/database.yml` file is using the `postgresql` adapter. The development section of your `config/database.yml` file should look something like this:

```term
:::>>  $ cat config/database.yml
```

Be careful here. If you omit the `sql` at the end of `postgresql` in the `adapter` section, your application will not work.

## Create a welcome page

Rails 6 no longer has a static index page in production by default. When you're using a new app, there will not be a root page in production, so we need to create one. We will first create a controller called `welcome` for our home page to live:

```term
:::>- $ rails generate controller welcome
```

Next we'll add an index page:

```html
:::>> file.write app/views/welcome/index.html.erb
<h2>Hello World</h2>
<p>
  The time is now: <%= Time.now %>
</p>
```

Now we need to make Rails route to this action. We'll edit `config/routes.rb` to set the index page to our new method:

```ruby
:::>> file.append config/routes.rb#2
  root 'welcome#index'
```

You can verify that the page is there by running your server:

```term
:::>> background.start("rails server", name: "server")
:::-- background.stop(name: "server")
```

And visiting [http://localhost:3000](http://localhost:3000) in your browser. If you do not see the page, [use the logs](#view-logs) that are output to your server to debug.

## Heroku gems

Previous versions of Rails required you to add a gem to your project [rails_12factor](https://github.com/heroku/rails_12factor) to enable static asset serving and logging on Heroku. If you are deploying a new application, this gem is not needed. If you are upgrading an existing application, you can remove this gem provided you have the appropriate configuration in your `config/environments/production.rb` file:


```ruby
# config/environments/production.rb
config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

if ENV["RAILS_LOG_TO_STDOUT"].present?
  logger           = ActiveSupport::Logger.new(STDOUT)
  logger.formatter = config.log_formatter
  config.logger = ActiveSupport::TaggedLogging.new(logger)
end
```

## Specify your Ruby version

Rails 6 requires Ruby 2.2.0 or above. Heroku has a recent version of Ruby installed by default, however you can specify an exact version by using the `ruby` DSL in your `Gemfile`. Depending on your version of Ruby that you are currently running it might look like this:


```ruby
:::-- $ sed -i'' -e '/^ruby/d' ./Gemfile
:::-> file.append Gemfile#4
ruby "2.6.5"
```

You should also be running the same version of Ruby locally. You can check this by running `$ ruby -v`. You can get more information on [specifying your Ruby version on Heroku here](https://devcenter.heroku.com/articles/ruby-versions).

## Store your app in Git

Heroku relies on [Git](http://git-scm.com/), a distributed source control management tool, for deploying your project. If your project is not already in Git, first verify that `git` is on your system:

```term
:::>- $ git --help
:::>> | $ head -n 5
```

If you don't see any output or get `command not found` you need to install Git on your system.

Once you've verified that Git works, first make sure you are in your Rails app directory by running `$ ls`:

The output should look like this:

```term
:::>> $ ls
```

Now run these commands in your Rails app directory to initialize and commit your code to Git:

```term
:::>- $ git init
:::>- $ git add .
:::>- $ git commit -m "init"
```

You can verify everything was committed correctly by running:

```term
:::>> $ git status
```

Now that your application is committed to Git you can deploy to Heroku.

## Deploy your application to Heroku

Make sure you are in the directory that contains your Rails app, then create an app on Heroku:

```term
:::>> $ heroku create
```

You can verify that the remote was added to your project by running:

```term
:::>> $ git config --list | grep heroku
```

If you see `fatal: not in a git directory` then you are likely not in the correct directory. Otherwise, you can deploy your code. After you deploy your code, you need to migrate your database, make sure it is properly scaled, and use logs to debug any issues that come up.

Deploy your code:

```term
:::>> $ git push heroku master
```

It is always a good idea to check to see if there are any warnings or errors in the output. If everything went well you can migrate your database.

## Migrate your database

If you are using the database in your application, you need to manually migrate the database by running:

```term
$ heroku run rake db:migrate
```

Any commands after the `heroku run` are executed on a Heroku [dyno](dynos). You can obtain an interactive shell session by running `$ heroku run bash`.

## Visit your application

You've deployed your code to Heroku. You can now instruct Heroku to execute a process type. Heroku does this by running the associated command in a [dyno](dynos), which is a lightweight container that is the basic unit of composition on Heroku.

Let's ensure we have one dyno running the `web` process type:

```term
:::>- $ heroku ps:scale web=1
```

You can check the state of the app's dynos. The `heroku ps` command lists the running dynos of your application:

```term
:::>> $ heroku ps
```

Here, one dyno is running.

We can now visit the app in our browser with `heroku open`.

```term
:::>> $ heroku open
```

You should now see the "Hello World" text we inserted above.

Heroku gives you a default web URL for simplicity while you are developing. When you are ready to scale up and use Heroku for production you can add your own [custom domain](https://devcenter.heroku.com/articles/custom-domains).

## View logs

If you run into any problems getting your app to perform properly, you will need to check the logs.

You can view information about your running app using one of the [logging commands](logging), `heroku logs`:

```term
:::>> $ heroku logs
```

You can also get the full stream of logs by running the logs command with the `--tail` flag option like this:

```term
$ heroku logs --tail
```

## Dyno sleeping and scaling

By default, new applications are deployed to a free dyno. Free apps will "sleep" to conserve resources. You can find more information about this behavior by reading about [free dyno behavior](free-dyno-hours).

To avoid dyno sleeping, you can upgrade to a hobby or professional dyno type as described in the [Dyno Types](dyno-types) article. For example, if you migrate your app to a professional dyno, you can easily scale it by running a command telling Heroku to execute a specific number of dynos, each running your web process type.

## Run the Rails console

Heroku allows you to run commands in a [one-off dyno](one-off-dynos) - scripts and applications that only need to be executed when needed - using the `heroku run` command. Use this to launch a Rails console process attached to your local terminal for experimenting in your app's environment:

```term
$ heroku run rails console
irb(main):001:0> puts 1+1
2
```

Another useful command for debugging is `$ heroku run bash` which will spin up a new dyno and give you access to a bash session.

## Run Rake commands

Rake can be run as an attached process exactly like the console:

```term
$ heroku run rake db:migrate
```

## Configure your webserver

By default, your app's web process runs `rails server`, which uses Puma in Rails 6. If you are upgrading an app you'll need to add `puma` to your application `Gemfile`:

```ruby
gem 'puma'
```

Then run

```term
:::>- $ bundle install
```

Now you are ready to configure your app to use Puma. For this tutorial we will use the default `config/puma.rb` of that ships with Rails 6, but we recommend reading more about configuring your application for maximum performance by [reading the Puma documentation](https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server).

Finally you will need to tell Heroku how to run your Rails app by creating a `Procfile` in the root of your application directory.

### Create a Procfile

Change the command used to launch your web process by creating a file called [Procfile](procfile) and entering this:

```
:::>> file.write Procfile
web: bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-development}
```

> Note: This file must be named `Procfile` exactly.

We recommend generating a Puma config file based on [our Puma documentation](https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server) for maximum performance.

To use the Procfile locally, you can use `heroku local`.

In addition to running commands in your `Procfile` `heroku local` can also help you manage environment variables locally through a `.env` file. Set the local `RACK_ENV` to development in your environment and a `PORT` to connect to. Before pushing to Heroku you'll want to test with the `RACK_ENV` set to production since this is the environment your Heroku app will run in.

```term
:::>> $ echo "RACK_ENV=development" >>.env
:::>> $ echo "PORT=3000" >> .env
```

> Note: Another alternative to using environment variables locally with a `.env` file is the [dotenv](https://github.com/bkeepers/dotenv) gem.

You'll also want to add `.env` to your `.gitignore` since this is for local environment setup.

```term
:::>- $ echo ".env" >> .gitignore
:::>- $ git add .gitignore
:::>- $ git commit -m "add .env to .gitignore"
```

If you're running Rails 6.0.0 you'll need to create a `tmp/pids` directory:

```term
:::>> $ mkdir -p tmp/pids
:::>> $ touch tmp/pids/.gitkeep
```

Test your Procfile locally using Foreman. You can now start your web server by running:

```term
:::>> background.start("heroku local", name: "local", wait: "Ctrl-C to stop", timeout: 15)
:::-- background.stop(name: "local")
```

Looks good, so press `Ctrl+C` to exit and you can deploy your changes to Heroku:

```term
:::>- $ git add .
:::>- $ git commit -m "use puma via procfile"
:::>- $ git push heroku master
```

Check `ps`. You'll see that the web process uses your new command specifying Puma as the web server.

```term
:::>> $ heroku ps
```

The logs also reflect that we are now using Puma.

```term
$ heroku logs
```

## Rails asset pipeline

There are several options for invoking the [Rails asset pipeline](http://guides.rubyonrails.org/asset_pipeline.html) when deploying to Heroku. For general information on the asset pipeline please see the [Rails 3.1+ Asset Pipeline on Heroku Cedar](rails-asset-pipeline) article.

The `config.assets.initialize_on_precompile` option has been removed is and not needed for Rails 6. Also, any failure in asset compilation will now cause the push to fail. For Rails 6 asset pipeline support see the [Ruby Support](ruby-support#rails-5-x-applications) page.

## Troubleshooting

If you push up your app and it crashes (`heroku ps` shows state `crashed`), check your logs to find out what went wrong. Here are some common problems.

### Runtime dependencies on development/test gems

If you're missing a gem when you deploy, check your Bundler groups. Heroku builds your app without the `development` or `test` groups, and if your app depends on a gem from one of these groups to run, you should move it out of the group.

One common example is using the RSpec tasks in your `Rakefile`. If you see this in your Heroku deploy:

```term
$ heroku run rake -T
Running `bundle exec rake -T` attached to terminal... up, ps.3
rake aborted!
no such file to load -- rspec/core/rake_task
```
Then you've hit this problem. First, duplicate the problem locally:

```term
$ bundle install --without development:test
…
$ bundle exec rake -T
rake aborted!
no such file to load -- rspec/core/rake_task
```

> Note: The `--without` option on bundler is sticky. You can get rid of this option by running `bundle config --delete without`.

Now you can fix it by making these Rake tasks conditional on the gem load. For example:

```ruby
begin
  require "rspec/core/rake_task"

  desc "Run all examples"

  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = %w[--color]
    t.pattern = 'spec/**/*_spec.rb'
  end
rescue LoadError
end
```

Confirm it works locally, then push to Heroku.

## Next steps

Congratulations! You have deployed your first Rails 6 application to Heroku. Here's some recommended reading:

* Visit the [Ruby support category](/categories/ruby-support) to learn more about using Ruby and Rails on Heroku.
* The [Deployment category](/categories/deployment) provides a variety of powerful integrations and features to help streamline and simplify your deployments.
