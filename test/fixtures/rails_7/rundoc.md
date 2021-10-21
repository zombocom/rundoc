```
:::-- rundoc
email = ENV['HEROKU_EMAIL'] || `heroku auth:whoami`

Rundoc.configure do |config|
  config.project_root = "myapp"
  config.filter_sensitive(email => "developer@example.com")
  config.filter_sensitive(Dir.pwd => ".")
end
```

<!--
  rundoc src:
  https://github.com/schneems/rundoc/blob/main/test/fixtures/rails_7/rundoc.md

  Command:
  $ bin/rundoc build --path test/fixtures/rails_7/rundoc.md
-->

Ruby on Rails is a popular web framework written in [Ruby](http://www.ruby-lang.org/). This guide covers using Rails 7 on Heroku. For information on running previous versions of Rails on Heroku, see the tutorial for [Rails 6.x](getting-started-with-rails6) or [Rails 5.x](getting-started-with-rails5).

```
:::-- $ ruby -e "exit 1 unless RUBY_VERSION == '3.0.2'"
```

Before continuing, it’s helpful to have:

- Basic familiarity with Ruby, Ruby on Rails, and Git
- A locally installed version of Ruby 2.7.0+, Rubygems, Bundler, and Rails 7+
- A Heroku user account: [Signup is free and instant](https://signup.heroku.com/devcenter).
- A locally installed version of the [Heroku CLI](heroku-cli#download-and-install)

## Local setup

With the Heroku CLI installed, `heroku` is now an available command in the terminal. Log in to Heroku using the CLI:

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

Press Enter at the prompt to upload an existing `ssh` key or create a new one. 

>info
>After November 30, 2021, Heroku [will no longer support the SSH Git transport](​​https://devcenter.heroku.com/changelog-items/2215). SSH keys will serve no purpose in pushing code to applications on the Heroku platform.

## Create a New or Upgrade an Existing Rails App 

Ensure Rails 7 is installed with `rails -v` before creating an app. If necessary, install Rails 7 with `gem install`:

```term
:::>> $ gem install rails --no-document --pre
```

Create an app and move it into its root directory:

```term
:::>- $ rails new myapp --database=postgresql
```

Move into the application directly and add the `x86_64-linux` and `ruby` platforms to `Gemfile.lock`.

```term
:::>- $ cd myapp
:::>> $ bundle lock --add-platform x86_64-linux --add-platform ruby
```

Create a local database:

```
:::>> $ bin/rails db:create
```

## Add the pg gem

For new or existing apps where `--database=postgresql` wasn’t defined, confirm the `sqlite3` gem doesn’t exist in the `Gemfile`. Add the `pg` gem in its place. 

Within the `Gemfile` remove:

```ruby
gem 'sqlite3'
```

And replace it with:

```ruby
gem 'pg'
```

> callout Heroku highly recommends using PostgreSQL locally during development. Maintaining [parity between development](http://www.12factor.net/dev-prod-parity) and deployment environments prevents subtle bugs from being introduced because of the differences in those environments. 
>
> [Install Postgres locally](heroku-postgresql#local-setup) now if not present on the system, already. For more information on why Postgres is recommended instead of Sqlite3, see [why Sqlite3 is not compatible with Heroku](sqlite3).

With the `Gemfile` updated, reinstall the dependencies: 

```ruby
$ bundle install
```

Doing so updates `Gemfile.lock` with the changes made previously.

In addition to using the `pg` gem, ensure that `config/database.yml` defines the `postgresql` adapter. The development section of `config/database.yml` file will look something like this:

```term
:::>>  $ cat config/database.yml
```

Be careful here. If the value of `adapter` is `postgres` and not `postgresql` (note the `sql` at the end), the application won’t work.

## Create a Welcome Page

Rails 7 no longer has a static index page in production by default. Apps upgraded to Rails 7 keep their existing page configurations, but new Rails 7 apps do not have an automatically generated welcome page. Create a `welcome` controller to hold the homepage:

```term
:::>- $ rails generate controller welcome
```

Create `app/views/welcome/index.html.erb` and add the following snippet:

```html
:::>> file.write app/views/welcome/index.html.erb
<h2>Hello World</h2>
<p>
  The time is now: <%= Time.now %>
</p>
```

With a welcome page created, create a route to map to this action. Edit `config/routes.rb` to set the index page to the new method:

```ruby
:::>> file.append config/routes.rb#2
  root 'welcome#index'
```

Verify the page is present by starting the Rails web server:

```term
:::>> background.start("rails server", name: "server")
:::-- background.stop(name: "server")
```

Visit [http://localhost:3000](http://localhost:3000) in a browser. If the page doesn’t display, [reference the logs](#view-logs) Rails outputs within the same terminal where `rails server` started to debug the error.

## Heroku Gems

Previous versions of Rails (Rails 4 and older) required the [rails_12factor](https://github.com/heroku/rails_12factor) gem to enable static asset serving and logging on Heroku. New Rails applications don’t need this gem. The gem can be removed from existing, upgraded applications provided the following code is present in `config/environments/production.rb`:

```ruby
# config/environments/production.rb
config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

if ENV["RAILS_LOG_TO_STDOUT"].present?
  logger           = ActiveSupport::Logger.new(STDOUT)
  logger.formatter = config.log_formatter
  config.logger = ActiveSupport::TaggedLogging.new(logger)
end
```

## Specify the Ruby Version

Rails 7 requires Ruby 2.7.0 or above. Heroku installs a recent version of Ruby buy default. Specify an exact version with the `ruby` DSL in `Gemfile` like the following example of defining Ruby 3.0.2:


```ruby
:::-- $ sed -i'' -e '/^ruby/d' ./Gemfile
:::-> file.append Gemfile#4
ruby "3.0.2"
```

Always use the same version of Ruby locally, too. Confirm the local version of ruby with `ruby -v`. Refer to the [Ruby Versions](ruby-versions) article for more details on defining a specific ruby version.

## Store The App in Git

Heroku relies on [Git](http://git-scm.com/), a distributed source control management tool, for deploying applications. If the application is not already in Git, first verify that `git` is on the system with `git --help`:

```term
:::>- $ git --help
:::>> | $ head -n 5
```

Git is not present if the command produces no output or `command not found`. Install Git on the system.

After verifying Git is functional, navigate to the root directory of the Rails app. The contents of the Rails app looks something like this when using `ls`:

```term
:::>> $ ls
```

Within the Rails app directly, initialize a local empty Git repository and commit the app’s code:

```term
:::>- $ git init
:::>- $ git add .
:::>- $ git commit -m "init"
```

Verify everything was committed correctly with `git status`:

```term
:::>> $ git status
```

With the application committed to Git, it is ready to deploy to Heroku.

## Deploy the Application to Heroku

Inside the Rails app’s root directory, use the Heroku CLI to create an app on Heroku:

```term
:::>> $ heroku create
```

The Heroku CLI adds the Git remote automatically. Verify it is set with `git config`:

```term
:::>> $ git config --list --local | grep heroku
```

Git returns `fatal: not in a git directory` if the current directory is incorrect or Git is not [initialized](#store-the-app-in-git). If Git returns a list of remotes, it is ready to deploy. 

>note
>Following changes in the industry, Heroku [updated the default branch name](​​https://devcenter.heroku.com/changelog-items/1829) to `main`. If the project uses `master` as its default branch name, use `git push heroku master`.

Deploy the code:

```term
:::>> $ git push heroku main
```

The output may display warnings or error messages. Check the output for these and make adjustments as necessary. 

If the deployment is successful, the application may need a few additional adjustments:

* Migration of the database
* Ensure proper dyno scaling
* Reference the app’s logs if any issues arise 

## Migrate The Database

If the application uses a database, trigger a migration by using the Heroku CLI to start a one-off  [dyno](dynos), which is a lightweight container that is the basic unit of composition on Heroku, and run `db:migrate`:

```term
$ heroku run rake db:migrate
```

Obtain an interactive shell session, instead, with `heroku run bash`.

## Access the Application

The application is successfully deployed to Heroku. Heroku runs application code using defined processes and [process types](procfile). New applications will not have a process type active by default. Scale the `web` process type using the Heroku CLI’s `ps:scale` command:

```term
:::>- $ heroku ps:scale web=1
```

Use the Heroku CLI’s `ps` command to display the state of all of an app’s dynos in the terminal:

```term
:::>> $ heroku ps
```

In the previous example, a single `web` process is running.

Use `heroku open` to launch the app in the browser.

```term
:::>> $ heroku open
```

The browser should display the “Hello World” text defined previously. If it does not, or an error is present, [review and confirm the welcome page contents](#create-a-welcome-page). 

Heroku provides a default web URL for every application during development. When the application is ready to scale up for production, add a [custom domain](https://devcenter.heroku.com/articles/custom-domains).

## View Application Logs

The app logs are a valuable tool if the app is not performing correctly or generating errors.

View information about a running app using the Heroku CLI [logging command](logging), `heroku logs`. Here is example output:

```term
:::>> $ heroku logs
```

Append `-t`/`--tail` to the command to see a full, live stream of the app’s logs:

```term
$ heroku logs --tail
```

## Dyno Sleeping and Scaling

New applications are deployed to a free dyno by default. After a period of inactivity, free apps will "sleep" to conserve resources. For more on Heroku’s free dyno behavior, see [Free Dyno Hours](free-dyno-hours).

Upgrade to a hobby or professional dyno type as described in the [Dyno Types](dyno-types) article to avoid dyno sleeping. For example, migrating an app to a production dyno allows for easy scaling by using the Heroku CLI `ps:scale` command to instruct the Heroku platform to start or stop additional dynos that run the same `web` process type.

## The Rails Console

Use the Heroku CLI `run` command to trigger [one-off dynos](one-off-dynos) to run scripts and applications only when necessary. Use the command to launch a Rails console process attached to the local terminal for experimenting in the app's environment:

```term
$ heroku run rails console
irb(main):001:0> puts 1+1
2
```

The `run bash` Heroku CLI command is also helpful for debugging. The command starts a new one-off dyno with an interactive bash session.

## Rake Commands

Run `rake` commands (`db:migrate`, for example) using the `run` command exactly like the Rails console:

```term
$ heroku run rake db:migrate
```

## Configure The Web Server

By default, a Rails app's web process runs `rails server`, which uses Puma in Rails 7. Apps upgraded to Rails 7 need the `puma` gem added to the app’s `Gemfile`:

```ruby
gem 'puma'
```

After adding the `puma` gem, install it:

```term
:::>- $ bundle install
```

Rails 7 uses `config/puma.rb` to define Puma’s configuration and functionality with Puma installed. Heroku recommends reviewing [additional Puma configuration options](https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server) to maximize the app’s performance. 

If `config/puma.rb` doesn’t exist, create one using [Heroku’s Puma documentation](https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server) for maximum performance.

With Puma installed, use the `Procfile` to instruct Heroku on how to launch the Rails app on a dyno.

### Create a Procfile

Change the command used to launch your web process by creating a file called [Procfile](procfile) inside the app’s root directory. Add the following line:

```
:::>> file.write Procfile
web: bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-development}
```

>note
>This file must be named `Procfile` exactly with a capital `P`, lowercase `rocfile`, and no file extension.

To use the Procfile locally, use the `local` Heroku CLI command.

In addition to running commands in the `Procfile`, `heroku local` can also manage environment variables locally through a `.env` file. Set `RACK_ENV` to `development` for the local environment and the `PORT` for Puma. Test with the `RACK_ENV` set to `production` before pushing to Heroku; `production` is the environment in which the Heroku app will run.

```term
:::>> $ echo "RACK_ENV=development" >>.env
:::>> $ echo "PORT=3000" >> .env
```

>note
>Another alternative to using environment variables locally with a `.env` file is the [dotenv](https://github.com/bkeepers/dotenv) gem.

Add `.env` to `.gitignore` since this is for local environment setup only.

```term
:::>- $ echo ".env" >> .gitignore
:::>- $ git add .gitignore
:::>- $ git commit -m "add .env to .gitignore"
```

Test the Procfile locally using [Foreman](run-your-app-locally-using-foreman)​​. Start the web server with `local`:

```term
:::>> background.start("heroku local", name: "local", wait: "Ctrl-C to stop", timeout: 15)
:::-- background.stop(name: "local")
```

A successful test will look similar to the previous example. Press `Ctrl+C` or `CMD+C` to exit and deploy the changes to Heroku:

```term
:::>- $ git add .
:::>- $ git commit -m "use puma via procfile"
:::>- $ git push heroku main || git push heroku master
```

Check `ps`. The `web` process is now using the new command specifying Puma as the web server:

```term
:::>> $ heroku ps
```

The logs also reflect that Puma is in use.

```term
$ heroku logs
```

## Rails asset pipeline

When deploying to Heroku, there are several options for invoking the [Rails asset pipeline](http://guides.rubyonrails.org/asset_pipeline.html). Please review the [Rails 3.1+ Asset Pipeline on Heroku Cedar](rails-asset-pipeline) article for general information on the asset pipeline.

Rails 7 removed the `config.assets.initialize_on_precompile` option because it is no longer needed. Additionally, any failure in asset compilation will now cause the push to fail. For Rails 7 asset pipeline support, see the [Ruby Support](ruby-support#rails-5-x-applications) page.

## Troubleshooting

If an app deployed to Heroku crashes (`heroku ps` shows state `crashed`), review the app’s logs to determine what went wrong. The following section covers common causes of app crashes.

### Runtime Dependencies on Development or Test Gems

If a gem is missing during deployment, check the Bundler groups. Heroku builds apps without the `development` or `test` groups, and if the app depends on a gem from one of these groups to run, move it out of the group.

A common example is using the RSpec tasks in the `Rakefile`. The error often looks like this:

```term
$ heroku run rake -T
Running `bundle exec rake -T` attached to terminal... up, ps.3
rake aborted!
no such file to load -- rspec/core/rake_task
```
First, duplicate the problem locally by running `bundle install` without the development or test gem groups:

```term
$ bundle install --without development:test
…
$ bundle exec rake -T
rake aborted!
no such file to load -- rspec/core/rake_task
```

>note
>The `--without` option on bundler is sticky. To get rid of this option, run `bundle config --delete without`.

Fix the error by making these Rake tasks conditional during gem load. For example:

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

## Next Steps

Congratulations! You deployed your first Rails 7 application to Heroku. Review the following articles next:

* Visit the [Ruby support category](/categories/ruby-support) to learn more about using Ruby and Rails on Heroku.
* The [Deployment category](/categories/deployment) provides a variety of powerful integrations and features to help streamline and simplify your deployments.
