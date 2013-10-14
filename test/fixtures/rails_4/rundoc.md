# Getting Started with Rails 4.x on Heroku

Ruby on Rails is a popular web framework written in [Ruby](http://www.ruby-lang.org/). The beta for Rails 4.0 was released in February 2013, for running older versions of Rails on Heorku see [Getting Started with Rails 3.x on Heroku](https://devcenter.heroku.com/articles/rails3)

* Basic Ruby/Rails knowledge, including an installed version of Ruby 1.9.3, Rubygems, Bundler, and Rails 4.

* Basic Git knowledge

* Your application must run on Ruby (MRI) 1.9.3 or above.

* A Heroku user account. [Signup is free and instant](https://api.heroku.com/signup/devcenter).

## Local workstation setup

Install the [Heroku Toolbelt](https://toolbelt.heroku.com/) on your local workstation. This ensures that you have access to the [Heroku command-line client](/categories/command-line), Foreman, and the Git revision control system.


Once installed, you'll have access to the `heroku` command from your command shell. Log in using the email address and password you used when creating your Heroku account:

<div class="callout" markdown="1">

Note that `$` before commands indicates they should be run on the command line, prompt, or terminal with appropriate permissions.

</div>

```term
$ heroku login

Enter your Heroku credentials.

Email: adam@example.com

Password:

Could not find an existing public key.

Would you like to generate one? [Yn]

Generating new SSH public key.

Uploading ssh public key /Users/adam/.ssh/id_rsa.pub
```


Press enter at the prompt to upload your existing `ssh` key or create a new one, used for pushing code later on.


# Write your app


You may be starting from an existing app, if so upgrade to Rails 4 before continuing. If not, a vanilla Rails 4 app will serve as a suitable sample app. To build a new app make sure that you're using the Rails 4.x using `$ rails -v`, then run.

```sh
:::= $ rails new myapp --database=postgresql
:::= $ cd myapp
```

Heroku Gems
-----------

Heroku integration has previously relied on using the Rails plugin system, which has been removed from Rails 4. To enable features such as static asset serving and logging on Heroku please add the following gems to your `Gemfile`:

    group :heroku do
      gem 'rails_log_stdout',           github: 'heroku/rails_log_stdout'
      gem 'rails3_serve_static_assets', github: 'heroku/rails3_serve_static_assets'
    end

Then run:

```
::: $ bundle install
```

That should be the minimum you need to do to integrate with Heroku.

Use Postgres
------------

<div class="callout" markdown="1">

We highly recommend using PostgreSQL during development. Maintaining parity between your development and deployment environments prevents subtle bugs from being introduced because of differences between your environments.

</div>

If you did not specify `postgresql` while creating your app (using `--database=postgresql`) you will need to add the `pg` gem to your Rails project. Edit your `Gemfile` and change this line:



```ruby
:::= file.remove Gemfile
gem 'sqlite3'
```


```ruby
:::= file.append Gemfile
gem 'pg'
```


And re-install your dependencies (to generate a new `Gemfile.lock`):

```ruby
::: $ bundle install
```

You will also need to ensure that your application uses postgres locally. Ensure that in your `config/database.yml` that the adapter is set to `postgresql`:


    development:
      adapter: postgresql
      encoding: utf8
      database: myapp_development
      pool: 5
      host: localhost


 Be careful here, if you omit the `sql` at the end of `postgresql` your application will not work. You can create and migrate your database locally by running:

```ruby
::: $ bundle exec rake db:create
::: $ bundle exec rake db:migrate
```

Specify Ruby Version in App
---------------------------

Rails 4 will not run on Ruby 1.8.7 which may be installed on your development computer by default, either use Ruby 1.9.3, 2.0 or JRuby in 1.9 compatibility mode. In your `Gemfile` add:


```ruby
:::= file.append Gemfile
ruby "2.0.0"
```





You should also be running the same version of Ruby locally. You can verify by running `$ ruby -v`.

Store your app in Git
---------------------

Heroku relies on [git](http://git-scm.com/), a flexible distributed source control managment tool, for deploying your project. If your project is not already in git first verify that `git` is on your system:

```sh
:::= $ git --help
```

If you don't see any output or get `command not found` you will need to install it on your system, verify that the Heroku toolbelt is installed.

Verify that you are in your Rails application directory:

```sh
:::= $ ls
```

Once you've verified that git works, run these three commands to initialize and commit your code to git:

```sh
:::  $ git init
:::  $ git add .
:::= $ git commit -m "init"
```

Now that your application is committed to git you can deploy to Heroku.

## Adding a Home Page for Your App

Rails 4 no longer has a static index page in production, if you're using a new app, there may be no root page.

## Deploy your application to Heroku


Make sure you are in the directory that contains your Rails app, then create the app on Heroku:

```sh
:::= $ heroku create
```

Verify that the remote was added to your project by running

```sh
$ git config -e
```

If you do not see `fatal: not in a git directory` than you are safe to deploy to Heroku. We will deploy to heroku, then migrate our database, and then use logs to debug any issues that come up.


Deploy your code:

```sh
:::= $ git push heroku master
```


## Migrate your Database

If you are using the database in your application you need to manually migrate the database by running:

```sh
:::= $ heroku run rake db:migrate
```

Any commands after the `heroku run` will be executed on a Heroku [dyno](dynos).


## Visit your application


You've deployed your code to Heroku. You can now instruct Heroku to execute a process type. Heroku does this by running the associated command in a [dyno](dynos) - a lightweight container which is the basic unit of composition on Heroku.



Let's ensure we have one dyno running the `web` process type:


```sh
:::= $ heroku ps:scale web=1
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

Heroku gives you a default web app name for simplicty while you are developing. When you are ready to scale up and use Heroku for production you can add your own [Custom Domain](https://devcenter.heroku.com/articles/custom-domains).


## View the logs

If you run into any problems getting your app to perform properly, you will  need to check the logs.

Heroku treats logs as streams of time-ordered events aggregated from the output streams of all the dynos running the components of your application. Heroku’s [Logplex](logplex) provides a single channel for all of these events.

You can view information about your running app using one of the [logging commands](logging), `heroku logs`:



```sh
:::= $ heroku logs
```

You can also get the full stream of logs by running the logs command with the `--tail` flag like this:

```sh
$ heroku logs --tail
```


## Dyno Idling and Scaling


Heroku will put your application to sleep if you are only running on the single free dyno, this is called [dyno idling](dynos#dyno-idling). This is done to conserve system resources and allows us to offer a free tier. Once your dyno is idled there will be a delay of a few seconds for the first request while we spin your app back up on our system. Subsequent requests will perform normally.



To avoid this, you can scale to more than one web dyno. For example:

```
$ heroku ps:scale web=2
```


For each application, Heroku provides [750 free dyno-hours](usage-and-billing#750-free-dynohours-per-app).  Running your app at 2 dynos would exceed this free, monthly allowance, so let's scale back:



```
$ heroku ps:scale web=1
```


Console
-------


Heroku allows you to run [one-off proceses](oneoff-admin-ps) - scripts and applications that only need to be executed when needed - using the `heroku run` command. Use this to launch a Rails console process attached to your local terminal for experimenting in your app's environment:


```
:::= $ heroku run rails console
exit
```


# Rake

Rake can be run as an attached process exactly like the console:


```sh
$ heroku run rake db:migrate
```



# Webserver

By default, your app's web process runs `rails server`, which uses Webrick. This is fine for testing, but for production apps you'll want to switch to a more robust webserver. We recommend Thin.


To use Thin with Rails, add it to your `Gemfile`:



```sh
gem 'thin'
```

Run `bundle install` to set up your bundle locally. For even better performance we recommend using a concurrent server such as [Unicorn](http://unicorn.bogomips.org/) or [Puma](https://github.com/puma/puma.io) that will allow your Rails app to take multiple requests at a time. However these servers can require additional setup that varies based on your application.



### Procfile


Change the command used to launch your web process by creating a file called [Procfile](procfile) and entering this:


```
:::= file.write Procfile

web: bundle exec rails server thin -p $PORT -e $RACK_ENV
```

Set the `RACK_ENV` to development in your environment


```
::: $ echo "RACK_ENV=development" >>.env
```


Test your Procfile locally using Foreman:


```
:::- $ gem uninstall foreman
:::= $ gem install foreman
:::= $ foreman start
```


Looks good, so press Ctrl-C to exit. Deploy your changes to Heroku:



```sh
::: $ git add .
::: $ git commit -m "use thin via procfile"
::: $ git push heroku
```


Check `ps`, you'll see the web process uses your new command specifying Thin as the web server



```sh
:::= $ heroku ps
```

The logs also reflect that we are now using Thin:



```sh
:::= $ heroku logs
```


## Rails Asset Pipeline


There are several options for invoking the [Rails asset pipeline](http://guides.rubyonrails.org/asset_pipeline.html) when deploying to Heroku. For full details please see the [Rails 3.1+ Asset Pipeline on Heroku Cedar](rails3x-asset-pipeline-cedar) article.

If the asset pipeline is working correctly you will see lines indicating that a temporary file is being written. This information is for debugging and does not indicate the final location of the file. Rails 3 did this but did not deliver the debugging lines to standard out, Rails 4 delivers the debugging lines by default. When your app is live you should be able to see all your files in the `public/assets` directory:

```sh
:::= $ heroku run bash
ls public/assets
```

# Troubleshooting


If you push up your app and it crashes (`heroku ps` shows state `crashed`), check your logs to find out what went wrong. Here are some common problems.



### Failed to require a source file



If your app failed to require a sourcefile, chances are good you're running Ruby 1.9.1 or 1.8 in your local environment. The load paths have changed in Ruby 1.9. Port your app forward to Ruby 1.9.2 making certain it works locally before trying to push to Cedar again.



### Encoding error



Ruby 1.9 added more sophisticated encoding support to the language. Not all gems work with Ruby 1.9 (see [isitruby19](http://isitruby19.com/) for information on a particular gem). If you hit an encoding error, you probably haven't fully tested your app with Ruby 1.9.2 in your local environment. Port your app forward to Ruby 1.9.2 making certain it works locally before trying to push to Cedar again.


### Missing a gem

If your app crashes due to missing a gem, you may have it installed locally but not specified in your `Gemfile`. **You must isolate all local testing using `bundle exec`.** For example, don't run `ruby web.rb`, run `bundle exec ruby web.rb`. Don't run `rake db:migrate`, run `bundle exec rake db:migrate`.


Another approach is to create a blank RVM gemset to be absolutely sure you're not touching any system-installed gems:



```sh
$ rvm gemset create my app

$ rvm gemset use my app
```


### Runtime dependencies on development/test gems



If you're still missing a gem when you deploy, check your Bundler groups. Heroku builds your app without the `development` or `test` groups, and if you app depends on a gem from one of these groups to run, you should move it out of the group.



One common example using the RSpec tasks in your `Rakefile`. If you see this in your Heroku deploy:


    $ heroku run rake -T

    Running `bundle exec rake -T` attached to terminal... up, ps.3

    rake aborted!

    no such file to load -- rspec/core/rake_task



Then you've hit this problem. First, duplicate the problem locally like so:



    :::term

    $ bundle install --without development:test

    …

    $ bundle exec rake -T

    rake aborted!

    no such file to load -- rspec/core/rake_task



Now you can fix it by making these Rake tasks conditional on the gem load. For example:


### Rakefile

```ruby
begin

  require "rspec/core/rake_task"



  desc "Run all examples"

  RSpec::Core::RakeTask.new(:spec) do |t|

    t.rspec_opts = %w[--color]

    t.pattern = 'spec/*_spec.rb'

  end

rescue LoadError

end
```

Confirm it works locally, then push to Heroku.

:

