## Image structure under the hood

> [!NOTE]
> Skip this section if you want to try building your application with CNBs and learn about container structure later.

If you’re an advanced `Dockerfile` user you might be interested in learning more about the internal structure of the image on disk. You can access the image disk interactively by using the `bash` docker command above.

If you view the root directory `/` you’ll see there is a `layers` folder. Every buildpack that executes gets a unique folder. For example:

```
:::>> $ docker run --rm my-image-name "ls /layers | grep ruby"
```

Individual buildpacks can compose multiple layers from their buildpack directory. For example you can see that `ruby` binary is present within that ruby buildpack directory:

```
:::>> $ docker run --rm my-image-name "which ruby"
```

OCI images are represented as sequential modifications to disk. By scoping buildpack disk modifications to their own directory, the CNB API guarantees that changes to a layer in one buildpack will not affect the contents of disk to another layer. This means that OCI images produced by CNBs are rebaseable by default, while those produced by Dockerfile are not.

We saw before how the image booted a web server by default. This is accomplished using an entrypoint. In another terminal outside of the running container you can view that entrypoint:

```
:::>> $ docker inspect my-image-name | grep '"Entrypoint": \[' -A2
```

From within the image, you can see that file on disk:

```
:::>> $ docker run --rm my-image-name "ls /cnb/process/"
```

While you might not need this level of detail to build and run an application with Cloud Native Buildpacks, it is useful to understand how they’re structured if you ever want to write your own buildpack.
