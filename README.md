# LoloVim

Configuración personal de Neovim basada en **LazyVim v8**, orientada a desarrollo **.NET Core / C#** en Windows con soporte para TypeScript, Python y Rust.

## Stack

| Componente | Detalle |
|---|---|
| Base | LazyVim v8 sobre lazy.nvim |
| Colorscheme | solarized-osaka (transparent) |
| Completion | blink.cmp |
| Picker | telescope.nvim + fzf-native |
| Formatter | conform.nvim |
| LSP principal C# | OmniSharp Roslyn v1.39.14 |
| Debug .NET | netcoredbg via nvim-dap |
| AI | GitHub Copilot + Claude Code CLI |

## Requisitos

### 1. Neovim

Versión mínima: **0.10+**

- Windows: `winget install Neovim.Neovim`
- macOS: `brew install neovim`
- Linux: ver [neovim releases](https://github.com/neovim/neovim/releases)

### 2. Dependencias base

| Herramienta | Para qué | Instalación |
|---|---|---|
| `git` | lazy.nvim y plugins | `winget install Git.Git` |
| `node` + `npm` | LSPs de JS/TS, Copilot | `winget install OpenJS.NodeJS` |
| `python 3` | pyright, black, isort | `winget install Python.Python.3` |
| `ripgrep` | telescope live grep | `winget install BurntSushi.ripgrep.MSVC` |
| `cmake` | telescope-fzf-native | `winget install Kitware.CMake` |
| `gcc` o `clang` | compilar fzf-native | `winget install MSYS2.MSYS2` (luego `pacman -S mingw-w64-x86_64-gcc`) |

> En macOS/Linux reemplazá `winget` por `brew` o el package manager de tu distro.

### 3. .NET SDK 8

Requerido para OmniSharp y netcoredbg.

- Windows: `winget install Microsoft.DotNet.SDK.8`
- macOS/Linux: ver [dot.net](https://dot.net)

### 4. Nerd Font

La config usa íconos de Nerd Fonts. Sin la fuente instalada vas a ver cuadritos.

Recomendada: **JetBrainsMono Nerd Font**

- Descargar: [nerdfonts.com](https://www.nerdfonts.com/font-downloads)
- Configurarla en tu terminal (Windows Terminal, iTerm2, Alacritty, etc.)

### 5. Shell

| Plataforma | Shell requerido |
|---|---|
| Windows | PowerShell (`pwsh`) — `winget install Microsoft.PowerShell` |
| macOS/Linux | `fish` — [fishshell.com](https://fishshell.com) |

### 6. Claude Code CLI (opcional)

Para el panel de Claude integrado en Neovim.

```bash
npm install -g @anthropic-ai/claude-code
```

## Instalación

### Windows

```powershell
# 1. Clonar la config
git clone https://github.com/TU_USUARIO/TU_REPO.git "$env:LOCALAPPDATA\nvim"

# 2. Abrir Neovim — lazy.nvim se instala solo y baja todos los plugins
nvim
```

### macOS / Linux

```bash
# 1. Clonar la config
git clone https://github.com/TU_USUARIO/TU_REPO.git ~/.config/nvim

# 2. Abrir Neovim
nvim
```

> La primera vez que abrís Neovim, lazy.nvim descarga e instala todos los plugins automáticamente. Después Mason instala los LSPs, formatters y linters. Esperá a que termine antes de abrir archivos.

## Keymaps principales

### General

| Keymap | Acción |
|---|---|
| `<leader>sa` | Select All |
| `<leader>z` | Zen Mode |
| `<leader>i` | Toggle Inlay Hints |
| `ss` / `sv` | Split horizontal / vertical |
| `sh/sk/sj/sl` | Mover entre ventanas |
| `te` | Nueva tab |
| `<Tab>` / `<S-Tab>` | Tab siguiente / anterior |

### Telescope

| Keymap | Acción |
|---|---|
| `;f` | Find Files |
| `;r` | Live Grep |
| `\\` | Buffers |
| `;e` | Diagnostics |
| `sf` | File Browser |

### LSP

| Keymap | Acción |
|---|---|
| `gd` | Go to Definition |
| `gi` | Go to Implementation |
| `gr` | Go to References |
| `gy` | Go to Type Definition |
| `<C-j>` | Next Diagnostic |

### C# — Navegación

| Keymap | Acción |
|---|---|
| `<leader>nC` | Find Controllers |
| `<leader>nS` | Find Services |
| `<leader>nR` | Find Repositories |
| `<leader>nD` | Find DTOs/Models |
| `<leader>nI` | Find Interfaces |
| `<leader>ni` | Smart Navigation (Controller→Service→Repo) |

### C# — Refactoring

| Keymap | Acción |
|---|---|
| `<leader>rn` | Rename con preview |
| `<leader>ca` / `<leader>cA` | Code Action / Source Action |
| `<leader>re` | Extract Method/Variable |
| `<leader>ri` | Inline Variable/Method |
| `<leader>rr` | Rewrite/Restructure |
| `<leader>qf` | Quick Fix |
| `<leader>co` | Organize Imports |
| `<leader>cu` | Remove Unused Imports |

### Debug (.NET — estilo Visual Studio)

| Keymap | Acción |
|---|---|
| `<F5>` | Start/Continue |
| `<F9>` | Toggle Breakpoint |
| `<F10>` | Step Over |
| `<F11>` | Step Into |
| `<S-F11>` | Step Out |
| `<leader>du` | Toggle DAP UI |
| `<leader>de` | Eval Expression |

### Claude Code

| Keymap | Acción |
|---|---|
| `<leader>co` | Abrir panel Claude |
| `<leader>ct` | Toggle panel Claude |
| `<leader>cc` | Cerrar panel Claude |
| `<leader>cs` | Enviar selección a Claude |
| `<leader>cf` | Enviar archivo completo |

## LSP configurado

| Lenguaje | Servidor |
|---|---|
| C# / .NET | OmniSharp Roslyn |
| TypeScript / JS | ts_ls |
| CSS | cssls |
| Tailwind | tailwindcss |
| HTML | html |
| YAML | yamlls |
| Python | pyright |
| Lua | lua_ls |
| Rust | rust-analyzer |

## Estructura

```
nvim/
├── init.lua                    # Bootstrap
├── lazyvim.json                # LazyVim v8 config
├── lazy-lock.json              # Lockfile de plugins
├── stylua.toml                 # Formato Lua
└── lua/
    ├── config/
    │   ├── lazy.lua            # Setup lazy.nvim
    │   ├── options.lua         # Opciones Vim/Neovim
    │   ├── keymaps.lua         # Keymaps custom
    │   ├── autocmds.lua        # Autocmds
    │   └── performance.lua     # Optimizaciones runtime
    └── plugins/
        ├── lsp.lua             # LSP + Mason
        ├── coding.lua          # Copilot, dial, inc-rename
        ├── editor.lua          # Telescope, git, colors
        ├── ui.lua              # UI: noice, bufferline, lualine
        ├── format.lua          # conform.nvim
        ├── treesitter.lua      # Treesitter
        ├── debug.lua           # DAP para .NET
        ├── colorscheme.lua     # solarized-osaka
        ├── claude-code.lua     # Panel Claude CLI
        ├── csharp-navigation.lua  # Navegación C# por capas
        └── csharp-refactor.lua    # Refactoring Roslyn
```
