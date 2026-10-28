# Debug Terminal
An in-game debug terminal + stats overlay for Godot 4: a command line with
built-in commands for inspecting/editing live nodes, watchers with threshold
coloring, conditional breakpoints, aliases, saved stat "profiles", and
draggable/resizable panels.

## Install

1. Copy the `debug_terminal` folder into your project's `addons/` folder, so
   you have `res://addons/debug_terminal/`.
2. Project Settings > Plugins > enable **Debug Terminal**.
   This registers two autoloads automatically: `DebugRegistry` (the
   command/watcher engine) and `DebugOverlay` (the on-screen panels). You
   don't need to add either manually, and disabling the plugin removes both.
3. Run your project and press `F3`. Type `help` in the terminal for list of commands.

## Try the demo

Open and run `addons/debug_terminal/demo/DemoScene.tscn` directly - it's a
minimal scene with arrows for controls, a square and a sample
watcher registered in code, so you can see the API in action.

## A few starting commands

- `help` - commands grouped by category (`help watchers` to filter one)
- `stats` - lists every watcher, grouped by category
- `show FPS`, `show_category rendering` - reveal stats on the panel
- `tree` - print the live scene hierarchy
- `set_node /root/Main/Player health 100` - edit a live property
- `break_if FPS < 20` - pause the game the instant a watcher crosses a
  threshold; `resume` to continue
- `save_profile combat`, `load_profile combat` - snapshot/restore which
  stats are shown
- `sysinfo` - OS/CPU/GPU/RAM/display/engine snapshot

## Registering your own commands and watchers

From any script, once the plugin is enabled:

```gdscript
DebugRegistry.register_command(
	"heal_player",
	func(amount: int = 100): player.health += amount; return "Healed %d" % amount,
	"heal_player [amount] - heals the player",
    "gameplay"
)

DebugRegistry.watch("PlayerHealth", func(): return player.health, 1, true, "gameplay")
```

See `demo/DemoScene.gd` for a runnable example of both.

## Known limitations

- Input isolation while typing works by force-releasing InputMap *actions*
  each frame the terminal input has focus. If your game reads raw keys
  directly (`Input.is_key_pressed`) instead of actions, those aren't
  covered.
- `alias` captures raw tokens as a single command + preset args, not a
  true multi-command macro language (no `;`-chaining).


## License
MIT License

Copyright (c) 2026 Patrick Heil (PawnxPawn)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
