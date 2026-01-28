"  This is my Vim.
"  There are many like this,
"  But this one is mine.
"  Without me, my Vim is useless.
"  Without Vim, I am useless.

"
" Fix VIM artifacts (OSC palette queries)
"

" 1) Prevent the runtime plugin from doing anything (even if sourced)
let g:loaded_colorresp = 1

" 2) Nuke the termcap requests so nothing gets sent even if some script tries
if exists('+t_RB') | set t_RB= | endif   " background color request
if exists('+t_RF') | set t_RF= | endif   " foreground color request
" (Optional, if present)
if exists('+t_RS') | set t_RS= | endif   " cursor shape request
if exists('+t_RC') | set t_RC= | endif   " cursor blink request
if exists('+t_RV') | set t_RV= | endif   " version request

" Clear terminal after exit just in case
augroup CleanExit
  autocmd!
  autocmd VimLeave * silent! execute "!tput rmcup || clear"
augroup END

"
" Vundle plugin manager requirements
"
set nocompatible
filetype off
" git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
set rtp+=~/.vim/bundle/Vundle.vim
" Run :PluginInstall to install everything
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

"
" Beautifiers
"
Plugin 'flazz/vim-colorschemes'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
"Plugin 'vim-scripts/CSApprox' " Convert GVim colorschemes for terminal Vim
Plugin 'ryanoasis/vim-devicons'
Plugin 'mhinz/vim-startify'

"
" General utilities
"
Plugin 'kshenoy/vim-signature'
Plugin 'mhinz/vim-grepper'
Plugin 'tpope/vim-speeddating'

"
" General programming
"
Plugin 'scrooloose/nerdcommenter'
Plugin 'scrooloose/nerdtree'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'tmhedberg/matchit'
Plugin 'w0rp/ale'

"
" Git
"
Plugin 'airblade/vim-gitgutter'
Plugin 'Xuyuanp/nerdtree-git-plugin' " requires: scrooloose/nerdtree

"
" HTML/XML
"
Plugin 'docunext/closetag.vim'

"
" Databases
"
"Plugin 'tpope/vim-dadbod'

call vundle#end()
" To ignore plugin indent changes use 'filetype plugin on' instead
filetype plugin indent on

" Change mapleader to ,
let mapleader = ","

" Search down into subfolders
set path+=**

" Update gitgutter, matchit, polyglot, etc every 500ms instead of default 4s
set updatetime=500

" Arrow key fix (https://github.com/spf13/spf13-vim/issues/780)
if &term[:4] == "xterm" || &term[:5] == 'screen' || &term[:3] == 'rxvt'
	inoremap <silent> <C-[>OC <RIGHT>
endif

"
" Vim UI
"
set bg=dark					" use colors for the dark background
syntax on					" switch on syntax highlighting
syntax enable
set t_Co=256				" Must be BEFORE the colorscheme
" Use colorscheme if installed
if filereadable(expand("~/.vim/bundle/vim-colorschemes/colors/gruvbox.vim"))
	let g:gruvbox_termcolors = 256
	colorscheme gruvbox
endif
" Other color schemes to try out
"colorscheme jellybeans

" Set transparent background (Thanks to https://stackoverflow.com/a/63382382/151647)
autocmd vimenter * hi Normal guibg=NONE ctermbg=NONE

"
" Options : basic
"
set autoread		" Reload files changed outside of Vim

" https://vimrcfu.com/snippet/68
set splitright		" Open vertical splits to the right of current window
set splitbelow		" Open horizontal splits below the current window


"
" Options : GUI
"
if has("gui_running")
	" GUI options {{{
	set guifont=SauceCodePro\ Nerd\ Font\ Semi-Bold\ 10
	set guioptions-=m " No menu
	set guioptions-=T " No toolbar
	set guioptions+=c " Use console dialogs where possible
	set guioptions+=lrb " Enable left, right, and bottom scrollbars
	set guioptions-=lrb " Disable left, right, and bottom scrollbars (retarded, but has to be set first)
endif


"
" Options : misc
"

set autowrite					" saves unwritten buffers
set backspace=indent,eol,start 	" backspace over everything in insert mode
set complete-=k					" Do not complete from dictionaries
set encoding=UTF-8				" Set encoding
set formatoptions=croq
set history=50					" keep last 50 commands
set laststatus=2				" always display the status line
set matchtime=5					" Show match for half a second
set mouse=a						" Mouse support
set mousehide 					" Hide mouse cursor while typing
set nowritebackup           	" do not write backup files
set nobackup					" do not create backup files
set noswapfile 					" do not create swap files
set nowrap						" No line wrapping
set number 						" Set line numbering
set numberwidth=4				" Number of columns in line numbering
set ruler						" show cursor position in the file
set showcmd						" show command autocompletion
set showmatch					" Show matching opening bracket
set statusline=%F%m%r%h%w\ [EOL=%{&ff}]\ [TYPE=%Y]\ [ENC=%{(&fenc==\"\"?&enc:&fenc)}]\ %=[POS=%04l,%04v]\ [LEN=%L][%p%%]
set title titlestring=vim\ -\ %F\ %h
set visualbell					" Don't beep me, you beep!
set wildmenu					" show autocompetion in status menu
set wildignore+=*/tmp/*,*.so,*.swp,*.zip
set wrapmargin=1				" margin from the right to show wrapping
set undofile 					" enable undo
set undodir=~/.vim/undodir 		" enable persistent undo

"
" Options : tabulation
"

set autoindent				" automatic indenting of new lines
set shiftwidth=4			" indent level
set smartindent				" get smart indenting for program code-like texts
set tabstop=4				" tabs are 4 characters long
set wildchar=<tab>			" Complete filenames with Tab

"
" Options : searching
"

set ignorecase				" ignore case
set incsearch				" incremental search (search while pattern is typed)
set nohlsearch				" do not highlight search patterns
set smartcase				" case-insensitive searching until pattern is in lower case
set wrapscan				" wrap search around the end of file

"
" Fix GUI artifacts
"
set notermguicolors

"
" Shortcuts
"

" Remap keys for split window ease of use.
nmap <C-j> <C-W>j
nmap <C-k> <C-W>k
nmap <C-h> <C-W>h
nmap <C-l> <C-W>l

" https://vimrcfu.com/snippet/77
" Move visual block
vnoremap <C-Up> :m '<-2<CR>gv=gv
vnoremap <C-Down> :m '>+1<CR>gv=gv

" http://stackoverflow.com/questions/741814/move-entire-line-up-and-down-in-vim
" Move single line
nnoremap <C-Up> :m -2<CR>==
nnoremap <C-Down> :m +1<CR>==
inoremap <C-Up> <ESC>:m -2<CR>==gi
inoremap <C-Down> <ESC>:m +1<CR>==gi

" https://vimrcfu.com/snippet/14
" Don't lose visual selection when shifting, so that >>>>>>>>> works
xnoremap <BS>  <gv
xnoremap <TAB>  >gv

" https://vimrcfu.com/snippet/186
" let terminal resize scale the internal windows
autocmd VimResized * :wincmd =

" Quit without saving. Helps quick file viewing in Midnight Commander
map <F4> :q<CR>

" Toggle left column (numbers, git gutter, etc)
" Useful for selecting with the mouse and for simple files
" Vim 8 supports 'set signcolumn=yes|no', but we are not there yet
function! ToggleLeftColumn()
	if &number == 1
		set nonumber
		if filereadable(expand("~/.vim/bundle/vim-gitgutter/plugin/gitgutter.vim"))
			GitGutterDisable
		endif
		echo "Left column is off"
	else
		set number
		if filereadable(expand("~/.vim/bundle/vim-gitgutter/plugin/gitgutter.vim"))
			GitGutterEnable
		endif
		echo "Left column is on"
	endif
	return
endfunc
nnoremap <F6> :call ToggleLeftColumn()<CR>
vnoremap <F6> :call ToggleLeftColumn()<CR>
inoremap <F6> <ESC>:call ToggleLeftColumn()<CR>i

" Save and exit
map <F10> :wq<CR>

" exit to normal mode with 'jj'
inoremap jj <ESC>

" DiffOrig - see the changes you made in the current file
" More info in ":help DiffOrig" and https://vimrcfu.com/snippet/214
if !exists(":DiffOrig")
	command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis
endif

" See what's changed with <Leader>?
map <Leader>? :DiffOrig<CR>

"
" File Types
"

" Instead of reverting the cursor to the last position in the buffer, we
" set it to the first line when editing a git commit message
au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

" https://vimrcfu.com/snippet/19
" Maps 'K' to open vim help for the word under cursor when editing vim files.
autocmd FileType vim setlocal keywordprg=:help

" Maps 'K' to open PHP function manual for the word under cursor when editing
" PHP files.
autocmd FileType php setlocal keywordprg=phpdoc

"
" Plugin configurations
"

" Airline
if filereadable(expand("~/.vim/bundle/vim-airline/plugin/airline.vim"))
	let g:airline#extensions#term#enabled = 0
	let g:airline#extensions#tabline#enabled = 1
	let g:airline#extensions#ale#enabled = 1
	let g:airline#extensions#branch#enabled = 1
	let g:airline_skip_empty_sections = 1
	let g:airline_theme='powerlineish'
	"let g:airline_left_sep=''
	"let g:airline_right_sep=''
	let g:airline_symbols = {}
	let g:airline#extensions#tabline#left_sep = ' '
	let g:airline#extensions#tabline#left_alt_sep = '|'
	let g:airline_left_sep          = '▶'
	let g:airline_left_alt_sep      = '»'
	let g:airline_right_sep         = '◀'
	let g:airline_right_alt_sep     = '«'
	let g:airline#extensions#branch#prefix     = '⤴' "➔, ➥, ⎇
	let g:airline#extensions#readonly#symbol   = '⊘'
	let g:airline#extensions#linecolumn#prefix = '¶'
	let g:airline#extensions#paste#symbol      = 'ρ'
	let g:airline_symbols.linenr    = '␊'
	let g:airline_symbols.branch    = '⎇'
	let g:airline_symbols.paste     = 'ρ'
	let g:airline_symbols.paste     = 'Þ'
	let g:airline_symbols.paste     = '∥'
	let g:airline_symbols.whitespace = 'Ξ'

	"let g:airline_solarized_reduced = 0
	" Only show the column number.
	"let g:airline_section_z = 'c:%c'
	" Use short forms for common modes.
	"let g:airline_mode_map = {
	"    \ 'n'  : 'N',
	"    \ 'i'  : 'I',
	"    \ 'R'  : 'R',
	"    \ 'v'  : 'V',
	"    \ 's'  : 'S',
	"    \ 't'  : 'T',
	"    \ }
endif

" ALE
if filereadable(expand("~/.vim/bundle/ale/plugin/ale.vim"))
	let g:ale_linters = {
		\   'php': ['php'],
		\}
	let g:ale_lint_on_save = 1
	let g:ale_lint_on_text_changed = 0
endif

" EditorConfig
if filereadable(expand("~/.vim/bundle/editorconfig-vim/plugin/editorconfig.vim"))
	" EditorConfig exclude patterns
	let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']
endif

" GitGutter
if filereadable(expand("~/.vim/bundle/vim-gitgutter/plugin/gitgutter.vim"))
	" Don't show gitgutter signs in files with more than 500 changes
	let g:gitgutter_max_signs = 500
endif

" Grepper
if filereadable(expand("~/.vim/bundle/vim-grepper/plugin/grepper.vim"))
	nnoremap <leader>g :Grepper -cword -noprompt<cr>
endif

" NERDComment
if filereadable(expand("~/.vim/bundle/nerdcommenter/plugin/NERD_commenter.vim"))
	let NERDCommentEmptyLines = 1
	let NERDDefaultAlign = 'left'
	let NERDCommentWholeLinesInVMode = 1
	map <Leader>c <plug>NERDCommenterToggle<CR>
	imap <Leader>c <Esc><plug>NERDCommenterToggle<CR>i
endif

" NERDTree
if filereadable(expand("~/.vim/bundle/nerdtree/plugin/NERD_tree.vim"))
	" Open NERDTree if no files were specified for vim startup
	" autocmd vimenter * if !argc() | NERDTree | endif

	" Toggle the file browser
	" Thanks to: https://stackoverflow.com/a/31631030/151647
	function! ToggleNERDTreeFind()
		if g:NERDTree.IsOpen()
			execute ':NERDTreeClose'
		else
			execute ':NERDTreeFind'
		endif
	endfunction
	"map <F3> :NERDTreeFind<CR>
	nnoremap <F3> :call ToggleNERDTreeFind()<CR>
endif
