"=============================================================================
"    Description: MRU entry list (with QFixPreview)
"         Author: fuenor <fuenor@gmail.com>
"                 http://sites.google.com/site/fudist/Home  (Japanese)
"  Last Modified: 2011-08-29 06:34
"=============================================================================
let s:Version = 1.07
scriptencoding utf-8

"What Is This:
"  Make mru (entry) list.
"
"Install:
"  Put this file into your runtime directory.
"    > vimfiles/plugin or .vim/plugin
"
"Usage:
" .vimrc
" let QFixMRU_Filename = '~/.qfixmru'
"
" " directory for relative path
" let QFixMRU_RootDir  = '~/mruroot'
"
" :QFixMRU {basedir}
" :QFixMRU all
"=============================================================================
if exists('disable_QFixMRU') && disable_QFixMRU == 1
  finish
endif
if exists('g:QFixMRU_version') && g:QFixMRU_version < s:Version
  unlet loaded_QFixMRU
endif
if exists("loaded_QFixMRU") && !exists('fudist')
  finish
endif
if v:version < 700 || &cp || !has('quickfix')
  finish
endif
let loaded_QFixMRU = 1
let g:QFixMRU_version = s:Version
let g:QFixMRU_Disable = 0

"=============================================================================
" vars
"=============================================================================
" QFixMRU_RootDir が存在すると、相対パス部分を
" QFixMRU_RootDirを基準とした絶対パスに置換して読み込み
" 以下と同等の処理
" call QFixMRURead(g:QFixMRU_Filename, g:QFixMRU_RootDir)
"
" 保存時の相対パス
" QFixMRU_BaseDirをMRUファイル読込後に書き換えると
" QFixMRU_BaseDirを基準とする相対パスで保存される。

" MRUファイル
if !exists('g:QFixMRU_Filename')
  let g:QFixMRU_Filename = '~/.qfixmru'
endif
" MRU保存ファイルのファイルエンコーディング
if !exists('g:QFixMRU_fileencoding')
  let g:QFixMRU_fileencoding = 'utf-8'
endif
" MRUをフルパスで保存する
if !exists('g:QFixMRU_FullPathMode')
  let g:QFixMRU_FullPathMode = 0
endif
" MRU最大表示数
if !exists('g:QFixMRU_Entries')
  let g:QFixMRU_Entries = 20
endif
" MRU最大登録数
if !exists('g:QFixMRU_EntryMax')
  let g:QFixMRU_EntryMax = 300
endif
" 基準dir以下のエントリのみを表示
if !exists('g:QFixMRU_DirMode')
  let g:QFixMRU_DirMode = 1
endif
" MRUに登録しないファイル名
if !exists('g:QFixMRU_IgnoreNFile')
  let g:QFixMRU_IgnoreNFile = '//'
endif
" MRUに登録しないファイル名
if !exists('g:QFixMRU_IgnoreFile')
  let g:QFixMRU_IgnoreFile = '^$'
endif
" MRUに登録しないエントリタイトル
if !exists('g:QFixMRU_IgnoreTitle')
  let g:QFixMRU_IgnoreTitle = '^$'
endif
" MRUに登録するファイル名
if !exists('g:QFixMRU_RegisterFile')
  " let g:QFixMRU_RegisterFile = '\.\(howm\|txt\|mkd\|wiki\)$'
  let g:QFixMRU_RegisterFile = ''
endif
" MRUタイトルの正規表現リスト
if !exists('g:QFixMRU_Title')
  " let g:QFixMRU_Title = {'mkd' : '^#',  'wiki' : '^='}
  let g:QFixMRU_Title = {}
endif
" 任意の拡張子のタイトルを追加設定
" 拡張子hogeのファイルの「行頭のfuga」をタイトルと見なす設定
" function! QFixMRUAddEntryRegxp()
"   let g:QFixMRU_Title['hoge']       = '^fuga'
"   let g:QFixMRU_Title['hoge_regxp'] = '^fuga'
" endfunction
" QFixMRUGetTitleRegxp(hoge)で取得される正規表現は hoge_regxpが優先される。
" 外部grepとvimgrepで正規表現が異なる場合のみ (suffix)_regxpを設定する。

"=============================================================================
" 内部変数
"=============================================================================
if !exists('g:QFixMRU_BaseDir')
  let g:QFixMRU_BaseDir = '~'
endif
let g:QFixMRU_state = 0
let s:MruDic = []
if !exists('g:qfixtempname')
  let g:qfixtempname = tempname()
endif
let s:tempfile = g:qfixtempname

let s:debug = 0
if exists('g:fudist') && g:fudist
  let s:debug = 1
endif

command! -count -nargs=* QFixMRU call QFixMRU(<f-args>)
command! -nargs=* QFixMRUread call QFixMRURead(<f-args>)
command! -nargs=* QFixMRURead call QFixMRURead(<f-args>)

augroup QFixMRU
  autocmd!
  autocmd VimEnter                    * call <SID>VimEnter()
  autocmd VimLeave                    * call <SID>VimLeave()
  autocmd BufRead,BufNewFile,BufEnter * call <SID>BufEnter()
  autocmd BufLeave                    * call <SID>BufLeave()
  autocmd BufWritePost                * call <SID>BufWritePost()
  autocmd CursorMoved                 * call <SID>CursorMoved()
augroup END

" MRU表示
function! QFixMRU(...)
  if g:QFixMRU_state == 0
    call QFixMRURead()
    call QFixMRUWrite(0)
  endif
  if len(s:MruDic) == 0
    echohl ErrorMsg
    redraw|echo 'QFixMRU: MRU is empty!'
    echohl None
    return
  endif
  let dirmode = g:QFixMRU_DirMode
  let basedir = expand('%:p:h')
  let entries = g:QFixMRU_Entries
  if count
    let entries = count
  endif
  for index in range (1, a:0)
    if a:{index} == '^\s*$'
    elseif a:{index} =~ '^clear$'
      call QFixMRUClear()
    elseif a:{index} =~ '^all$'
      let dirmode = 0
      let entries = 0
      let basedir = g:QFixMRU_BaseDir
    elseif a:{index} !~ '^/:'
      let basedir = a:{index}
    endif
  endfor
  let dir = dirmode ? basedir : ''

  call QFixMRUWrite(0)
  call QFixMRUOpenPre(s:MruDic, entries, dir)
  let sq = QFixMRUPrecheck(s:MruDic, entries, dir)
  call QFixMRUOpen(sq, basedir)
  redraw | echo ''
endfunction

function! QFixMRUPrecheck(sq, entries, dir)
  let osq = a:sq
  let dir = a:dir
  let entries = a:entries
  if entries == 0
    let entries = len(osq) + 1
  endif
  let dirmode = (dir != '')

  if g:QFixMRU_IgnoreFile != ''
    let exclude = g:QFixMRU_IgnoreFile
    call filter(osq, "v:val['filename'] !~ '".exclude."'")
  endif
  if g:QFixMRU_IgnoreTitle != ''
    let exclude = g:QFixMRU_IgnoreTitle
    call filter(osq, "v:val['text'] !~ '".exclude."'")
  endif

  let sq = deepcopy(osq)
  if dirmode
    let dir = QFixNormalizePath(fnamemodify(dir, ':p'))
    call filter(sq, "stridx(v:val['filename'], dir)==0")
  endif

  " 高速化のためtempバッファ使用
  silent! exec 'split '
  silent! exec 'silent! edit '.s:tempfile
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted

  let s:prevfname = ''
  let mru = []
  let mruidx = 0
  for d in sq
    let file = d['filename']
    if !bufexists(file) && !filereadable(file)
      call filter(osq, "match(v:val['filename'], file)")
      continue
    endif
    let tpattern = ''
    silent! let tpattern = g:QFixMRU_Title[tolower(fnamemodify(file, ':e'))]
    if tpattern != ''
      let [min, max] = s:QFixMRUEntryRange(file, d['lnum'], d['text'], tpattern)
      if min == 0
        call remove(sq, mruidx)
        continue
      endif
      if d['text'] !~ '^'.tpattern.'\s*$'
        if d['lnum'] < min || d['lnum'] > max
          let d['lnum'] = min
        endif
      endif
    endif
    call add(mru, d)
    let entries -= 1
    if entries == 0
      break
    endif
    let mruidx += 1
  endfor
  silent! bd

  return mru
endfunction

" Windowsパス正規化
let s:MSWindows = has('win95') + has('win16') + has('win32') + has('win64')
silent! function QFixNormalizePath(path, ...)
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

function! s:QFixMRUEntryRange(file, lnum, title, tpattern)
  let lnum = a:lnum
  let tpattern = a:tpattern
  if s:prevfname != a:file
    silent! %delete _
    let mfile = a:file
    if bufloaded(mfile)
      let glist = getbufline(mfile, 1, '$')
      call setline(1, glist)
    else
      call s:read(mfile)
    endif
  endif
  let s:prevfname = a:file
  call cursor(lnum, 1)
  let title = escape(a:title, '[].*~\#')
  let min = search(title, 'cbW')
  if min == 0
    let min = search(title, 'cW')
  endif
  let max = search(tpattern, 'W') - 1
  if max < 1
    let max = line('$')
  endif
  return [min, max]
endfunction

function! s:read(mfile)
  let mfile = a:mfile
  let cmd = '0read '
  let opt = ''
  let cmd = cmd . QFixPreviewReadOpt(mfile)
  silent! exec cmd . ' ' . opt .' '. escape(mfile, ' #%')
  silent! $delete _
endfunction

" プレビューのエンコーディング強制オプション
silent! function QFixPreviewReadOpt(file)
  return ''
endfunction

" MRU表示前処理
silent! function QFixMRUOpenPre(sq, entries, dir)
  if exists('g:loaded_QFixWin')
    call QFixPclose()
  endif
endfunction

" MRU表示処理(Quickfixウィンドウを開く)
silent! function QFixMRUOpen(sq, basedir)
  let sq = a:sq

  if exists('g:loaded_QFixWin')
    let g:QFix_SearchPath = a:basedir
    call QFixSetqflist(sq)
    call QFixCopen('', 1)
    call cursor(1, 1)
  else
    silent! call setqflist(sq)
    silent! copen
  endif
endfunction

" MRU read
" call QFixMRURead({file}, {substitute_dir})
" call QFixMRURead({file}, {substitute_dir}, {'/merge'})
function! QFixMRURead(...)
  let g:QFixMRU_state = 1
  let file = g:QFixMRU_Filename
  let basedir = ''
  let merge = 0
  if g:QFixMRU_state == 0
    let g:QFixMRU_state = 1
    let merge = 1
  endif
  for index in range (1, a:0)
    if a:{index} =~ '^/merge$'
      let merge = 1
    elseif index == 1
      let file = a:{index}
    elseif index == 2
      let basedir = a:{index}
    endif
  endfor
  if basedir == '' && exists('g:QFixMRU_RootDir')
    let basedir = g:QFixMRU_RootDir
  endif
  let g:QFixMRU_Filename = file
  let file = expand(file)
  if !filereadable(file)
    if merge == 0
      let s:MruDic = []
    endif
    if basedir != ''
      let g:QFixMRU_BaseDir = basedir
    endif
    return
  endif
  " echo 'QFixMRU : Now loading...'
  let mdic = readfile(file)
  let from = g:QFixMRU_fileencoding
  let to   = &enc
  let d = substitute(iconv(mdic[0], from, to), '\\', '/', 'g')
  let d = substitute(d, '|.*', '', '')
  if isdirectory(expand(d))
    let g:QFixMRU_BaseDir = d
    silent! call remove(mdic, 0)
  elseif !isdirectory(expand(g:QFixMRU_BaseDir)) && !isdirectory(expand(basedir))
    let dir = basedir != '' ? basedir : g:QFixMRU_BaseDir
    let mes = printf("!!! QFixMRU : (%s) is not directory.\nContinue anyway?", dir)
    let choice = confirm(mes, "&OK\n&Cancel", 2, "W")
    if choice != 1
      return
    endif
    let g:QFixMRU_BaseDir = '~'
  endif
  if merge
    let mergedic = deepcopy(s:MruDic)
  endif
  let prevPath = escape(getcwd(), ' ')
  silent! exec 'lchdir ' . escape(expand(g:QFixMRU_BaseDir), ' ')
  silent! exec 'lchdir ' . escape(expand(basedir), ' ')
  let bpath = getcwd()
  let bpath = substitute(bpath, '\\', '/', 'g')
  let s:MruDic = []
  for d in mdic
    let d = iconv(d, from, to)
    let idx = match(d, '|')
    let file = strpart(d, 0, idx)
    " CAUTION:パフォーマンス優先
    " let file = fnamemodify(file, ':p')
    if !g:QFixMRU_FullPathMode
      if filereadable(bpath.'/'.file)
        let file = bpath.'/'.file
      elseif !filereadable(file)
        continue
      endif
    elseif !filereadable(file)
      continue
    endif
    let file = substitute(file, '\\', '/', 'g')
    let d = strpart(d, idx+1)
    let idx = match(d, '|')
    let lnum = strpart(d, 0, idx)
    let d = strpart(d, idx+1)
    let text = d
    let usefile = {'filename':file, 'lnum':lnum, 'text':text}
    call add(s:MruDic, usefile)
  endfor
  if merge
    for m in mergedic
      call s:Register(m)
    endfor
  endif
  silent! exec 'lchdir ' . prevPath
  if basedir != ''
    let g:QFixMRU_BaseDir = basedir
  elseif a:0 > 1
    let g:QFixMRU_BaseDir = substitute(a:2, '\\', '/', 'g')
  endif
  " redraw | echo ''
endfunction

"カーソルをエントリ先頭行・末尾行へ移動
command! -count -nargs=1 QFixMRUMoveCursor call QFixMRUMoveCursor(<q-args>)
function! QFixMRUMoveCursor(pos, ...)
  if a:pos == 'top'
    call cursor(1, 1)
  elseif a:pos == 'bottom'
    call cursor(line('$'), 1)
  else
    let tpattern = QFixMRUGetTitleRegxp(fnamemodify(expand('%'), ':e'))
    let cnt = 1
    if count
      let cnt = count
    endif
    for i in range(1, cnt)
      if a:pos == 'next'
        let fline = search(tpattern, 'nW')
        if fline == 0
          let fline = line('$')
        elseif i == cnt
          let fline = fline - 1
        endif
      elseif a:pos == 'prev'
        let opt = 'nbW'
        if i == 1
          let opt = 'cnbW'
        endif
        let fline = search(tpattern, opt)
        if fline == 0
          let fline = line('1')
        else
          let fline = fline
        endif
      endif
      call cursor(fline, 1)
    endfor
  endif
endfunction

"Get mru title or entry
"mode : 'title' or 'entry'
function! QFixMRUGet(mode, mfile, lnum, ...)
  let title = ''
  let mode = a:mode

  let mfile = a:mfile
  if mfile != '%'
    let mfile = fnamemodify(a:mfile, ':p')
  endif
  let lnum = a:lnum
  let tpattern = ''
  silent! let tpattern = g:QFixMRU_Title[tolower(fnamemodify(expand(mfile), ':e'))]
  if a:0
    let tpattern = a:1
  endif

  if mfile != '%'
    silent! exec 'split '
    silent! exec 'silent! edit '.s:tempfile
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal nobuflisted
    silent! %delete _
    if bufloaded(mfile)
      let glist = getbufline(mfile, 1, '$')
      call setline(1, glist)
      let s:lastfile = mfile
    else
      call s:read(mfile)
    endif
  endif

  let save_cursor = getpos('.')
  call cursor(lnum, 1)

  let flnum = 1
  let elnum = line('$')
  let text = getline(lnum)
  if tpattern != ''
    let tlnum = search(tpattern, 'cbW')
    if tlnum
      let ttext = getline(tlnum)
      let text = ttext != '' ? ttext : text
      let lnum = tlnum
      let flnum = tlnum
    endif
    let tlnum = search(tpattern, 'nW')
    if tlnum
      let elnum = tlnum - 1
    endif
  endif
  call cursor(lnum, 1)
  "空白行なら一番近い行の内容を取得
  if text == ''
    let tlnum = search('^\s*[^[:space:]]', 'cnbW')
    if tlnum == 0
      let tlnum = search('\s*[^[:space:]]', 'cnW')
    endif
    if tlnum
      let text = getline(tlnum)
    endif
  endif
  let text = strpart(text, 0, 1024-strlen(mfile)-32)
  if mode == 'entry'
    let glist = getline(flnum, elnum)
  endif

  if mfile != '%'
    silent! bd
  else
    call setpos('.', save_cursor)
  endif

  if mode == 'entry'
    if a:lnum > elnum
      return [[], -1, -1]
    endif
    return [glist, flnum, elnum]
  endif
  return [text, flnum, elnum]
endfunction

"Get mru title regular expression
function! QFixMRUGetTitleGrepRegxp(suffix)
  let t = ''
  silent! let t = g:QFixMRU_Title[a:suffix.'_regxp']
  if t == ''
    silent! let t = g:QFixMRU_Title[a:suffix]
  endif
  return t
endfunction

"Get mru title regular expression for vim
function! QFixMRUGetTitleRegxp(suffix)
  let suffix = tolower(a:suffix)
  let t = ''
  silent! let t = g:QFixMRU_Title[suffix]
  return t
endfunction

" Change basedir
function! QFixMRUSetBaseDir(basedir)
  let g:QFixMRU_BaseDir = substitute(a:basedir, '\\', '/', 'g')
endfunction

" Get mru list
function! QFixMRUGetList(...)
  let entries = 0
  let dir = ''
  for index in range (1, a:0)
    if a:{index} =~ '^\d\+$'
      let entries = a:{index}
    else
      let dir = a:{index}
    endif
  endfor
  call QFixMRUWrite(0)
  if dir == ''
    return deepcopy(s:MruDic)
  endif
  return QFixMRUPrecheck(s:MruDic, entries, dir)
endfunction

" Set mru list
function! QFixMRUSetList(list)
  let s:MruDic = deepcopy(a:list)
endfunction

function! QFixMRUClear()
  let idx = 0
  for d in s:MruDic
    let tpattern = ''
    silent! let tpattern = g:QFixMRU_Title[tolower(fnamemodify(d['filename'], ':e'))]
    if tpattern != '' && d['text'] =~ tpattern.'\s*$'
      call remove(s:MruDic, idx)
      continue
    endif
    let idx += 1
  endfor
endfunction

" MRU register / write
" 0 : 登録処理
" 1 : セーブ
"call QFixMRUWrite(0)
"call QFixMRUWrite(1, {filename}, {basedir})
function! QFixMRUWrite(write, ...)
  if g:QFixMRU_Disable
    return
  endif
  let write = a:write
  let mrufile = g:QFixMRU_Filename
  for index in range (1, a:0)
    if index == 1
      let mrufile = a:{index}
    else
      let g:QFixMRU_BaseDir = substitute(a:{index}, '\\', '/', 'g')
    endif
  endfor
  if write
    call s:WriteMru(s:MruDic, mrufile)
    return
  endif
  if &buftype != ''
    return
  endif
  let prevPath = escape(getcwd(), ' ')
  let mfile = expand('%:p')
  let mfile = substitute(mfile, '\\', '/', 'g')
  if g:QFixMRU_IgnoreFile != '' && mfile =~ g:QFixMRU_IgnoreFile
    return
  endif
  if g:QFixMRU_RegisterFile != '' && mfile !~ g:QFixMRU_RegisterFile
    return
  endif
  if !bufexists(mfile) && !filereadable(mfile)
    return
  endif

  let lnum = search('^\s*[^[:space:]]', 'cnbW')
  if lnum == 0
    let lnum = search('\s*[^[:space:]]', 'cnW')
  endif
  let [text, min, max] = QFixMRUGet('title', '%', lnum)
  let mru = {'filename':mfile, 'lnum':lnum, 'text':text}
  call s:Register(mru)
endfunction

function! s:Register(mru)
  let mru = a:mru
  let mfile = mru['filename']
  let mfile = QFixNormalizePath(fnamemodify(mfile, ':p'))
  let text = mru['text']
  let lnum = mru['lnum']

  if g:QFixMRU_RegisterFile != '' && mfile !~ g:QFixMRU_RegisterFile
    return
  endif
  if g:QFixMRU_IgnoreFile   != '' && mfile =~ g:QFixMRU_IgnoreFile
    return
  endif
  if g:QFixMRU_IgnoreTitle  != '' && text =~ g:QFixMRU_IgnoreTitle
    return
  endif

  if QFixMRURegisterCheck(mru)
    return
  endif

  " 重複エントリの削除
  let tpattern = ''
  silent! let tpattern = g:QFixMRU_Title[tolower(fnamemodify(mfile, ':e'))]

  let idx = 0
  for d in s:MruDic
    let dfile = d['filename']
    let dfile = QFixNormalizePath(fnamemodify(dfile, ':p'))
    if dfile == mfile
      if tpattern == ''
        silent! call remove(s:MruDic, idx)
        continue
      elseif match(text, '\V'.escape(d['text'], '\\')) == 0 && (d['text'] =~ tpattern.'\s*$' || d['lnum'] == lnum)
        silent! call remove(s:MruDic, idx)
        continue
      elseif d['text'] !~ tpattern || d['text'] == text
        silent! call remove(s:MruDic, idx)
        continue
      endif
    endif
    let idx += 1
  endfor
  call insert(s:MruDic, mru)
  if len(s:MruDic) > g:QFixMRU_EntryMax
    call remove(s:MruDic, g:QFixMRU_EntryMax, -1)
  endif
endfunction

function! s:WriteMru(mru, mrufile)
  let mrudic = a:mru
  if len(mrudic) == 0
    return
  endif
  call filter(mrudic, "v:val['filename'] !~ '".g:QFixMRU_IgnoreNFile."'")
  let mrufile = expand(a:mrufile)
  let from = &enc
  let to   = g:QFixMRU_fileencoding
  let prevPath = escape(getcwd(), ' ')
  let g:QFixMRU_BaseDir = substitute(g:QFixMRU_BaseDir, '\\', '/', 'g')
  let mlist = []
  let mline = g:QFixMRU_BaseDir
  call add(mlist, mline)
  silent! exec 'lchdir ' . escape(expand(g:QFixMRU_BaseDir), ' ')
  for d in mrudic
    let file = d['filename']
    if !g:QFixMRU_FullPathMode
      let file = fnamemodify(file, ':.')
    endif
    let file = substitute(file, '\\', '/', 'g')
    let mline = file.'|'.d['lnum'].'|'.d['text']
    let mline = iconv(mline, from, to)
    call add(mlist, mline)
  endfor
  silent! exec 'lchdir ' . prevPath
  let ostr = []
  silent! let ostr = readfile(mrufile)
  if mlist != ostr
    call writefile(mlist, mrufile)
  endif
endfunction

" MRU登録時チェック
silent! function QFixMRURegisterCheck(mru)
  let mfile = a:mru['filename']
  let lnum  = a:mru['lnum']
  let text  = a:mru['text']
  return 0
endfunction

function! s:VimEnter()
  silent! call QFixMRUAddEntryRegxp()
endfunction

function! s:BufEnter()
  let b:QFixMRU_moved = 0
endfunction

function! s:BufLeave()
  call QFixMRUWrite(0)
endfunction

function! s:BufWritePost()
  call QFixMRUWrite(0)
endfunction

function! s:CursorMoved()
  if !exists('b:QFixMRU_moved')
    let b:QFixMRU_moved = 0
  endif
  if b:QFixMRU_moved == 0
    call QFixMRUWrite(0)
    let b:QFixMRU_moved = 1
  endif
endfunction

function! s:VimLeave()
  call QFixMRUVimLeave()
  if g:QFixMRU_state == 1
    call QFixMRUWrite(0)
    call QFixMRUWrite(1)
  endif
endfunction

silent! function QFixMRUVimLeave()
endfunction

