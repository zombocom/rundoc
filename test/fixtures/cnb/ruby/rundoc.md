```
:::-- rundoc.configure
Rundoc.configure do |config|
  config.filter_sensitive(
    "tmp/rundoc_screenshots/screenshot_1.png" =>
      "assets/images/ruby-getting-started-screenshot.png"
  )
end
```

```
:::>> rundoc.require "./intro.md"
```

```
:::>> rundoc.require "../shared/install_pack.md"
```

```
:::>> rundoc.require "../shared/configure_builder.md"
```

```
:::>> rundoc.require "../shared/what_is_a_builder.md"
```

```
:::>> rundoc.require "./download.md"
```

```
:::>> rundoc.require "../shared/pack_build.md"
```

```
:::>> rundoc.require "../shared/what_is_pack_build.md"
```

```
:::>> rundoc.require "../shared/use_the_image.md"
```

```
:::>> rundoc.require "./image_structure.md"
```

```
:::>> rundoc.require "../shared/call_to_action.md"
```

```
:::>> rundoc.require "./multiple_langs.md"
```

```
:::>> rundoc.require "../shared/procfile.md"
```
