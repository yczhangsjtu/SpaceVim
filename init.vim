"=============================================================================
" init.vim --- Entry file for neovim
" Copyright (c) 2016-2022 Wang Shidong & Contributors
" Author: Wang Shidong < wsdjeg@outlook.com >
" URL: https://spacevim.org
" License: GPLv3
"=============================================================================

" set default encoding to utf-8
" Let Vim use utf-8 internally, because many scripts require this
set encoding=utf-8
scriptencoding utf-8

" Enable nocompatible
if &compatible
  set nocompatible
endif

let g:_spacevim_root_dir = escape(fnamemodify(resolve(fnamemodify(expand('<sfile>'),
      \ ':p:h:gs?\\?'.((has('win16') || has('win32')
      \ || has('win64'))?'\':'/') . '?')), ':p:gs?[\\/]?/?'), ' ')
lockvar g:_spacevim_root_dir
if has('nvim')
  let s:qtdir = split(&rtp, ',')[-1]
  if s:qtdir =~# 'nvim-qt'
    let &rtp = s:qtdir . ',' . g:_spacevim_root_dir . ',' . $VIMRUNTIME
  else
    let &rtp = g:_spacevim_root_dir . ',' . $VIMRUNTIME
  endif
else
  let &rtp = g:_spacevim_root_dir . ',' . $VIMRUNTIME
endif
call SpaceVim#logger#info('Loading SpaceVim from: ' . g:_spacevim_root_dir)

if has('vim_starting')
  " python host
  " @bug python2 error on neovim 0.6.1
  " let g:loaded_python_provider = 0
  if !empty($PYTHON_HOST_PROG)
    let g:python_host_prog  = $PYTHON_HOST_PROG
    call SpaceVim#logger#info('$PYTHON_HOST_PROG is not empty, setting g:python_host_prog:' . g:python_host_prog)
  endif
  if !empty($PYTHON3_HOST_PROG)
    let g:python3_host_prog = $PYTHON3_HOST_PROG
    call SpaceVim#logger#info('$PYTHON3_HOST_PROG is not empty, setting g:python3_host_prog:' . g:python3_host_prog)
    if !has('nvim') 
          \ && (has('win16') || has('win32') || has('win64'))
          \ && exists('&pythonthreedll')
          \ && exists('&pythonthreehome')
      let &pythonthreedll = get(split(globpath(fnamemodify($PYTHON3_HOST_PROG, ':h'), 'python*.dll'), '\n'), -1, '')
      call SpaceVim#logger#info('init &pythonthreedll:' . &pythonthreedll)
      let &pythonthreehome = fnamemodify($PYTHON3_HOST_PROG, ':h')
      call SpaceVim#logger#info('init &pythonthreehome:' . &pythonthreehome)
    endif
  endif
endif

call SpaceVim#begin()

call SpaceVim#custom#load()

call SpaceVim#default#keyBindings()

call SpaceVim#end()

call SpaceVim#logger#info('finished loading SpaceVim!')
" vim:set et sw=2 cc=80:

" Following are my custom settings
let mapleader = "," " map leader to comma
set tabstop=2
set shiftwidth=2
set t_Co=256
nnoremap <Up> gk
nnoremap <Down> gj
noremap - ddp
inoremap <c-u> <esc>viwUA
nnoremap <c-u> viwU
nnoremap <leader>ev :vsplit $HOME/.SpaceVim/vimrc<cr>
nnoremap <leader>sv :source $HOME/.SpaceVim/vimrc<cr>
nnoremap <leader>" viw<esc>a"<esc>bi"<esc>lel
nnoremap <leader>' viw<esc>a'<esc>bi'<esc>lel
vnoremap " <esc>`>a"<esc>`<i"<esc>
vnoremap ' <esc>`>a'<esc>`<i'<esc>
inoremap jk <esc>

augroup filetype_vim
  autocmd!
  autocmd FileType tags setlocal noexpandtab
  autocmd FileType vimwiki setlocal colorcolumn=80
augroup END
nnoremap <C-n> :NERDTreeToggle<CR>
nnoremap <leader>l :lnext<CR>
nnoremap <leader>p :lprevious<CR>
nnoremap <leader>yy "+yy
vnoremap <leader>yy "+y
noremap <leader>p "+p
let g:floaterm_keymap_toggle = '<F12>'
let g:floaterm_width = 0.9
let g:floaterm_height = 0.9
let g:vim_markdown_folding_disabled = 1

let g:UltiSnipsSnippetDirectories = ["UltiSnips", "my-snippets"]
let g:formatdef_custom_autopep8 = '"autopep8 -".(g:DoesRangeEqualBuffer(a:firstline, a:lastline) ? " --range ".a:firstline." ".a:lastline : "" )." ".(&textwidth ? "--max-line-length=".&textwidth : "")." ".(&shiftwidth ? "--indent-size=".&shiftwidth : "")'
let g:formatters_python = ["custom_autopep8"]
let g:syntastic_python_python_exec = 'python3'
let g:syntastic_python_checkers = ['python']
let g:syntastic_python_pycodestyle_args = "--indent-size=2"
let g:neomake_python_pycodestyle_maker = {
  \ 'args': [
  \ '--indent-size=2',
  \ ],
  \ }

let g:neomake_python_enabled_makers = ['pycodestyle']

let g:vimtex_view_general_viewer = '/Applications/Skim.app/Contents/SharedSupport/displayline'
let g:vimtex_view_general_options = '-r @line @pdf @tex'

let g:vimtex_compiler_latexmk = { 
        \ 'executable' : 'latexmk',
        \ 'options' : [ 
        \   '-xelatex',
        \   '-file-line-error',
        \   '-synctex=1',
        \   '-interaction=nonstopmode',
        \ ],
        \}

let g:vimtex_compiler_latexmk_engines = {
    \ '_'                : '-xelatex',
    \}

function! s:write_server_name() abort
  let nvim_server_file = (has('win32') ? $TEMP : '/tmp') . '/vimtexserver.txt'
  call writefile([v:servername], nvim_server_file)
endfunction

augroup vimtex_mac
  autocmd!
  autocmd User VimtexEventCompileSuccess call UpdateSkim()
  autocmd FileType tex call s:write_server_name()
  au FileType tex nnoremap <leader>lv :VimtexView<CR>
augroup END


function! UpdateSkim() abort
  let l:out = b:vimtex.out()
  let l:src_file_path = expand('%:p')
  let l:cmd = [g:vimtex_view_general_viewer, '-r']

  if !empty(system('pgrep Skim'))
  call extend(l:cmd, ['-g'])
  endif

  call jobstart(l:cmd + [line('.'), l:out, l:src_file_path])
endfunction

let g:loaded_ruby_provider = 0
let g:loaded_perl_provider = 0
let g:loaded_node_provider = 0
