# cmdlog-micro

This is a plugin for the [Micro text-editor](https://github.com/zyedidia/micro).  
It lets you run terminal commmands without leaving your editor, printing output to a view inside the editor.

PS: This plugin is OS-agnostic, and the Unix-specific things are merely for example.

## Installation

**Micro version >= 1.3.5 is required**

1. Add `https://raw.githubusercontent.com/sum01/cmdlog-micro/master/repo.json` to your `pluginrepos`, like so...

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

Put `"Alt-l": "cmdlog.prompt_runit"` (replace `Alt-l` with desired keybind) in your `bindings.json`.  
This has the side-effect of not requiring to have to quote things, since the prompt will auto-quote your input.

### Chaining Commands

Use the semi-colon `;` to chain commands, like so...  
`runit "ls -l;git --version"`
