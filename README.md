# LoloVim

Configuración personal de Neovim basada en **LazyVim v8**, orientada a desarrollo web (Node.js, React, Next.js) y Python en Windows, con soporte para Rust.

## Stack

| Componente | Detalle |
|---|---|
| Base | LazyVim v8 sobre lazy.nvim |
| Colorscheme | solarized-osaka (transparent) |
| Completion | blink.cmp |
| Picker | telescope.nvim + fzf-native |
| Formatter | conform.nvim |
| Debug | nvim-dap + nvim-dap-python (Python) + nvim-dap-vscode-js (Node/JS/TS) |
| Testing | neotest (neotest-python + neotest-vitest) |
| Tasks | overseer.nvim + package-info.nvim |
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
| `python 3` | pyright, ruff, debugpy | `winget install Python.Python.3` |
| `ripgrep` | telescope live grep | `winget install BurntSushi.ripgrep.MSVC` |
| `cmake` | telescope-fzf-native | `winget install Kitware.CMake` |
| `gcc` o `clang` | compilar fzf-native | `winget install MSYS2.MSYS2` (luego `pacman -S mingw-w64-x86_64-gcc`) |

> En macOS/Linux reemplazá `winget` por `brew` o el package manager de tu distro.

### 3. Nerd Font

La config usa íconos de Nerd Fonts. Sin la fuente instalada vas a ver cuadritos.

Recomendada: **JetBrainsMono Nerd Font**

- Descargar: [nerdfonts.com](https://www.nerdfonts.com/font-downloads)
- Configurarla en tu terminal (Windows Terminal, iTerm2, Alacritty, etc.)

### 4. Shell

| Plataforma | Shell requerido |
|---|---|
| Windows | PowerShell (`pwsh`) — `winget install Microsoft.PowerShell` |
| macOS/Linux | `fish` — [fishshell.com](https://fishshell.com) |

### 5. Claude Code CLI (opcional)

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

### Debug (Python / Node — estilo Visual Studio)

| Keymap | Acción |
|---|---|
| `<F5>` | Start/Continue |
| `<F9>` | Toggle Breakpoint |
| `<F10>` | Step Over |
| `<F11>` | Step Into |
| `<S-F11>` | Step Out |
| `<leader>du` | Toggle DAP UI |
| `<leader>de` | Eval Expression |
| `<leader>dpr` | Python: Run Test Method |
| `<leader>dpc` | Python: Run Test Class |

### Testing (neotest)

| Keymap | Acción |
|---|---|
| `<leader>tr` | Run Nearest Test |
| `<leader>tf` | Run Test File |
| `<leader>ts` | Toggle Summary |

### Tasks (overseer.nvim)

| Keymap | Acción |
|---|---|
| `<leader>oo` | Toggle Task List |
| `<leader>or` | Run Task |

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
| TypeScript / JS | ts_ls |
| CSS | cssls |
| Tailwind | tailwindcss |
| HTML | html |
| YAML | yamlls |
| Python | pyright + ruff |
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
        ├── debug.lua           # DAP UI + virtual-text + keymaps (genérico)
        ├── debug-python.lua    # nvim-dap-python (debugpy)
        ├── debug-node.lua      # nvim-dap-vscode-js (pwa-node)
        ├── testing.lua         # neotest (Python + Vitest)
        ├── tasks.lua           # overseer.nvim + package-info.nvim
        ├── colorscheme.lua     # solarized-osaka
        └── claude-code.lua     # Panel Claude CLI
```
