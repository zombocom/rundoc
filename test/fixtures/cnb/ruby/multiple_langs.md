## Configuring multiple languages

Language support is provided by individual buildpacks that are shipped with the builder. The above example uses the `heroku/nodejs` buildpack which is [visible on GitHub](https://github.com/heroku/buildpacks-ruby). When you execute `pack build` with a builder, every buildpack has the opportunity to "detect" if it should execute against that project. The `heroku/ruby` buildpack looks for a `Gemfile.lock` in the root of the project and if found, knows how to detect a node version and install dependencies.

In addition to this auto-detection behavior, you can specify buildpacks through the `--buildpack` flag with the `pack` CLI or through a [project.toml](https://buildpacks.io/docs/for-app-developers/how-to/build-inputs/specify-buildpacks/) file at the root of your application.

For example, if you wanted to install both Ruby, NodeJS and Python you could create a `project.toml` file in the root of your application and specify those buildpacks.

```toml
:::>> file.write project.toml
[_]
schema-version = "0.2"
id = "sample.ruby+python.app"
name = "Sample Ruby & Python App"
version = "1.0.0"

[[io.buildpacks.group]]
uri = "heroku/python"

[[io.buildpacks.group]]
uri = "heroku/nodejs"

[[io.buildpacks.group]]
uri = "heroku/ruby"

[[io.buildpacks.group]]
uri = "heroku/procfile"
```

Ensure that a `requirements.txt` file, a `package.json` file and a `Gemfile.lock` file all exist and then build your application:

```
:::>> $ touch requirements.txt
:::>> $ pack build multiple-languages-app --path .
```

You can run the image and inspect the dependencies:

```
$ docker run -it --rm --platform linux/amd64 multiple-languages-app bash
:::>- $ docker run --rm --platform linux/amd64 multiple-languages-app python --version
```
