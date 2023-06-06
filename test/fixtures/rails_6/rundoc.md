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
  https://github.com/schneems/rundoc/blob/main/test/fixtures/rails_6/rundoc.md

  Command:
  $ bin/rundoc build --path test/fixtures/rails_6/rundoc.md
-->

> warning
> The latest version of Rails available is [Rails 7](https://devcenter.heroku.com/articles/getting-started-with-rails7). If you're starting a new application, we recommend you use the most recently released version.

Ruby on Rails is a popular web framework written in [Ruby](http://www.ruby-lang.org/). This guide covers using Rails 6 on Heroku. For information on running previous versions of Rails on Heroku, see the tutorial for [Rails 5.x](getting-started-with-rails5) or [Rails 4.x](getting-started-with-rails4).

The tutorial assumes that you have:

- Basic familiarity with Ruby/Rails and Git
- A locally installed version of Ruby 2.5.0+, Rubygems, Bundler, and Rails 6+
- A locally installed version of the [Heroku CLI](heroku-cli#install-the-heroku-cli)
- A [verified Heroku Account](https://devcenter.heroku.com/articles/account-verification)
- A subscription to the [Eco dynos plan](eco-dyno-hours) (recommended)

>note
>Using dynos and databases to complete this tutorial counts towards your usage. We recommend using our [low-cost plans](https://blog.heroku.com/new-low-cost-plans) to complete this tutorial. Eligible students can apply for platform credits through our new [Heroku for GitHub Students program](https://blog.heroku.com/github-student-developer-program).

```
:::-- $ ruby -e "exit 1 unless RUBY_VERSION == '3.0.6'"
```

## Local Setup

After installing the [Heroku CLI](heroku-cli#install-the-heroku-cli), log in through your terminal:

```term
$ heroku login
heroku: Press any key to open up the browser to login or q to exit
 ›   Warning: If browser does not open, visit
 ›   https://cli-auth.heroku.com/auth/browser/***
heroku: Waiting for login...
Logging in... done
Logged in as me@example.com
```

This command opens your web browser to the Heroku login page. If your browser is already logged in to Heroku, click the **`Log in`** button on the page.

This authentication is required for the `heroku` and `git` commands to work correctly.

## Create a New or Upgrade an Existing Rails App

Ensure that you're using Rails 6.x by running `rails -v`. If necessary, install it with this command:

```term
:::>> $ gem install rails -v 6.1.7.3 --no-document
```

Create a Rails app:

```term
:::>- $ rails _6.1.7.3_ new myapp --database=postgresql
```

Move into the application directory and add the `x86_64-linux` and `ruby` platforms to `Gemfile.lock`.

```term
:::>- $ cd myapp
:::>> $ bundle lock --add-platform x86_64-linux --add-platform ruby
```

Create a local database:

```
:::>> $ bin/rails db:create
```

## Add the pg Gem

For new or existing apps where `--database=postgresql` isn’t defined, confirm the `sqlite3` gem doesn’t exist in the `Gemfile`. Add the `pg` gem in its place.

```ruby
gem 'sqlite3'
```

To this:

```ruby
gem 'pg'
```

> callout
>Heroku highly recommends using PostgreSQL locally during development. Maintaining [parity between development](http://www.12factor.net/dev-prod-parity) and deployment environments prevents introducing subtle bugs due to the differences in environments.
>
> [Install Postgres locally](heroku-postgresql#local-setup). For more information on why Postgres is recommended instead of Sqlite3, see [why Sqlite3 is not compatible with Heroku](sqlite3).

With the `Gemfile` updated, reinstall the dependencies:

```ruby
$ bundle install
```

The installation also updates `Gemfile.lock` with the changes.

In addition to the `pg` gem, ensure that `config/database.yml` defines the `postgresql` adapter. The development section of `config/database.yml` file looks something like this:

```term
:::>>  $ cat config/database.yml
```

Be careful here. If the value of `adapter` is `postgres` and not `postgresql`, the application won’t work.

## Create a Welcome Page

Rails 6 no longer has a static index page in production by default. When you're using a new app, there isn't a root page in production, so you must create one. Create a controller called `welcome` for the home page:

```term
:::>- $ rails generate controller welcome
```

```html
:::>> file.write app/views/welcome/index.html.erb
<h2>Hello World</h2>
<p>
  The time is now: <%= Time.now %>
</p>
```

Create a Rails route to this action. Edit `config/routes.rb` to set the index page to the new method:

```ruby
:::>> file.append config/routes.rb#2
  root 'welcome#index'
```

You can verify that the page is there by running your server:

```term
:::>> background.start("rails server", name: "server")
:::-- background.stop(name: "server")
```

Visit [http://localhost:3000](http://localhost:3000) in your browser. If you don't see the page, [use the logs](#view-application-logs) to debug.  Rails outputs logs in the same terminal where `rails server` started.

## Specify the Ruby Version

Rails 6 requires Ruby 2.5.0 or above. Heroku has a recent version of Ruby installed by default. Specify an exact version with the `ruby` DSL in `Gemfile`. For example:

```ruby
:::-- $ sed -i'' -e '/^ruby/d' ./Gemfile
:::-> file.append Gemfile#4
ruby "3.0.6"
```

Always use the same version of Ruby locally. Confirm the local version of ruby with `ruby -v`. Refer to the [Ruby Versions](ruby-versions) article for more details on defining a specific ruby version.

## Create a Procfile

Use a [Procfile](procfile), a text file in the root directory of your application, to explicitly declare what command to execute to start your app.

This Procfile declares a single process type, `web`, and the command needed to run it.  The name `web` is important here.  It declares that this process type is attached to Heroku's [HTTP routing](http-routing) stack and receives web traffic when deployed.

By default, a Rails app’s web process runs `rails server`, which uses Puma in Rails 7. When you deploy a Rails 7 application without a Procfile, this command executes. However, we recommend explicitly declaring how to boot your server process via a Procfile.

```
:::>> file.write Procfile
web: bundle exec puma -C config/puma.rb
```

>note
>The `Procfile` filename is case sensitive. There is no file extension.

If `config/puma.rb` doesn’t exist, create one using [Heroku’s Puma documentation](https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server) for maximum performance.

A Procfile can contain additional process types.  For example, you can declare a [background worker process](background-jobs-queueing#process-model) that processes items off a queue.


## Store The App in Git

Heroku relies on [Git](http://git-scm.com/), a distributed source control management tool, for deploying applications. If the application is not already in Git, first verify that `git` is on the system with `git --help`:

```term
:::>- $ git --help
:::>> | $ head -n 5
```

If the command produces no output or `command not found`, [install Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).

Navigate to the root directory of the Rails app. Use the `ls` command to see its contents:

```term
:::>> $ ls
```

Within the Rails app directly, initialize a local empty Git repository and commit the app’s code:

```term
:::>- $ git init
:::>- $ git add .
:::>- $ git commit -m "init"
```

Verify everything committed correctly with `git status`:

```term
:::>> $ git status
```

With the application committed to Git, it's ready to deploy to Heroku.

## Fix a babel regression

Rails 6 relies on the [webpacker gem](https://github.com/rails/webpacker) which uses babel as a dependency. Version 7.22.0 of [babel released a breaking change](https://github.com/babel/babel/issues/15679) in a minor version that caused new Rails 6.1.x apps to break. Rails 6 and webpacker are no longer receiving bug fixes so unless babel reverts the change, then you will need to workaround this bug in your new app.

Test to see if your application is affected by this bug by running this command:

```term
:::>> $ rake webpacker:clobber webpacker:compile  2>&1 | grep "Cannot find package '@babel/plugin-proposal-private-methods'"
```

To fix this issue modify `babel.config.js`, replace `plugin-proposal-private-methods` with `plugin-transform-private-methods`:

```diff
-        '@babel/plugin-plugin-private-methods',
+        '@babel/plugin-transform-private-methods',
```

```ruby
:::-- $ sed -i'' -e 's/plugin-proposal-private-methods/plugin-transform-private-methods/' ./babel.config.js
```

Verify that it works correctly:

```term
:::>- $ rake webpacker:clobber webpacker:compile
```

Commit the fix to git:

```
:::>- $ git add .
:::>- $ git commit -m "fix babel error"
```

## Create a Heroku App

>warning
>Using a dyno and a database to complete this tutorial counts towards your usage. [Delete your app](https://devcenter.heroku.com/articles/heroku-cli-commands#heroku-apps-destroy), and [database](https://devcenter.heroku.com/articles/heroku-postgresql#removing-the-add-on) as soon as you're done to control costs.

To create an app on Heroku, use the Heroku CLI Inside the Rails app’s root directory:

```term
:::>> $ heroku create --stack heroku-20
```

When you create an app, a git remote called `heroku` is also created and associated with your local git repository. Git remotes are versions of your repository that live on other servers. You deploy your app by pushing its code to that special Heroku-hosted remote associated with your app. Verify the remote is set with `git config`:

```term
:::>> $ git config --list --local | grep heroku
```

If the current directory is incorrect or Git isn't [initialized](#store-the-app-in-git), Git returns `fatal: not in a git directory`. If Git returns a list of remotes, it's ready to deploy.

>note
>Following changes in the industry, Heroku has updated our default git branch name to `main`. If the project you’re deploying uses `master` as its default branch name, use `git push heroku master`.

## Provision a Database

Provision a [Heroku Postgres](https://devcenter.heroku.com/articles/heroku-postgresql) database, one of the add-ons available through the [Elements Marketplace](https://www.heroku.com/elements/addons). Add-ons are cloud services that provide out-of-the-box additional services for your application, such as logging, monitoring, databases, and more.

>note
>A `mini` Postgres size costs [$5 a month, prorated to the minute](https://elements.heroku.com/addons/heroku-postgresql). At the end of this tutorial, we prompt you to [delete your database](https://devcenter.heroku.com/articles/heroku-postgresql#removing-the-add-on) to minimize costs.

```term
:::>> $ heroku addons:create heroku-postgresql:mini
```

Your Heroku app can now access this Postgres database. The `DATABASE_URL` environment variable stores your credentials, which Rails connects to by convention.

## Deploy the App to Heroku

>warning
>Using a dyno to complete this tutorial counts towards your usage. [Delete your app](https://devcenter.heroku.com/articles/heroku-cli-commands#heroku-apps-destroy) as soon as you're done to control costs.

Deploy your code. This command pushes the `main` branch of the sample repo to your `heroku` remote, which then deploys to Heroku:

```term
:::>> $ git push heroku main
```

If the output displays warnings or error messages, check the output and make adjustments.

After a successful deployment, complete these tasks as necessary:

* Database migrations
* Scale your dynos
* Check the app’s logs if issues arise

## Migrate The Database

If you're using a database in your application, trigger a migration by using the Heroku CLI to start a one-off [dyno](dynos). You can run commands, typically scripts and applications that are part of your app, in one-off dynos using the `heroku run` command. You can trigger a database migration with this command:

```term
$ heroku run rake db:migrate
```

To use an interactive shell session instead, you can execute `heroku run bash`.

## Scale and Access the Application

Heroku runs application code using defined processes and [process types](procfile). New applications don't a process type active by default. The following command scales your app up to one dyno, running the `web` process:

```term
:::>- $ heroku ps:scale web=1
```

Use the Heroku CLI’s `ps` command to display the state of all app dynos in the terminal:

```term
:::>> $ heroku ps
```

By default, apps use Eco dynos if you're subscribed to [Eco](eco-dyno-hours). Otherwise, it defaults to Basic dynos. The Eco dynos plan is shared across all Eco dynos in your account and is recommended if you plan on deploying many small apps to Heroku. Eco dynos sleep if they don't receive any traffic for half an hour.  This sleep behavior causes a few seconds delay for the first request upon waking. Eco dynos consume from a monthly, account-level quota of [eco dyno hours](eco-dyno-hours). As long as you haven't exhausted the quota, your apps can continue to run.

To avoid dyno sleeping, upgrade to a Basic or higher dyno type as described in the [Dyno Types](dyno-types) article. Upgrading to at least Standard dynos also allows you to scale up to multiple dynos per process type.

To launch the app in the browser, run `heroku open`:

```term
:::>> $ heroku open
```

The browser displays the “Hello World” text. If it doesn't, or there's an error, [review and confirm the welcome page contents](#create-a-welcome-page).

Heroku provides a [default web URL](app-names-and-subdomains) for every application during development. When the application is ready for production, add a [custom domain](https://devcenter.heroku.com/articles/custom-domains).

## View Application Logs

The app logs are a valuable tool if the app is not performing correctly or generating errors.

View information about a running app using the Heroku CLI [logging command](logging), `heroku logs`. Here's example output:

```term
:::>> $ heroku logs
```

You can also get the full stream of logs by running the logs command with the `--tail` flag option like this:

```term
$ heroku logs --tail
```

By default, Heroku stores 1500 lines of logs from your application, but the full log stream is available as a service. Several [add-on providers](https://elements.heroku.com/addons/#logging) have logging services that provide things such as log persistence, search, and email and SMS alerts.

## Optional Steps

### Use The Rails Console

Use the Heroku CLI `run` command to trigger [one-off dynos](one-off-dynos) to run scripts and applications only when necessary. Use the command to launch a Rails console process attached to the local terminal for experimenting in the app's environment:

```term
$ heroku run rails console
irb(main):001:0> puts 1+1
2
```

### Run Rake Commands

Run `rake` commands, such as `db:migrate`, using the `run` command exactly like the Rails console:

```term
$ heroku run rake db:migrate
```

### Use a Procfile locally

To use the `Procfile` locally, use the `heroku local` CLI command.

In addition to running commands in the `Procfile`, the `heroku local` command can also manage environment variables locally through a `.env` file. Set `RACK_ENV` to `development` for the local environment and the `PORT` for Puma.

```term
:::>> $ echo "RACK_ENV=development" >>.env
:::>> $ echo "PORT=3000" >> .env
```

>note
> Another alternative to using environment variables locally with a `.env` file is the [dotenv](https://github.com/bkeepers/dotenv) gem.

Add `.env` to `.gitignore` as these variables are for local environment setup only.

```term
:::>- $ echo ".env" >> .gitignore
:::>- $ git add .gitignore
:::>- $ git commit -m "add .env to .gitignore"
```

Test the Procfile locally using [Foreman](heroku-local#run-your-app-locally-using-foreman)​​. Start the web server with `local`:

```term
:::>> background.start("heroku local", name: "local", wait: "Ctrl-C to stop", timeout: 15)
:::-- background.stop(name: "local")
```

Press `Ctrl+C` or `Cmd+C` to exit.

## Rails asset pipeline

When deploying to Heroku, there are several options for invoking the [Rails asset pipeline](http://guides.rubyonrails.org/asset_pipeline.html). See the [Rails 3.1+ Asset Pipeline on Heroku Cedar](rails-asset-pipeline) article for general information on the asset pipeline.

Rails 6 removed the `config.assets.initialize_on_precompile` option because it's no longer needed. Additionally, any failure in asset compilation now causes the push to fail. For Rails 6 asset pipeline support, see the [Ruby Support](ruby-support#rails-5-x-applications) page.

## Remove Heroku Gems

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

## Troubleshooting

If an app deployed to Heroku crashes, for example, `heroku ps` shows the state `crashed`, review the app’s logs. The following section covers common causes of app crashes.

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
>The `--without` option on `bundler` is persistent. To remove this option, run `bundle config --delete without`.

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

Confirm it works locally, then push it to Heroku.

## Next Steps

Congratulations! You deployed your first Rails 6 application to Heroku. Review the following articles next:

* Visit the [Ruby support category](/categories/ruby-support) to learn more about using Ruby and Rails on Heroku.
* The [Deployment category](/categories/deployment) provides a variety of powerful integrations and features to help streamline and simplify your deployments.

## Deleting Your App and Add-on

Remove the app and database from your account. You're only charged for the resources you used.

>warning
>This action removes your add-on and any data saved in the database.

```term
$ heroku addons:destroy heroku-postgresql
```

>warning
>This action permanently deletes your application

```term
$ heroku apps:destroy
```

You can confirm that your add-on and app are gone with the commands:

```term
$ heroku addons --all
$ heroku apps -all
```

You're now ready to <a href= "https://devcenter.heroku.com/articles/preparing-a-codebase-for-heroku-deployment" target= "_blank">deploy your app</a>.
