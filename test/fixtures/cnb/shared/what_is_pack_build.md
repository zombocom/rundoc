## What does `pack build` do?

> [!NOTE]
> Skip ahead if you want to run the application first and get into the details later.

When you run `pack build` with a builder, each buildpack runs a detection script to determine if it should be eligible to build the application. In our case the `heroku/nodejs-engine` and `heroku/nodejs-npm-install` buildpacks found a `package.json` file on disk and reported that they knew how to install those dependencies. You can view a list of the buildpacks used in the output above:

```
:::-> $ grep DETECTING -A5 ./build_output.txt
```

After the detect phase, each buildpack will execute. Buildpacks can inspect your project, install files to disk, run commands, write environment variables, [and more](https://buildpacks.io/docs/for-buildpack-authors/). You can see some examples of that in the output above.

You can see that the binary is being downloaded and dependencies are installed:

If you’re familiar with Dockerfile you might know that [many commands in a Dockerfile will create a layer](https://dockerlabs.collabnix.com/beginners/dockerfile/Layering-Dockerfile.html). Buildpacks also use layers, but the CNB buildpack API provides for fine grained control over what exactly is in these layers and how they’re composed. Unlike Dockerfile, all images produced by CNBs [can be rebased](https://tag-env-sustainability.cncf.io/blog/2023-12-reduce-reuse-rebase-buildpacks/#reduce-reuserebase). The CNB api also improves on many of the pitfalls outlined in the satirical article [Write a Good Dockerfile in 19 'Easy' Steps](https://jkutner.github.io/2021/04/26/write-good-dockerfile.html).
