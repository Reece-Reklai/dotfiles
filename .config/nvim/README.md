# 🧠 Neovim Learning & Reference Guide

This is your **personal Neovim study and reference manual** —
a short, structured, and beginner-friendly guide to understanding your config, finding help in docs, and mastering core features like LSP, Treesitter, and formatting.

---

## 🧭 Quick Learning Path

If you're new, follow this order for best results:
1) 🪜 Core Setup & Basics/
├─ Leader Key
├─ Clipboard Integration
└─ Line Numbers

2) ⚙️ Keymaps & Navigation/
├─ Defining Mappings
└─ Keymap Modes (normal, insert, visual)

3) 🧩 Plugin Management/
├─ Plugin Overview Table
└─ How Neovim Loads Plugins

4) 🌳 Treesitter — Smarter Syntax/
├─ What Treesitter Does
└─ Example Setup

5) 🧠 LSP — Language Server Protocol/
├─ Overview of LSP Features
├─ Main Plugins (Mason, LSPConfig)
└─ Example Config

6) 💬 Autocompletion & Snippets/
├─ Setting up nvim-cmp
└─ Integrating LuaSnip

7) ✂️ Formatting & Linting/
└─ Using conform.nvim for Code Formatting

8) ⚡ Useful Neovim Commands/
└─ Health, Info, and Debug Commands

9) 🧩 Debugging & Troubleshooting/
├─ Common Checks
└─ Reloading and Inspecting Variables

10) 📚 Learning Resources & References/
├─ Official Neovim Docs
├─ Plugin Docs
└─ Lua Learning

11) 💡 Tips for Growth/
└─ Everyday Efficiency Tricks

---

## 🪜 1. Core Setup & Basics

### 🔹 Leader Key

The **leader key** is used as a prefix for your custom shortcuts.

```lua
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
Setting this early ensures all your mappings work consistently.

Usually set to space for convenience.

Docs:
:help mapleader
https://neovim.io/doc/user/map.html#mapleader

🔹 Clipboard Integration
Sync Neovim’s clipboard with your OS clipboard so you can paste to/from other programs.

lua
Copy code
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)
vim.schedule() delays execution to avoid slowing startup.

Remove if you prefer Neovim’s own internal clipboard.

Docs:
:help 'clipboard'
https://neovim.io/doc/user/options.html#'clipboard'

🔹 Line Numbers
Use both:

number → Absolute line numbers

relativenumber → Relative line numbers (for 5j, 3k, etc.)

Docs:
:help number
https://neovim.io/doc/user/options.html#'number'

⚙️ 2. Keymaps & Navigation
Define shortcuts with the modern Lua API:

lua
Copy code
vim.keymap.set('n', '<leader>q', vim.cmd.quit, { desc = 'Quit Neovim' })
Modes:

n = normal

i = insert

v = visual

{ 'n', 'v' } = multiple modes

Docs:
:help vim.keymap.set()
https://neovim.io/doc/user/lua.html#vim.keymap.set()

🧩 3. Plugin Management Overview
Plugins extend Neovim with new features.

Plugin	Purpose
nvim-treesitter	Syntax, structure, highlighting
nvim-lspconfig	Connects Neovim to language servers
mason.nvim	Installs LSP servers and tools
mason-lspconfig.nvim	Bridges Mason + LSPConfig
nvim-cmp	Completion engine
LuaSnip	Snippet engine
conform.nvim	Formatter and linter

Docs:
:help packages
https://neovim.io/doc/user/repeat.html#packages

🌳 4. Treesitter — Smarter Syntax Highlighting
Treesitter uses AST parsing to understand your code structure.
It improves syntax highlighting, indentation, and code navigation.

Example:

lua
Copy code
require('nvim-treesitter.configs').setup({
  ensure_installed = { 'lua', 'go', 'rust', 'javascript', 'html' },
  highlight = { enable = true },
  indent = { enable = true },
})
Docs:
https://github.com/nvim-treesitter/nvim-treesitter#readme

🧠 5. LSP — Language Server Protocol
LSP adds IDE-like features to Neovim:

Hover documentation

Go-to definition

Diagnostics

Rename symbol

Main plugins:

mason.nvim — installs servers

mason-lspconfig.nvim — integrates Mason + LSPConfig

nvim-lspconfig — connects Neovim to servers

Example:

lua
Copy code
require('lspconfig').lua_ls.setup({
  settings = {
    Lua = {
      format = {
        enable = true,
        defaultConfig = {
          indent_style = "space",
          indent_size = "2",
        },
      },
    },
  },
})
Docs:
:help lspconfig
https://github.com/neovim/nvim-lspconfig#readme

💬 6. Autocompletion & Snippets
Combine nvim-cmp for completions with LuaSnip for snippets.

Example:

lua
Copy code
local cmp = require('cmp')
cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
  }),
})
Docs:
:help ins-completion
https://neovim.io/doc/user/insert.html#ins-completion
https://github.com/hrsh7th/nvim-cmp
https://github.com/L3MON4D3/LuaSnip

✂️ 7. Formatting & Linting
Use formatters via conform.nvim to keep your code consistent.

lua
Copy code
require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = { "prettier" },
  },
})
Docs:
https://github.com/stevearc/conform.nvim#readme

⚡ 8. Useful Neovim Commands
Command	Description
:checkhealth	Check plugin and LSP health
:messages	Show startup logs
:scriptnames	List loaded scripts
:verbose map <key>	Find conflicting mappings
:LspInfo	Show LSP server info
:Mason	Open Mason UI

Docs:
https://neovim.io/doc/user/usr_toc.html

🧩 9. Debugging & Troubleshooting
Quick checks
Run :checkhealth

Check logs via :messages

Reload config: :luafile %

Print variables:

lua
Copy code
:lua print(vim.inspect(variable))
Docs:
:help lua-guide
https://neovim.io/doc/user/lua-guide.html

📚 10. Learning Resources & References
🔸 Official Neovim Docs
Manual — https://neovim.io/doc/user/

Lua Guide — https://neovim.io/doc/user/lua-guide.html

API Reference — https://neovim.io/doc/user/api.html

🔸 Plugin Docs
nvim-lspconfig — https://github.com/neovim/nvim-lspconfig

mason.nvim — https://github.com/williamboman/mason.nvim

nvim-cmp — https://github.com/hrsh7th/nvim-cmp

LuaSnip — https://github.com/L3MON4D3/LuaSnip

nvim-treesitter — https://github.com/nvim-treesitter/nvim-treesitter

conform.nvim — https://github.com/stevearc/conform.nvim

🔸 Lua Learning
Learn Lua Fast — https://learnxinyminutes.com/docs/lua/

Lua for Neovim — https://neovim.io/doc/user/lua.html

💡 Tips for Growth
Open help anytime: :help <topic> (e.g. :help mapleader)

Hover over a function and press K to view documentation.

Reload config without restarting: :luafile %

Regularly check plugin health: :checkhealth

Tweak one setting at a time and observe behavior.

