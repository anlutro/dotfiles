" indentation settings - http://stackoverflow.com/a/1878983/2490608
" to use tabs:
set tabstop=4 softtabstop=0 shiftwidth=4 noexpandtab
" to use spaces:
"set tabstop=4 softtabstop=0 shiftwidth=4 expandtab smarttab

" allow cursor to go to the end of the line when not in insert mode
set virtualedit=onemore

" allow configs based on filetype I guess?
filetype on

" always show the ruler (current line number/column)
set ruler

" show a 1-line status bar (2 is default in neovim)
set laststatus=1

" disable all mouse interaction
set mouse=

" enable line wrapping, don't split words when wrapping
set wrap
set linebreak

" show line numbers
set number

" show whitespace characters
set list
set listchars=tab:→\ 

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
