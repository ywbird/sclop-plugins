<!-- Official 0rwx logos from https://0rwx.com/ (CC0 / public domain). -->
<p>
  <a href="https://0rwx.com/">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="docs/assets/AI-X-dark.svg">
      <source media="(prefers-color-scheme: light)" srcset="docs/assets/AI-X-light.svg">
      <img src="docs/assets/AI-X-light.svg" alt="AI:X — AI가 만든 프로젝트 (0rwx)" width="64" height="64" align="right">
    </picture>
  </a>
</p>

# sclop-plugins

My plugins for [slop-sclop](https://github.com/ywbird/slop-sclop), a minimal coding agent for the terminal.

## Install

```sh
git clone https://github.com/ywbird/sclop-plugins.git ~/.config/sclop/plugins
```

Then load the ones you want in `~/.config/sclop/init.lua`:

```lua
require('plugins/interview')
require('plugins/0rwx-ai-x')
require('plugins/opencode-session-header').setup()
require('plugins/notify')
require('plugins/turn-notify').setup()
```

## Plugins

| Plugin | Description |
| --- | --- |
| `interview.lua` | `/interview [project goal]` starts a project interview with the `interview-me` skill, then records the confirmed intent in `TODO.md` |
| `0rwx-ai-x/` | `/0rwx [README path]` inserts the official AI:X logo block (CC0, 0rwx.com) before the title, copies `assets/AI-X-{dark,light}.svg` to `docs/assets/` and commits both (skipped without git or outside a work tree); no agent turn, and a second run is a no-op |
| `opencode-session-header.lua` | Sends a stable `x-opencode-session` header on provider requests, so opencode Go keeps one session across turns |
| `notify.lua` | `notify` tool: sends a desktop notification with `notify-send` (`summary` required, `body` and `urgency` optional) |
| `turn-notify.lua` | Sends one `sclop: turn finished` notification when a turn runs 60 s or longer (`min_seconds` to change); silent on shorter turns and when `notify-send` is missing |

## Built-in plugins

These ship with sclop (`/usr/local/share/sclop/plugins`) and are not part of this repo:

| Plugin | Description |
| --- | --- |
| `korean-ime.lua` | Korean IME handling in the input prompt |
| `question.lua` | `question` tool for asking the user and waiting for an answer |
| `webfetch.lua` | `webfetch` tool for fetching URLs as markdown or html |
