if exists('loaded_hex2rgb_vim') || &cp || v:version < 700
  finish
endif
let g:loaded_hex2rgb_vim= 1

" check whether valid hex string
function! s:ConvertToRGB(code) abort
 let rgb = ['00','00','00']
 let result = matchlist(a:code,'\v(#){0,1}(\x{6})')
 let result = filter(result,{ _,val -> len(val) >=0 && len(matchstr(val,'#')) == 0})
 let value=-1
 if len(result) > 0
   let code_str = result[0]
   let rgb[0] = str2nr(code_str[0:1],16)
   let rgb[1] = str2nr(code_str[2:3],16)
   let rgb[2] = str2nr(code_str[4:5],16)
   if len(code_str) > 0
     let value = str2nr(code_str,16)
   else
     let value = -1
   endif
 endif
 " #000000-#ffffff
 return [value >= 0 && value <= 0xffffff, join(rgb,',')]
endfunction

" convert RGB string to [R,G,B]
function! s:hex2rgb(code,...) abort
  let range = a:firstline . "," . a:lastline
  let cursor_pos = getcurpos() " [0, lnum, col, off, curswant]
  let save_cursor = getpos('.') " [bufnum, lnum, col, off]
  let save_cursor[0] = bufnr()
  let save_cursor[2] = cursor_pos[4] " actual col
  let save_cursor[3] = cursor_pos[3] " off
  if a:firstline != a:lastline
    echoerr "Only support hex in the same line"
    return
  endif 
  let value = a:code
  if len(value) == 0
    " treat selected string as unicode
    " left column: trimmed if visual selection doesn't start on the first
    " column
    let leftCol = getpos("'<")[2] 
    " right column: cut if visual selection doesn't end on the last column
    let rightCol = getpos("'>")[2]
    let value = getline(a:firstline)[leftCol - 1: rightCol - (&selection == 'inclusive' ? 1 : 2)]
  endif
  let [is_valid, code_str] = s:ConvertToRGB(value)
  if is_valid
    let save_cursor[2] = cursor_pos[4]-1
    call setpos('.', save_cursor)
    call feedkeys("i" . code_str . "\<esc>")
  else
    echoerr "invalid"
    echoerr code_str
  endif
  let save_cursor[2] = cursor_pos[4]
  call setpos('.', save_cursor)
  unlet save_cursor
endfunction

command! -range -nargs=* Hex2rgb call <SID>hex2rgb(<q-args>)
