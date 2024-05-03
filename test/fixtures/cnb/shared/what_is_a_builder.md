## What is a builder?

> [!NOTE]
> Skip ahead if you want to build the application first and get into the details later. You won't need to
> know about builders for the rest of this tutorial.

In short, a builder is a delivery mechanism for buildpacks. A builder contains references to base images and individual buildpacks. A base image contains the operating system and system dependencies. Buildpacks are the components that will configure an image to run your application, that’s where the bulk of the logic lives and why the project is called “Cloud Native Buildpacks” and not “Cloud Native Builders.”

You can view the contents of a builder via the command `pack builder inspect`. For example:

```
:::>> $ pack builder inspect heroku/builder:22 | grep Buildpacks: -m1 -A10
```

> [!NOTE]
> Your output version numbers may differ.

This output shows the various buildpacks that represent the different languages that are supported by this builder such as `heroku/go` and `heroku/nodejs-engine`.
