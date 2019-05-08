## master

## 1.0.1

- Allow non-headless browser sessions and navigation [#23](https://github.com/schneems/rundoc/pull/23)
- Fix issue where a background task's log file was not present before it was attempted to be opened.
- Allow composability of documents `rundoc.depend_on` and `rundoc.require` [#19](https://github.com/schneems/rundoc/pull/19)
- The `rundoc` command is now `rundoc.configure`.
- Ignore chdir warning since that affect is intentional [#20](https://github.com/schneems/rundoc/pull/20)

## 1.0.0

- Now using a propper PEG parser (parslet)
