```
:::- rundoc
email = ENV['HEROKU_EMAIL'] || `heroku auth:whoami`

Rundoc.configure do |config|
  config.project_root = "myapp"
  config.filter_sensitive(email => "developer@example.com")
end
```

Ruby on Rails is a popular web framework written in [Ruby](http://www.ruby-lang.org/). This guide covers using Rails 4 on Heroku, running previous versions of Rails on Heroku see [Getting Started with Rails 3.x on Heroku](https://devcenter.heroku.com/articles/rails3).

> callout If you are already familiar with Heroku and Rails, reference the [simplifed Rails 4 on Heroku guide](https://devcenter.heroku.com/articles/rails4) instead. For general information on how to develop and architect apps for use on Heroku, see [Architecting Applications for Heroku](https://devcenter.heroku.com/articles/architecting-apps).

For this guide you will need:

- Basic Ruby/Rails knowledge
- Locally installed version of Ruby 2.0.0+, Rubygems, Bundler, and Rails 4+
- Basic Git knowledge
- A Heroku user account: [Signup is free and instant](https://api.heroku.com/signup/devcenter)

## Local Workstation Setup

Install the [Heroku Toolbelt](https://toolbelt.heroku.com/) on your local workstation. This ensures that you have access to the [Heroku command-line client](/categories/command-line), Foreman, and the Git revision control system. You will also need [Ruby and Rails installed](http://guides.railsgirls.com/install/).

Once installed, you'll have access to the `$ heroku` command from your command shell. Log in using the email address and password you used when creating your Heroku account:


> callout Note that `$` symbol before commands indicates they should be run on the command line, prompt, or terminal with appropriate permissions. Do not copy the `$` symbol.

```sh
$ heroku login
Enter your Heroku credentials.
Email: schneems@example.com
Password:
Could not find an existing public key.
Would you like to generate one? [Yn]
Generating new SSH public key.
Uploading ssh public key /Users/adam/.ssh/id_rsa.pub
```

Press enter at the prompt to upload your existing `ssh` key or create a new one, used for pushing code later on.

## Write your App

> callout To run on Heroku your app must be configured to use the Postgres database, have all dependencies declared in your `Gemfile`, and have the `rails_12factor` gem in the production group of your `Gemfile`


You may be starting from an existing app, if so [upgrade to Rails 4](http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-3-2-to-rails-4-0) before continuing. If not, a vanilla Rails 4 app will serve as a suitable sample app. To build a new app make sure that you're using the Rails 4.x using `$ rails -v`. You can get the new version of rails by running,

```sh
:::= $ gem install rails --no-ri --no-rdoc
```

Then create a new app:

```sh
::: $ rails new myapp --database=postgresql
```

Once finished change your directory to the newly created Rails app

```sh
::: $ cd myapp
```

> callout If you experience problems or get stuck with this tutorial, your questions may be answered in a later part of this document. Once you experience a problem try reading through the entire document and then going back to your issue. It can also be useful to review your previous steps to ensure they all executed correctly.

Rails 4 no longer has a static index page in production. When you're using a new app, there will not be a root page in production, so we need to create one. We will first create a controller called `welcome` for our home page to live:

```sh
::: $ rails generate controller welcome
```

Next we'll add an index page.

```sh
:::= file.write app/views/welcome/index.html.erb
<h2>Hello World</h2>
<p>
  The time is now: <%= Time.now %>
</p>
```

Now we need to have Rails route to this action. We'll edit `config/routes.rb` to set the index page to our new method:

```ruby
:::= file.append config/routes.rb#2
  root 'welcome#index'
```

You can verify that the page is there by running your server:

```sh
$ rails server
```

And visiting [http://localhost:3000](http://localhost:3000) in your browser. If you do not see the page, use the logs that are output to your server to debug.

## Heroku gems

Heroku integration has previously relied on using the Rails plugin system, which has been removed from Rails 4. To enable features such as static asset serving and logging on Heroku please add `rails_12factor` gem to your `Gemfile`.

```ruby
:::= file.append Gemfile
gem 'rails_12factor', group: :production
```

Then run:

```sh
::: $ bundle install
```

We talk more about Rails integration on our [Ruby Support page](https://devcenter.heroku.com/articles/ruby-support#injected-plugins).

## Use Postgres

> callout We highly recommend using PostgreSQL during development. Maintaining [parity between your development](http://www.12factor.net/dev-prod-parity) and deployment environments prevents subtle bugs from being introduced because of differences between your environments. [Install Postgres locally](https://devcenter.heroku.com/articles/heroku-postgresql#local-setup) now if it is not allready on your system.

If you did not specify `postgresql` while creating your app (using `--database=postgresql`) you will need to add the `pg` gem to your Rails project. Edit your `Gemfile` and change this line:

```ruby
gem 'sqlite3'
```

To this:

```ruby
gem 'pg'
```

You can get more information on why this change is needed and how to configure your app to run postgres locally see [why you cannot use Sqlite3 on Heroku](https://devcenter.heroku.com/articles/sqlite3).

In addition to using the `pg` gem, you'll also need to ensure the `config/database.yml` is using the `postgresql` adapter.

You will also need to remove the `username` field in your `database.yml` if there is one so:

```
:::= file.remove config/database.yml
username: myapp
```

This line tells rails that the database `myapp_development` should be run under a role of `myapp`. Since you likely don't have this role in your database we will remove it. With the line remove Rails will try to access the database as user who is currently logged into the computer.

The development section of your `config/database.yml` file should look something like this:

```sh
:::  $ cat config/database.yml
:::= | $ head -n 23
```

Be careful here, if you omit the `sql` at the end of `postgresql` your application will not work.

Now re-install your dependencies (to generate a new `Gemfile.lock`):

```ruby
$ bundle install
```

## Specify Ruby version in app


Rails 4 requires Ruby 1.9.3 or above. Heroku has a recent version of Ruby installed, however you can specify an exact version by using the `ruby` DSL in your `Gemfile`. For this guide we'll be using Ruby 2.0.0 so add this to your `Gemfile`:

```ruby
:::= file.append Gemfile
ruby "2.0.0"
```

You should also be running the same version of Ruby locally. You can verify by running `$ ruby -v`. You can get more information on [specifying your Ruby version on Heroku here](https://devcenter.heroku.com/articles/ruby-versions).

## Store your App in Git

Heroku relies on [git](http://git-scm.com/), a distributed source control managment tool, for deploying your project. If your project is not already in git first verify that `git` is on your system:

```sh
::: $ git --help
:::= | $ head -n 10
```

If you don't see any output or get `command not found` you will need to install it on your system, verify that the [Heroku toolbelt](https://toolbelt.heroku.com/) is installed.

Once you've verified that git works, first make sure you are in your Rails app directory by running:

```sh
$ ls
```

The output should look like this:

```sh
:::= $ ls
```

Now run these commands in your Rails app directory to initialize and commit your code to git:

```sh
::: $ git init
::: $ git add .
::: $ git commit -m "init"
```

You can verify everything was committed correctly by running:

```sh
:::= $ git status
```

Now that your application is committed to git you can deploy to Heroku.

## Deploy your application to Heroku

Make sure you are in the directory that contains your Rails app, then create an app on Heroku:

```sh
:::= $ heroku create
```

You can verify that the remote was added to your project by running

```sh
$ git config -e
```

If you see `fatal: not in a git directory` then you are likely not in the corect directory. Otherwise you may deploy your code. After you deploy your code, you will need to migrate your database, make sure it is properly scaled and use logs to debug any issues that come up.

Deploy your code:

```sh
:::= $ git push heroku master
```

It is always a good idea to check to see if there are any warnings or errors in the output. If everything went well you can migrate your database.

## Migrate your database

If you are using the database in your application you need to manually migrate the database by running:

```sh
$ heroku run rake db:migrate
```

Any commands after the `heroku run` will be executed on a Heroku [dyno](dynos).


## Visit your application


You've deployed your code to Heroku. You can now instruct Heroku to execute a process type. Heroku does this by running the associated command in a [dyno](dynos) - a lightweight container which is the basic unit of composition on Heroku.

Let's ensure we have one dyno running the `web` process type:

```sh
::: $ heroku ps:scale web=1
```

You can check the state of the app's dynos. The `heroku ps` command lists the running dynos of your application:

```sh
:::= $ heroku ps
```

Here, one dyno is running.

We can now visit the app in our browser with `heroku open`.

```sh
:::= $ heroku open
```

You should now see the "Hello World" text we inserted above.

Heroku gives you a default web url for simplicty while you are developing. When you are ready to scale up and use Heroku for production you can add your own [Custom Domain](https://devcenter.heroku.com/articles/custom-domains).

## View the logs

If you run into any problems getting your app to perform properly, you will need to check the logs.

You can view information about your running app using one of the [logging commands](logging), `heroku logs`:

```sh
:::= $ heroku logs
```

You can also get the full stream of logs by running the logs command with the `--tail` flag option like this:

```sh
$ heroku logs --tail
```

## Dyno sleeping and scaling

Having only a single web dyno running will result in the dyno [going to sleep](dynos#dyno-sleeping) after one hour of inactivity.  This causes a delay of a few seconds for the first request upon waking. Subsequent requests will perform normally.

To avoid this, you can scale to more than one web dyno. For example:

```sh
$ heroku ps:scale web=2
```

For each application, Heroku provides [750 free dyno-hours](usage-and-billing#750-free-dyno-hours-per-app).  Running your app at 2 dynos would exceed this free, monthly allowance, so let's scale back:

```sh
$ heroku ps:scale web=1
```

## Console

Heroku allows you to run commands in a [one-off dyno](oneoff-admin-ps) - scripts and applications that only need to be executed when needed - using the `heroku run` command. Use this to launch a Rails console process attached to your local terminal for experimenting in your app's environment:

```sh
$ heroku run rails console
irb(main):001:0> puts 1+1
2
```

## Rake

Rake can be run as an attached process exactly like the console:

```sh
$ heroku run rake db:migrate
```

## Webserver

By default, your app's web process runs `rails server`, which uses Webrick. This is fine for testing, but for production apps you'll want to switch to a more robust webserver. On Cedar, [we recommend Unicorn as the webserver](ruby-production-web-server). Regardless of the webserver you choose, production apps should always specify the webserver explicitly in the `Procfile`.

First, add Unicorn to your application `Gemfile`:

```ruby
:::= file.append Gemfile
gem 'unicorn'
```

Then run

```sh
::: $ bundle install
```

Now you are ready to configure your app to use Unicorn.

Create a configuration file for Unicorn at `config/unicorn.rb`:

```sh
::: $ touch config/unicorn.rb
```

Now we're going to add Unicorn specific configuration options, that we explain in detail in [Heroku's Unicorn documentation](https://devcenter.heroku.com/articles/rails-unicorn):

```ruby
:::= file.write config/unicorn.rb

worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
timeout 15
preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
```

This default configuration assumes a standard Rails app with Active Record. You should get acquainted with the different options in [the official Unicorn documentation](http://unicorn.bogomips.org/Unicorn/Configurator.html).

Finally you will need to tell Heroku how to run your Rails app by creating a `Procfile` in the root of your application directory.

### Procfile

Change the command used to launch your web process by creating a file called [Procfile](procfile) and entering this:

```
:::= file.write Procfile
web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
```

Note: The case of `Procfile` matters, the first letter must be uppercase.

Set the `RACK_ENV` to development in your environment and a `PORT` to connect to. Before pushing to Heroku you'll want to test with the `RACK_ENV` set to production since this is the enviroment your Heroku app will run in.

```sh
:::= $ echo "RACK_ENV=development" >>.env
:::= $ echo "PORT=3000" >> .env
```

You'll also want to add `.env` to your `.gitignore` since this is for local enviroment setup.

```sh
::: $ echo ".env" >> .gitignore
::: $ git add .gitignore
::: $ git commit -m "add .env to .gitignore"
```

Test your Procfile locally using Foreman:

```sh
::: $ gem install foreman
```

You can now start your web server by running

```sh
$ foreman start
18:24:56 web.1  | I, [2013-03-13T18:24:56.885046 #18793]  INFO -- : listening on addr=0.0.0.0:5000 fd=7
18:24:56 web.1  | I, [2013-03-13T18:24:56.885140 #18793]  INFO -- : worker=0 spawning...
18:24:56 web.1  | I, [2013-03-13T18:24:56.885680 #18793]  INFO -- : master process ready
18:24:56 web.1  | I, [2013-03-13T18:24:56.886145 #18795]  INFO -- : worker=0 spawned pid=18795
18:24:56 web.1  | I, [2013-03-13T18:24:56.886272 #18795]  INFO -- : Refreshing Gem list
18:24:57 web.1  | I, [2013-03-13T18:24:57.647574 #18795]  INFO -- : worker=0 ready
```

Looks good, so press Ctrl-C to exit and you can deploy your changes to Heroku:

```sh
::: $ git add .
::: $ git commit -m "use unicorn via procfile"
::: $ git push heroku master
```

Check `ps`, you'll see the web process uses your new command specifying Unicorn as the web server

```sh
:::= $ heroku ps
```

The logs also reflect that we are now using Unicorn:

```sh
$ heroku logs
```

## Rails Asset Pipeline

There are several options for invoking the [Rails asset pipeline](http://guides.rubyonrails.org/asset_pipeline.html) when deploying to Heroku. For general information on the asset pipeline please see the [Rails 3.1+ Asset Pipeline on Heroku Cedar](rails3x-asset-pipeline-cedar) article.

The `config.assets.initialize_on_precompile` option has been removed is and not needed for Rails 4. Also, any failure in asset compilation will now cause the push to fail. For Rails 4 asset pipeline support see the [Ruby Support](https://devcenter.heroku.com/articles/ruby-support#rails-4-x-applications) page.

## Troubleshooting

If you push up your app and it crashes (`heroku ps` shows state `crashed`), check your logs to find out what went wrong. Here are some common problems.

### Runtime dependencies on development/test gems

If you're missing a gem when you deploy, check your Bundler groups. Heroku builds your app without the `development` or `test` groups, and if you app depends on a gem from one of these groups to run, you should move it out of the group.

One common example using the RSpec tasks in your `Rakefile`. If you see this in your Heroku deploy:

```sh
$ heroku run rake -T
Running `bundle exec rake -T` attached to terminal... up, ps.3
rake aborted!
no such file to load -- rspec/core/rake_task
```

Then you've hit this problem. First, duplicate the problem locally:

```sh
$ bundle install --without development:test
…
$ bundle exec rake -T
rake aborted!
no such file to load -- rspec/core/rake_task
```

Now you can fix it by making these Rake tasks conditional on the gem load. For example:

### Rakefile

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


## Done

You now have your first application deployed to Heroku. The next step is to deploy your own application. If you're interested in reading more you can read more about [Ruby on Heroku at the Devcenter](https://devcenter.heroku.com/categories/ruby).
