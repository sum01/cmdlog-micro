# cmdlog

The main command is `runit`, which follows the format `runit "cmd args;secondcmd secondargs"`

Option for vertical instead of horizontal: `cmdlog-vertical` which is `false` by default.  
Set it to `true` to open as a vertical split (instead of horizontal) by doing CtrlE `set cmdlog-vertical true`.

Note that input must be quoted if it contains spaces, but is optional if if it's a single word like `runit pwd`.  
Args are optional, but a simple example is `runit "git --version"`.

## Chaining Commands

Commands can be chained by using a semi-colon as a delimiter.  
Example chaining commands: `runit "git init;touch myfile.js;git add myfile.js;git commit -m 'created my file'"`

## Keybinding

If you want to keybind `runit` to open a prompt, add `cmdlog.prompt_runit` to your `bindings.json`
Example: `"Alt-l": "cmdlog.prompt_runit"`

Note that the prompt auto-quotes input, so you don't have to quote it if you use the `prompt_runit` binding.
