"
" Plugins
"

" Load all bundles via Pathogen vim plugin
call pathogen#infect()
call pathogen#helptags()

" Change mapleader to ,
let mapleader = ","
" Search down into subfolders
set path+=**

" Syntax
"
set bg=dark					" use colors for the dark background
syntax on					" switch on syntax highlighting
syntax enable
set t_Co=256				" Must be BEFORE the colorscheme
let g:lucius_no_term_bg=1   " Transparent background
colorscheme lucius
" hi Normal           ctermfg=253             ctermbg=none cterm=none " Set transparent background

" Airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#syntastic#enabled = 1
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


" Disable folding for Markdown
let g:vim_markdown_folding_disabled = 1

" JavaScript and HTML indentation plugin settings
let html_indent_inctags = "html,body,head,tbody"
let html_indent_script1 = "inc"
let html_indent_style1 = "inc"

" Open NERDTree if no files were specified for vim startup
autocmd vimenter * if !argc() | NERDTree | endif

" Syntastic settings
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

let g:syntastic_error_symbol='✗'
let g:syntastic_warning_symbol='⚠'
let g:syntastic_style_error_symbol = '✗'
let g:syntastic_style_warning_symbol = '⚠'


" Disable PHP coding style check with Syntastic
let g:syntastic_php_checkers=['php']
let g:syntastic_phpcs_disable=1


" Syntax highlighting in PHP files
let php_sql_query=0
let php_parent_error_close=1
let php_parent_error_open=1
let php_htmlInStrings=0
let php_noShortTags=1
let php_folding=0

" EditorConfig exclude patterns
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']

"
" Options : basic
"
filetype plugin on
filetype indent on
set autoread		" Reload files changed outside of Vim
set nocompatible    " Don't pretend to be vi

" https://vimrcfu.com/snippet/68
set splitright		" Open vertical splits to the right of current window
set splitbelow		" Open horizontal splits below the current window


"
" Options : GUI
"
if has("gui_running")
	" GUI options {{{
	set guifont=Fixedsys\ Excelsior\ 3.01\ 12
	set guioptions-=m " No menu
	set guioptions-=T " No toolbar
	set guioptions+=c " Use console dialogs where possible
	set guioptions+=lrb " Enable left, right, and bottom scrollbars
	set guioptions-=lrb " Disable left, right, and bottom scrollbars (retarded, but has to be set first)
endif


"
" Options : misc
"

set autowrite				" saves unwritten buffers
set bs=2					" backspace over everything in insert mode
set complete-=k				" Do not complete from dictionaries
set encoding=utf-8			" Set encoding
set formatoptions=croq
set history=50				" keep last 50 commands
set laststatus=2			" always display the status line
set matchtime=5				" Show match for half a second
set mouse=a					" Mouse support
set nowritebackup           " do not write backup files
set nobackup				" do not create backup files
set noswapfile 				" do not create swap files
set nowrap					" No line wrapping
set number 					" Set line numbering
set numberwidth=4			" Number of columns in line numbering
set ruler					" show cursor position in the file
set showcmd					" show command autocompletion
set showmatch				" Show matching opening bracket
set statusline=%F%m%r%h%w\ [EOL=%{&ff}]\ [TYPE=%Y]\ [ENC=%{(&fenc==\"\"?&enc:&fenc)}]\ %=[POS=%04l,%04v]\ [LEN=%L][%p%%]
set title titlestring=vim\ -\ %F\ %h
set visualbell				" Don't beep me, you beep!
set wildmenu				" show autocompetion in status menu
set wrapmargin=1			" margin from the right to show wrapping

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

" Update gitgutter signs and such every 250ms instead of default 4s
set updatetime=250
" Don't show gitgutter signs in files with more than 500 changes
let g:gitgutter_max_signs = 500

" https://vimrcfu.com/snippet/19
" Maps 'K' to open vim help for the word under cursor when editing vim files.
autocmd FileType vim setlocal keywordprg=:help

" Maps 'K' to open PHP function manual for the word under cursor when editing
" PHP files.
autocmd FileType php setlocal keywordprg=phpdoc

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

" NERDComment plugin
let NERDCommentEmptyLines = 1
let NERDDefaultAlign = 'left'
let NERDCommentWholeLinesInVMode = 1
map <Leader>c <plug>NERDCommenterToggle<CR>
imap <Leader>c <Esc><plug>NERDCommenterToggle<CR>i

" Toggle the file browser
" Thanks to: https://stackoverflow.com/a/31631030/151647
function! ToggleNERDTreeFind()
    if g:NERDTree.IsOpen()
        execute ':NERDTreeClose'
    else
        execute ':NERDTreeFind'
    endif
endfunction
nnoremap <F3> :call ToggleNERDTreeFind()<CR>
"map <F3> :NERDTreeFind<CR>
" Quit without saving. Helps quick file viewing in Midnight Commander
map <F4> :q<CR>

" Toggle left column (numbers, git gutter, syntastic)
" Useful for selecting with the mouse and for simple files
" Vim 8 supports 'set signcolumn=yes|no', but we are not there yet
function! ToggleLeftColumn()
	if &number == 1
		set nonumber
		GitGutterDisable
		echo "Left column is off"
	else
		set number
		GitGutterEnable
		echo "Left column is on"
	endif
	return
endfunc
nnoremap <F6> :call ToggleLeftColumn()<CR>
vnoremap <F6> :call ToggleLeftColumn()<CR>
inoremap <F6> <ESC>:call ToggleLeftColumn()<CR>i

" Use phpctags for tagbar
let g:tagbar_phpctags_bin="~/bin/phpctags"
" Show tag bar
let g:tagbar_autofocus = 1
map <F9> :TagbarToggle<CR>
" Save and exit
map <F10> :wq<CR>

" Zeal offline documentation
let g:zv_file_types = {
	\ 'php': 'cakephp,php',
	\ }

" exit to normal mode with 'jj'
inoremap jj <ESC>

