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



- Write your app


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



```
:::= file.append
  gem 'sqlite3'
```




To this:



    :::ruby

    gem 'pg'



And re-install your dependencies (to generate a new `Gemfile.lock`):



    :::term

    $ bundle install

You will also need to ensure that your application uses postgres locally. Ensure that in your `config/database.yml` that the adapter is set to `postgresql`:


    development:
      adapter: postgresql
      encoding: utf8
      database: myapp_development
      pool: 5
      host: localhost


 Be careful here, if you omit the `sql` at the end of `postgresql` your application will not work. You can create and migrate your database locally by running:

    :::term
    $ bundle exec rake db:create
    $ bundle exec rake db:migrate


Specify Ruby Version in App
---------------------------

Rails 4 will not run on Ruby 1.8.7 which may be installed on your development computer by default, either use Ruby 1.9.3, 2.0 or JRuby in 1.9 compatibility mode. In your `Gemfile` add:

    ruby "1.9.3"

or

    ruby "2.0.0"

You should also be running the same version of Ruby locally. You can verify by running `$ ruby -v`.

Store your app in Git
---------------------

Heroku relies on [git](http://git-scm.com/), a flexible distributed source control managment tool, for deploying your project. If your project is not already in git first verify that `git` is on your system:

    :::term

    $ git --help
    usage: git [--version] [--exec-path[=<path>]] [--html-path] [--man-path] [--info-path]
               [-p|--paginate|--no-pager] [--no-replace-objects] [--bare]
               [--git-dir=<path>] [--work-tree=<path>] [--namespace=<name>]
               [-c name=value] [--help]
               <command> [<args>]
    # ...

If you don't see any output or get `command not found` you will need to install it on your system, verify that the Heroku toolbelt is installed.

Once you've verified that git works, run these three commands in your Rails app directory to initialize and commit your code to git:

    :::term
    $ git init

    $ git add .

    $ git commit -m "init"


Now that your application is committed to git you can deploy to Heroku.

Deploy your application to Heroku

----------------------

Make sure you are in the directory that contains your Rails app, then create the app on Heroku:

    :::term

    $ heroku create

    Creating severe-mountain-793... done, stack is cedar

    http://severe-mountain-793.herokuapp.com/ | git@heroku.com:severe-mountain-793.git

    Git remote heroku added

Verify that the remote was added to your project by running

    :::term
    $ git config -e

If you do not see `fatal: not in a git directory` than you are safe to deploy to Heroku. After you deploy you will need to migrate your database, make sure it is properly scaled and use logs to debug any issues that come up.


Deploy your code:

    :::term

    $ git push heroku master
    Counting objects: 112, done.
    Delta compression using up to 4 threads.
    Compressing objects: 100% (77/77), done.
    Writing objects: 100% (112/112), 27.01 KiB, done.
    Total 112 (delta 20), reused 112 (delta 20)
    -----> Ruby/Rails app detected
    -----> Using Ruby version: ruby-1.9.3
    -----> Installing dependencies using Bundler version 1.3.0.pre.5
           Running: bundle install --without development:test --path vendor/bundle --binstubs vendor/bundle/bin --deployment
           Fetching gem metadata from https://rubygems.org/.........
           Fetching gem metadata from https://rubygems.org/..
           Fetching git://github.com/rails/rails.git
           Fetching git://github.com/rails/coffee-rails.git
           Fetching git://github.com/heroku/rails3_serve_static_assets.git
           Fetching git://github.com/heroku/rails_log_stdout.git
           Fetching git://github.com/rails/sass-rails.git
           Installing rake (10.0.3)
           Installing i18n (0.6.1)
           Installing minitest (4.6.1)
           Installing multi_json (1.6.1)
           Installing atomic (1.0.1)
           Installing thread_safe (0.1.0)
           Installing tzinfo (0.3.35)
           Using activesupport (4.0.0.beta) from git://github.com/rails/rails.git (at master)
           Installing builder (3.1.4)
           Installing erubis (2.7.0)
           Installing rack (1.5.2)
           Installing rack-test (0.6.2)
           Using actionpack (4.0.0.beta) from git://github.com/rails/rails.git (at master)
           Installing mime-types (1.21)
           Installing polyglot (0.3.3)
           Installing treetop (1.4.12)
           Installing mail (2.5.3)
           Using actionmailer (4.0.0.beta) from git://github.com/rails/rails.git (at master)
           Using activemodel (4.0.0.beta) from git://github.com/rails/rails.git (at master)
           Installing activerecord-deprecated_finders (0.0.3)
           Installing arel (3.0.2)
           Using activerecord (4.0.0.beta) from git://github.com/rails/rails.git (at master)
           Installing coffee-script-source (1.4.0)
           Installing execjs (1.4.0)
           Installing coffee-script (2.2.0)
           Installing json (1.7.7)
           Installing rdoc (3.12.1)
           Installing thor (0.17.0)
           Using railties (4.0.0.beta) from git://github.com/rails/rails.git (at master)
           Using coffee-rails (4.0.0.beta) from git://github.com/rails/coffee-rails.git (at master)
           Installing hike (1.2.1)
           Installing jbuilder (1.0.2)
           Installing jquery-rails (2.2.1)
           Installing pg (0.14.1)
           Using bundler (1.3.0.pre.5)
           Installing tilt (1.3.3)
           Installing sprockets (2.8.2)
           Installing sprockets-rails (2.0.0.rc2)
           Using rails (4.0.0.beta) from git://github.com/rails/rails.git (at master)
           Using rails3_serve_static_assets (0.0.1) from git://github.com/heroku/rails3_serve_static_assets.git (at master)
           Using rails_log_stdout (0.0.1) from git://github.com/heroku/rails_log_stdout.git (at master)
           Installing sass (3.2.5)
           Using sass-rails (4.0.0.beta) from git://github.com/rails/sass-rails.git (at master)
           Installing turbolinks (1.0.0)
           Installing uglifier (1.3.0)
           Your bundle is complete! It was installed into ./vendor/bundle
           Post-install message from rdoc:
           Depending on your version of ruby, you may need to install ruby rdoc/ri data:
           <= 1.8.6 : unsupported
           = 1.8.7 : gem install rdoc-data; rdoc-data --install
           = 1.9.1 : gem install rdoc-data; rdoc-data --install
           >= 1.9.2 : nothing to do! Yay!
           Cleaning up the bundler cache.
    -----> Writing config/database.yml to read from DATABASE_URL
    -----> Preparing app for Rails asset pipeline
           Running: rake assets:precompile
           I, [2013-02-25T15:15:26.999810 #1771]  INFO -- : Writing /tmp/build_8twtg5uo0zrj/public/assets/rails-a48208150b2c0da4f80797a999919b58.png
           I, [2013-02-25T15:15:29.993217 #1771]  INFO -- : Writing /tmp/build_8twtg5uo0zrj/public/assets/application-e4bf17ac068b4157db532671a5294743.js
           I, [2013-02-25T15:15:30.065780 #1771]  INFO -- : Writing /tmp/build_8twtg5uo0zrj/public/assets/application-a543268ce31a2798b68675fbfcb1bcdc.css
           Asset precompilation completed (6.24s)
    -----> Rails plugin injection
           Injecting rails_log_stdout
           Injecting rails3_serve_static_assets
    -----> Discovering process types
           Procfile declares types      -> (none)
           Default types for Ruby/Rails -> console, rake, web, worker

    -----> Compiled slug size: 77.6MB
    -----> Launching... done, v6
           http://calm-brook-1268.herokuapp.com deployed to Heroku

    To git@heroku.com:calm-brook-1268.git
     * [new branch]      master -> master



Note: that Rails 4 no longer has a static index page in production, if you're using a new app, there may be no root page.



## Migrate your Database

If you are using the database in your application you need to manually migrate the database by running:

    :::term
    $ heroku run rake db:migrate

Any commands after the `heroku run` will be executed on a Heroku [dyno](dynos).




## Visit your application


You've deployed your code to Heroku. You can now instruct Heroku to execute a process type. Heroku does this by running the associated command in a [dyno](dynos) - a lightweight container which is the basic unit of composition on Heroku.



Let's ensure we have one dyno running the `web` process type:



    :::term

    $ heroku ps:scale web=1



You can check the state of the app's dynos. The `heroku ps` command lists the running dynos of your application:



    :::term

    $ heroku ps

    === web: `bundle exec rails server -p $PORT`

    web.1: up for 5s



Here, one dyno is running.



We can now visit the app in our browser with `heroku open`.



    :::term

    $ heroku open

    Opening severe-mountain-793… done

Heroku gives you a default web app name for simplicty while you are developing. When you are ready to scale up and use Heroku for production you can add your own [Custom Domain](https://devcenter.heroku.com/articles/custom-domains).


## View the logs

If you run into any problems getting your app to perform properly, you will first need to check the logs.

Heroku treats logs as streams of time-ordered events aggregated from the output streams of all the dynos running the components of your application. Heroku’s [Logplex](logplex) provides a single channel for all of these events.

You can view information about your running app using one of the [logging commands](logging), `heroku logs`:



    :::term

    $ heroku logs

    2013-03-10T11:10:34-08:00 heroku[web.1]: State changed from created to starting

    2013-03-10T11:10:37-08:00 heroku[web.1]: Running process with command: `bundle exec rails server -p 53136`

    2013-03-10T11:10:40-08:00 app[web.1]: [2013-03-10 19:10:40] INFO WEBrick 1.3.1

    2013-03-10T11:10:40-08:00 app[web.1]: [2013-03-10 19:10:40] INFO ruby 1.9.2 (2010-12-25) [x86_64-linux]

    2013-03-10T11:10:40-08:00 app[web.1]: [2013-03-10 19:10:40] INFO WEBrick::HTTPServer#start: pid=12198 port=53136

    2013-03-10T11:10:42-08:00 heroku[web.1]: State changed from starting to up


You can also get the full stream of logs by running the logs command with the `--tail` flag like this:

    :::term

    $ heroku logs --tail


## Dyno Idling and Scaling


Heroku will put your application to sleep if you are only running on the single free dyno, this is called [dyno idling](dynos#dyno-idling). This is done to conserve system resources and allows us to offer a free tier. Once your dyno is idled there will be a delay of a few seconds for the first request while we spin your app back up on our system. Subsequent requests will perform normally.



To avoid this, you can scale to more than one web dyno. For example:


    :::term

    $ heroku ps:scale web=2



For each application, Heroku provides [750 free dyno-hours](usage-and-billing#750-free-dynohours-per-app).  Running your app at 2 dynos would exceed this free, monthly allowance, so let's scale back:



    :::term

    $ heroku ps:scale web=1



Console

-------



Heroku allows you to run [one-off proceses](oneoff-admin-ps) - scripts and applications that only need to be executed when needed - using the `heroku run` command. Use this to launch a Rails console process attached to your local terminal for experimenting in your app's environment:



    :::term

    $ heroku run rails console

    Running `bundle exec rails console` attached to terminal... up, ps.1

    irb(main):001:0>



Rake

----



Rake can be run as an attached process exactly like the console:



    :::term

    $ heroku run rake db:migrate



Webserver

---------



By default, your app's web process runs `rails server`, which uses Webrick. This is fine for testing, but for production apps you'll want to switch to a more robust webserver. We recommend Thin.



To use Thin with Rails, add it to your `Gemfile`:



    :::ruby

    gem 'thin'



Run `bundle install` to set up your bundle locally. For even better performance we recommend using a concurrent server such as [Unicorn](http://unicorn.bogomips.org/) or [Puma](https://github.com/puma/puma.io) that will allow your Rails app to take multiple requests at a time. However these servers can require additional setup that varies based on your application.



### Procfile



Change the command used to launch your web process by creating a file called [Procfile](procfile) and entering this:



    web: bundle exec rails server thin -p $PORT -e $RACK_ENV



Set the `RACK_ENV` to development in your environment



    $ echo "RACK_ENV=development" >>.env



Test your Procfile locally using Foreman:


    $ gem install foreman

    $ foreman start

    11:35:11 web.1 | started with pid 3007

    11:35:14 web.1 | => Booting thin

    11:35:14 web.1 | => Rails 3.0.4 application starting in development on http://0.0.0.0:5000

    11:35:14 web.1 | => Call with -d to detach

    11:35:14 web.1 | => Ctrl-C to shutdown server

    11:35:15 web.1 | >> Thin web server (v1.2.8 codename Black Keys)

    11:35:15 web.1 | >> Maximum connections set to 1024

    11:35:15 web.1 | >> Listening on 0.0.0.0:5000, CTRL+C to stop



Looks good, so press Ctrl-C to exit. Deploy your changes to Heroku:



    $ git add .

    $ git commit -m "use thin via procfile"

    $ git push heroku



Check `ps`, you'll see the web process uses your new command specifying Thin as the web server



    :::term

    $ heroku ps

    Process State Command

    ------------ ------------------ ------------------------------

    web.1 starting for 3s bundle exec rails server thin -p $..



The logs also reflect that we are now using Thin:



    :::term

    $ heroku logs

    2013-03-10T11:38:43-08:00 heroku[web.1]: State changed from created to starting

    2013-03-10T11:38:47-08:00 heroku[web.1]: Running process with command: `bundle exec rails server thin -p 34533`

    2013-03-10T11:38:50-08:00 app[web.1]: => Booting Thin

    2013-03-10T11:38:50-08:00 app[web.1]: => Rails 3.0.4 application starting in production on http://0.0.0.0:34533

    2013-03-10T11:38:50-08:00 app[web.1]: => Call with -d to detach

    2013-03-10T11:38:50-08:00 app[web.1]: => Ctrl-C to shutdown server

    2013-03-10T11:38:50-08:00 app[web.1]: >> Thin web server (v1.2.7 codename No Hup)

    2013-03-10T11:38:50-08:00 app[web.1]: >> Maximum connections set to 1024

    2013-03-10T11:38:50-08:00 app[web.1]: >> Listening on 0.0.0.0:34533, CTRL+C to stop

    2013-03-10T11:38:55-08:00 heroku[web.1]: State changed from starting to up



## Rails Asset Pipeline



There are several options for invoking the [Rails asset pipeline](http://guides.rubyonrails.org/asset_pipeline.html) when deploying to Heroku. For full details please see the [Rails 3.1+ Asset Pipeline on Heroku Cedar](rails3x-asset-pipeline-cedar) article.



Troubleshooting

---------------



If you push up your app and it crashes (`heroku ps` shows state `crashed`), check your logs to find out what went wrong. Here are some common problems.



### Failed to require a source file



If your app failed to require a sourcefile, chances are good you're running Ruby 1.9.1 or 1.8 in your local environment. The load paths have changed in Ruby 1.9. Port your app forward to Ruby 1.9.2 making certain it works locally before trying to push to Cedar again.



### Encoding error



Ruby 1.9 added more sophisticated encoding support to the language. Not all gems work with Ruby 1.9 (see [isitruby19](http://isitruby19.com/) for information on a particular gem). If you hit an encoding error, you probably haven't fully tested your app with Ruby 1.9.2 in your local environment. Port your app forward to Ruby 1.9.2 making certain it works locally before trying to push to Cedar again.



### Missing a gem



If your app crashes due to missing a gem, you may have it installed locally but not specified in your `Gemfile`. **You must isolate all local testing using `bundle exec`.** For example, don't run `ruby web.rb`, run `bundle exec ruby web.rb`. Don't run `rake db:migrate`, run `bundle exec rake db:migrate`.



Another approach is to create a blank RVM gemset to be absolutely sure you're not touching any system-installed gems:



    :::term

    $ rvm gemset create my app

    $ rvm gemset use my app



### Runtime dependencies on development/test gems



If you're still missing a gem when you deploy, check your Bundler groups. Heroku builds your app without the `development` or `test` groups, and if you app depends on a gem from one of these groups to run, you should move it out of the group.



One common example using the RSpec tasks in your `Rakefile`. If you see this in your Heroku deploy:



    :::term

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



    :::ruby

    begin

      require "rspec/core/rake_task"



      desc "Run all examples"

      RSpec::Core::RakeTask.new(:spec) do |t|

        t.rspec_opts = %w[--color]

        t.pattern = 'spec/*_spec.rb'

      end

    rescue LoadError

    end



Confirm it works locally, then push to Heroku.

:

