" use Vim settings, rather than Vi settings (much better!).
set nocompatible                        " original vi has nothing to do with my world
filetype off                            " no legacy filetype handling
set relativenumber                      " turn on linenumbers
set number
set noswapfile                          " turning off swapfiles


" *********************************************** 
"	Vundle
" ***********************************************
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#rc()
Plugin 'gmarik/Vundle.vim'



"
"	Plugins
"
Plugin 'tpope/vim-rails.git'              " rails powerup
Plugin 'Lokaltog/vim-easymotion'          " Vim Jumping Motions
Plugin 'altercation/vim-colors-solarized' " Solarized Colors
Plugin 'scrooloose/syntastic.git'
Plugin 'kien/ctrlp.vim.git'               " Fuzzy file, buffer, mru, tag, etc finder.
Plugin 'airblade/vim-gitgutter.git'
Plugin 'tpope/vim-fugitive'               " git commands
Plugin 'scrooloose/nerdtree'
Plugin 'flazz/vim-colorschemes'
Plugin 'pearofducks/ansible-vim'
Plugin 'Valloric/YouCompleteMe'

"
" work around for booting up ruby files faster
"
let g:ruby_path = system('rbenv prefix')



"
"	ColorScheme
"
syntax on
set background=dark
colorscheme gruvbox
set t_Co=256

if $ITERM_PROFILE=="inside"
	colorscheme gruvbox
elseif $ITERM_PROFILE=="outside"
	colorscheme PaperColor 
endif

"
"	other
"
set expandtab                                                    " Set to use spaces not tabs
set title                                                            " Set the terminal title
set autoindent                                                " autoindent on CR
set copyindent                                                " copy previous indenting
set tabstop=2                                                    " Global Tab Width
set shiftwidth=2                                        " number of spaces for auto-indent
set laststatus=2                                            " Show the statusline all the time
set hidden                                                        " handle multiple buffers better

filetype plugin indent on     " required

" Set autoreading to on
set autoread
au CursorHold * checktime 					" allow backspacing over everything in insert mode
set nobackup                                                    " keep no backup file flying free
set history=50                                                " keep 50 lines of command line history
set ruler                                                            " show the cursor position all the time
set showcmd                                                        " display incomplete commands
set incsearch                                                    " do incremental searching
set showmode                                                    " Display the Mode
set backspace=indent,eol,start                " Nice Backspaceing

" Force Defaults to UTF-8
set encoding=utf-8
set fileencoding=utf-8

let g:ctrlp_show_hidden = 1
let NERDTreeShowHidden = 1


set mouse+=a
