set nocompatible " stop resetting everything

colorscheme molokai
" filetype indent plugin on " stop auto-indenting

" vim --version | grep -oP "[-+]clipboard"
" Note that copied lines will include whitespace.
" Solution is to use http://vim.wikia.com/wiki/Accessing_the_system_clipboard
" However, vim needs to be compiled with this support
" local vim is not compiled with this, so disabled for now
"if version >= 703
"  set colorcolumn=81
"endif
set number
set ruler
set hlsearch
syntax on
hi LineNr ctermfg=244 ctermbg=234
hi ColorColumn ctermbg=1
let g:NERDTreeDirArrows=0
set shortmess+=I
set synmaxcol=0
set wildmenu
set ttyfast

" This will copy a ton of whitespace at the end of the line
"set cursorline

set laststatus=2
set incsearch

" Note that highlighted whitespace will be copied. This is fine since it's
" actually in the file.
hi ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$\| \+\ze\t/

" Don't expand tabs
set noexpandtab   " this is broken
" set nopreserveindent " if enabled, vim changes spaces -> tabs when possible
set nocindent     " also broken
set indentexpr=   " go away
set indentkeys=   " lovely how `set paste` doesn't document this one
set shiftwidth=4  " okay
set softtabstop=0 " no
set noautoindent  " just no
set nosmartindent " really not interested in your shit, vim
set norevins      " 'reverse insert' is dumb too
set tabstop=4     " this is probably what you're looking for !

" Don't wrap long lines at all tyvm
set textwidth=0
set wrapmargin=0
set formatoptions-=t
set nolinebreak

" KeithB: disable comment continuation
" http://vim.wikia.com/wiki/Disable_automatic_comment_insertion
set comments=""
set commentstring=""
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

set scrolloff=5

" KeithB: disable modeline
" https://github.com/numirias/security/blob/master/doc/2019-06-04_ace-vim-neovim.md
set nomodeline

