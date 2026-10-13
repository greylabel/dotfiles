set nocompatible
syntax enable

set number
set relativenumber
set cursorline
set scrolloff=8
set sidescrolloff=8
set wrap
set splitright
set splitbelow
set showcmd
set showmode
set showmatch
set autoindent
set smartindent
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set ignorecase
set smartcase
set clipboard=unnamedplus
set termguicolors
set noerrorbells
set visualbell
set hidden
set backupcopy=yes
set updatetime=250
set timeoutlen=300
set mouse=a
set signcolumn=yes
set backupdir^=~/tmp
set directory^=~/tmp

filetype on
filetype indent on
filetype plugin on

let mapleader = " "
let maplocalleader = " "

nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>v :vsplit<CR>
nnoremap <leader>s :split<CR>
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l
nnoremap <leader>e :Explore<CR>
