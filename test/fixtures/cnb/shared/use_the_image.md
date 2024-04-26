## Use the image

Even though we used `pack` and CNBs to build our image, it can be run with your favorite tools like any other OCI image. We will be using the `docker` command line to run our image.

By default, images will be booted into a web server configuration. You can launch the app we just built by running:

```
:::>> background.start("docker run -it --rm --env PORT=9292 -p 9292:9292 my-image-name", name: "docker_server")
:::-- $ sleep 10
:::-> background.log.read(name: "docker_server")
```

Now when you visit http://localhost:9292 you should see a working web application:

```
:::>> website.visit(name: "localhost", url: "http://localhost:9292")
:::>> website.screenshot(name: "localhost")
```

Don't forget to stop the docker container when you're done.

```
:::-- $ docker stop $(docker ps -q --filter ancestor=my-image-name )
:::-- background.stop(name: "docker_server")
```

Here's a quick breakdown of that command we just ran:

- `docker run` Create and run a new container from an image.
- `-it` Makes the container interactive and allocates a TTY.
- `--rm` Automatically remove the container when it exits.
- `--env PORT=9292` Creates an environment variable named `PORT` and sets it to `9292` this is needed so the application inside the container knows what port to bind the web server.
- `-p 9292:9292` Publishes a container's port(s) to the host. This is what allows requests from your machine to be received by the container.
- `my-image-name` The name of the image you want to use for the application.

So far, we've downloaded an application via git and run a single command `pack build` to generate an image, and then we can use that image as if it was generated via a Dockerfile via the `docker run` command.

In addition to running the image as a web server, you can access the container's terminal interactively. In a new terminal window try running this command:

```
$ docker run -it --rm my-image-name bash
```

Now you can inspect the container interactively. For example, you can see the files on disk with `ls`:

```
$ ls
:::-> $ docker run --rm --platform linux/amd64 my-image-name ls
```

And anything else you would typically do via an interactive container session.
