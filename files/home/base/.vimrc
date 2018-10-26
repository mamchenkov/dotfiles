"  This is my Vim.
"  There are many like this,
"  But this one is mine.
"  Without me, my Vim is useless.
"  Without Vim, I am useless.

" Vundle plugin manager requirements
set nocompatible
filetype off
" git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
set rtp+=~/.vim/bundle/Vundle.vim
" Run :PluginInstall to install everything
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

" Libraries and utils used by other plugins
Plugin 'tomtom/tlib_vim'
Plugin 'mattn/webapi-vim'
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'xolox/vim-misc'

" Beautifiers
Plugin 'flazz/vim-colorschemes'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'vim-scripts/CSApprox'
Plugin 'ryanoasis/vim-devicons'
Plugin 'mhinz/vim-startify'

" General utilities
Plugin 'yssl/QFEnter'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'ervandew/supertab'
Plugin 'mhinz/vim-grepper'
Plugin 'tyru/open-browser.vim'
Plugin 'tpope/vim-speeddating'
Plugin 'tpope/vim-eunuch'

" General programming
Plugin 'scrooloose/nerdcommenter'
Plugin 'scrooloose/nerdtree'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'majutsushi/tagbar'
Plugin 'sheerun/vim-polyglot'
Plugin 'tmhedberg/matchit'
Plugin 'KabbAmine/zeavim.vim'
Plugin 'tyru/open-browser-github.vim' " requires tyru/open-browser.vim
Plugin 'tyru/open-browser-unicode.vim' " requires tyru/open-browser.vim
Plugin 'ludovicchabant/vim-gutentags'
Plugin 'w0rp/ale'

" Git
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-fugitive'
Plugin 'mattn/gist-vim' " requieres: mattn/webapi-vim
Plugin 'Xuyuanp/nerdtree-git-plugin' " requires: scrooloose/nerdtree

" HTML/XML
Plugin 'docunext/closetag.vim'

" JavaScript
Plugin 'vim-scripts/jQuery'

" PHP
Plugin 'vim-php/tagbar-phpctags.vim'
Plugin 'shawncplus/phpcomplete.vim'

" WordPress
" Plugin 'dsawardekar/wordpress.vim'

" Databases
Plugin 'tpope/vim-dadbod'

call vundle#end()
" To ignore plugin indent changes use 'filetype plugin on' instead
filetype plugin indent on

" Change mapleader to ,
let mapleader = ","
" Search down into subfolders
set path+=**

" Update gitgutter, matchit, polyglot, etc every 250ms instead of default 4s
set updatetime=250

"
" Vim UI
"
set bg=dark					" use colors for the dark background
syntax on					" switch on syntax highlighting
syntax enable
set t_Co=256				" Must be BEFORE the colorscheme
" hi Normal           ctermfg=253             ctermbg=none cterm=none " Set transparent background
" Use colorscheme if installed
if filereadable(expand("~/.vim/bundle/vim-colorschemes/colors/lucius.vim"))
	let g:lucius_no_term_bg=1   " Transparent background
	colorscheme lucius
endif

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
set wrapmargin=1				" margin from the right to show wrapping

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
	let g:airline#extensions#tabline#enabled = 1
	let g:airline#extensions#ale#enabled = 1
	let g:airline#extensions#branch#enabled = 1
	let g:airline#extensions#tagbar#enabled = 1
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

" Gutentags
if filereadable(expand("~/.vim/bundle/vim-gutentags/plugin/gutentags.vim"))
	" Where to store tag files
	let g:gutentags_cache_dir = '~/.vim/gutentags'
	let g:gutentags_ctags_exclude = ['*.css', '*.html', '*.js', '*.json', '*.xml',
		\ '*.phar', '*.ini', '*.rst', '*.md',
		\ '*vendor/*/test*', '*vendor/*/Test*',
		\ '*vendor/*/fixture*', '*vendor/*/Fixture*',
		\ '*var/cache*', '*var/log*']
	map <silent> <leader>jd :CtrlPTag<cr><C-\>w
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

" QFEnter
if filereadable(expand("~/.vim/bundle/QFEnter/plugin/QFEnter.vim"))
	let g:qfenter_keymap = {}
	let g:qfenter_keymap.vopen = ['<C-v>']
	let g:qfenter_keymap.hopen = ['<C-CR>', '<C-s>', '<C-x>']
	let g:qfenter_keymap.topen = ['<C-t>']
endif

" Polyglot
if filereadable(expand("~/.vim/bundle/vim-polyglot/ftdetect/polyglot.vim"))
	" JavaScript and HTML indentation plugin settings
	let html_indent_inctags = "html,body,head,tbody"
	let html_indent_script1 = "inc"
	let html_indent_style1 = "inc"

	" Syntax highlighting in PHP files
	let php_sql_query=0
	let php_parent_error_close=1
	let php_parent_error_open=1
	let php_htmlInStrings=0
	let php_noShortTags=1
	let php_folding=0
endif

" Supertab
if filereadable(expand("~/.vim/bundle/supertab/plugin/supertab.vim"))
	" Close Scratch buffer when popup closes
	let g:SuperTabClosePreviewOnPopupClose = 1

	" Add omnicomplition to supertab if there is one
	autocmd FileType *
	\ if &omnifunc != '' |
	\   call SuperTabChain(&omnifunc, "<c-n>") |
	\ endif
endif

" Tagbar
if filereadable(expand("~/.vim/bundle/tagbar/plugin/tagbar.vim"))
	" Show tag bar
	let g:tagbar_autofocus = 1
	map <F9> :TagbarToggle<CR>
endif

" Tagbar PHP ctags
if filereadable(expand("~/.vim/bundle/tagbar-phpctags.vim/plugin/tagbar-phpctags.vim"))
	" Use phpctags for tagbar
	let g:tagbar_phpctags_bin="~/bin/phpctags"
endif

" Zeal
if filereadable(expand("~/.vim/bundle/zeavim.vim/plugin/zeavim.vim"))
	" Zeal offline documentation
	let g:zv_file_types = {'php':'cakephp,php'}
	autocmd FileType php setlocal keywordprg=zeal
endif
