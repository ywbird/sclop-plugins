# sclop-plugins

My plugins for [slop-sclop](https://github.com/ywbird/slop-sclop), a minimal coding agent for the terminal.

## Install

```sh
git clone https://github.com/ywbird/sclop-plugins.git ~/.config/sclop/plugins
```

Then load the ones you want in `~/.config/sclop/init.lua`:

```lua
require('plugins/interview')
require('plugins/0rwx-ai-x').setup()
require('plugins/opencode-session-header').setup()
```

## Plugins

| Plugin | Description |
| --- | --- |
| `interview.lua` | `/interview [project goal]` starts a project interview with the `interview-me` skill, then records the confirmed intent in `TODO.md` |
| `0rwx-ai-x/` | Tells the agent to start every README it writes with the official AI:X logo block (CC0, 0rwx.com); ships `assets/AI-X-{dark,light}.svg` to copy into `docs/assets/` |
| `opencode-session-header.lua` | Sends a stable `x-opencode-session` header on provider requests, so opencode Go keeps one session across turns |

## Built-in plugins

These ship with sclop (`/usr/local/share/sclop/plugins`) and are not part of this repo:

| Plugin | Description |
| --- | --- |
| `korean-ime.lua` | Korean IME handling in the input prompt |
| `question.lua` | `question` tool for asking the user and waiting for an answer |
| `webfetch.lua` | `webfetch` tool for fetching URLs as markdown or html |
