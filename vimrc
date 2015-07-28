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
