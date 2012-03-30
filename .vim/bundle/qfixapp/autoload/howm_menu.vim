"=============================================================================
"    Description: HowmTitlelist for QFixHowm
"         Author: fuenor <fuenor@gmail.com>
"  Last Modified: 0000-00-00 00:00
"        Version: 1.00
"=============================================================================
scriptencoding utf-8

if exists('loaded_HowmMenu') && !exists('fudist')
  finish
endif
let loaded_HowmMenu = 1

if v:version < 700
  finish
endif

let s:howmsuffix = 'howm'

if !exists('g:HowmFiles_Sort')
  let g:HowmFiles_Sort = ''
endif

if !exists('g:QFixHowm_MenuCloseOnJump')
  let g:QFixHowm_MenuCloseOnJump = 1
endif
if !exists('g:QFixHowm_MenuHeight')
  let g:QFixHowm_MenuHeight = 0
endif
if !exists('g:QFixHowm_MenuWidth')
  let g:QFixHowm_MenuWidth = 0
endif
if !exists('g:QFixHowm_MenuWrap')
  let g:QFixHowm_MenuWrap = 0
endif
if !exists('g:QFixHowm_MenuPreview')
  let g:QFixHowm_MenuPreview = 0
endif
if !exists('g:QFixHowm_MenuCmd')
  let g:QFixHowm_MenuCmd = ''
endif
if !exists('g:HowmFiles_Preview')
  let g:HowmFiles_Preview = 1
endif

let s:howmsuffix = 'howm'
let s:filehead = 'howm://'

""""""""""""""""""""""""""""""
" 高速リスト一覧
""""""""""""""""""""""""""""""
augroup HowmFiles
  au!
  autocmd BufWinEnter __HOWM_MENU__ call <SID>BufWinEnterMenu(g:HowmFiles_Preview, s:filehead)
  autocmd BufLeave    __HOWM_MENU__ call <SID>BufLeaveMenu()
  autocmd CursorHold  __HOWM_MENU__ call <SID>PreviewMenu(s:filehead)
augroup END

function! s:TogglePreview(...)
  let b:PreviewEnable = !b:PreviewEnable
  if a:0
    " let g:QFixHowm_MenuPreview = b:PreviewEnable
  else
    let g:HowmFiles_Preview = b:PreviewEnable
  endif
  if !b:PreviewEnable
    call QFixPclose()
  endif
endfunction

function! s:Close()
  if winnr('$') == 1 || (winnr('$') == 2 && b:PreviewEnable == 1)
    if tabpagenr('$') > 1
      tabclose
    else
      silent! b #
      " silent! close
    endif
  else
    close
  endif
endfunction

function! s:Getfile(lnum, ...)
  let l = a:lnum
  let str = getline(l)
  if a:0
    let head = a:1
    if str !~ '^'.head
      return ['', 0]
    endif
    let str = substitute(str, '^'.head, '', '')
  endif
  let file = substitute(str, '|.*$', '', '')
  silent! exec 'lchdir ' . escape(g:qfixmemo_dir, ' ')
  let file = fnamemodify(file, ':p')
  if !filereadable(file)
    return ['', 0]
  endif
  let lnum = matchstr(str, '|\d\+\( col \d\+\)\?|')
  let lnum = matchstr(lnum, '\d\+')
  if lnum == ''
    let lnum = 1
  endif
  let file = substitute(file, '\\', '/', 'g')
  return [file, lnum]
endfunction

function! s:Search(cmd, ...)
  if a:0
    let _key = a:1
  else
    let mes = a:cmd == 'g' ? '(exclude)' : ''
    let _key = input('Search for pattern'.mes.' : ')
    if _key == ''
      return
    endif
  endif
  let @/=_key
  call s:Exec(a:cmd.'/'._key.'/d')
  call cursor(1, 1)
endfunction

function! s:SortExec(...)
  let mes = 'Sort type? (r:reverse)+(m:mtime, n:name, t:text, h:howmtime) : '
  if a:0
    let pattern = a:1
  else
    let pattern = input(mes, '')
  endif
  if pattern =~ 'r\?m'
    let g:QFix_Sort = substitute(pattern, 'm', 'mtime', '')
  elseif pattern =~ 'r\?n'
    let g:QFix_Sort = substitute(pattern, 'n', 'name', '')
  elseif pattern =~ 'r\?t'
    let g:QFix_Sort = substitute(pattern, 't', 'text', '')
  elseif pattern =~ 'r\?h'
    let g:QFix_Sort = substitute(pattern, 'h', 'howmtime', '')
  elseif pattern == 'r'
    let g:QFix_Sort = 'reverse'
  else
    return
  endif

  echo 'HowmFiles : Sorting...'
  let sq = []
  for n in range(1, line('$'))
    let [pfile, lnum] = s:Getfile(n)
    let text = substitute(getline(n), '[^|].*|[^|].*|', '', '')
    let mtime = getftime(pfile)
    let sepdat = {"filename":pfile, "lnum": lnum, "text":text, "mtime":mtime, "bufnr":-1}
    call add(sq, sepdat)
  endfor

  if g:QFix_Sort =~ 'howmtime'
    let sq = QFixHowmSort('howmtime', 0, sq)
    if pattern =~ 'r.*'
      let sq = reverse(sq)
    endif
    let g:QFix_Sort = 'howmtime'
  elseif g:QFix_Sort =~ 'mtime'
    let sq = s:Sort(g:QFix_Sort, sq)
  elseif g:QFix_Sort =~ 'name'
    let sq = s:Sort(g:QFix_Sort, sq)
  elseif g:QFix_Sort =~ 'text'
    let sq = s:Sort(g:QFix_Sort, sq)
  elseif g:QFix_Sort == 'reverse'
    let sq = reverse(sq)
  endif
  silent! exec 'lchdir ' . escape(g:qfixmemo_dir, ' ')
  let s:glist = []
  for d in sq
    let filename = fnamemodify(d['filename'], ':.')
    let line = printf("%s|%d| %s", filename, d['lnum'], d['text'])
    call add(s:glist, line)
  endfor
  setlocal modifiable
  silent! %delete _
  call setline(1, s:glist)
  setlocal nomodifiable
  call cursor(1,1)
  redraw|echo 'Sorted by '.g:QFix_Sort.'.'
endfunction

function! s:Sort(cmd, sq)
  if a:cmd =~ 'mtime'
    let sq = sort(a:sq, "s:QFixCompareTime")
  elseif a:cmd =~ 'name'
    let sq = sort(a:sq, "s:QFixCompareName")
  elseif a:cmd =~ 'text'
    let sq = sort(a:sq, "s:QFixCompareText")
  endif
  if g:QFix_Sort =~ 'r.*'
    let sq = reverse(a:sq)
  endif
  let g:QFix_SearchResult = []
  return sq
endfunction

function! s:QFixCompareName(v1, v2)
  if a:v1.filename == a:v2.filename
    return (a:v1.lnum > a:v2.lnum?1:-1)
  endif
  return ((a:v1.filename) . a:v1.lnum> (a:v2.filename) . a:v2.lnum?1:-1)
endfunction

function! s:QFixCompareTime(v1, v2)
  if a:v1.mtime == a:v2.mtime
    if a:v1.filename != a:v2.filename
      return (a:v1.filename < a:v2.filename?1:-1)
    endif
    return (a:v1.lnum > a:v2.lnum?1:-1)
  endif
  return (a:v1.mtime < a:v2.mtime?1:-1)
endfunction

function! s:QFixCompareText(v1, v2)
  if a:v1.text == a:v2.text
    return (a:v1.filename < a:v2.filename?1:-1)
  endif
  return (a:v1.text < a:v2.text?1:-1)
endfunction

function! s:Cmd_RD(cmd, fline, lline)
  let [file, lnum] = s:Getfile(a:fline)
  if a:cmd == 'Delete'
    let mes = "!!! Delete file(s) !!!"
  elseif a:cmd == 'Remove'
    let mes = "!!! Remove to (".g:qfixmemo_dir.")"
  else
    return 0
  endif
  let choice = confirm(mes, "&Yes\n&Cancel", 2, "W")
  if choice != 1
    return 0
  endif
  for lnum in range(a:fline, a:lline)
    let [file, lnum] = s:Getfile(lnum)
    let dst = expand(g:qfixmemo_dir).'/'.fnamemodify(file, ':t')
    if a:cmd == 'Delete'
      call delete(file)
    elseif a:cmd == 'Remove'
      echoe 'Remove' fnamemodify(file, ':t')
      call rename(file, dst)
    endif
  endfor
  return 1
endfunction

function! s:Exec(cmd, ...) range
  let cmd = a:cmd
  if a:firstline != a:lastline
    let cmd = a:firstline.','.a:lastline.cmd
  endif
  if a:0
    if s:Cmd_RD(a:1, a:firstline, a:lastline) != 1
      return
    endif
  endif
  let mod = &modifiable ? '' : 'no'
  setlocal modifiable
  exec cmd
  exec 'setlocal '.mod.'modifiable'
endfunction

""""""""""""""""""""""""""""""
"メニュー画面
""""""""""""""""""""""""""""""
"メニューファイルディレクトリ
if !exists('g:QFixHowm_MenuDir')
  let g:QFixHowm_MenuDir = ''
endif
"メニューファイル名
if !exists('g:QFixHowm_Menufile')
  let g:QFixHowm_Menufile = 'Menu-00-00-000000.'.s:howmsuffix
endif
" メニュー画面に表示する MRUリストのエントリ数
if !exists('g:QFixHowm_MenuRecent')
  let g:QFixHowm_MenuRecent = 5
endif

command! -count -nargs=* QFixHowmOpenMenuCache         call QFixHowmOpenMenu('cache')
command! -count -nargs=* QFixHowmOpenMenu              call QFixHowmOpenMenu()

let s:menubufnr = 0
function! howm_menu#Init()
endfunction

function! QFixHowmOpenMenu(...)
  call qfixmemo#Init()
  if count > 0
    let g:QFixHowm_ShowScheduleMenu = count
  endif
  redraw | echo 'QFixHowm : Open menu...'
  let winnr = QFixWinnr()
  exec winnr.'wincmd w'
  if &buftype == 'quickfix'
    silent! wincmd w
  endif
  let g:QFix_Disable = 1
  silent! let firstwin = s:GetBufferInfo()
  if g:QFixHowm_MenuDir== ''
    let mfile = g:qfixmemo_dir. '/'.g:QFixHowm_Menufile
  else
    let mfile = g:QFixHowm_MenuDir  . '/' . g:QFixHowm_Menufile
  endif
  let mfile = fnamemodify(mfile, ':p')
  let mfile = substitute(mfile, '\\', '/', 'g')
  let mfile = substitute(mfile, '/\+', '/', 'g')
  let mfilename = '__HOWM_MENU__'

  if !filereadable(mfile)
    let dir = fnamemodify(mfile, ':h')
    if isdirectory(dir) == 0 && dir != ''
      call mkdir(dir, 'p')
    endif
    let from = &enc
    let to   = g:qfixmemo_fileencoding
    call myhowm_msg#MenuInit()
    call map(g:QFixHowmMenuList, 'iconv(v:val, from, to)')
    call writefile(g:QFixHowmMenuList, mfile)
  endif
  let glist = qfixmemo#Readfile(mfile, g:qfixmemo_fileencoding)
  let use_reminder = count(glist, '%reminder')
  let use_recent   = count(glist, '%recent')
  let use_random   = count(glist, '%random')
  let from = g:qfixmemo_fileencoding
  let to   = &enc

  redraw|echo 'QFixHowm : Make mru list...'
  let recent = QFixMRUGetList(g:qfixmemo_dir, g:QFixHowm_MenuRecent)
  if use_random
    redraw|echo 'QFixHowm : Read random cache...'
    let random = qfixmemo#RandomWalk(g:qfixmemo_random_file, 'qflist')
  endif
  let reminder = []
  if use_reminder
    redraw|echo 'QFixHowm : Make reminder cache...'
    let saved_ull = g:QFix_UseLocationList
    let g:QFix_UseLocationList = 1
    if a:0
      let reminder = QFixHowmListReminderCache("menu")
    else
      let reminder = QFixHowmListReminder("menu")
    endif
    let g:QFix_UseLocationList = saved_ull
  endif

  let menubuf = 0
  for i in range(1, winnr('$'))
    if fnamemodify(bufname(winbufnr(i)), ':t') == mfilename
      exec i . 'wincmd w'
      let menubuf = i
      let g:HowmMenuLnum = getpos('.')
      break
    endif
  endfor
  if s:menubufnr
    exec 'b '.s:menubufnr
  else
    if g:QFixHowm_MenuCmd != ''
      exec g:QFixHowm_MenuCmd
    endif
    silent! exec 'silent! edit '.mfilename
    let s:menubufnr = bufnr('%')
  endif
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  setlocal modifiable
  exec 'setlocal fenc='.g:qfixmemo_fileencoding
  exec 'setlocal ff='.g:qfixmemo_fileformat
  if g:QFix_Width > 0
    exec "normal! ".g:QFixHowm_MenuWidth."\<C-W>|"
  endif
  if g:QFixHowm_MenuHeight > 0
    exec 'resize '. g:QFixHowm_MenuHeight
  endif
  silent! %delete _
  silent! exec 'silent! -1put=glist'
  silent! $delete _
  exec 'lchdir ' . escape(g:qfixmemo_dir, ' ')
  call cursor(1,1)
  if search('%menu%', 'cW') > 0
    let str = substitute(getline('.'), '%menu%', mfile, '')
    call setline(line('.'), str)
  endif
  call cursor(1, 1)
  if use_reminder
    call s:HowmMenuReplace(reminder, '^\s*%reminder')
  endif
  if use_recent
    call s:HowmMenuReplace(recent, '^\s*%recent')
  endif
  if use_random
    call s:HowmMenuReplace(random, '^\s*%random')
  endif
  call setpos('.', g:HowmMenuLnum)
  if exists("*QFixHowmOpenMenuPost")
    call QFixHowmOpenMenuPost()
  endif
  setlocal nomodifiable
  if firstwin
    enew
    b #
  endif
  let g:QFix_Disable = 0
endfunction

let s:first = 0
function! s:GetBufferInfo()
  if s:first
    return 0
  endif
  redir => bufoutput
  buffers
  redir END
  for buf in split(bufoutput, '\n')
    let bits = split(buf, '"')
    let b = {"attributes": bits[0], "line": substitute(bits[2], '\s*', '', '')}
    if bits[0] !~ '^\s*1\s' || bits[0] =~ '^\s*1\s*#'
      let s:first = 1
      return 0
    endif
  endfor
  return 1
endfunction

function! s:HowmMenuReplace(sq, rep, ...)
  let glist = []
  for d in a:sq
    if exists('d["filename"]')
      let file = d['filename']
    else
      let file = bufname(d['bufnr'])
    endif
    let file = fnamemodify(file, ':.')
    let file = 'howm://'.file
    call add(glist, printf("%s|%d| %s", file, d['lnum'], d['text']))
  endfor
  if a:0
    let from = a:1
    let to   = &enc
    call map(glist, 'iconv(v:val, from, to)')
  endif
  let save_cursor = getpos('.')
  call cursor(1,1)
  if search(a:rep, 'cW') > 0
    silent! delete _
    silent! exec 'silent! -1put=glist'
  endif
  call setpos('.', save_cursor)
endfunction

silent! function HowmMenuCmd_()
  call HowmMenuCmdMap(',')
  call HowmMenuCmdMap('r,')
  call HowmMenuCmdMap('I', 'H')
  call HowmMenuCmdMap('.', 'c')
  call HowmMenuCmdMap('u')
  call HowmMenuCmdMap('<Space>', ' ')
  call HowmMenuCmdMap('m')
  call HowmMenuCmdMap('o', 'l')
  call HowmMenuCmdMap('O', 'L')
  call HowmMenuCmdMap('A')
  call HowmMenuCmdMap('a')
  call HowmMenuCmdMap('ra')
  call HowmMenuCmdMap('s')
  call HowmMenuCmdMap('S', 'g')
  call HowmMenuCmdMap('<Tab>', 'y')
  call HowmMenuCmdMap('t')
  call HowmMenuCmdMap('ry')
  call HowmMenuCmdMap('rt')
  call HowmMenuCmdMap('rr')
  call HowmMenuCmdMap('rk')
  call HowmMenuCmdMap('rR')
  call HowmMenuCmdMap('rN')
  call HowmMenuCmdMap('rA')
  call HowmMenuCmdMap('R', 'rA')
endfunction

function! HowmMenuCmdMap(cmd, ...)
  let cmd = a:0 ? a:1 : a:cmd
  let cmd = ':call QFixHowmCmd("'.cmd.'")<CR>'
  if g:QFixHowm_MenuCloseOnJump && cmd =~ '"[cu ]"'
    let cmd = cmd.':<C-u>call HowmMenuClose()<CR>'
  endif
  exec 'silent! nnoremap <buffer> <silent> '.a:cmd.' '.cmd
endfunction

function! QFixHowmCmd(cmd)
  if g:qfixmemo_grep_cword
    let g:qfixmemo_grep_cword = -1
  endif
  if a:cmd =~ '^[sg]$'
  endif
  let cmd = g:qfixmemo_mapleader.a:cmd
  echo 'QFixHowm : exec '.cmd
  call feedkeys(cmd, 't')
endfunction

function! s:HowmMenuCR() range
  let save_cursor = getpos('.')
  if count
    call cursor(count, 1)
  endif
  call search('[^\s]', 'cb', line('.'))
  call search('[^\s]', 'cw', line('.'))
  let [lnum, fcol] = searchpos('%', 'ncb', line('.'))
  let [lnum, lcol] = searchpos(']', 'ncw', line('.'))
  let cmd = strpart(getline('.'), fcol, (lcol-fcol))
  let dcmd = matchstr(cmd, '"\s"\[[^ ]\+\]')
  if dcmd != ''
    let cmd = dcmd
  else
    let cmd = substitute(cmd, '\s\+.*$', '', '')
    let cmd = matchstr(cmd, '"[^ ]\+"\[[^ ]\+\]')
  endif
  if cmd != ''
    let cmd = substitute(matchstr(cmd, '".\+"'), '^"\|"$', '', 'g')
    if cmd =~ '^<.*>$'
      exec 'let cmd = '.'"\'.cmd.'"'
    endif
    call feedkeys(cmd, 't')
    call setpos('.', save_cursor)
    return ''
  endif
  let [file, lnum] = s:Getfile('.', s:filehead)
  if !filereadable(file)
    call QFixMemoUserModeCR()
    return ''
  endif
  call QFixPclose()
  if g:QFixHowm_MenuCloseOnJump
    exec 'edit '.escape(file, ' %#')
  else
    call QFixEditFile(file)
  endif
  call cursor(lnum, 1)
  exec 'normal! zz'
  return ''
endfunction

function! s:MenuCmd_J()
  let g:QFixHowm_MenuCloseOnJump = !g:QFixHowm_MenuCloseOnJump
  echo 'Close on jump : ' . (g:QFixHowm_MenuCloseOnJump? 'ON' : 'OFF')
endfunction

function! HowmMenuClose()
  if winnr('$') == 1 || (winnr('$') == 2 && g:QFix_Win > 0)
    exec 'silent! b#'
    return
  endif
  let mfilename = '__HOWM_MENU__'
  for i in range(1, winnr('$'))
    if fnamemodify(bufname(winbufnr(i)), ':t') == mfilename
      exec i . 'wincmd w'
      exec 'silent! close'
    endif
  endfor
endfunction

function! s:BufWinEnterMenu(preview, head)
  " set nowinfixheight
  " set winfixwidth
  let &wrap=g:QFixHowm_MenuWrap
  let b:updatetime = g:QFix_PreviewUpdatetime
  exec 'setlocal updatetime='.b:updatetime
  if !exists('b:PreviewEnable')
    let b:PreviewEnable = a:preview
  endif

  hi link QFMenuButton	Special
  hi link QFMenuSButton	Identifier
  exe 'set ft='.g:qfixmemo_filetype
  call qfixmemo#Syntax()
  runtime! syntax/howm_schedule.vim
  syn region QFMenuSButton start=+%"\zs+ end=+[^"]\+\ze"\[+ end='$'
  syn region QFMenuButton  start=+"\[\zs+ end=+[^\]]\+\ze\(\s\|]\)+ end='$'
  exe 'syn match mqfFileName "^'.a:head.'[^|]*"'.' nextgroup=qfSeparator'
  syn match qfSeparator "|" nextgroup=qfLineNr contained
  syn match qfLineNr    "[^|]*" contained contains=qfError
  syn match qfError     "error" contained

  hi link mqfFileName Directory
  hi link qfLineNr  LineNr
  hi link qfError Error
  call QFixHowmQFsyntax()

  nnoremap <buffer> <silent> J :<C-u>call <SID>MenuCmd_J()<CR>
  nnoremap <buffer> <silent> q :<C-u>call <SID>Close()<CR>
  nnoremap <buffer> <silent> i :<C-u>call <SID>TogglePreview('menu')<CR>
  call QFixAltWincmdMap()
  nnoremap <buffer> <silent> <CR> :<C-u>call <SID>HowmMenuCR()<CR>
  nnoremap <buffer> <silent> <2-LeftMouse> <ESC>:<C-u>call <SID>HowmMenuCR()<CR>
  call HowmMenuCmd_()
  silent! call HowmMenuCmd()

  silent! exec 'lchdir ' . escape(g:qfixmemo_dir, ' ')
endfunction

let g:HowmMenuLnum = [0, 1, 1, 0]
function! s:BufLeaveMenu()
  " set nowinfixheight
  let g:HowmMenuLnum = getpos('.')
  if b:PreviewEnable
    call QFixPclose()
  endif
endfunction

function! s:PreviewMenu(head)
  if b:PreviewEnable < 1
    return
  endif
  let [file, lnum] = s:Getfile('.', a:head)
  if file == '' && g:QFixHowm_MenuPreview == 0
    call QFixPclose()
    return
  endif
  call QFixPreviewOpen(file, lnum)
endfunction

