" use Vim settings, rather than Vi settings (much better!).
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
Plugin 'Lokaltog/vim-easymotion'          " Vim Jumping Motions
Plugin 'dense-analysis/ale'
Plugin 'ctrlpvim/ctrlp.vim.git'               " Fuzzy file, buffer, mru, tag, etc finder.
Plugin 'airblade/vim-gitgutter.git'
Plugin 'tpope/vim-fugitive'               " git commands
Plugin 'scrooloose/nerdtree'
Plugin 'flazz/vim-colorschemes'
Plugin 'pearofducks/ansible-vim'
Plugin 'tpope/vim-surround'
Plugin 'mileszs/ack.vim' 
Plugin 'chriskempson/base16-vim'
Plugin 'jiangmiao/auto-pairs'
Plugin 'dracula/vim'
Plugin 'fatih/vim-go'
Plugin 'Yggdroot/indentLine'
Plugin 'pangloss/vim-javascript'
Plugin 'jelera/vim-javascript-syntax'
Plugin 'tmhedberg/SimpylFold'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'nvie/vim-flake8'
Plugin 'avakhov/vim-yaml'
Plugin 'godlygeek/tabular'
Plugin 'plasticboy/vim-markdown'
Plugin 'mzlogin/vim-markdown-toc'
Plugin 'hashivim/vim-terraform'
Plugin 'ycm-core/YouCompleteMe'
Plugin 'puremourning/vimspector'

"
" work around for booting up ruby files faster
"
let g:ruby_path = system('rbenv prefix')

"
" Spelling
"
set spelllang=en
set spellfile=/Users/pablo/Workspace/dotfiles/spell/en.utf-8.add
:nnoremap <C-n> :setlocal spell! spelllang=en_us<CR>

"
" Indenting
"
:nnoremap <C-i> :IndentLinesToggle<CR>

"
"	ColorScheme
"
syntax on
set t_Co=256
set background=dark
colorscheme dracula 

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
set foldmethod=indent         " setup folding
set foldlevel=99

:nnoremap <space> za

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
let g:ackprg = 'ag --nogroup --nocolor --column'

set mouse=a
map <ScrollWheelUp> <C-Y>
map <ScrollWheelDown> <C-E>

" Sets highlight search on
set hlsearch

" Turn off auto comment on new line
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Python settings
" Setup PEP 8 indentation
let python_highlight_all=1
au BufNewFile,BufRead *.py 
  \ set tabstop=4
  \ softtabstop=4
  \ shiftwidth=4
  \ textwidth=79
  \ expandtab
  \ autoindent
  \ fileformat=unix

let g:vimspector_enable_mappings='HUMAN'

function! HighlightRepeats() range
  let lineCounts = {}
  let lineNum = a:firstline
  while lineNum <= a:lastline
    let lineText = getline(lineNum)
    if lineText != ""
      let lineCounts[lineText] = (has_key(lineCounts, lineText) ? lineCounts[lineText] : 0) + 1
    endif
    let lineNum = lineNum + 1
  endwhile
  exe 'syn clear Repeat'
  for lineText in keys(lineCounts)
    if lineCounts[lineText] >= 2
      exe 'syn match Repeat "^' . escape(lineText, '".\^$*[]') . '$"'
    endif
  endfor
endfunction

command! -range=% HighlightRepeats <line1>,<line2>call HighlightRepeats()

" Remap Ctrl+A for tmux integration
cnoremap <C-c> <C-a>
