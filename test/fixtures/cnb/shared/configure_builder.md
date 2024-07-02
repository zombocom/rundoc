## Configure the default pack builder

Once `pack` is installed, the only configuration you'll need for this tutorial is to set a default builder:

```
:::>> $ pack config default-builder heroku/builder:22
```

You can view your default builder at any time:

```
:::>> $ pack config default-builder
```

The following tutorial is built on amd64 architecture (also known as x86). If you are building on a machine with different architecture (such as arm64/aarch64 for a Mac) you will need to tell Docker to use `linux/amd64` architecture. You can do this via a `--platform linux/amd64` flag or by exporting an environment variable:

```
$ export DOCKER_DEFAULT_PLATFORM=linux/amd64
:::-- rundoc.configure
# Needed because all `$` commands are run as separate isolated processes

ENV["DOCKER_DEFAULT_PLATFORM"] = "linux/amd64"
```
