" ============================================================================
" File:        molly.vim
" Description: Speed is key!
" Maintainer:  William Estoque <william.estoque at gmail dot com>
" Last Change: 23 March, 2010
" License:     MIT
"
" ============================================================================
let s:Molly_version = '0.0.1'

command -nargs=? -complete=dir Molly call <SID>MollyController()
silent! nmap <unique> <silent> <Leader>x :Molly<CR>

let g:filelist = split(system('find . ! -regex ".*/\..*" -type f -print'), "\n")
let g:query = ""

function! s:MollyController()
  execute "sp molly"
  call BindKeys()
  call SetLocals()
endfunction

function BindKeys()
  let asciilist = range(97,122)
  let asciilist = extend(asciilist, range(32,47))
  let asciilist = extend(asciilist, range(58,64))
  let asciilist = extend(asciilist, [91,92,93,95,96,123,125,126])

  let specialChars = {
    \  '<BS>'   : 'Backspace',
    \  '<Del>'  : 'Delete',
    \  '<CR>'   : 'AcceptSelection',
    \  '<C-t>'  : 'AcceptSelectionTab',
    \  '<C-v>'  : 'AcceptSelectionVSplit',
    \  '<C-CR>' : 'AcceptSelectionSplit',
    \  '<C-s>'  : 'AcceptSelectionSplit',
    \  '<Tab>'  : 'ToggleFocus',
    \  '<C-c>'  : 'Cancel',
    \  '<Esc>'  : 'Cancel',
    \  '<C-u>'  : 'Clear',
    \  '<C-e>'  : 'CursorEnd',
    \  '<C-a>'  : 'CursorStart'
  \}

  " \  'SelectNext'            :  ['<C-n>', '<C-j>', '<Down>'],
  " \  'SelectPrev'            :  ['<C-p>', '<C-k>', '<Up>'],
  " \  'CursorLeft'            :  ['<Left>', '<C-h>'],
  " \  'CursorRight'           :  ['<Right>', '<C-l>'],

  for n in asciilist
    execute "noremap <buffer> <silent>" . "<Char-" . n . "> :call HandleKey('" . nr2char(n) . "')<CR>"
  endfor

  for key in keys(specialChars)
    execute "noremap <buffer> <silent>" . key  . " :call HandleKey" . specialChars[key] . "()<CR>"
  endfor
endfunction

function HandleKey(key)
  let g:query = g:query . a:key
  call ExecuteQuery()
endfunction

function HandleKeyBackspace()
  let g:query = strpart(g:query, 0, strlen(g:query) - 1)
  call ExecuteQuery()
endfunction

function HandleKeyCancel()
  let g:query = ""
  execute "q!"
endfunction

function HandleKeyAcceptSelection()
  let filename = getline(".")
  execute "q!"
  execute "e " . filename
  unlet filename
  let g:query = ""
endfunction

function HandleKeyAcceptSelectionVSplit()
  let filename = getline(".")
  execute "q!"
  execute "vs " . filename
  unlet filename
  let g:query = ""
endfunction

function HandleKeyAcceptSelectionSplit()
  let filename = getline(".")
  execute "q!"
  execute "sp " . filename
  unlet filename
  let g:query = ""
endfunction

function ClearBuffer()
  execute ":1,$d"
endfunction

function SetLocals()
  setlocal bufhidden=wipe
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal nowrap
  setlocal nonumber
  setlocal nolist
  setlocal foldcolumn=0
  setlocal foldlevel=99
  setlocal nospell
  setlocal nobuflisted
  setlocal textwidth=0
  setlocal cursorline
endfunction

function ExecuteQuery()
  let listcopy = copy(g:filelist)
  let newlist = filter(listcopy, "v:val =~ \('" . g:query . "'\)")
  call ClearBuffer()
  call setline(".", newlist)
  unlet newlist
  unlet listcopy
  echo ">> " . g:query
endfunction
