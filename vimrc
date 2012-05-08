" Syntax highlighting
set t_Co=256 " 256 color term
set background=dark
syntax on
"color koehler
color molokai
hi ColorColumn ctermbg=lightgrey guibg=lightgrey

" General
set nocompatible " With vi
filetype plugin indent on
set autochdir " Change into file's dir.
set fileformats=unix,dos,mac " Support all, prefer unix
set hidden 

set nobackup
"set backup " Backup files
"set backupdir=~/.vim/backup
"set directory=~/.vim/tmp " Swap files

set textwidth=80 " 80 chars per line
set colorcolumn=+1 " 80 char mark
set linebreak " Break lines after 80 chars at logical points
set wrap " And otherwise always
set number " Line numbers
set numberwidth=5 " 99999 lines max
set showmatch " Matching braces

" No sound/bells
set noerrorbells
set novisualbell " Don't flash screen
set t_vb=
set tm=500

" Searching
set incsearch " Incremental search
set ignorecase
set smartcase
set hlsearch " Highlight search results

" Indentation (4 spaces)
set smarttab
set expandtab
set autoindent
set smartindent
set tabstop=4
set softtabstop=4
set shiftwidth=4

" Move a line of text using alt+[jk]
nmap <M-j> mz:m+<cr>`z
nmap <M-k> mz:m-2<cr>`z
vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

" Delete all trailing whitespaces for Python
func! DeleteTrailingWS()
    exe "normal mz"
    %s/\s\+$//ge
    exe "normal `z"
endfunc
autocmd BufWrite *.py :call DeleteTrailingWS()

" Smart home
map <khome> <home>
nmap <khome> <home>
inoremap <silent> <home> <C-O>:call Home()<CR>
nnoremap <silent> <home> :call Home()<CR>
function! Home()
    let curcol = wincol()
    normal ^
    let newcol = wincol()
    if newcol == curcol
        normal 0
    endif
endfunction

command! W w
command! Q q
command! WQ wq
command! Wq wq

" Auto reload vimrc after editing
autocmd! bufwritepost ~/.vimrc source ~/.vimrc

