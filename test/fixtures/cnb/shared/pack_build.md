## Build the application image with the pack CLI

Now build an image named `my-image-name` by executing the heroku builder against the application by running the
`pack build` command:

```
$ pack build my-image-name --path .
:::-- $ docker rmi -f my-image-name
:::-- $ pack build my-image-name --path . 2>&1 | tee build_output.txt
:::-> $ cat build_output.txt
```

> [!NOTE]
> Your output may differ.

Verify that you see “Successfully built image my-image-name” at the end of the output. And verify that the image is present locally:

```
:::>> $ docker image ls --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}" | grep my-image-name
```
