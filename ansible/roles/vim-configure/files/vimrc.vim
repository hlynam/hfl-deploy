" Use UTF-8 for reading files and writing new files
set encoding=utf-8
set fileencodings=utf-8

" Set the default clipboard to 'unnamedplus' so that copy (yy) paste (p)
" work from vim to other applications, including the host OS (i.e. the Mac).
set clipboard=unnamedplus

" Stop vim from interpreting modelines in stdin (or normal text files)
" http://stackoverflow.com/questions/8583028/vim-e518-unknown-option
set nomodeline

" turn on syntax highlighting
syntax on

" auto-indent tabs
set smartindent

" highlight matches from a search
set hlsearch

" show matches incrementally as search string is entered in ex
set incsearch

" show line numbers
set number

" set case insensitive searching
set ignorecase

" Stop vim from continuing comments when a newline is entered
" https://vi.stackexchange.com/questions/1983/how-can-i-get-vim-to-stop-putting-comments-in-front-of-new-lines
autocmd FileType * set fo-=c fo-=r fo-=o

