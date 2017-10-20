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
	function! TmuxUserHasManuallySetWindowName()
		let l:currentWindowName = substitute(system("tmux display-message -p '#W'"), '\n$', '', '')
		"call system('echo Line: ' . shellescape(l:currentWindowName) . ' >> ~/vim-debug.txt')
		if (l:currentWindowName !~# '^vim$') && (l:currentWindowName !~# '^new-window$') && (l:currentWindowName !~# ': vim$')
			" User has manually set tmux window title, so don't change it
			return 1
		endif
		return 0
	endfunction

	function! TmuxSetWindowName()
		" Try and identify only the buffers created by the user
		" https://devhints.io/vimscript-functions
		let l:bufferList = map(filter(range(0, bufnr('$')), 'bufwinnr(v:val)>=0 && bufloaded(v:val) && bufexists(v:val) && bufname(v:val) != ""'), 'substitute(bufname(v:val), ".*/", "", "")')

		" Remove duplicates
		let l:bufferList = filter(l:bufferList, 'count(l:bufferList, v:val) == 1')

		if len(l:bufferList) > 0
			" Sort list so that g:cachedWindowList doesn't change
			" if filename list hasn't changed
			call sort(l:bufferList)

			let l:windowName = join(l:bufferList, "; ") . ': vim'
			" call system('echo List: ' . shellescape(l:windowList) . ' >> ~/vim-debug.txt')

			" Cache window title as 'call system()' can take a long time
			" compared with standard vimscript statements
			if exists("g:cachedWindowList")
				if g:cachedWindowList ==# l:windowName
					" call system('echo Match: ' . shellescape(l:windowName) . ' >> ~/vim-debug.txt')
					return
				endif
			endif
			let g:cachedWindowList = l:windowName

			if TmuxUserHasManuallySetWindowName()
				return
			endif

			call system("tmux rename-window " . shellescape(l:windowName))
		else
			call TmuxResetWindowName()
		endif
	endfunction

	function! TmuxResetWindowName()
		if TmuxUserHasManuallySetWindowName()
			return
		endif

		call system("tmux rename-window vim")
	endfunction

	augroup augroup_tmux
		autocmd!

		" Handle netrw
		autocmd FileType netrw call TmuxSetWindowName()

		" Handle normal buffers
		autocmd FileReadPost,BufReadPost,BufNewFile,BufEnter * call TmuxSetWindowName()
		"autocmd BufEnter * call TmuxSetWindowName()

		" Clear tmux window name on exit
		autocmd VimLeave * call TmuxResetWindowName()
	augroup END
endif

" Copy full path of current filename to clipboard register
" http://stackoverflow.com/questions/2233905/how-can-i-expand-the-full-path-of-the-current-file-to-pass-to-a-command-in-vim
nnoremap <space>y :let @+=expand('%:p')<cr>

" If you delete a lot of lines, this can be quite slow
" d_ does not use the copy buffer and is quicker
nnoremap <space>v :<c-u>v//d_<cr>
nnoremap <space>g :<c-u>g//d_<cr>

" Allow * and # to work in visual mode
" https://github.com/nelstrom/vim-visual-star-search/blob/master/plugin/visual-star-search.vim
function! s:VSetSearch(cmdtype)
  let temp = @s
  norm! gv"sy
  let @/ = '\V' . substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
  let @s = temp
endfunction
xnoremap * :<C-u>call <SID>VSetSearch('/')<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call <SID>VSetSearch('?')<CR>?<C-R>=@/<CR><CR>

