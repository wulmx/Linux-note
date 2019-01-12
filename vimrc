set nocompatible
map <F5> :w<cr>:r!python %<cr>
" .. solarized
let g:solarized_termtrans=1
let g:solarized_contrast="normal"
let g:solarized_visibility="normal"
" color 
set background=dark
set t_Co=256
 
" ctrlp
let g:ctrlp_map = '<leader>ff'
let g:ctrlp_cmd = 'CtrlP'
" show recently opened files
map <leader>fp :CtrlPMRU<CR>
" set wildignore+=*/tmp/*,*.so,*.swp,*.zip     " MacOSX/Linux"
let g:ctrlp_custom_ignore = {
     \ 'dir':  '\v[\/]\.(git|hg|svn|rvm)$',
     \ 'file': '\v\.(exe|so|dll|zip|tar|tar.gz)$', 
     \ }
"\ 'link': 'SOME_BAD_SYMBOLIC_LINKS',
let g:ctrlp_working_path_mode=0
let g:ctrlp_match_window_bottom=1
let g:ctrlp_max_height=15
let g:ctrlp_match_window_reversed=0
let g:ctrlp_mruf_max=500
let g:ctrlp_follow_symlinks=1
 
" vim-powerline....
" let g:Powerline_symbols = 'fancy'
let g:Powerline_symbols = 'unicode'
 
" ......
let g:rbpt_colorpairs = [
    \ ['brown',       'RoyalBlue3'],
    \ ['Darkblue',    'SeaGreen3'],
    \ ['darkgray',    'DarkOrchid3'],
    \ ['darkgreen',   'firebrick3'],
    \ ['darkcyan',    'RoyalBlue3'],
    \ ['darkred',     'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['brown',       'firebrick3'],
    \ ['gray',        'RoyalBlue3'],
    \ ['black',       'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['Darkblue',    'firebrick3'],
    \ ['darkgreen',   'RoyalBlue3'],
    \ ['darkcyan',    'SeaGreen3'],
    \ ['darkred',     'DarkOrchid3'],
    \ ['red',         'firebrick3'],
    \ ]
let g:rbpt_max = 40
let g:rbpt_loadcmd_toggle = 0
 
" .....
let g:indent_guides_enable_on_vim_startup = 0  " ....
let g:indent_guides_guide_size            = 1  " ........
let g:indent_guides_start_level           = 2  " .............

set cursorline
set tabstop=4
set expandtab
function PythonHeader()
    call setline(1, "# -*- coding: utf-8 -*-")
    normal o
    normal o
endfunc
autocmd BufNewFile *.py call PythonHeader()
map :!clear ;python %
let g:go_version_warning = 0
set nocompatible              " be iMproved, required  
filetype off                  " required  
set rtp+=~/.vim/bundle/Vundle.vim 
call vundle#begin()
Plugin 'gmarik/Vundle.vim'
Plugin 'fatih/vim-go'
Plugin 'scrooloose/nerdtree'
Plugin 'majutsushi/tagbar'
Plugin 'vim-scripts/ctags.vim'
Plugin 'scrooloose/syntastic'
Plugin 'kien/ctrlp.vim'
Plugin 'davidhalter/jedi-vim'
Plugin 'klen/python-mode'
call vundle#end()            " required 
"Bundle 'dgryski/vim-godef'
map <F3> :NERDTreeMirror<CR>
map <F3> :NERDTreeToggle<CR>
nmap <F4> :TagbarToggle<CR>
filetype plugin indent on    " required  
autocmd vimenter * if !argc()|NERDTree|endif
let g:NERDTreeDirArrowExpandable = '.'
let g:NERDTreeDirArrowCollapsible = '.'
let NERDTreeIgnore = ['\.pyc$']  " .....pyc.....
""Making it prettier
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let g:godef_split = 3
let g:godef_same_file_in_same_window = 1
syntax on

if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
   set fileencodings=ucs-bom,utf-8,latin1
endif
"set tags=/home/wulm/I_pcp/pcp-4.0.2/src/tags
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
"set encoding=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
"set encoding=ucs-bom,gb18030,gbk,gb2312,cp936
set nocompatible	" Use Vim defaults (much better!)
set bs=indent,eol,start		" allow backspacing over everything in insert mode
"set ai			" always set autoindenting on
"set backup		" keep a backup file
set viminfo='20,\"50	" read/write a .viminfo file, don't store more
			" than 50 lines of registers
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set nu
" Only do this part when compiled with support for autocommands
if has("autocmd")
  augroup redhat
  autocmd!
  " In text files, always limit the width of text to 78 characters
  " autocmd BufRead *.txt set tw=78
  " When editing a file, always jump to the last cursor position
  autocmd BufReadPost *
  \ if line("'\"") > 0 && line ("'\"") <= line("$") |
  \   exe "normal! g'\"" |
  \ endif
  " don't write swapfile on most commonly used directories for NFS mounts or USB sticks
  autocmd BufNewFile,BufReadPre /media/*,/run/media/*,/mnt/* set directory=~/tmp,/var/tmp,/tmp
  " start with spec file template
  autocmd BufNewFile *.spec 0r /usr/share/vim/vimfiles/template.spec
  augroup END
endif

if has("cscope") && filereadable("/usr/bin/cscope")
   set csprg=/usr/bin/cscope
   set csto=0
   set cst
   set nocsverb
   " add any database in current directory
   if filereadable("cscope.out")
      cs add $PWD/cscope.out
   " else add database pointed to by environment
   elseif $CSCOPE_DB != ""
      cs add $CSCOPE_DB
   endif
   set csverb
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

filetype plugin on

if &term=="xterm"
     set t_Co=8
     set t_Sb=[4%dm
     set t_Sf=[3%dm
endif

" Don't wake up system with blinking cursor:
" http://www.linuxpowertop.org/known.php
let &guicursor = &guicursor . ",a:blinkon0"
set bg=dark