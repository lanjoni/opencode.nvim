# opencode.nvim

[![tests](https://github.com/lanjoni/opencode.nvim/actions/workflows/test.yml/badge.svg)](https://github.com/lanjoni/opencode.nvim/actions/workflows/test.yml)
![neovim version](https://img.shields.io/badge/Neovim-0.8%2B-green)
![status](https://img.shields.io/badge/Status-beta-blue)

**a new neovim integration for opencode** — bringing opencode assistant to your favorite editor with a pure lua implementation.

> 🎯 **TL;DR:** this project is a fork of [coder/claudecode.nvim](https://github.com/coder/claudecode.nvim). the reason? well, I've been using `claudecode.nvim` directly and the experience is amazing with this plugin. after some time I'm testing opencode, and it seems the only existing integrations with it are not smooth enough in comparison to my previous claude code experience. so, to improve it, I made this fork, specially handling file reference with properly anchors (with text like `@path/to/file#L1-L2`) instead of what other opencode plugins does (refer just using plain text). also it's important to mention that implementation was made using opencode with [kimi k2.5](https://www.kimi.com/ai-models/kimi-k2-5).

<https://github.com/user-attachments/assets/c069c25a-5dba-4737-b4c9-b0962c804f40>

## what makes this special

the original implementation has a reverse-engineered version of claude code plugin for other IDEs, so that's one of the reasons why this experience was so smooth.

- **pure lua, zero dependencies** — built entirely with `vim.loop` and neovim built-ins
- **built with AI** — used opencode to make this implementation
- **proper file handling** - as opencode still doesn't support websocket connection (that's an issue and this feature is in development right now) all handling here doesn't have the smoothiest experience, BUT it seems better integrated for simple usage (as I prefer to use a vanilla setup for my coding experience), making correctly file handling and interacting better with terminal

## installation

```lua
{
  "lanjoni/opencode.nvim",
  dependencies = { "folke/snacks.nvim" },
  config = true,
  keys = {
    { "<leader>a", nil, desc = "AI/OpenCode" },
    { "<leader>ac", "<cmd>OpenCode<cr>", desc = "Toggle OpenCode" },
    { "<leader>af", "<cmd>OpenCodeFocus<cr>", desc = "Focus OpenCode" },
    { "<leader>ar", "<cmd>OpenCode --resume<cr>", desc = "Resume OpenCode" },
    { "<leader>aC", "<cmd>OpenCode --continue<cr>", desc = "Continue OpenCode" },
    { "<leader>ab", "<cmd>OpenCodeAdd %<cr>", desc = "Add current buffer" },
    { "<leader>as", "<cmd>OpenCodeSend<cr>", mode = "v", desc = "Send to OpenCode" },
    {
      "<leader>as",
      "<cmd>OpenCodeTreeAdd<cr>",
      desc = "Add file",
      ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
    },
    -- Diff management
    { "<leader>aa", "<cmd>OpenCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>OpenCodeDiffDeny<cr>", desc = "Deny diff" },
  },
}
```

that's it! the plugin will auto-configure everything else.

## requirements

- neovim >= 0.8.0
- [opencode](https://opencode.ai/docs/) installed
- [folke/snacks.nvim](https://github.com/folke/snacks.nvim) for enhanced terminal support

## local installation configuration

if you have your opencode in some different place that you may want to refer (or even a local development branch) you can use a local installation path.

### configuring for local installation

configure the plugin with the direct path:

```lua
{
  "lanjoni/opencode.nvim",
  dependencies = { "folke/snacks.nvim" },
  opts = {
    terminal_cmd = "~/.opencode/local/opencode", -- Point to local installation
  },
  config = true,
  keys = {
    -- Your keymaps here
  },
}
```

> **Note**: If OpenCode was installed globally via npm, you can use the default configuration without specifying `terminal_cmd`.

## Quick Demo

```vim
" Launch OpenCode in a split
:OpenCode

" OpenCode now sees your current file and selections in real-time!

" Send visual selection as context
:'<,'>OpenCodeSend

" OpenCode can open files, show diffs, and more
```

## usage

1. **launch opencode**: run `:OpenCode` to open opencode in a split terminal (I like to use the default settings pressing `<leader>ac`
2. **send context**:
   - select text in visual mode and use `<leader>as` to send it to opencode
   - in `nvim-tree`/`neo-tree`/`oil.nvim`/`mini.nvim`, press `<leader>as` on a file to add it to opencode's context
3. **let opencode work**: opencode can now:
   - see your current file and selections in real-time
   - open files in your editor
   - show diffs with proposed changes
   - access diagnostics and workspace info
  
also to keep things minimal, I removed the model selection to make it directly to opencode. the implementation can be done in future but for now I usually recommend selecting models and more inside the opencode interface.

## key commands

- `:OpenCode` - toggle the opencode terminal window
- `:OpenCodeFocus` - smart focus/toggle opencode terminal
- `:OpenCodeSend` - send current visual selection to opencode
- `:OpenCodeAdd <file-path> [start-line] [end-line]` - add specific file to opencode context with optional line range
- `:OpenCodeDiffAccept` - accept diff changes
- `:OpenCodeDiffDeny` - reject diff changes

## working with diffs

when opencode proposes changes, the plugin opens a native Neovim diff view:

- **Accept**: `:w` (save) or `<leader>aa`
- **Reject**: `:q` or `<leader>ad`

you can edit opencode's suggestions before accepting them.

## how it works

This plugin integrates with OpenCode using terminal-based communication. When you launch OpenCode, the plugin opens it in a dedicated terminal and communicates via stdin injection.

### current implementation (terminal-based)

1. **terminal launch**: opens opencode in a split terminal with `--port` flag for http api access
2. **autocomplete simulation**: sends `@filename` via terminal input to trigger opencode's autocomplete
3. **file references**: selects files from autocomplete to create styled file parts
4. **context sharing**: sends visual selections and file references directly to the prompt

### WIP: future websocket/sse support

when opencode implements proper IDE integration api:
- websocket or sse for bidirectional communication
- structured message support (filepart, agentpart, etc.)
- lock file system at `~/.opencode/ide/[port].lock`
- mcp tool implementation

the current terminal-based approach provides immediate functionality while we await official websocket api support from opencode.

## architecture

built with pure lua and zero external dependencies:

- **Terminal Integration** - Direct terminal control with `jobstart()` and stdin injection
- **Autocomplete Simulation** - Triggers OpenCode's TUI autocomplete via keystrokes
- **Port Management** - HTTP API port tracking for future enhancements
- **Selection Tracking** - Real-time context updates
- **Native Diff Support** - Seamless file comparison
- **WIP: WebSocket Server** - RFC 6455 compliant implementation (for future OpenCode API)

For deep technical details, see [ARCHITECTURE.md](./ARCHITECTURE.md).

## Advanced Configuration

```lua
{
  "lanjoni/opencode.nvim",
  dependencies = { "folke/snacks.nvim" },
  opts = {
    -- Server Configuration
    port_range = { min = 10000, max = 65535 },
    auto_start = true,
    log_level = "info", -- "trace", "debug", "info", "warn", "error"
    terminal_cmd = nil, -- Custom terminal command (default: "opencode")
                        -- For local installations: "~/.opencode/local/opencode"
                        -- For native binary: use output from 'which opencode'

    -- Send/Focus Behavior
    -- When true, successful sends will focus the OpenCode terminal if already connected
    focus_after_send = false,

    -- Selection Tracking
    track_selection = true,
    visual_demotion_delay_ms = 50,

    -- Terminal Configuration
    terminal = {
      split_side = "right", -- "left" or "right"
      split_width_percentage = 0.30,
      provider = "auto", -- "auto", "snacks", "native", "external", "none", or custom provider table
      auto_close = true,
      snacks_win_opts = {}, -- Opts to pass to `Snacks.terminal.open()` - see Floating Window section below

      -- Provider-specific options
      provider_opts = {
        -- Command for external terminal provider. Can be:
        -- 1. String with %s placeholder: "alacritty -e %s" (backward compatible)
        -- 2. String with two %s placeholders: "alacritty --working-directory %s -e %s" (cwd, command)
        -- 3. Function returning command: function(cmd, env) return "alacritty -e " .. cmd end
        external_terminal_cmd = nil,
      },
    },

    -- Diff Integration
    diff_opts = {
      layout = "vertical", -- "vertical" or "horizontal"
      open_in_new_tab = false,
      keep_terminal_focus = false, -- If true, moves focus back to terminal after diff opens
      hide_terminal_in_new_tab = false,
      -- on_new_file_reject = "keep_empty", -- "keep_empty" or "close_window"

      -- Legacy aliases (still supported):
      -- vertical_split = true,
      -- open_in_current_tab = true,
    },
  },
  keys = {
    -- Your keymaps here
  },
}
```

### Working Directory Control

You can fix the OpenCode terminal's working directory regardless of `autochdir` and buffer-local cwd changes. Options (precedence order):

- `cwd_provider(ctx)`: function that returns a directory string. Receives `{ file, file_dir, cwd }`.
- `cwd`: static path to use as working directory.
- `git_repo_cwd = true`: resolves git root from the current file directory (or cwd if no file).

Examples:

```lua
require("opencode").setup({
  -- Top-level aliases are supported and forwarded to terminal config
  git_repo_cwd = true,
})

require("opencode").setup({
  terminal = {
    cwd = vim.fn.expand("~/projects/my-app"),
  },
})

require("opencode").setup({
  terminal = {
    cwd_provider = function(ctx)
      -- Prefer repo root; fallback to file's directory
      local cwd = require("opencode.cwd").git_root(ctx.file_dir or ctx.cwd) or ctx.file_dir or ctx.cwd
      return cwd
    end,
  },
})
```

## Floating Window Configuration

The `snacks_win_opts` configuration allows you to create floating OpenCode terminals:

```lua
{
  "lanjoni/opencode.nvim",
  dependencies = { "folke/snacks.nvim" },
  keys = {
    { "<C-,>", "<cmd>OpenCodeFocus<cr>", desc = "OpenCode", mode = { "n", "x" } },
  },
  opts = {
    terminal = {
      snacks_win_opts = {
        position = "float",
        width = 0.9,
        height = 0.9,
        keys = {
          hide = { "<C-,>", function(self) self:hide() end, mode = "t", desc = "Hide" },
        },
      },
    },
  },
}
```

For complete configuration options, see:

- [Snacks.nvim Terminal Documentation](https://github.com/folke/snacks.nvim/blob/main/docs/terminal.md)
- [Snacks.nvim Window Documentation](https://github.com/folke/snacks.nvim/blob/main/docs/win.md)

## Terminal Providers

### None (No-Op) Provider

Run OpenCode without any terminal management inside Neovim. This is useful for advanced setups where you manage the CLI externally (tmux, kitty, separate terminal windows) while still using the WebSocket server and tools.

You have to take care of launching CC and connecting it to the IDE yourself. (e.g. `opencode --ide` or launching opencode and then selecting the IDE using the `/ide` command)

```lua
{
  "lanjoni/opencode.nvim",
  opts = {
    terminal = {
      provider = "none", -- no UI actions; server + tools remain available
    },
  },
}
```

Notes:

- No windows/buffers are created. `:OpenCode` and related commands will not open anything.
- The WebSocket server still starts and broadcasts work as usual. Launch the OpenCode CLI externally when desired.

### External Terminal Provider

Run OpenCode in a separate terminal application outside of Neovim:

```lua
-- Using a string template (simple)
{
  "lanjoni/opencode.nvim",
  opts = {
    terminal = {
      provider = "external",
      provider_opts = {
        external_terminal_cmd = "alacritty -e %s", -- %s is replaced with opencode command
        -- Or with working directory: "alacritty --working-directory %s -e %s" (first %s = cwd, second %s = command)
      },
    },
  },
}

-- Using a function for dynamic command generation (advanced)
{
  "lanjoni/opencode.nvim",
  opts = {
    terminal = {
      provider = "external",
      provider_opts = {
        external_terminal_cmd = function(cmd, env)
          -- You can build complex commands based on environment or conditions
          if vim.fn.has("mac") == 1 then
            return { "osascript", "-e", string.format('tell app "Terminal" to do script "%s"', cmd) }
          else
            return "alacritty -e " .. cmd
          end
        end,
      },
    },
  },
}
```

### Custom Terminal Providers

You can create custom terminal providers by passing a table with the required functions instead of a string provider name:

```lua
require("opencode").setup({
  terminal = {
    provider = {
      -- Required functions
      setup = function(config)
        -- Initialize your terminal provider
      end,

      open = function(cmd_string, env_table, effective_config, focus)
        -- Open terminal with command and environment
        -- focus parameter controls whether to focus terminal (defaults to true)
      end,

      close = function()
        -- Close the terminal
      end,

      simple_toggle = function(cmd_string, env_table, effective_config)
        -- Simple show/hide toggle
      end,

      focus_toggle = function(cmd_string, env_table, effective_config)
        -- Smart toggle: focus terminal if not focused, hide if focused
      end,

      get_active_bufnr = function()
        -- Return terminal buffer number or nil
        return 123 -- example
      end,

      is_available = function()
        -- Return true if provider can be used
        return true
      end,

      -- Optional functions (auto-generated if not provided)
      toggle = function(cmd_string, env_table, effective_config)
        -- Defaults to calling simple_toggle for backward compatibility
      end,

      _get_terminal_for_test = function()
        -- For testing only, defaults to return nil
        return nil
      end,
    },
  },
})
```

### Custom Provider Example

Here's a complete example using a hypothetical `my_terminal` plugin:

```lua
local my_terminal_provider = {
  setup = function(config)
    -- Store config for later use
    self.config = config
  end,

  open = function(cmd_string, env_table, effective_config, focus)
    if focus == nil then focus = true end

    local my_terminal = require("my_terminal")
    my_terminal.open({
      cmd = cmd_string,
      env = env_table,
      width = effective_config.split_width_percentage,
      side = effective_config.split_side,
      focus = focus,
    })
  end,

  close = function()
    require("my_terminal").close()
  end,

  simple_toggle = function(cmd_string, env_table, effective_config)
    require("my_terminal").toggle()
  end,

  focus_toggle = function(cmd_string, env_table, effective_config)
    local my_terminal = require("my_terminal")
    if my_terminal.is_focused() then
      my_terminal.hide()
    else
      my_terminal.focus()
    end
  end,

  get_active_bufnr = function()
    return require("my_terminal").get_bufnr()
  end,

  is_available = function()
    local ok, _ = pcall(require, "my_terminal")
    return ok
  end,
}

require("opencode").setup({
  terminal = {
    provider = my_terminal_provider,
  },
})
```

The custom provider will automatically fall back to the native provider if validation fails or `is_available()` returns false.

Note: If your command or working directory may contain spaces or special characters, prefer returning a table of args from a function (e.g., `{ "alacritty", "--working-directory", cwd, "-e", "opencode", "--help" }`) to avoid shell-quoting issues.

## Auto-Save Plugin Issues

Using auto-save plugins can cause diff windows opened by OpenCode to immediately accept without waiting for input. You can avoid this using a custom condition:

<details>
<summary>Pocco81/auto-save.nvim</summary>

```lua
opts = {
  -- ... other options
  condition = function(buf)
    local fn = vim.fn
    local utils = require("auto-save.utils.data")

    -- First check the default conditions
    if not (fn.getbufvar(buf, "&modifiable") == 1 and utils.not_in(fn.getbufvar(buf, "&filetype"), {})) then
      return false
    end

    -- Exclude opencode diff buffers by buffer name patterns
    local bufname = vim.api.nvim_buf_get_name(buf)
    if bufname:match("%(proposed%)") or
       bufname:match("%(NEW FILE %- proposed%)") or
       bufname:match("%(New%)") then
      return false
    end

    -- Exclude by buffer variables (opencode sets these)
    if vim.b[buf].opencode_diff_tab_name or
       vim.b[buf].opencode_diff_new_win or
       vim.b[buf].opencode_diff_target_win then
       return false
    end

    -- Exclude by buffer type (opencode diff buffers use "acwrite")
    local buftype = fn.getbufvar(buf, "&buftype")
    if buftype == "acwrite" then
      return false
    end

    return true -- Safe to auto-save
  end,
},
```

</details>
<details>
<summary>okuuva/auto-save.nvim</summary>

```lua
opts = {
  -- ... other options
  condition = function(buf)
    -- Exclude opencode diff buffers by buffer name patterns
    local bufname = vim.api.nvim_buf_get_name(buf)
    if bufname:match('%(proposed%)') or bufname:match('%(NEW FILE %- proposed%)') or bufname:match('%(New%)') then
      return false
    end

    -- Exclude by buffer variables (opencode sets these)
    if
      vim.b[buf].opencode_diff_tab_name
      or vim.b[buf].opencode_diff_new_win
      or vim.b[buf].opencode_diff_target_win
    then
      return false
    end

    -- Exclude by buffer type (opencode diff buffers use "acwrite")
    local buftype = vim.fn.getbufvar(buf, '&buftype')
    if buftype == 'acwrite' then
      return false
    end

    return true -- Safe to auto-save
  end,
},
```

</details>

## Troubleshooting

- **OpenCode not connecting?** Check `:OpenCodeStatus` and verify lock file exists in `~/.opencode/ide/`
- **Need debug logs?** Set `log_level = "debug"` in opts
- **Terminal issues?** Try `provider = "native"` if using snacks.nvim
- **Local installation not working?** If you used `opencode install`, set `terminal_cmd = "~/.opencode/local/opencode"` in your config. Check `which opencode` vs `ls ~/.opencode/local/opencode` to verify your installation type.
- **Native binary installation not working?** If you used the alpha native binary installer, run `opencode doctor` to verify installation health and use `which opencode` to find the binary path. Set `terminal_cmd = "/path/to/opencode"` with the detected path in your config.

## Contributing

Run tests with `make test` or `LUA_PATH="./lua/?.lua;./lua/?/init.lua;./?.lua;$LUA_PATH" busted tests/`.

## License

[MIT](LICENSE)

## Acknowledgements

- [OpenCode CLI](https://opencode.ai) by Anthropic
- Built with assistance from AI (how meta!)
