# cmdlog-micro

This plugin for the [Micro text-editor](https://github.com/zyedidia/micro) lets you run terminal/shell/program commmands (with/without args) without leaving your editor.  
Any output is printed to a new (hsplit) view inside the editor.

## Installation

**Micro version >= 1.3.5 is required**

1. Add `https://raw.githubusercontent.com/sum01/cmdlog-micro/pre_release/repo.json` to your `pluginrepos`, like so...

```json
  "pluginrepos": [
    "https://raw.githubusercontent.com/sum01/cmdlog-micro/master/repo.json"
  ],
```

2. Run `plugin install cmdlog` and restart Micro.

## Usage

The main command is `runit`. Using it looks like `runit "git --version"`.

**NOTE:** Because of how Micro works, you must quote any input containing spaces.  
But you don't have to quote a single command that has no args. So `runit ls` is still valid.

### Keybinding

In your `bindings.json`, put `"Alt-l": "cmdlog.prompt_runit"` (replacing `Alt-l` with desired keybind).  
This has the side-effect of not requiring to have to quote things, since the prompt will auto-quote your input.

### Chaning Commands

Use the semi-colon `;` to chain commands, like so...  
`runit "ls -l;git --version"`
