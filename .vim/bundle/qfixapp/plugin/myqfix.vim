"=============================================================================
"    Description: QFixPreview
"                 Preview, sortings and advanced search for Quickfix.
"         Author: Futoshi Ueno <fuenor@gmail.com>
"                 http://sites.google.com/site/fudist/Home  (Japanese)
"  Last Modified: 2011-08-29 06:01
"=============================================================================
scriptencoding utf-8
let s:Version = 2.83

"What Is This:
"  This plugin adds preview, sortings and advanced search to your quickfix window.
"
"Install:
"  Put this file into your runtime directory.
"    > vimfiles/plugin or .vim/plugin
"
"Usage:
"  Execute a quickfix command(vimgrep, grep, make, etc.) and open the quickfix window.
"
"Commands:
"  | <C-w>, | Open/Close (quickfix window)
"  | <C-w>. | Move to the quickfix window
"
"  On the quickfix window:
"  | q | Close
"  | i | Open/Close (preview window)
"  | S | Sort commands
"  | s | Filter by string
"  | r | Filter by string (exclude)
"
"  | d dd | delete
"  | p P  | put
"
"  | u | Undo
"  | U | Undo all
"
"  | A | Save
"  | O | Restore
"
"=============================================================================
if exists('disable_QFixWin') && disable_QFixWin == 1
  finish
endif
if exists('g:QFixWin_version') && g:QFixWin_version < s:Version
  unlet loaded_QFixWin
endif
if exists("loaded_QFixWin") && !exists('fudist')
  finish
endif
if v:version < 700 || &cp || !has('quickfix')
  finish
endif
let g:QFixWin_version = s:Version
let loaded_QFixWin = 1

"プレビューの有効/無効
if !exists('g:QFix_PreviewEnable')
  let g:QFix_PreviewEnable = 1
endif
"quickfixウィンドウの高さ
if !exists('g:QFix_Height')
  let g:QFix_Height = 10
endif
"quickfixウィンドウの幅
if !exists('g:QFix_Width')
  let g:QFix_Width = 0
endif
"Quickfixウィンドウのコマンド指定
if !exists('g:QFix_CopenCmd')
  let g:QFix_CopenCmd = ''
endif
"カーソル強調表示を有効にする
if !exists('g:QFix_CursorLine')
  let g:QFix_CursorLine = 1
endif
"プレビューウィンドウのコマンド指定
if !exists('g:QFix_PreviewOpenCmd')
  let g:QFix_PreviewOpenCmd = ''
endif
"プレビューウィンドウのサイズ指定
if !exists('g:QFix_PreviewWidth')
  let g:QFix_PreviewWidth = 0
endif
"プレビューのカーソル強調表示
if !exists('g:QFix_PreviewCursorLine')
  let g:QFix_PreviewCursorLine = 1
endif
"プレビューハイライト
if !exists('g:QFix_PreviewFtypeHighlight')
  let g:QFix_PreviewFtypeHighlight = 1
endif
"'tab'に設定すると<S-CR>はファイルをタブで開く
if !exists('g:QFix_Edit')
  let g:QFix_Edit = ''
endif
"ファイルを開くとQuickfixウィンドウを閉じる
if !exists('g:QFix_CloseOnJump')
  let g:QFix_CloseOnJump = 0
endif
"ファイルを開く時に編集中のウィンドウも使用する
if !exists('g:QFix_UseModifiedWindow')
  let g:QFix_UseModifiedWindow = 1
endif
"プレビューしない拡張子
if !exists('g:QFix_PreviewExclude')
  let g:QFix_PreviewExclude = '\.pdf$\|\.mp3$\|\.jpg$\|\.bmp$\|\.png$\|\.zip$\|\.rar$\|\.exe$\|\.dll$\|\.lnk$'
endif

"プレビューする間隔
if !exists('g:QFix_PreviewUpdatetime')
  let g:QFix_PreviewUpdatetime = 12
endif
"ファイル名取得の高速化
if !exists('g:QFix_HighSpeedPreview')
  let g:QFix_HighSpeedPreview = 0
endif

"Quickfixウィンドウのサイズをキープする
if !exists('g:QFix_HeightFixMode')
  let g:QFix_HeightFixMode = 0
endif

"プレビューウィンドウタイトル
if !exists('g:QFix_PreviewName')
  let g:QFix_PreviewName = 'QuickfixPreview'
endif
"ファイルを分割して開いたときの最小ウィンドウ高さ
if !exists('g:QFix_WindowHeightMin')
  let g:QFix_WindowHeightMin = 0
endif
"quickfixウィンドウのデフォルト高さ
if !exists('g:QFix_HeightDefault')
  let g:QFix_HeightDefault = g:QFix_Height
endif

if !exists('g:QFix_Copen_winfixheight')
  let g:QFix_Copen_winfixheight   = 1
endif
if !exists('g:QFix_Copen_winfixwidth')
  let g:QFix_Copen_winfixwidth    = 0
endif
if !exists('g:QFix_Preview_winfixheight')
  let g:QFix_Preview_winfixheight = 1
endif
if !exists('g:QFix_Preview_winfixwidth')
  let g:QFix_Preview_winfixwidth  = 1
endif
if !exists('g:QFix_TabEditMode')
  let g:QFix_TabEditMode = 1
endif

""""""""""""""""""""""""""""""
"キーマップ
""""""""""""""""""""""""""""""
silent! nnoremap <unique> <silent> <C-w>, :ToggleQFixWin<CR>
silent! nnoremap <unique> <silent> <C-w>. :MoveToQFixWin<CR>

""""""""""""""""""""""""""""""
"コマンド
""""""""""""""""""""""""""""""
command! -count OpenQFixWin call OpenQFixWin(<line2>-<line1>+1)
command! CloseQFixWin call QFixCclose()
command! -count ToggleQFixWin call ToggleQFixWin(<line2>-<line1>+1)
command! -count MoveToQFixWin call MoveToQFixWin(<line2>-<line1>+1)
command! -count ResizeQFixWin call ResizeQFixWin(<line2>-<line1>+1)
command! -nargs=* -bang QFixCopen call QFixCopen(<q-args>, <bang>0)
command! QFixCclose   call QFixCclose()
command! -count ResizeOnQFix call ResizeOnQFix(<count>)
command! -nargs=? -count QFdo call QFdo(<q-args>, <count>)
command! -nargs=* -bang -count MyGrepWriteResult call MyGrepWriteResult(<bang>0, <q-args>)
command! -count -nargs=* -bang MyGrepReadResult call MyGrepReadResult(<bang>0, <q-args>)
command! -nargs=* FList call s:FL(<q-args>)

augroup QFix
  autocmd!
  autocmd BufWinEnter      quickfix call <SID>QFixSetup()
  autocmd BufWinLeave             * call <SID>QFixBufWinLeave()
  autocmd BufEnter                * call <SID>QFixBufEnter()
  autocmd BufLeave                * call <SID>QFixBufLeave()
  autocmd QuickFixCmdPre          * call <SID>QFixCmdPre()
  autocmd QuickFixCmdPost *vimgrep* call <SID>QFixSetVimgrepEnv()
  autocmd CursorHold              * call <SID>QFPreview()
augroup END

""""""""""""""""""""""""""""""
"内部変数
""""""""""""""""""""""""""""""
let s:debug = 0
if exists('g:fudist') && g:fudist
  let s:debug = 1
else
  "デフォルトで使用させない
  let g:QFix_HighSpeedPreview = 0
endif
let g:QFix_Win = -1
let g:QFix_DefaultUpdatetime = &updatetime

let s:QFix_PreviewWin = -1
let s:QFixPreviewfile = ''

let g:QFix_SearchPath = ''
let g:QFix_SelectedLine = 1
let g:QFix_SearchResult = []
let g:QFix_HSPSearchPath = ''
if !exists('g:QFix_UseLocationList')
  let g:QFix_UseLocationList = 0
endif

let g:QFix_Disable = 0
let g:QFix_Resize = 1
let g:QFix_PreviewEnableLock = 0
let g:QFix_PreviousPath = getcwd()
silent! function FudistPerf(title)
endfunction

function! FudistEnv()
  if has('unix')
    silent! redir @">
  else
    silent! redir @*>
  endif
  if exists('g:fudist_debug')
    echo g:fudist_debug
  endif
endfunction

let s:tempdir = fnamemodify(tempname(), ':p:h')
if !exists('g:qfixtempname')
  let g:qfixtempname = tempname()
endif

" Windowsパス正規化
let s:MSWindows = has('win95') + has('win16') + has('win32') + has('win64')
function! QFixNormalizePath(path, ...)
  let path = a:path
  " let path = expand(a:path)
  if s:MSWindows
    if a:0 " 比較しかしないならキャピタライズ
      let path = toupper(path)
    else
      " expand('~') で展開されるとドライブレターは大文字、
      " expand('c:/')ではそのままなので統一
      let path = substitute(path, '^\([a-z]\):', '\u\1:', '')
    endif
    let path = substitute(path, '\\', '/', 'g')
  endif
  return path
endfunction

"BufWinEnter
function! s:QFixSetup(...)
  let g:QFix_Win = expand('<abuf>')
  let g:QFix_HSPSearchPath = getcwd()
  if !exists('g:MyGrep_Key') && !exists('g:QFixHowm_Key')
    let g:QFix_HighSpeedPreview = 0
  endif
  let s:QFixPreviewfile = ''
  if g:QFix_PreviewEnable < 0
    let g:QFix_PreviewEnable = 1
  endif
  if g:QFix_CursorLine
    setlocal cursorline
  else
    setlocal nocursorline
  endif
  setlocal nobuflisted
  setlocal nowrap
  nnoremap <buffer> <silent> q :QFixCclose<CR>
  nnoremap <buffer> <silent> <CR>   :call <SID>BeforeJump()<CR><CR>:call <SID>AfterJump()<CR>
  nnoremap <buffer> <silent> <S-CR> :call <SID>BeforeJump()<CR>:call <SID>QFixSplit()<CR>:call <SID>AfterJump()<CR>
  if g:QFix_Edit == 'tab'
    nnoremap <buffer> <silent> <S-CR> :call <SID>BeforeJump()<CR>:call <SID>QFixEdit()<CR>:call <SID>AfterJump()<CR>
  endif
  nnoremap <buffer> <silent> <C-w>.     :ResizeOnQFix<CR>
  call QFixAltWincmdMap()

  nnoremap <buffer> <silent> i :<C-u>call <SID>QFixTogglePreview()<CR>
  nnoremap <buffer> <silent> <C-h> :<C-u>call <SID>QFixTogglePreviewMode()<CR>
  nnoremap <buffer> <silent> <C-l> :<C-u>call <SID>QFreload()<CR><C-l>
  nnoremap <buffer> <silent> I :<C-u>call QFixToggleHighlight()<CR>
  nnoremap <buffer> <silent> J :<C-u>call QFixCmd_J()<CR>
  nnoremap <buffer> <silent> A :MyGrepWriteResult<CR>
  silent! nnoremap <buffer> <unique> <silent> o :MyGrepWriteResult<CR>
  nnoremap <buffer> <silent> O :MyGrepReadResult<CR>
  nnoremap <buffer> <silent> r :<C-u>call QFixSearchStringsR()<CR>
  nnoremap <buffer> <silent> s :<C-u>call QFixSearchStrings()<CR>
  nnoremap <buffer> <silent> u :<C-u>call QFixRestoreUndo()<CR>
  nnoremap <buffer> <silent> U :<C-u>call QFixRestoreUndo('init')<CR>
  silent! nnoremap <buffer> <unique> <silent> S :<C-u>call QFixSortExec()<CR>
  nnoremap <buffer> <silent> Q :<C-u>call QFdofe('', 'normal')<CR>
  vnoremap <buffer> <silent> Q :<C-u>call QFdofe('', 'visual')<CR>
  nnoremap <buffer> <silent> dd :call <SID>QFixDelete()<CR>
  nnoremap <buffer> <silent> p :call <SID>QFixPut(0)<CR>
  nnoremap <buffer> <silent> P :call <SID>QFixPut(1)<CR>
  vnoremap <buffer> <silent> d :call <SID>QFixDelete()<CR>
  call QFixResize(g:QFix_Height)
  if exists("*QFixSetupPost")
    call QFixSetupPost()
  endif
  if g:QFix_PreviewUpdatetime
    if g:QFix_PreviewUpdatetime != &updatetime
      let g:QFix_DefaultUpdatetime = &updatetime
    endif
    exec 'setlocal updatetime='.g:QFix_PreviewUpdatetime
  endif
endfunction

function! QFixAltWincmdMap()
  nnoremap <buffer> <silent> <C-w>h     :QFixAltWincmd h<CR>
  nnoremap <buffer> <silent> <C-w>j     :QFixAltWincmd j<CR>
  nnoremap <buffer> <silent> <C-w>k     :QFixAltWincmd k<CR>
  nnoremap <buffer> <silent> <C-w>l     :QFixAltWincmd l<CR>
  nnoremap <buffer> <silent> <C-w><C-h> :QFixAltWincmd h<CR>
  nnoremap <buffer> <silent> <C-w><C-j> :QFixAltWincmd j<CR>
  nnoremap <buffer> <silent> <C-w><C-k> :QFixAltWincmd k<CR>
  nnoremap <buffer> <silent> <C-w><C-l> :QFixAltWincmd l<CR>
endfunction

command! -nargs=1 -count QFixAltWincmd call QFixAltWincmd_(count, <q-args>)
function! QFixAltWincmd_(cnt, cmd)
  call QFixPclose()
  let cnt = a:cnt == 0 ? 1 : a:cnt
  exec cnt.'wincmd '.a:cmd
  return
endfunction

let s:UndoDic = []
"Quickfixウィンドウ用アンドゥ
function! QFixSaveUndo()
  let path = g:QFix_SearchPath
  call add(s:UndoDic, [QFixGetqflist(), path])
endfunction

"Quickfixウィンドウ用アンドゥ
function! QFixRestoreUndo(...)
  if len(s:UndoDic) == 0
    return
  endif
  let idx = a:0 > 0 ? 0 : -1
  let [qf, path] = s:UndoDic[idx]
  if idx == 0
    let s:UndoDic = []
  else
    call remove(s:UndoDic, idx)
  endif
  let g:QFix_SearchPath = path
  call QFixSetqflist(qf)
  QFixCopen
endfunction

"edit
function! s:QFixEdit()
  let qfbuf = bufnr('%')
  let h = g:QFix_Height
  let qf = QFixGetqflist()
  let bufnum = qf[line('.')-1]['bufnr']
  let lnum = qf[line('.')-1]['lnum']
  let col = qf[line('.')-1]['col']
  let file = fnamemodify(bufname(bufnum), ':p')
  let file = escape(file, ' ')
  if g:QFix_TabEditMode == 1
    QFixCclose
  endif
  call QFixEditFile(file)
  if g:QFix_TabEditMode == 1
    QFixCopen
    wincmd p
  endif
  return
endfunction

"Quickfix ウィンドウPreview ON/OFF。
function! s:QFixTogglePreview()
  if g:QFix_PreviewEnable <= 0
    let g:QFix_PreviewEnable = 1
  else
    let g:QFix_PreviewEnable = 0
    if winnr('$') == 2
      wincmd o
      return
    endif
  endif
  silent! pclose!
endfunction

"BufEnter
function! s:QFixBufEnter(...)
  if &previewwindow
    if s:QFix_PreviewWin == bufnr('%')
      if winnr('$') == 1
        call QFixPclose()
      else
        let winnum = bufwinnr(g:QFix_Win)
        exec winnum . 'wincmd w'
      endif
    endif
    return
  endif
  if expand('<abuf>') == g:QFix_Win
    if g:QFix_PreviewEnable > 0
      call QFixPclose()
    endif
    wincmd p
    let g:QFix_PreviousPath = getcwd()
    wincmd p
    call QFixResize(g:QFix_Height)
    if g:QFix_PreviewUpdatetime
      if g:QFix_PreviewUpdatetime != &updatetime
        let g:QFix_DefaultUpdatetime = &updatetime
      endif
      exec 'setlocal updatetime='.g:QFix_PreviewUpdatetime
    endif
    if g:QFix_HighSpeedPreview
      let cmd = g:QFix_UseLocationList ? 'lopen' : 'copen'
      exec cmd
    endif
    call cursor(g:QFix_SelectedLine, 1)
    return
  endif
  if &updatetime != g:QFix_PreviewUpdatetime
    let g:QFix_DefaultUpdatetime = &updatetime
  endif
  if exists('b:updatetime')
    exec 'setlocal updatetime='.b:updatetime
  elseif g:QFix_DefaultUpdatetime
    exec 'setlocal updatetime='.g:QFix_DefaultUpdatetime
  endif
endfunction

"BufLeave
function! s:QFixBufLeave(...)
  if expand('<abuf>') == g:QFix_Win
    let g:QFix_SelectedLine = line('.')
    call QFixPclose()
  endif
endfunction

"BufWinLeave
function! s:QFixBufWinLeave(...)
  if expand('<abuf>') == g:QFix_Win
    let g:QFix_Win = -1
  endif
endfunction

"CursorHold
function! s:QFPreview()
  if g:QFix_PreviewEnable > 0 && &buftype == 'quickfix'
    call QFixPreview()
  endif
endfunction

"CmdPre
function! s:QFixCmdPre()
  let g:QFix_SearchPath = ''
  let g:QFix_SelectedLine = 1
  let g:QFix_Height = g:QFix_HeightDefault
  let s:UndoDic = []
endfunction

"vimgrep初期化
function! s:QFixSetVimgrepEnv(...)
  let g:QFix_SelectedLine = 1
endfunction

""""""""""""""""""""""""""""""
"copen for highspeed mode
""""""""""""""""""""""""""""""
function! s:QFreload()
  if !exists("g:loaded_MyGrep") && !exists('g:loaded_MyHowm')
    return
  endif
  let g:QFix_SearchPath = g:QFix_PreviousPath
  let g:QFix_SelectedLine = line('.')
  QFixCopen
  let g:QFix_PreviousPath = g:QFix_SearchPath
  call ResizeQFixWin(g:QFix_Height)
  call cursor(g:QFix_SelectedLine, 1)
endfunction

""""""""""""""""""""""""""""""
"Before <CR>
""""""""""""""""""""""""""""""
function! s:BeforeJump() range
  cal QFixPclose()
  call QFixCR('before')
  if count == 0
    return
  endif
  call cursor(count, 1)
endfunction
silent! function QFixCR(mode)
endfunction

""""""""""""""""""""""""""""""
"After <CR>
""""""""""""""""""""""""""""""
function! s:AfterJump(...)
  exe "normal! zz"
  if winheight(0) < g:QFix_WindowHeightMin
    exec 'resize '. g:QFix_WindowHeightMin
  endif
  call QFixCR('after')
  if g:QFix_CloseOnJump
    QFixCclose
  endif
endfunction

""""""""""""""""""""""""""""""
"split
""""""""""""""""""""""""""""""
function! s:QFixSplit()
  let qfbuf = bufnr('%')
  let h = g:QFix_Height
  let qf = QFixGetqflist()
  let bufnum = qf[line('.')-1]['bufnr']
  let lnum = qf[line('.')-1]['lnum']
  let col = qf[line('.')-1]['col']
  let file = fnamemodify(bufname(bufnum), ':p')
  let file = escape(file, ' ')
  let winnum = bufwinnr(bufnum)
  if g:QFix_CopenCmd !~ 'vertical'
    split
    exec 'edit ' . escape(file, ' #%')
  else
    if winnum == -1
      let winnr = QFixWinnr()
      if winnr < 1
      else
        exec winnr.'wincmd w'
      endif
      split
      exec 'edit ' . escape(file, ' #%')
    else
      exec winnum.'wincmd w'
      split
    endif
  endif
  call cursor(lnum, col)
  let g:QFix_Height = h
  return
endfunction

""""""""""""""""""""""""""""""
"Delete
""""""""""""""""""""""""""""""
function! s:QFixDelete() range
  let g:QFix_SelectedLine = line('.')
  let qf = QFixGetqflist()
  let l = line('.') - 1
  let g:QFixDelete = []
  for loop in range(a:firstline, a:lastline)
    call add(g:QFixDelete, remove(qf, l))
  endfor
  call QFixSetqflistOpen(qf)
  silent! exec 'normal! '.g:QFix_SelectedLine.'G'
  return
endfunction

""""""""""""""""""""""""""""""
"put
""""""""""""""""""""""""""""""
let g:QFixDelete = []
function! s:QFixPut(ofs)
  let g:QFix_SelectedLine = line('.')
  let l = line('.') - a:ofs
  let qf = QFixGetqflist()
  call extend(qf, g:QFixDelete, l)
  call QFixSetqflistOpen(qf)
  silent! exec 'normal! '.g:QFix_SelectedLine.'G'
endfunction

""""""""""""""""""""""""""""""
"リサイズ
""""""""""""""""""""""""""""""
function! QFixResize(size)
  let w = &lines - winheight(0) - &cmdheight - (&laststatus > 0 ? 1 : 0)
  if w  > 0
    exec 'resize ' . a:size
  endif
  let g:QFix_Height = a:size
endfunction

""""""""""""""""""""""""""""""
"ジャンプ後のウィンドウ動作切替
""""""""""""""""""""""""""""""
function! QFixCmd_J()
  let g:QFix_CloseOnJump = !g:QFix_CloseOnJump
  echo 'Close on jump : ' . (g:QFix_CloseOnJump? 'ON' : 'OFF')
endfunction

""""""""""""""""""""""""""""""
"ハイスピードプレビューの切替
""""""""""""""""""""""""""""""
function! s:QFixTogglePreviewMode()
  let g:QFix_HighSpeedPreview = !g:QFix_HighSpeedPreview
  echo 'Preview mode : ' . (g:QFix_HighSpeedPreview? 'HighSpeed' : 'Normal')
endfunction

""""""""""""""""""""""""""""""
"quickfixソートをトグル
""""""""""""""""""""""""""""""
function! QFixSortExec(...)
  let mes = 'Sort type? (r:reverse)+(m:mtime, n:name, t:text) : '
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
  elseif pattern == 'r'
    let g:QFix_Sort = 'reverse'
  else
    return
  endif
  if g:QFix_Sort =~ 'mtime'
    let sq = QFixSort(g:QFix_Sort)
  elseif g:QFix_Sort =~ 'name'
    let sq = QFixSort(g:QFix_Sort)
  elseif g:QFix_Sort =~ 'text'
    let sq = QFixSort(g:QFix_Sort)
  elseif g:QFix_Sort =~ 'reverse'
    let sq = QFixGetqflist()
    let sq = reverse(sq)
  endif
  call QFixSetqflistOpen(sq)
  let g:QFix_SelectedLine = 1
  MoveToQFixWin
  call cursor(1,1)
  redraw|echo 'Sorted by '.g:QFix_Sort.'.'
endfunction

""""""""""""""""""""""""""""""
"quickfixをソート
""""""""""""""""""""""""""""""
let g:QFix_Sort = ''
function! QFixSort(cmd)
  let save_qflist = QFixGetqflist()
  if a:cmd =~ 'mtime'
    let bname = ''
    let bmtime = 0
    for d in save_qflist
      if bname == bufname(d.bufnr)
        let d['mtime'] = bmtime
      else
        let d['mtime'] = getftime(bufname(d.bufnr))
      endif
      let bname  = bufname(d.bufnr)
      let bmtime = d.mtime
    endfor
    let save_qflist = sort(save_qflist, "QFixCompareTime")
  elseif a:cmd =~ 'name'
    let save_qflist = sort(save_qflist, "QFixCompareName")
  elseif a:cmd =~ 'text'
    let save_qflist = sort(save_qflist, "QFixCompareText")
  endif
  if a:cmd =~ 'r.*'
    let save_qflist = reverse(save_qflist)
  endif
  let g:QFix_SearchResult = []
  return save_qflist
endfunction

""""""""""""""""""""""""""""""
"quickfix比較
""""""""""""""""""""""""""""""
function! QFixCompareName(v1, v2)
  if a:v1.bufnr == a:v2.bufnr
    return (a:v1.lnum > a:v2.lnum?1:-1)
  endif
  return (bufname(a:v1.bufnr) . a:v1.lnum> bufname(a:v2.bufnr).a:v2.lnum?1:-1)
endfunction
function! QFixCompareTime(v1, v2)
  if a:v1.mtime == a:v2.mtime
    if a:v1.bufnr != a:v2.bufnr
      return (bufname(a:v1.bufnr) < bufname(a:v2.bufnr)?1:-1)
    endif
    return (a:v1.lnum > a:v2.lnum?1:-1)
  endif
  return (a:v1.mtime < a:v2.mtime?1:-1)
endfunction
function! QFixCompareText(v1, v2)
  if a:v1.text == a:v2.text
    return (bufname(a:v1.bufnr) < bufname(a:v2.bufnr)?1:-1)
  endif
  return (a:v1.text > a:v2.text?1:-1)
endfunction

""""""""""""""""""""""""""""""
"Quickfixウィンドウを文字列で絞り込み。
""""""""""""""""""""""""""""""
function! QFixSearchStrings(...)
  if a:0
    let _key = a:1
  else
    let _key = input('Search for pattern : ')
    if _key == ''
      return
    endif
  endif
  let qf = QFixGetqflist()
  let idx = 0
  for d in qf
    if d['text'] !~ _key && bufname(d['bufnr']) !~ _key
      call remove(qf, idx)
      continue
    endif
    let idx += 1
  endfor
  call QFixSetqflistOpen(qf)
  let @/=_key
  call s:HighlightSearchWord(1)
  MoveToQFixWin
  call QFixPclose()
endfunction

""""""""""""""""""""""""""""""
"Quickfixウィンドウを文字列で絞り込み。
""""""""""""""""""""""""""""""
function! QFixSearchStringsR(...)
  if a:0
    let _key = a:1
  else
    let _key = input('Search for pattern (exclude) : ')
    if _key == ''
      return
    endif
  endif
  let qf = QFixGetqflist()
  let idx = 0
  for d in qf
    if d['text'] =~ _key || bufname(d['bufnr']) =~ _key
      call remove(qf, idx)
      continue
    endif
    let idx += 1
  endfor
  call QFixSetqflistOpen(qf)
  let @/=_key
  call s:HighlightSearchWord(1)
  MoveToQFixWin
  call QFixPclose()
endfunction

""""""""""""""""""""""""""""""
" searchWord にしたがって、ハイライトを設定する
" searchWordType を見て searchWord の解釈を変える
"  0: 固定文字列
"  1: 正規表現 ( grep )
"  2: 正規表現 ( Vim )
""""""""""""""""""""""""""""""
function! s:HighlightSearchWord(searchWordType)
  let searchWord = @/
  let searchWordType = a:searchWordType
  if searchWord == ''
    return
  endif
  if searchWordType == 0
    let pat = '\c\V' . escape(searchWord, '\')
  elseif searchWordType == 1
    let pat = '\c\v' . escape(searchWord, '=~@%()[]+|')
  elseif searchWordType == 2
    let pat = searchWord
  else
    return
  endif
  silent! syntax clear QFixSearchWord
  hi QFixSearchWord ctermfg=Red ctermbg=Grey guifg=Red guibg=bg
  silent! exec 'syntax match QFixSearchWord display "' . escape(pat, '"') . '"'
endfunction

""""""""""""""""""""""""""""""
"ハイライト切替
""""""""""""""""""""""""""""""
function! QFixToggleHighlight()
  let g:QFix_PreviewFtypeHighlight = !g:QFix_PreviewFtypeHighlight
  let s:QFixPreviewfile = ''
  echo 'FileType syntax : ' . (g:QFix_PreviewFtypeHighlight? 'ON' : 'OFF')
endfunction

""""""""""""""""""""""""""""""
"Quickfixウィンドウを開く
""""""""""""""""""""""""""""""
function! OpenQFixWin(...)
  QFixCopen
  if a:0 && a:1 > 1
    let g:QFix_Height = a:1
  endif
  call QFixResize(g:QFix_Height)
endfunction

""""""""""""""""""""""""""""""
"Quickfixウィンドウへ移動
""""""""""""""""""""""""""""""
function! MoveToQFixWin(...)
  let winnum = bufwinnr(g:QFix_Win)
  if winnum == -1
    QFixCopen
  else
    if winnum != winnr()
      exec winnum . 'wincmd w'
    endif
  endif
  if a:0 && a:1 > 1
    let g:QFix_Height = a:1
    call QFixResize(g:QFix_Height)
  endif
endfunction

""""""""""""""""""""""""""""""
"サイズを変更する
""""""""""""""""""""""""""""""
function! ResizeQFixWin(...)
  if &buftype != 'quickfix'
    return
  endif
  let size = g:QFix_HeightDefault
  if a:0 && a:1 > 1
    let size = a:1
  endif
  let g:QFix_Height = size
  MoveToQFixWin
  call QFixResize(g:QFix_Height)
  let g:QFix_Height = size
  silent! wincmd p
endfunction

""""""""""""""""""""""""""""""
"サイズを変更する
""""""""""""""""""""""""""""""
function! ResizeOnQFix(...)
  if &buftype != 'quickfix'
    return
  endif
  let size = g:QFix_HeightDefault
  if count > 1
    let size = a:1
  endif
  let g:QFix_Height = size
  call QFixResize(g:QFix_Height)
endfunction

""""""""""""""""""""""""""""""
"Quickfixウィンドウのトグル
""""""""""""""""""""""""""""""
function! ToggleQFixWin(...)
  if a:0 && a:1 > 1
    let g:QFix_Height = a:1
    call QFixResize(g:QFix_Height)
  endif
  if bufexists(g:QFix_Win+0) == 0 || bufwinnr(g:QFix_Win) == -1
    QFixCopen
  else
    QFixCclose
  endif
endfunction

""""""""""""""""""""""""""""""
"copen代替
""""""""""""""""""""""""""""""
function! QFixCopen(cmd, mode)
  if g:QFix_Disable
    return
  endif
  if a:cmd == ''
    let cmd = g:QFix_CopenCmd
  else
    let cmd = a:cmd
  endif
  let cmd = cmd . (g:QFix_UseLocationList ? ' l' : ' c')
  let spath = g:QFix_SearchPath
  let spath = expand(spath)
  let opath = getcwd()
  let qf = QFixGetqflist()
  let idx = len(qf)-1
  if idx < 0
    let g:QFix_SearchPath = ''
    let g:QFix_SelectedLine = 1
  endif
  call QFixPclose()
  let saved_pe = g:QFix_PreviewEnable
  let g:QFix_PreviewEnable = 0
  silent! exec cmd . 'open ' . g:QFix_Height
  if spath != ''
    silent! exec 'lchdir ' . escape(spath, ' ')
    silent! exec cmd .'open ' . g:QFix_Height
  endif
  if spath != '' && a:mode == 0
    "登録されている半分のファイルが QFix_SearchPath以下になかったらクリア
    let none = 0
    let cpath = g:QFix_SearchPath
    let cpath = expand(cpath)
    let ppath = '|'
    let none = idx / 2
    for n in qf
      let file = bufname(n['bufnr'])
      let path = fnamemodify(file, ':h')
      if path == ppath
        let none -= 1
      else
        let file = printf("%s/%s", cpath, file)
        if filereadable(file)
          let none -= 1
          let ppath = path
        endif
      endif
      if none < 1
        break
      endif
    endfor
    if none > 0
      let g:QFix_SearchPath = ''
      let g:QFix_SelectedLine = 1
      silent! exec 'lchdir ' . escape(opath, ' ')
      silent! exec cmd .'open ' . g:QFix_Height
    endif
  endif
  let g:QFix_Win = bufnr('%')
  if g:QFix_Width > 0
    exe "normal! ".g:QFix_Width."\<C-W>|"
  endif
  let g:QFix_PreviewEnable = saved_pe
  let &winfixheight = g:QFix_Copen_winfixheight
  let &winfixwidth  = g:QFix_Copen_winfixwidth
  silent! exec 'normal! '.g:QFix_SelectedLine.'G'
endfunction

""""""""""""""""""""""""""""""
"cclose代替
""""""""""""""""""""""""""""""
function! QFixCclose()
  if g:QFix_Disable
    return
  endif
  if g:QFix_UseLocationList
    silent! lclose
  else
    silent! cclose
  endif
endfunction

""""""""""""""""""""""""""""""
"setqflist代替
"""""""""""""""""""""""""""""
function! QFixSetqflist(sq, ...)
  let cmd = 'a:sq'. (a:0 == 0 ? '' : ",'".a:1."'")
  if g:QFix_UseLocationList
    exec 'call setloclist(0, '.cmd.')'
  else
    exec 'call setqflist('.cmd.')'
  endif
endfunction

function! QFixSetqflistOpen(...)
  if a:0
    let qf = a:1
  else
    let qf = QFixGetqflist()
  endif
  call QFixSaveUndo()
  call QFixSetqflist(qf)
  QFixCopen
  return qf
endfunction

""""""""""""""""""""""""""""""
"getqflist代替
""""""""""""""""""""""""""""""
function! QFixGetqflist()
  if g:QFix_UseLocationList
    return getloclist(0)
  else
    return getqflist()
  endif
endfunction

""""""""""""""""""""""""""""""
"pclose代替
""""""""""""""""""""""""""""""
function! QFixPclose()
  if g:QFix_Disable
    return
  endif
  if g:QFix_PreviewEnable < 1
    return
  endif
  if g:QFix_PreviewEnableLock == 1
    return
  endif
  let s:UseQFixPreviewOpen = 0
  let h = g:QFix_Height
  if &buftype == 'quickfix' && g:QFix_HeightFixMode == 0 && g:QFix_Resize > 0
    let h = winheight(0)
  endif
  if winnr('$') == 2 && tabpagenr('$') > 1 && g:QFix_PreviewEnable
  elseif winnr('$') == 1 && tabpagenr('$') > 1 && &previewwindow
    tabclose
  else
    let saved_winfixheight = &winfixheight
    let saved_winfixwidth  = &winfixwidth
    setlocal nowinfixheight
    setlocal nowinfixwidth
    silent! pclose!
    let &winfixheight = saved_winfixheight
    let &winfixwidth  = saved_winfixwidth
  endif
  if &buftype == 'quickfix'
    call QFixResize(h)
    let g:QFix_Height = h
  endif
  let s:UseQFixPreviewOpen = 1
endfunction

""""""""""""""""""""""""""""""
"Quickfixプレビュー。
""""""""""""""""""""""""""""""
let s:UseQFixPreviewOpen = 1

function! QFixPreview()
  if g:QFix_PreviewEnable < 1
    return
  endif
  let file = ''
  if g:QFix_HighSpeedPreview
    let gfile = QFixGetHSP('file')
    let lnum = QFixGetHSP('lnum')
    let file = fnamemodify(gfile, ':p')
    if !filereadable(file)
      let file = ''
    endif
  endif
  if file == ''
    let qf = QFixGetqflist()
    let cline = line('.')
    if cline > len(qf)
      return
    endif
    let cline -= 1
    let buf = qf[cline]['bufnr']
    let lnum = qf[cline]['lnum']
    if buf == 0
      let file = ''
    elseif bufexists(buf + 0) != 0
      let file = bufname(buf)
    else
      let file = qf[cline]['filename']
    endif
    let file = fnamemodify(file, ':p')
  endif
  if s:UseQFixPreviewOpen
    call QFixPreviewOpen(file, lnum)
  endif
  return
endfunction

""""""""""""""""""""""""""""""
"Quickfixプレビュー本体。
""""""""""""""""""""""""""""""
function! QFixPreviewOpen(file, line, ...)
  if g:QFix_Disable
    return
  endif
  let file = a:file
  let file = substitute(file, '\s$', '', '')
  if s:QFixPreviewfile == file
    silent! wincmd P
    if &previewwindow
      if a:line == line('.')
        silent! wincmd p
        return
      endif
      silent! exec 'normal '. a:line .'Gzz'
      if g:QFix_PreviewCursorLine
        setlocal cursorline
      else
        setlocal nocursorline
      endif
      silent! wincmd p
      return
    endif
  endif
  let s:QFixPreviewfile = file
  if &previewwindow
  else
    let saved_winfixheight = &winfixheight
    let saved_winfixwidth  = &winfixwidth
    " setlocal winfixheight
    " setlocal winfixwidth
    silent! exec 'silent! '.g:QFix_PreviewOpenCmd.' pedit! '.s:tempdir.'/'.g:QFix_PreviewName
    let &winfixheight = saved_winfixheight
    let &winfixwidth  = saved_winfixwidth
  endif
  silent! wincmd P
  let s:QFix_PreviewWin = bufnr('%')
  " set options
  setlocal nobuflisted
  setlocal noswapfile
  setlocal buftype=nofile
  setlocal bufhidden=delete
  let &winfixheight = g:QFix_Preview_winfixheight
  let &winfixwidth  = g:QFix_Preview_winfixwidth
  if g:QFix_PreviewWidth > 0
    exe "normal! ".g:QFix_PreviewWidth."\<C-W>|"
  endif
  if exists('g:QFix_PreviewHeight')
    exec 'resize '.g:QFix_PreviewHeight
  endif
  setlocal modifiable
  silent! %delete _
  if g:QFix_PreviewExclude != '' && file =~ g:QFix_PreviewExclude
    setlocal nomodifiable
    silent! wincmd p
    return
  endif

  let prevPath = escape(getcwd(), ' ')
  if g:QFix_SearchPath != ''
    silent! exec 'lchdir ' . escape(g:QFix_SearchPath, ' ')
  endif

  if g:QFix_PreviewFtypeHighlight != 0
    call s:QFixFtype_(file)
    "BufReadの副作用への安全策
    silent! %delete _
  else
    silent! call s:HighlightSearchWord(1)
  endif
  if bufloaded(file) "バッファが存在する場合
    let glist = getbufline(file, 1,'$')
    call setline(1, glist)
  else
    let cmd = '-r '
    let file = substitute(file, '\\', '/', 'g')
    let cmd = cmd . QFixPreviewReadOpt(file)
    silent! exec cmd.' '.escape(file, ' %#')
    silent! $delete _
  endif
  silent! exec 'normal! '. a:line .'Gzz'
  if g:QFix_PreviewCursorLine
    setlocal cursorline
  else
    setlocal nocursorline
  endif
  setlocal nomodifiable
  silent! exec 'lchdir ' . prevPath
  silent! wincmd p
endfunction

" プレビューのエンコーディング強制オプション
silent! function QFixPreviewReadOpt(file)
  return ''
endfunction

"filetypeを返す
"プレビュー用ファイルタイプ指定
function! s:QFixFtype_(file)
  if exists('g:QFix_PreviewFtype')
    let suffix = fnamemodify(a:file, ':e')
    silent! let pft = g:QFix_PreviewFtype[suffix]
    if exists('pft')
      silent! exec 'setlocal filetype='.pft
      return pft
    endif
  endif
  let file = fnamemodify(a:file, ':t')
  exec 'silent! doau BufNewFile '.file
  "for QFixHowm
  call QFixFtype(a:file)
  return ''
endfunction

silent! function QFixFtype(file)
endfunction

""""""""""""""""""""""""""""""
"quickfixからファイル名を取り出し。
""""""""""""""""""""""""""""""
function! QFixGet(cmd, ...)
  let desc = a:cmd
  if a:cmd == 'file'
    let desc = 'filename'
  endif
  let qf = QFixGetqflist()
  let cline = line('.')
  if a:0 > 0
    let cline = a:1
  endif
  if cline > len(qf)
    return
  endif
  let cline -= 1
  if a:cmd == 'file'
    let buf = qf[cline]['bufnr']
    let file = fnamemodify(bufname(buf), ':p')
    let file = substitute(file, '\\', '/', 'g')
    return file
  endif
  if a:cmd == 'lnum'
    return qf[cline]['lnum']
  endif
  let cnum  = str2nr(substitute(matchstr(line, ' [0-9]\+|'), '|', '', ''))
  if a:cmd == 'cnum'
    return qf[cline]['col']
  endif
  return qf[cline]['text']
endfunction

""""""""""""""""""""""""""""""
"quickfixからファイル名を取り出し(ハイスピードプレビュー用)
""""""""""""""""""""""""""""""
function! QFixGetHSP(cmd, ...)
  let line  = getline('.')
  if a:0
    let line  = a:1
  endif
  let fname = substitute(matchstr(line, '^[^|]*'), '\\', '/', 'g')
  let line  = matchstr(line, '^[^|]*|.*|')
  let lnum  = str2nr(substitute(matchstr(line, '|[0-9]\+'), '|', '', ''))
  if a:cmd == 'file'
    let fname = substitute(fname, '\\', '/', 'g')
    return fname
  endif
  if a:cmd == 'lnum'
    return lnum
  endif
  let cnum  = str2nr(substitute(matchstr(line, ' [0-9]\+|'), '|', '', ''))
  if a:cmd == 'cnum'
    return cnum
  endif
  return substitute(line, '^\(.*\d\+\s*|\)\{-1}', '', '') == e.title
endfunction

""""""""""""""""""""""""""""""
"ファイルが存在するので開く
"追加パラメータが'split'ならスプリットで開く
""""""""""""""""""""""""""""""
function! QFixEditFile(file, ...)
  let file = fnamemodify(a:file, ':p')
  let file = substitute(file, '\\', '/', 'g')
  let mode = a:0 > 0 ? a:1 : ''
  let opt  = a:0 > 1 ? a:2 : ''
  let winnum = bufwinnr(file)
  if winnum == winnr()
    return
  endif
  if winnum != -1
    exec winnum . 'wincmd w'
    return
  endif

  let winnr = QFixWinnr()
  if winnr < 1 || mode == 'split'
    split
  else
    exec winnr.'wincmd w'
  endif

  let dir = fnamemodify(file, ':h')
  if isdirectory(dir) == 0
    call mkdir(dir, 'p')
  endif
  exec g:QFix_Edit.'edit ' . opt . escape(file, ' #%')
endfunction

""""""""""""""""""""""""""""""
"通常バッファを返す
"通常バッファがない場合は-1を返す
""""""""""""""""""""""""""""""
"ファイルを開く時、編集されているバッファを使用してhiddenにする。
if !exists('g:QFix_HiddenModifiedBuffer')
  let g:QFix_HiddenModifiedBuffer = 1
endif

function! QFixWinnr()
  let g:QFix_PreviewEnableLock = 1
  let pwin = winnr()
  let max = winnr('$')
  let hidden = &hidden
  let w = -1
  for i in range(1, max)
    exec i . 'wincmd w'
    if &buftype == '' && &previewwindow == 0
      if &modified == 0
        let w = i
        break
      endif
      if g:QFix_UseModifiedWindow
        let w = i
      endif
    endif
  endfor
  exec pwin.'wincmd w'
  let g:QFix_PreviewEnableLock = 0
  return w
endfunction

""""""""""""""""""""""""""""""
"grepした結果を保存する
""""""""""""""""""""""""""""""
let s:result = []
let s:resulttime = 0
let s:resultpath = ''
"現在登録されているGrep結果を保存するファイル
if !exists('g:MyGrep_Resultfile')
  let g:MyGrep_Resultfile = '~/.qfgrep.txt'
endif

function! MyGrepWriteResult(mode, file) range
  let file = expand(g:MyGrep_Resultfile)
  if count
    let file = substitute(file, '\(\.[^.]\+$\)', count.'\1', '')
  endif
  if a:file != ''
    let file = a:file
  endif
  " let file = fnamemodify(file, ':p')
  let firstline = 1
  let cnt = line('$')-1
  let s:result = []
  "let dir = g:QFix_SearchPath
  let dir = getcwd()
  call add(s:result, dir . '|'.line('.').'|')
  for d in range(firstline, firstline+cnt)
    let text = getline(d)
    if text == ''
      continue
    endif
    let fname = substitute(text, '|.*$', '', '')
    let fname = fnamemodify(fname, ':p')
    let text = fname . matchstr(text, '|.*')
    let s:result = add(s:result, text)
  endfor
  call writefile(s:result, file)
  call remove(s:result, 0)
  let s:resultpath = g:QFix_SearchPath
  let s:resulttime = getftime(file)
  redraw|echo 'QFixGrep : WriteResult "'.file.'"'
endfunction

""""""""""""""""""""""""""""""
"grepした結果を読み込む
""""""""""""""""""""""""""""""
function! MyGrepReadResult(readflag, ...)
  let file = expand(g:MyGrep_Resultfile)
  if a:0 > 1
    let file = a:2
  endif
  if count
    let file = substitute(file, '\(\.[^.]\+$\)', count.'\1', '')
  endif
  if a:readflag
    let s:resulttime = 0
  endif
  let s:resulttime = 0
  if !filereadable(file)
    return
  endif
  if s:resulttime != getftime(file)
    let s:result = readfile(file)
    let s:resultpath = substitute(s:result[0], '|.*$', '','')
    let g:QFix_SearchPath = s:resultpath
    let g:QFix_SelectedLine = matchstr(s:result[0], '|\d\+')
    let g:QFix_SelectedLine = substitute(g:QFix_SelectedLine, '|', '','g')
    call remove(s:result, 0)
    let s:resulttime = getftime(file)
  endif
  redraw|echo 'QFixGrep : Loading...'
  let prevPath = escape(getcwd(), ' ')
  let saved_efm = &efm
"  set errorformat=%f\|%\\s%#%l\|%m
  if exists('g:MyGrep_errorformat')
    let &errorformat=g:MyGrep_errorformat
  endif
  cgetexpr s:result
  let &errorformat = saved_efm
  redraw|echo 'QFixGrep : ReadResult "'.file.'"'

  let g:QFix_SelectedLine = 1
  QFixCopen
  MoveToQFixWin
endfunction

""""""""""""""""""""""""""""""
"ファイルリストを作成して登録
""""""""""""""""""""""""""""""
function! s:FL(file)
  let file = a:file
  if file == ''
    let file = '*'
  endif
  if file !~ '[*.]$'
    let file = file.'/*'
  endif
  let path = substitute(a:file, '[*./\\]\+$', '', '')
  if path == ''
    let path = expand("%:p:h")
  endif
  if !isdirectory(path)
    echoe '"' . path.'" does not exist!'
    return
  endif
  let list = s:GetFileList(path, file)
  call s:addtitle(path, list)
  call s:ShowFileList(path, list)
endfunction
"ファイルリストの作成
function! s:GetFileList(path, file)
  let files = split(glob(a:file), '\n')
  let list = []
  let lnum = 1
  let text = ''
  for n in files
    if !isdirectory(n)
      let usefile = {'filename':n, 'lnum':lnum, 'text':text}
      call insert(list, usefile)
    endif
  endfor
  return list
endfunction
"登録
function! s:ShowFileList(path, list)
  let prevPath = escape(getcwd(), ' ')
  let g:QFix_SelectedLine = 1
  let g:QFix_SearchResult = []
  let g:QFix_SearchPath = a:path
  QFixCclose
  call QFixSetqflist(a:list)
  QFixCopen
endfunction
"サマリー
function! s:addtitle(path, list)
  let prevPath = escape(getcwd(), ' ')
  let h = g:QFix_Height
  silent! exec 'split '
  silent! exec 'silent! edit '.g:qfixtempname
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  let prevfname = ''
  for d in a:list
    let file = d.filename
    if g:QFix_PreviewExclude != '' && file =~ g:QFix_PreviewExclude
      continue
    endif
    if !filereadable(file)
      continue
    endif
    if prevfname != file
      silent! %delete _
      let tmpfile = escape(file, ' #%')
      silent! exec '0read '.tmpfile
      silent! $delete _
    endif
    let prevfname = file
    call cursor(d.lnum, 1)
    for i in range(1, line('$'))
      let str = getline(i)
      if str != ''
        let d.text = str
        let d.lnum = i
        break
      endif
    endfor
  endfor
  silent! exec 'silent! edit '.g:qfixtempname
  setlocal buftype=nofile
  silent! bd!
  let g:QFix_Height = h
endfunction

""""""""""""""""""""""""""""""
"Quickfixリストに対してコマンド実行
""""""""""""""""""""""""""""""
function! QFdo(cmd, cnt)
  let cmd = a:cmd
  if a:cmd == ''
    let cmd = input('command? ', s:prevcmd)
  endif
  if cmd == ''
    return
  endif
  call QFdoexec(cmd, a:firstline, a:cnt)
endfunction

let s:prevcmd=''
function! QFdofe(cmd, mode) range
  let cmd = a:cmd
  if a:cmd == ''
    let cmd = input('command? ', s:prevcmd)
  endif
  if cmd == ''
    return
  endif
  let s:prevcmd = cmd
  let fline = a:firstline
  let lline = a:lastline
  let cnt = a:lastline-a:firstline
  if a:firstline == a:lastline && a:mode == 'normal'
    let fline = 1
    let lline = 0
  endif
  call QFdoexec(cmd, fline, lline)
endfunction

function! QFdoexec(cmd, fline, lline)
  let qf = QFixGetqflist()
  if len(qf) == 0
    echohl ErrorMsg
    redraw|echom 'QFdo : nolist!'
    echohl None
    return
  endif
  let fline = a:fline
  let lline = a:lline
  if lline == 0
    let lline = len(qf)
  endif
  let cnt = lline - fline + 1
  let cmd = a:cmd
  if cmd =~ '^:'
    let cmd = substitute(cmd, '^:', '', '')
  else
    let cmd = 'normal! '.cmd
  endif
  let mru = 0
  silent! let mru = g:QFixHowm_UseMRU
  let g:QFixHowm_UseMRU = 0
  exec 'cr '.fline
  for l in range(cnt)
    silent! exec cmd
    silent! cn
  endfor
  exec 'cr '.fline
  let g:QFixHowm_UseMRU = mru
endfunction

""""""""""""""""""""""""""""""
"mru.vim対策
"nnoremap <silent> gkm :let QFix_Resize = 0<CR>:MRU<CR>
"MRU起動前にQFix_Resizeを0にして下さい
""""""""""""""""""""""""""""""
augroup QFixResize
  au!
  au BufWinEnter __MRU_Files__ let g:QFix_Resize = 0
  au BufWinLeave __MRU_Files__ let g:QFix_Resize = -1
  au BufEnter * call QFixResizeBufEnter()
augroup END

function! QFixResizeBufEnter()
  if g:QFix_Resize == -1
    call ResizeQFixWin(g:QFix_Height)
    let g:QFix_Resize = 1
  endif
endfunction

function! QFixExec(cmd)
  let g:QFix_Resize = 0
  exec a:cmd
endfunction

