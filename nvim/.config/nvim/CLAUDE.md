# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This directory is the `nvim` Stow package's payload (`nvim/.config/nvim/...`) and gets symlinked to `~/.config/nvim/`. The parent `../../../CLAUDE.md` covers repo-wide conventions (Stow layout, Catppuccin palette, cross-file wiring); this file covers Neovim-internal specifics.

## Architecture

Config derives from [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), split into modules:

- `init.lua` — minimal bootstrap. Sets `<space>` as leader (both `mapleader` and `maplocalleader`), sets `vim.g.have_nerd_font = false` (so plugins fall back to unicode/empty icons), then requires in order: `options` → `keymaps` → `lazy-bootstrap` → `lazy-plugins`. Leader must be set before plugins load.
- `lua/lazy-bootstrap.lua` — clones lazy.nvim (`stable` branch) into `stdpath('data')/lazy/lazy.nvim` on first run.
- `lua/lazy-plugins.lua` — **explicit** plugin registry. Each plugin is a `require 'plugins.<name>'` line inside the `lazy.setup{...}` table. Dropping a new file into `lua/plugins/` is **not** enough — you must also add a matching `require` line here. Several entries are commented out (`tokyonight`, `kanagawa`, `which-key`, `todo-comments`, `mini`, `debug`) — these are available to re-enable but currently off.
- `lua/plugins/*.lua` — one plugin (or closely-related group) per file, each returning a lazy.nvim spec table.
- `lazy-lock.json` — pinned plugin commits. Commit it alongside any plugin version/spec change.

## Tooling chain (LSP / format / lint)

Three plugins share Mason's `PATH` and together cover the "on-save" developer loop — a change in one often requires matching changes in the others.

- **LSP** (`lua/plugins/lspconfig.lua`): servers are declared in the `servers` table (currently `cssls`, `tailwindcss`, `ts_ls`, `html`, `yamlls`, `lua_ls`). `mason-tool-installer` auto-installs every key in `servers` plus the extras appended via `vim.list_extend(ensure_installed, {...})` (currently just `stylua`). `mason-lspconfig` is set with `ensure_installed = {}` and `automatic_installation = false` on purpose — installs are driven by `mason-tool-installer`, not mason-lspconfig. To add an LSP: add it to `servers`, then run `:Mason` or restart. Capabilities are merged from `blink.cmp` (not nvim-cmp).
- **Formatters** (`lua/plugins/conform.lua`): `conform.nvim` runs `format_on_save` on `BufWritePre` with a 500ms timeout and `lsp_format = 'fallback'`. `c` and `cpp` are explicitly opted out. `<leader>f` formats manually. Tools like `prettierd`, `stylua`, `black`, `isort`, `dockerfmt`, `markdownlint`, `beautysh`, `tombi`, `rustywind` must be on `PATH` — install via Mason (`:MasonInstall <tool>`) or add to `ensure_installed` in lspconfig.lua.
- **Linters** (`lua/plugins/lint.lua`): `nvim-lint` runs on `BufEnter`, `BufWritePost`, `InsertLeave` (modifiable buffers only). Linters by filetype: `eslint_d`, `markdownlint`, `jsonlint`, `hadolint`, `vale`. These also come from Mason.

LSP buffer keymaps (set via the `LspAttach` autocmd in lspconfig.lua) route navigation through fzf-lua: `gd`, `gr`, `gi`, `gO`, `gW`, `grt` all use `fzf-lua` pickers, not the builtin quickfix. `grn` = rename, `gra` = code action, `<leader>th` = toggle inlay hints.

## Search / pickers

`fzf-lua` is the sole picker (telescope was removed in `1f24d18`). Semicolon-prefixed keys are the primary bindings: `;f` files, `;r` live grep (hidden + 4096 max cols), `;t` help, `;e` workspace diagnostics, `;q` quickfix, `;s` treesitter symbols, `;;` resume. `<leader>s*` is the secondary namespace (`sk`, `ss`, `sw`, `s.`, `sn`). `<leader><leader>` = buffers, `<leader>/` = fuzzy-in-current-buffer.

## Style

`.stylua.toml` pins: 2-space indent, 160-column line, `AutoPreferSingle` quotes, `call_parentheses = "None"` (so `require 'foo'` without parens is the canonical form — stylua will strip them). When editing Lua here, follow that style or `stylua` will rewrite on save.

## Common commands

- `:Lazy` — plugin manager UI; `:Lazy update` to update, `:Lazy sync` to install missing.
- `:Mason` — LSP/tool installer UI; `:MasonInstall <tool>` for one-offs.
- `:checkhealth` — kickstart includes `lua/plugins/health.lua`; run after changes to verify.
- `:ConformInfo` — inspect which formatter will run for the current buffer.
- `<leader>f` — format current buffer; `<leader>d` — line diagnostic float; `<leader>q` — diagnostics → loclist.
