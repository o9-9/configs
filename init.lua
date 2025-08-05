local vim = vim
local g = vim.g
local keymap  = vim.keymap
local opt = vim.opt

local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
      fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
      vim.cmd [[packadd packer.nvim]]
      return true
    end
    return false
  end
  
  local packer_bootstrap = ensure_packer()

local plugins = require('packer').startup({function(use, use_rocks)
    use 'wbthomason/packer.nvim'
    use 'morhetz/gruvbox'
    use "nvim-lua/plenary.nvim"
    use {'nvim-telescope/telescope.nvim', tag = '0.1.0', requires = {{'nvim-lua/plenary.nvim'}}}
    -- use {'nvim-telescope/telescope-fzf-native.nvim', run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }
    --use 'nvim-tree/nvim-web-devicons'
    -- use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use {'neoclide/coc.nvim', branch = 'release'}
    use {'ggandor/leap.nvim'}
    
    if packer_bootstrap then 
      require("packer").sync()
    end
end, config = {
  log = {
    level = "warn"
  }
}})

local leap = require("leap")
local telescope_builtin = require("telescope.builtin")
-- local dap = require("dap")

-- set up swap directory
SWAP_DIR = "/tmp/.vim/swp"
os.execute("mkdir -p " .. SWAP_DIR)
opt.directory = SWAP_DIR .. "/" -- trailing / means use absolute path for swap files to prevent collision

-- set up undo directory
UNDO_DIR = "/tmp/.vim/undo"
os.execute("mkdir -p "..UNDO_DIR)
opt.undodir = UNDO_DIR .. "/"

-- create a convenience noremap function by mode
local function make_noremap(mode)
    return function (lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { noremap = true, desc = desc })
    end
end

-- create a convenience map function by mode
local function make_map(mode)
    return function (lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { noremap = false, desc = desc })
    end
end

-- global options
g.mapleader = " "
g.maplocalleader = " "

-- buffer local options
opt.autoread = true
opt.backup = false
opt.cursorline = true
opt.encoding = "utf-8"
opt.expandtab = true
opt.number = true
opt.scrolloff = 3
opt.shiftwidth = 4
opt.signcolumn = "yes"
opt.spell = false
opt.statusline = "%F%m%r%h%w%=(%{&ff}/%Y) (line %l/%L, col %c)"
opt.tabstop = 4
opt.timeoutlen = 300
opt.updatetime = 300
opt.wildmenu = true
opt.writebackup = false

vim.cmd.filetype("plugin", "indent", "on") 
vim.cmd.colorscheme("gruvbox")

-- todo: right toggle spellcheck

-- convenience noremap functions
local inoremap = make_noremap('i')
local nnoremap = make_noremap('n')
local vnoremap = make_noremap('v')
local xnoremap = make_noremap('x')

-- convenience map functions
local imap = make_map('i')
local nmap = make_map('n')
local vmap = make_map('v')
local xmap = make_map('x')

-- insert mappings
inoremap("<f1>", "<esc>:x<cr>", "save and exit")
inoremap("kj", "<esc>", "insert to normal mode from home row")

-- normal mappings
nnoremap("<f1>", ":x<cr>", "save and exit")
nnoremap("<leader>j", "<c-d>", "page down")
nnoremap("<leader>u", "<c-b>", "page up")
nnoremap("H", "^", "go to start of line")
nnoremap("L", "$", "go to end of line")
nnoremap("<leader>w", "<c-w>", "window navigation")
nnoremap("<leader>h", ":noh<cr>", "clear highlights")
nnoremap("<leader>y", '"+y', "copy moved over text to clipboard")

-- visual mappings
vnoremap("H", "^", "go to start of line")
vnoremap("L", "$", "go to end of line")
vnoremap("<leader>(", "\"tdi()<esc>\"tP2l", "surround with ()")
vnoremap("<leader>[", "\"tdi[]<esc>\"tP2l", "surround with []")
vnoremap("<leader>{", "\"tdi{}<esc>\"tP2l", "surround with {}")
vnoremap("<leader>\"", "\"tdi\"\"<esc>\"tP2l", "surround with \"\"")
vnoremap("<leader>'", "\"tdi''<esc>\"tP2l", "surround with ''")
vnoremap("<leader>`", "\"tdi``<esc>\"tP2l", "surround with ``")
vnoremap("<leader>y", '"+y', "copy visual selection to clipboard")


-- visual line mappings
xnoremap("<leader>s", ":sort<cr>", "sort lines ascending")
xnoremap("<leader>y", '"+y', "copy visual line selection to clipboard")

-- telescope mappings
nnoremap("<leader>ff", telescope_builtin.find_files, "fuzzy find files by name")
nnoremap("<leader>fg", telescope_builtin.live_grep, "fuzzy find lines of code")
nnoremap("<leader>fb", telescope_builtin.buffers, "fuzzy find buffers by name")

-- override formatoptions
vim.api.nvim_create_augroup("override_formatoptions", { clear = true })
vim.api.nvim_create_autocmd({ "VimEnter" }, {
    group = "override_formatoptions",
    pattern = { "*" },
    callback = function() opt.formatoptions:remove({ "c", "r", "o" }) end
})

-- show regular line numbers when insert mode and show relative line numbers when no in insert mode
vim.api.nvim_create_augroup("line_number_toggle", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
    group = "line_number_toggle",
    pattern = { "*" },
    command = "if &nu && mode() != 'i' | set rnu | endif"
})
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
    group = "line_number_toggle",
    pattern = { "*" },
    command = "if &nu | set nornu | endif"
})

-- lua configuraiton
vim.api.nvim_create_augroup("filetype_lua", { clear = true })
vim.api.nvim_create_autocmd({ "FileType" }, {
    group = "filetype_lua",
    pattern = "lua",
    callback = function() nnoremap("<leader>kc", ":s/^/#/<cr>:noh<cr>", "comment out line") end
})

-- use leap.nvim maps for sSxX
leap.add_default_mappings()