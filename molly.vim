" ============================================================================
" File:        molly.vim
" Description: Speed is key!
" Maintainer:  William Estoque <william.estoque at gmail dot com>
" Last Change: 23 March, 2010
" License:     MIT
"
" ============================================================================
let s:Molly_version = '0.0.2'

command -nargs=? -complete=dir Molly call <SID>MollyController()
silent! nmap <unique> <silent> <Leader>x :Molly<CR>

let s:query = ""
let s:filelist = split(system('find . ! -regex ".*/\..*" -type f -print'), "\n")

function! s:MollyController()
  execute "sp molly"
  call BindKeys()
  call SetLocals()
endfunction

function RefreshFileList()
  let s:filelist = split(system('find . ! -regex ".*/\..*" -type f -print'), "\n")
endfunction

function BindKeys()
  let asciilist = range(97,122)
  let asciilist = extend(asciilist, range(32,47))
  let asciilist = extend(asciilist, range(58,90))
  let asciilist = extend(asciilist, [91,92,93,95,96,123,125,126])

  let specialChars = {
    \  '<BS>'    : 'Backspace',
    \  '<Del>'   : 'Delete',
    \  '<CR>'    : 'AcceptSelection',
    \  '<C-t>'   : 'AcceptSelectionTab',
    \  '<C-v>'   : 'AcceptSelectionVSplit',
    \  '<C-CR>'  : 'AcceptSelectionSplit',
    \  '<C-s>'   : 'AcceptSelectionSplit',
    \  '<Tab>'   : 'ToggleFocus',
    \  '<C-c>'   : 'Cancel',
    \  '<Esc>'   : 'Cancel',
    \  '<C-u>'   : 'Clear',
    \  '<C-e>'   : 'CursorEnd',
    \  '<C-a>'   : 'CursorStart',
    \  '<C-n>'   : 'SelectNext',
    \  '<C-j>'   : 'SelectNext',
    \  '<Down>'  : 'SelectNext',
    \  '<C-k>'   : 'SelectPrev',
    \  '<C-p>'   : 'SelectPrev',
    \  '<Up>'    : 'SelectPrev',
    \  '<C-h>'   : 'CursorLeft',
    \  '<Left>'  : 'CursorLeft',
    \  '<C-l>'   : 'CursorRight',
    \  '<Right>' : 'CursorRight'
  \}

  for n in asciilist
    execute "noremap <buffer> <silent>" . "<Char-" . n . "> :call HandleKey('" . nr2char(n) . "')<CR>"
  endfor

  for key in keys(specialChars)
    execute "noremap <buffer> <silent>" . key  . " :call HandleKey" . specialChars[key] . "()<CR>"
  endfor
endfunction

function HandleKey(key)
  let s:query = s:query . a:key
  call ExecuteQuery()
endfunction

function HandleKeySelectNext()
  call setpos(".", [0, line(".") + 1, 1, 0])
endfunction

function HandleKeySelectPrev()
  call setpos(".", [0, line(".") - 1, 1, 0])
endfunction

function HandleKeyCursorLeft()
  echo "left"
endfunction

function HandleKeyCursorRight()
  echo "right"
endfunction

function HandleKeyBackspace()
  let s:query = strpart(s:query, 0, strlen(s:query) - 1)
  call ExecuteQuery()
endfunction

function HandleKeyCancel()
  let s:query = ""
  execute "q!"
endfunction

function HandleKeyAcceptSelection()
  let filename = getline(".")
  execute "q!"
  execute "e " . filename
  unlet filename
  let s:query = ""
endfunction

function HandleKeyAcceptSelectionVSplit()
  let filename = getline(".")
  execute "q!"
  execute "vs " . filename
  unlet filename
  let s:query = ""
endfunction

function HandleKeyAcceptSelectionSplit()
  let filename = getline(".")
  execute "q!"
  execute "sp " . filename
  unlet filename
  let s:query = ""
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
  let listcopy = copy(s:filelist)
  let newlist = filter(listcopy, "v:val =~ \('" . s:query . "'\)")
  call ClearBuffer()
  call setline(".", newlist)
  unlet newlist
  unlet listcopy
  echo ">> " . s:query
endfunction
