" allow configs based on filetype I guess?
filetype on
filetype plugin indent on

"" INDENTATION
" to use tabs:
set tabstop=4 softtabstop=0 shiftwidth=4 noexpandtab
" to use spaces:
"set tabstop=4 softtabstop=0 shiftwidth=4 expandtab smarttab

" override for certain file types
autocmd FileType yaml setlocal shiftwidth=2 tabstop=2 expandtab

" enable auto and smartindent
set autoindent
set smartindent

"" APPEARANCE AND BEHAVIOUR
" allow cursor to go to the end of the line when not in insert mode
set virtualedit=onemore

" disable all mouse interaction
set mouse=

" show line numbers
set number

" always show the ruler (current line number/column)
set ruler

" show a 1-line status bar (2 is default in neovim)
set laststatus=1

" enable line wrapping, don't split words when wrapping
set wrap
set linebreak

" show whitespace characters
set list
set listchars=tab:→\ 

"" SYNTAX HIGHLIGHTING
" enable syntax highlighting
syntax on

" which color scheme to use
set background=dark
color jellybeans
" color scheme overrides
highlight Normal ctermbg=none
highlight LineNr ctermfg=240 ctermbg=none
highlight NonText ctermfg=238 ctermbg=none
highlight SpecialKey ctermfg=238 ctermbg=none
