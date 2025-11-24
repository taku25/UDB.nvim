# UDB.nvim

# Unreal Debugger Bridge 💓 Neovim

`UDB.nvim` is a bridge plugin designed to easily perform C++ debugging for Unreal Engine projects within Neovim. Instead of manually writing a tedious `launch.json`, it analyzes the project structure to dynamically generate debug configurations (Launch Config), allowing you to start debugging immediately via `nvim-dap`.

This is the core debugging plugin of the **Unreal Neovim Plugin Suite**, and it depends on [UNL.nvim](https://github.com/taku25/UNL.nvim) and [nvim-dap](https://github.com/mfussenegger/nvim-dap).

[English](README.md) | [日本語 (Japanese)](README_ja.md)

-----

## ✨ Features

  * **Zero-Config Debugging**:
      * Automatically calculates engine paths and binary output locations based on the `.uproject` file location.
      * Automatically handles tedious path specifications and argument settings (e.g., `-game`, `-log`), allowing you to start debugging right away.
  * **Flexible Target Selection**:
      * **Editor**: Launches in Editor mode, supporting Live Coding and Blueprint debugging.
      * **Game**: Launches as a standalone game to debug the actual gameplay environment.
      * **Client / Server**: Supports configurations for future expansion.
  * **UBT.nvim Integration (Recommended)**:
      * If [UBT.nvim](https://github.com/taku25/UBT.nvim) is installed, it automatically retrieves accurate presets from your build settings.
      * Even without UBT, it has fallback functionality to standard configurations (e.g., Development Editor).
  * **nvim-dap Integration**:
      * Wraps [nvim-dap](https://github.com/mfussenegger/nvim-dap), the de facto standard for Neovim, providing a launch flow specialized for Unreal Engine.
      * Supports major DAP adapters such as `codelldb`.

## 🔧 Requirements

  * Neovim v0.11.3 or higher
  * [**UNL.nvim**](https://github.com/taku25/UNL.nvim) (**Required**)
  * [**nvim-dap**](https://github.com/mfussenegger/nvim-dap) (**Required**)
  * **Debugger Adapter:**
      * Setup of `codelldb` (recommended) or `cpptools` is required for C++ debugging.
      * Using [mason.nvim](https://github.com/williamboman/mason.nvim) and [mason-nvim-dap.nvim](https://github.com/jay-babu/mason-nvim-dap.nvim) is strongly recommended.

## 🚀 Installation

Install with your preferred plugin manager.

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
  'taku25/UDB.nvim',
  dependencies = {
     'taku25/UNL.nvim',
     'mfussenegger/nvim-dap',
     -- Optional: Recommended for a better UI experience
     'rcarriga/nvim-dap-ui', 
  },
  opts = {
    -- Place UDB specific configurations here
  },
}
```

## ⚙️ Configuration

This plugin is configured via the setup function of the library `UNL.nvim`, but you can also pass `opts` directly to `UDB.nvim`.

Below are the default settings for `UDB.nvim`:

```lua
opts = {
  logging = {
    level = "info",
    -- Other log settings follow UNL standards
  },
  
  -- Debugger Settings
  debugger = {
    -- The name of the DAP adapter to use by default
    -- Specify the adapter name installed via mason-nvim-dap, etc.
    adapter_type = "codelldb", 
  },

  -- Default Target Settings (Fallback when UBT integration is unavailable)
  presets = {
    { name = "Editor (Development)", Platform = "Win64", IsEditor = true, Configuration = "Development" },
    { name = "Editor (DebugGame)",   Platform = "Win64", IsEditor = true, Configuration = "DebugGame" },
    { name = "Game (Development)",   Platform = "Win64", IsEditor = false, Configuration = "Development" },
  },
  
  default_preset = "Editor (Development)",
}
```

## ⚡ Usage

All commands start with `:UDB`.

```viml
" Start debugging with the default (or previously selected) target
:UDB run_debug

" Select a target (Editor/Game/Configuration) and start debugging
:UDB run_debug!
```

### Command Details

  * **`:UDB run_debug[!]`**:
      * **Without arguments**: Starts the debugger immediately using the configured `default_preset` or the previously used configuration. Automatically detects if the current file is within an Unreal Engine project and acts based on that project's root.
      * **With Bang (`!`)**:
          * Opens a Picker UI to select the launch target.
          * The list displays dynamic presets retrieved from `UBT.nvim` or fallback presets defined in `Config`.
          * Examples:
              * `Editor (Development)`: Launches the Editor (UnrealEditor.exe ProjectName ...)
              * `Game (Development)`: Launches the Game (ProjectName.exe ...)

## 🤖 API & Automation (Automation Examples)

You can customize keymaps using the `UDB.api` module.

### Keymap Example

You can achieve Visual Studio-like operation, such as F5 to start debugging and Shift+F5 to select a target.

```lua
local udb = require("UDB.api")

-- F5: Start Debugging (Last used setting or Default)
vim.keymap.set('n', '<F5>', function() 
  udb.run_debug({ has_bang = false }) 
end, { desc = "UDB: Start Debugging" })

-- Shift+F5: Select Target & Start Debugging
vim.keymap.set('n', '<S-F5>', function() 
  udb.run_debug({ has_bang = true }) 
end, { desc = "UDB: Select Target & Debug" })
```

## Related Plugins

Unreal Engine Plugin Suite:

  * [UEP.nvim](https://github.com/taku25/UEP.nvim): Project exploration and navigation.
  * [UEA.nvim](https://www.google.com/search?q=https://github.com/taku25/UEA.nvim): Search for Blueprint asset references.
  * [UBT.nvim](https://github.com/taku25/UBT.nvim): Build tool integration (Recommended for fetching UDB presets).
  * [UCM.nvim](https://github.com/taku25/UCM.nvim): Add or remove C++ classes.
  * [ULG.nvim](https://github.com/taku25/ULG.nvim): Log output and Live Coding operations.
  * [USH.nvim](https://github.com/taku25/USH.nvim): Unreal Shell integration.
  * [neo-tree-unl](https://github.com/taku25/neo-tree-unl.nvim): Solution Explorer-like tree view.
  * [tree-sitter-unreal-cpp](https://github.com/taku25/tree-sitter-unreal-cpp): Unreal C++ syntax highlighting.

## 📜 License

MIT License

Copyright (c) 2025 taku25

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
