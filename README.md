# Custom Neovim Configuration (Kickstart-based)

A minimalist, high-performance Neovim configuration built from the ground up using **Lazy.nvim**. This setup focuses on "only what I use," moving away from the bloat of pre-configured distributions like LazyVim while maintaining powerful IDE-like features.

## 🚀 Core Philosophies
- **Visibility:** One primary `init.lua` makes the configuration easy to trace and modify.
- **Performance:** Minimal plugin count (under 15) ensuring near-instant startup.
- **Native-First:** Prioritizes Neovim 0.10+ native features (like built-in commenting and folding) over external plugins where possible.

## 🛠️ Key Components

### 🎨 Aesthetics & UI
- **Theme:** `tokyonight-night` for a vibrant, low-strain dark mode.
- **Statusline:** `lualine.nvim` provides mode, file info, and LSP status.
- **Indent Guides:** `indent-blankline` helps visualize code scope levels.
- **Git Integration:** `gitsigns` shows additions, changes, and deletions in the gutter.

### 🔍 Navigation & Search
- **Telescope:** The centerpiece for fuzzy finding. Custom-tuned with a dropdown theme for buffer searches.
- **Nvim-Tree:** A sidebar file explorer for visual project management.
- **Smart Folds:** Treesitter-aware folding (`za`) that understands code logic/scope rather than just indentation.

### 💻 Development Tools
- **LSP & Mason:** Modern `LspAttach` logic for managing and connecting language servers (`lua_ls`, `gopls`, etc.).
- **Treesitter:** Uses Neovim's native API for fast, reliable syntax highlighting and smart indentation.
- **Autocompletion:** `nvim-cmp` with specific logic for Arrow Key navigation and Snippet jumping via Tab.

---

## ⌨️ Custom Keybindings

The `<leader>` key is set to **Space**.

### Telescope (Search)
| Keybind | Action | Description |
|:--- |:--- |:--- |
| `<leader>sf` | Search Files | Fuzzy find files in your project |
| `<leader>sb` | Search Buffer | Fuzzy find **inside** the current file (Dropdown) |
| `<leader>/` | Global Grep | Search for text strings across the whole project |
| `<leader>sr` | Recent Files | Re-open recently edited files |
| `<leader>ss` | Symbols | Jump to functions/variables in current file |
| `<leader><space>`| Buffers | Switch between currently open files |

### LSP (Intellisense)
| Keybind | Action | Description |
|:--- |:--- |:--- |
| `gd` | Go to Definition | Jump to where a variable/function is defined |
| `K` | Hover | Show documentation/type info for word under cursor |
| `<leader>rn`| Rename | Project-wide variable renaming |
| `<leader>ca`| Code Action | Apply LSP suggested fixes |

### Autocompletion (Menu)
- **`<Down>` / `<Up>`**: Navigate the suggestion list.
- **`<Enter>`**: Confirm selection.
- **`<Tab>`**: Jump to the next placeholder in a code snippet.
- **`<S-Tab>`**: Jump to the previous placeholder in a code snippet.

### General & Windowing
| Keybind | Action |
|:--- |:--- |
| `<leader>e` | Toggle File Explorer (Sidebar) |
| `<Esc>` | Clear search highlights |
| `Ctrl + h/j/k/l` | Navigate between split windows |
| `gcc` | Toggle line comment (Native Neovim) |

---

## 📦 Installation

1. Backup your current config: `mv ~/.config/nvim ~/.config/nvim_backup`
2. Clone this configuration into `~/.config/nvim/init.lua`.
3. Open Neovim; `Lazy.nvim` will automatically download and install all plugins.
4. Run `:Mason` to install any additional LSP servers or formatters you require.

## ⚙️ Requirements
- **Neovim 0.10+** (Required for native commenting and modern LSP logic)
- **Nerd Font:** For devicons in the statusline and file tree.
- **Ripgrep:** For Telescope global grep functionality (`<leader>/`).
