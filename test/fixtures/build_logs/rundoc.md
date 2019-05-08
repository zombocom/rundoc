Logs produced while building your application (deploying) are separated from your [runtime logs](https://devcenter.heroku.com/articles/logging#log-retrieval). The build logs for failed and successful deploys are available via the dashboard of the application.

```
:::-- $ touch Gemfile
:::-- $ bundle _1.15.2_ install
:::-- $ git init && git add . && git commit -m first
:::-- $ heroku create
:::-- $ git push heroku master
```

To view your build logs, first visit the dashboard for the application (`https://dashboard.heroku.com/apps/<app-name>`):

```
:::>> website.visit(name: "dashboard", url: "https://dashboard.heroku.com", visible: true)

while current_url != "https://dashboard.heroku.com/apps"
  puts "waiting for successful login: #{current_url}"
  sleep 1
end

git_url = `git config --get remote.heroku.url`.chomp
app_name = git_url.split("/").last.gsub(".git", "")
session.visit "https://dashboard.heroku.com/apps/#{app_name}"
sleep 2

email = ENV['HEROKU_EMAIL'] || `heroku auth:whoami`
session.execute_script %Q{$("span:contains(#{email}").html('developer@example.com')}

:::>> website.screenshot(name: "dashboard", upload: "s3")
```

Next click on the "Activity" tab:

```
:::>> website.nav(name: "dashboard")
session.first(:link, "Activity").click
sleep 2

email = ENV['HEROKU_EMAIL'] || `heroku auth:whoami`
session.execute_script %Q{$("span:contains(#{email}").html('developer@example.com')}

:::>> website.screenshot(name: "dashboard", upload: "s3")
```

From here you can click on "View build log" to see your most recent build:

```
:::>> website.nav(name: "dashboard")
session.first(:link, "View build log").click
sleep 2

email = ENV['HEROKU_EMAIL'] || `heroku auth:whoami`
session.execute_script %Q{$("span:contains(#{email}").html('developer@example.com')}

:::>> website.screenshot(name: "dashboard", upload: "s3")
```
