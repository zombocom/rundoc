## Configuring your web process with the Procfile

Most buildpacks rely on existing community standards to allow you to configure your application declaratively. They can also implement custom logic based on file contents on disk or environment variables present at build time.

The `Procfile` is a configuration file format that was [introduced by Heroku in 2011](https://devcenter.heroku.com/articles/procfile), you can now use this behavior on your CNB-powered application via the `heroku/procfile`, which like the rest of the buildpacks in our builder [is open source](https://github.com/heroku/buildpacks-procfile). The `heroku/procfile` buildpack allows you to configure your web startup process.

This is the `Procfile` of the getting started guide:

```
:::-> $ cat Procfile
```

By including this file and using `heroku/procfile` buildpack, your application will receive a default web process. You can configure this behavior by changing the contents of that file.
