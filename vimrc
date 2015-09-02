" indentation settings - http://stackoverflow.com/a/1878983/2490608
" to use tabs:
set tabstop=4 softtabstop=0 shiftwidth=4 noexpandtab
" to use spaces:
"set tabstop=4 softtabstop=0 shiftwidth=4 expandtab smarttab

" allow cursor to go to the end of the line when not in insert mode
set virtualedit=onemore

" allow configs based on filetype I guess?
filetype on

" add a column marker at 70 columns in git commit messages
au FileType gitcommit set colorcolumn=70

" always show line numbers
set number

" always show the ruler (current line number/column)
set ruler

" show a 1-line status bar (2 is default in neovim)
set laststatus=1

" make line numbers yellow (brown is default in neovim)
highlight LineNr ctermfg=11 guifg=Yellow
