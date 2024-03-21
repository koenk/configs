set nocompatible " With vi
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'
Plugin 'dense-analysis/ale'
Plugin 'mileszs/ack.vim'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-fugitive'
Plugin 'vim-scripts/gitignore'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'rust-lang/rust.vim'
Plugin 'szw/vim-tags'
Plugin 'shougo/neocomplete.vim'
Plugin 'godlygeek/tabular'
Plugin 'haya14busa/vim-asterisk'
Plugin 'Vimjas/vim-python-pep8-indent'
call vundle#end()

" Disable powerline (if present) and set up airline
let g:powerline_loaded = 1
"let g:airline_powerline_fonts = 1
let g:airline_theme='powerlineish'

filetype plugin indent on
set autochdir " Change into file's dir.
autocmd VimEnter * set autochdir
set fileformats=unix,dos,mac " Support all, prefer unix
set encoding=utf-8 " Use UTF-8 as standard encoding
set hidden " Support hidden buffers (backgrounded buffers with unsaved changes)
let mapleader="," " Change leader to , instead of \

set ofu=syntaxcomplete#Complete " Omnicomplete
let g:SuperTabDefaultCompletionType = "context" " Supertab

" Tune python syntax checker:
"  E221 Multiple spaces before operator
"  E701 Multiple statements on one line (colon)
"  E704 Multiple statements on one line (def)
"  W503 Line break occurred before a binary operator
"  E265 Block comment should start with '# '
"  E266 Too many leading '#' for block comment
"  F541 f-string without any placeholders
let g:ale_python_flake8_options = '--ignore=E221,E701,E704,W503,E265,E266,F541 --max-line-length=120'

let g:ale_linters = {
      \   'python': ['flake8'],
      \   'scala': ['sbtserver'],
      \}

" Improve speed of CtrlP by using external ag tool.
let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

" Better Ctrl-P bindings: ctrl-p for mixed (files, buffers, mru)
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlPMixed'
" And ctrl-o to use file-only mode
nmap <C-o> :CtrlP<CR>

let g:acp_enableAtStartup = 0
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
    return pumvisible() ? neocomplete#close_popup() : "\<CR>"
endfunction
inoremap <expr><TAB> pumvisible() ? "\<CR>" : "\<TAB>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
let g:neocomplete#enable_auto_select = 1


set nobackup
set nowritebackup
set noswapfile
set undofile
set undodir=~/.vim/undodir
set tags=./.tags

set textwidth=80 " 80 chars per line
if exists('+colorcolumn')
    set colorcolumn=+1 " 80 char mark
endif
set linebreak " Break lines after 80 chars at logical points
set wrap " And otherwise always
set number " Line numbers
set numberwidth=5 " 99999 lines max
set showmatch " Matching braces
set cursorline " Highlight current line
set laststatus=2 " Always show status line
set wildmenu " Better tab-complete when selecting files
set wildmode=list:longest,full " Complete to common string, 2nd tab scrolls
set wildignore=*.pdf,*.pyc,*.o,*.so,*.a,*.jpg,*.png,main,*~,*.d
set scrolloff=5 " Always keep current line five lines off the screen edge

" No sound/bells
set noerrorbells
set novisualbell " Don't flash screen
set belloff=all
set t_vb=
set tm=500

" Searching
set incsearch " Incremental search
set ignorecase " Case insensitive
set smartcase " unless you explicitly type capitals
set hlsearch " Highlight search results
set wrapscan " Wrap around

" Indentation (4 spaces)
set smarttab " Align Tab and Backspace with tabs
set expandtab " Insert spaces
set autoindent " Copy indentation of line above when going to a new line
set tabstop=4
set softtabstop=4
set shiftwidth=4
set shiftround " When (un)indenting lines, round these to tab positions
set backspace=eol,start,indent

" Syntax highlighting
set t_Co=256 " 256 color term
set background=dark
syntax on
color wombat256mod
"hi ColorColumn              ctermbg=lightgrey guibg=lightgrey
hi ColorColumn              ctermbg=239 guibg=lightgrey
"hi Pmenu       ctermfg=252  ctermbg=240
"hi PmenuSel    ctermfg=254  ctermbg=243
set t_ut= " Fixes background color issue in for instance tmux

" Also map : to ; for no-shift
nnoremap ; :

" Escape from insert mode with jj
inoremap jj <Esc>

" Y like C,D etc
nmap Y y$

" Clears search highlighting
nnoremap <space> :noh<CR>

" Faster saving
nnoremap <leader>w :w<CR>

" Select pasted text
nnoremap <leader>v V`]

" Toggle line numbers
nmap <leader>l :setlocal number!<CR>

" Toggle paste mode
nmap <leader>p :set paste!<CR>

" Spellcheck shortcuts
map <leader>ss :setlocal spell!<CR>
map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg
map <leader>s? z=


" Easier buffer navigation
nmap <C-j> :bn<CR>
nmap <C-k> :bp<CR>
nmap <C-e> :b#<CR>

" Move by screen lines instead of file lines up and down.
nnoremap j gj
nnoremap k gk

" Move a line of text using alt+[jk]
nmap <M-j> mz:m+<cr>`z
nmap <M-k> mz:m-2<cr>`z
vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

" Shortcut for wrapping selected text and paragraph into text width.
vmap Q gq
nmap Q gqap

map *   <Plug>(asterisk-*)
map #   <Plug>(asterisk-#)
map g*  <Plug>(asterisk-g*)
map g#  <Plug>(asterisk-g#)
map z*  <Plug>(asterisk-z*)
map gz* <Plug>(asterisk-gz*)
map z#  <Plug>(asterisk-z#)
map gz# <Plug>(asterisk-gz#)

" Make this (it deletes all chars on line in insert mode) undo-able better.
inoremap <C-U> <C-G>u<C-U>

fun! StripTrailingWhitespace()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

" Remove trailing whitespace
au BufWrite * :call StripTrailingWhitespace()

" Restore last cursor position
if has("autocmd")
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif

" When joining lines, remove leading comment markers
set formatoptions+=j

" When automatically breaking lines (because of textwidth), don't leave
" a one-letter word on the line.
set formatoptions+=1

" Show tabs, trailing whitespace, non-breakable spaces
set list listchars=tab:→\ ,nbsp:␣,trail:•,extends:⟩,precedes:⟨

command! W w
command! Q q
command! WQ wq
command! Wq wq
command! Qa qa
command! QA qa

" Auto reload vimrc after editing
autocmd! bufwritepost ~/.vimrc source ~/.vimrc

" Auto enable spellchecking for text-based files
autocmd FileType tex,markdown setlocal spell


augroup filetype
    au! BufRead,BufNewFile *.ll     set filetype=llvm
    au! BufRead,BufNewFile *.inc    set filetype=sh
augroup END

" Use ag (silversearcher) instead of ack because of speed
if executable('ag')
    let g:ackprg = 'ag --vimgrep'
endif
let g:ack_autoclose = 1 " Close quickfix window when pressing enter
cnoreabbrev ag Ack!


"set nocscoperelative " Use paths relative from the cscope.out file
set cscopetag " Use cscope and ctag for Ctrl-]

function! LoadCscope()
  let db = findfile("cscope.out", ".;")
  if (!empty(db))
    let path = strpart(db, 0, match(db, "/cscope.out$"))
    if (empty(path))
        let path = "."
    endif
    let path = fnamemodify(path, ':p')
    set nocscopeverbose " suppress 'duplicate connection' error
    exe "cs add " . db . " " . path
    set cscopeverbose
  " else add the database pointed to by environment variable
  elseif $CSCOPE_DB != ""
    cs add $CSCOPE_DB
  endif
endfunction
au BufEnter /* call LoadCscope()

" Language specific settings
au FileType python setlocal textwidth=120
au FileType c,cpp setlocal cindent cinoptions=:0,l1,g0,(0
