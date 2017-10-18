" Use UTF-8
set encoding=utf-8
set fileencodings=utf-8

" Set default clipboard to 'unnamedplus'
set clipboard=unnamedplus

" Turn on syntax highlighting
syntax on

" Stop vim from continuing comments when a newline is entered
" https://vi.stackexchange.com/questions/1983/how-can-i-get-vim-to-stop-putting-comments-in-front-of-new-lines
augroup augroup_comments
	autocmd!

	autocmd FileType * set fo-=c fo-=r fo-=o
augroup END

" Auto-indent tabs
set smartindent

" Don't interpret modelines in stdin
set nomodeline

" Show incremental matches as search string is entered (e.g. /xyz)
set incsearch

" When searching, highlight matches
set hlsearch

" Case insensitive searching
set ignorecase

" Enable line numbers
set number

" Display ruler with column and row position
set ruler

" Show filename on statusline
set laststatus=2

" Set tabs to 2 columns
set tabstop=2 softtabstop=2 shiftwidth=2 noexpandtab

" When vim calls system() it places temp files in /tmp
" But cron.daily/tmpwatch may delete this directory which causes problems
" Instead place temp files in home directory
let $TMPDIR = $HOME . '/.vim/tmpdir'
if !isdirectory($TMPDIR)
    call mkdir($TMPDIR, "p")
endif

" Under tmux dynamically set the tmux window name
" based on the files open in vim
" Check that we are running under tmux ($TERM begins with 'screen')
if &term =~# "^screen"
	function! TmuxSetWindowName()
		" Identify only the buffers created by the user
		let bufferList = map(filter(range(0, bufnr('$')), '(bufname(v:val) != "") && bufwinnr(v:val)>=0 && bufloaded(v:val) && bufexists(v:val)'), 'bufname(v:val)')

		if len(bufferList) > 0
			call system("~/src/tools/tmux/tmux-set-window-name.pl", join(bufferList, "\n"))
		else
			call TmuxResetWindowName()
		endif
	endfunction

	function! TmuxResetWindowName()
		call system("~/src/tools/tmux/tmux-set-window-name.pl")
	endfunction

	augroup augroup_tmux
		autocmd!

		" Handle netrw
		autocmd FileType netrw call TmuxSetWindowName()

		" Handle normal buffers
		autocmd FileReadPost,BufReadPost,BufNewFile,BufEnter * call TmuxSetWindowName()

		" Clear tmux window name on exit
		autocmd VimLeave * call TmuxResetWindowName()
	augroup END
endif

