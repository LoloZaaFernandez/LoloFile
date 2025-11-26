-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.mapleader = " "

vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

vim.opt.number = true
vim.opt.relativenumber = true -- Números relativos para mejor navegación

vim.opt.title = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.hlsearch = true
vim.opt.backup = false
vim.opt.showcmd = true
vim.opt.cmdheight = 0 -- Ocultar cmdline cuando no se usa (moderno)
vim.opt.laststatus = 3
vim.opt.expandtab = true
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8

-- Shell configuración - detectar si es Windows o Unix
if vim.fn.has("win32") == 1 then
  vim.opt.shell = "pwsh" -- PowerShell en Windows
  vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
  vim.opt.shellquote = ""
  vim.opt.shellxquote = ""
else
  vim.opt.shell = "fish" -- Fish en Unix
end

vim.opt.backupskip = { "/tmp/*", "/private/tmp/*" }
vim.opt.inccommand = "split"
vim.opt.ignorecase = true -- Case insensitive searching UNLESS /C or capital in search
vim.opt.smartcase = true -- Smart case
vim.opt.smarttab = true
vim.opt.breakindent = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.wrap = false -- No Wrap lines
vim.opt.backspace = { "start", "eol", "indent" }
vim.opt.path:append({ "**" }) -- Finding files - Search down into subfolders
vim.opt.wildignore:append({ "*/node_modules/*", "*/dist/*", "*/build/*", "*/.git/*" })
vim.opt.splitbelow = true -- Put new windows below current
vim.opt.splitright = true -- Put new windows right of current
vim.opt.splitkeep = "cursor"
vim.opt.mouse = "a" -- Habilitar mouse (recomendado en LazyVim moderno)

-- Undercurl
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

-- Add asterisks in block comments
vim.opt.formatoptions:append({ "r" })

vim.cmd([[au BufNewFile,BufRead *.astro setf astro]])
vim.cmd([[au BufNewFile,BufRead Podfile setf ruby]])

-- Configuraciones modernas de LazyVim
vim.opt.confirm = true -- Confirmar antes de salir con cambios no guardados
vim.opt.cursorline = true -- Resaltar línea actual
vim.opt.formatoptions = "jcroqlnt" -- tcqj por defecto
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.grepprg = "rg --vimgrep"
vim.opt.pumblend = 10 -- Transparencia en popup menu
vim.opt.pumheight = 10 -- Máximo número de items en popup
vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })
vim.opt.showmode = false -- No mostrar modo (ya está en lualine)
vim.opt.signcolumn = "yes" -- Siempre mostrar signcolumn
vim.opt.spelllang = { "en", "es" }
vim.opt.termguicolors = true -- True color support
vim.opt.timeoutlen = 300 -- Menor timeout para mappings
vim.opt.undofile = true -- Historial de deshacer persistente
vim.opt.undolevels = 10000
vim.opt.updatetime = 200 -- Menor updatetime para mejor respuesta
vim.opt.virtualedit = "block" -- Permitir cursor más allá del final de línea en modo visual block
vim.opt.winminwidth = 5 -- Ancho mínimo de ventanas
vim.opt.smoothscroll = true -- Scroll suave

-- File types
vim.filetype.add({
  extension = {
    mdx = "mdx",
  },
})

vim.g.lazyvim_prettier_needs_config = true
vim.g.lazyvim_picker = "telescope"
vim.g.lazyvim_cmp = "blink.cmp"
vim.g.autoformat = false
