-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

vim.api.nvim_exec(
[[
augroup Packer
autocmd!
autocmd BufWritePost init.lua PackerCompile
augroup end
]],
false
)

local use = require('packer').use
require('packer').startup(function()
  use 'wbthomason/packer.nvim' -- Package manager
  use 'pineapplegiant/spaceduck' -- Color scheme 
  use 'itchyny/lightline.vim' -- Fancier statusline
  use {'kristijanhusak/orgmode.nvim', config = function()
    -- require('orgmode').setup{}
    require('orgmode').setup_ts_grammar()
  end 
  }
  use 'folke/tokyonight.nvim'
  use {'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  use { 'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/nvim-compe' -- Autocompletion plugin
  use 'L3MON4D3/LuaSnip' -- Snippets plugin
  use 'junegunn/goyo.vim'
  use 'godlygeek/tabular'
  use {'shaunsingh/oxocarbon.nvim', run = './install.sh'}
  use 'plasticboy/vim-markdown'
  use 'Yazeed1s/oh-lucy.nvim'
  use {
  "folke/trouble.nvim",
  requires = "kyazdani42/nvim-web-devicons",
  config = function()
    require("trouble").setup {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  end
}
  use {'nyoom-engineering/oxocarbon.nvim'}
  use {
    'romgrk/barbar.nvim',
    requires = {'kyazdani42/nvim-web-devicons'}
  }
  end
)

require('lsp_config')

--Make line numbers default
vim.wo.number = true

--Set colorscheme (order is important here)
vim.o.termguicolors = true
vim.g.onedark_terminal_italics = 2
-- vim.cmd.colorscheme "tokyonight"
-- vim.cmd.colorscheme 'oh-lucy-evening'
vim.cmd.colorscheme "oxocarbon"
vim.g.tokyonight_style = "night"
vim.o.ruler = false
vim.o.laststatus = 0
vim.o.mouse = 'a'

-- Spaces instead of tabs
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2

--Set statusbar
vim.g.lightline = {
  colorscheme = 'tokyonight',
  active = { left = { { 'mode', 'paste' }, { 'gitbranch', 'readonly', 'filename', 'modified' } } },
  component_function = { gitbranch = 'fugitive#head' },
}

vim.api.nvim_set_keymap('', '<Space>', '<Nop>', { noremap = true, silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('telescope')
-- Tabs
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Move to previous/next
map('n', '<A-,>', ':BufferPrevious<CR>', opts)
map('n', '<A-.>', ':BufferNext<CR>', opts)
-- Re-order to previous/next
map('n', '<A-<>', ':BufferMovePrevious<CR>', opts)
map('n', '<A->>', ' :BufferMoveNext<CR>', opts)
-- Goto buffer in position...
map('n', '<leader>1', ':BufferGoto 1<CR>', opts)
map('n', '<leader>2', ':BufferGoto 2<CR>', opts)
map('n', '<A-3>', ':BufferGoto 3<CR>', opts)
map('n', '<A-4>', ':BufferGoto 4<CR>', opts)
map('n', '<A-5>', ':BufferGoto 5<CR>', opts)
map('n', '<A-6>', ':BufferGoto 6<CR>', opts)
map('n', '<A-7>', ':BufferGoto 7<CR>', opts)
map('n', '<A-8>', ':BufferGoto 8<CR>', opts)
map('n', '<A-9>', ':BufferGoto 9<CR>', opts)
map('n', '<A-0>', ':BufferLast<CR>', opts)

require('barbar')
require('treesiter')
-- Tab
-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- Compe setup
require('compe').setup {
  source = {
    path = true,
    nvim_lsp = true,
    luasnip = true,
    buffer = false,
    calc = false,
    nvim_lua = false,
    vsnip = false,
    ultisnips = false,
  },
}

vim.diagnostic.config({underline = false})
vim.diagnostic.config({virtual_text = false})
vim.diagnostic.config({
  float = {
    source = 'always',
    border = border
  },
})
vim.api.nvim_set_keymap('n', '<leader>dd', [[<cmd>lua vim.diagnostic.open_float()<CR>]], { noremap = true, silent = true })
--
-- Utility functions for compe and luasnip
local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
  local col = vim.fn.col '.' - 1
  if col == 0 or vim.fn.getline('.'):sub(col, col):match '%s' then
    return true
  else
    return false
  end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
local luasnip = require 'luasnip'

_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t '<C-n>'
  elseif luasnip.expand_or_jumpable() then
    return t '<Plug>luasnip-expand-or-jump'
  elseif check_back_space() then
    return t '<Tab>'
  else
    return vim.fn['compe#complete']()
  end
end

_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t '<C-p>'
  elseif luasnip.jumpable(-1) then
    return t '<Plug>luasnip-jump-prev'
  else
    return t '<S-Tab>'
  end
end

-- Map tab to the above tab complete functiones
vim.api.nvim_set_keymap('i', '<Tab>', 'v:lua.tab_complete()', { expr = true })
vim.api.nvim_set_keymap('s', '<Tab>', 'v:lua.tab_complete()', { expr = true })
vim.api.nvim_set_keymap('i', '<S-Tab>', 'v:lua.s_tab_complete()', { expr = true })
vim.api.nvim_set_keymap('s', '<S-Tab>', 'v:lua.s_tab_complete()', { expr = true })

-- Map compe confirm and complete functions
vim.api.nvim_set_keymap('i', '<cr>', 'compe#confirm("<cr>")', { expr = true })
vim.api.nvim_set_keymap('i', '<c-space>', 'compe#complete()', { expr = true })
