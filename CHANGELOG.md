## master

## 1.1.1

- Fix log read race condition (https://github.com/schneems/rundoc/pull/25)

## 1.1.0

- Pipe logic is now implemented through a parser (https://github.com/schneems/rundoc/pull/22)
- Bugfix, background processes error when the log file is not touched before read, not sure why this is possible but here's a fix for it anyway (https://github.com/schneems/rundoc/commit/620ae55d8a5d3d443cf5e8cb77950a841f92900c)

## 1.0.1

- Allow non-headless browser sessions and navigation [#23](https://github.com/schneems/rundoc/pull/23)
- Fix issue where a background task's log file was not present before it was attempted to be opened.
- Allow composability of documents `rundoc.depend_on` and `rundoc.require` [#19](https://github.com/schneems/rundoc/pull/19)
- The `rundoc` command is now `rundoc.configure`.
- Ignore chdir warning since that affect is intentional [#20](https://github.com/schneems/rundoc/pull/20)

## 1.0.0

- Now using a propper PEG parser (parslet)
