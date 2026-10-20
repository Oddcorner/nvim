# Custom Neovim Configuration (Kickstart-based)

A minimalist, high-performance Neovim configuration built from the ground up on Neovim's built-in plugin manager, **vim.pack**. This setup focuses on "only what I use," moving away from the bloat of pre-configured distributions like LazyVim while maintaining powerful IDE-like features.

## 🚀 Core Philosophies
- **Visibility:** One primary `init.lua` makes the configuration easy to trace and modify.
- **Performance:** Minimal plugin count (7) ensuring near-instant startup.
- **Native-First:** Prioritizes Neovim 0.12 native features (LSP, completion, fuzzy cmdline, statusline) over external plugins where possible.

## 🛠️ Key Components

### 🎨 Aesthetics & UI
- **Theme:** `tokyonight-night` for a vibrant, low-strain dark mode.
- **Statusline:** Neovim's default statusline shows diagnostics and LSP progress.
- **Indent Guides:** `listchars` (`leadmultispace`) draws a guide every `shiftwidth` columns.
- **Git Integration:** `gitsigns` shows additions, changes, and deletions in the gutter.

### 🔍 Navigation & Search
- **Fuzzy finding:** Native command-line autocompletion (`wildtrigger()`) with fuzzy matching drives `:find` (via `fd`), `:b` and `:Recent`. `:Grep` (`<leader>/`) searches the project with ripgrep into quickfix.
- **Oil:** Edit the filesystem like a buffer.
- **File slots:** Global marks `A`-`D` work like harpoon.

### 💻 Development Tools
- **LSP:** `vim.lsp.config` / `vim.lsp.enable` (`lua_ls`, `gopls`).
- **Treesitter:** Uses Neovim's native API for fast, reliable syntax highlighting and smart indentation.
- **Autocompletion:** Native `'autocomplete'` + `vim.lsp.completion`, with built-in snippet jumping via Tab.

---

## ⌨️ Custom Keybindings

The `<leader>` key is set to **Space**.

### Search
| Keybind | Action | Description |
|:--- |:--- |:--- |
| `<leader>sf` | Search Files | Fuzzy find files in your project |
| `<leader>sb` | Search Buffer | Fuzzy find **inside** the current file (location list) |
| `<leader>/` | Global Grep | Search for text strings across the whole project |
| `<leader>sr` | Recent Files | Re-open recently edited files |
| `<leader><space>`| Buffers | Switch between currently open files |

### LSP (Intellisense)
| Keybind | Action | Description |
|:--- |:--- |:--- |
| `gd` | Go to Definition | Jump to where a variable/function is defined |
| `K` | Hover | Show documentation/type info for word under cursor |
| `<leader>rn`| Rename | Project-wide variable renaming |
| `<leader>ca`| Code Action | Apply LSP suggested fixes |
| `grr` / `gri` / `grt` | References / Implementation / Type definition | Built-in defaults |
| `grc` | Incoming Calls | Who calls this function? |
| `<leader>ss` / `<leader>sw` | Symbols | Document / workspace symbols |

### Autocompletion (Menu)
- **`<Down>` / `<Up>`**: Navigate the suggestion list.
- **`<Enter>`**: Confirm selection (or the first item).
- **`<Tab>`**: Jump to the next placeholder in a code snippet.
- **`<S-Tab>`**: Jump to the previous placeholder in a code snippet.

### General & Windowing
| Keybind | Action |
|:--- |:--- |
| `<leader>e` | Open Oil file explorer |
| `<leader>a` / `<leader>q` | Add file to a slot / list slots |
| `<leader>1`-`4` | Jump to file slot |
| `<Esc>` | Clear search highlights |
| `Ctrl + h/j/k/l` | Navigate between split windows |
| `gcc` | Toggle line comment (Native Neovim) |

---

## 📦 Installation

1. Backup your current config: `mv ~/.config/nvim ~/.config/nvim_backup`
2. Clone this configuration into `~/.config/nvim/init.lua`.
3. Open Neovim; `vim.pack` installs all plugins at the revisions in `nvim-pack-lock.json`.
4. Update plugins with `:lua vim.pack.update()`.

## ⚙️ Requirements
- **Neovim 0.12+** (Required for `vim.pack`, `'autocomplete'` and `wildtrigger()`)
- **Language servers:** `lua-language-server` and `gopls` on `PATH` (e.g. `go install golang.org/x/tools/gopls@latest`, `sudo dnf install lua-language-server`).
- **Ripgrep** and **fd:** For `:Grep` (`<leader>/`) and `:find` (`<leader>sf`).
