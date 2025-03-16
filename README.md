# Neovim Beginner’s Power Pack
A modern, beginner-friendly `init.lua` configuration for Neovim, packed with essentials to supercharge your editing without the steep learning curve. Inspired by kickstart.nvim.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 🚀 What is this?
This `init.lua` is your launchpad into Neovim! Designed for beginners, it offers a clean setup with must-have features like autocompletion, syntax highlighting, and fuzzy finding—all while keeping things lightweight and easy to understand. Whether you're coding Rust, Go, Java, or just editing text, this config has you covered.

## ✨ Features
- **Plug-and-Play**: Works out of the box with `lazy.nvim` for effortless plugin management.
- **Smart Navigation**: Fuzzy file finding with Telescope, plus intuitive window movement (`<C-h/j/k/l>`).
- **Code Superpowers**: LSP support for Rust, Go, Java, Lua, and more, with autocompletion and diagnostics.
- **Pretty & Practical**: Tokyo Night theme, Treesitter-powered syntax highlighting, and a sleek statusline.
- **Beginner-Friendly**: Every setting and keymap is commented for easy learning.
- **Git Integration**: Visualize changes with Gitsigns.
- **Extras**: REST client, surround editing, and todo comment highlighting.

## 🛠️ Prerequisites
- [Neovim](https://neovim.io/) (v0.8.0 or later).
- Git (for cloning and plugin installation).
- A terminal emulator (e.g., iTerm2, Alacritty, or your default).
- Optional: A Nerd Font for icon support (set `vim.g.have_nerd_font = true` in `init.lua`).

## 📥 Installation
1. **Backup your current config** (if any):
   ```bash
   mv ~/.config/nvim ~/.config/nvim.bak
Clone this repo:
git clone https://github.com/yourusername/nvim-beginner-power-pack ~/.config/nvim
Launch Neovim:
nvim
Wait for plugins: lazy.nvim will install everything automatically on first launch (takes a few seconds).

🎉 Usage
Open Neovim with nvim.
Explore keybindings (prefix: <Space>):
<leader>sf: Search files with Telescope.
<leader>sg: Live grep across your project.
gd: Jump to definition (LSP).
K: Hover documentation.
<leader>ca: Code actions.
<C-h/j/k/l>: Switch between windows.
Check init.lua comments for more!

🔧 Customization
Add Plugins: Edit the require('lazy').setup() section.
Change Keymaps: Modify vim.keymap.set() calls.
Switch Themes: Replace tokyonight-night in the folke/tokyonight.nvim config.
Nerd Fonts: Enable with vim.g.have_nerd_font = true for icons.

🌟 Highlights
Telescope: Blazing-fast file and text search.
LSP: Built-in support for Rust (with Clippy), Go, Java, and Lua.
Treesitter: Precise syntax highlighting for multiple languages.
Mini.nvim: Lightweight tools for surround editing and AI textobjects.

🤝 Contributing
Love it? Hate it? Want to tweak it?
Fork this repo.
Create a branch (git checkout -b my-cool-feature).
Commit changes (git commit -m "Add my cool feature").
Push it (git push origin my-cool-feature).
Open a Pull Request!

📜 License
MIT License—see LICENSE for details.

🙌 Thanks
The Neovim team for an amazing editor.
Plugin authors like folke, hrsh7th, and more.
You, for trying this out!
Start Vimming like a pro! 🎈
