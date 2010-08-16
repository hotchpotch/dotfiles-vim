scriptencoding utf-8

" add runtimepathe .vim/bundle/* 
call pathogen#runtime_append_all_bundles()

"set nocompatible  " Use Vim defaults instead of 100% vi compatibility
set backspace=indent,eol,start  " more powerful backspacing

" Now we set some defaults for the editor 
set textwidth=0   " Don't wrap words by default
set nobackup    " Don't keep a backup file
" set viminfo='50,<1000,s100,\"50 " read/write a .viminfo file, don't store more than
set viminfo='500,<10000,s1000,\"500 " read/write a .viminfo file, don't store more than
"set viminfo='50,<1000,s100,:0,n~/.vim/viminfo
set history=1000 " keep 50 lines of command line history
set ruler   " show the cursor position all the time

" Suffixes that get lower priority when doing tab completion for filenames.
" These are files we are not likely to want to edit or read.
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc

" We know xterm-debian is a color terminal
if &term =~ "xterm-debian" || &term =~ "xterm-xfree86" || &term =~ "xterm-256color"
 set t_Co=16
 set t_Sf=[3%dm
 set t_Sb=[4%dm
endif

syntax on

if has("autocmd")
  filetype plugin on
  filetype indent on
  " これらのftではインデントを無効に
  " autocmd FileType php filetype indent off
  " autocmd FileType xhtml :set indentexpr=
endif

" Some Debian-specific things
augroup filetype
  au BufRead reportbug.*    set ft=mail
  au BufRead reportbug-*    set ft=mail
augroup END
"
" タブ幅の設定
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set modelines=0

set smartindent
"検索文字列が小文字の場合は大文字小文字を区別なく検索する
set ignorecase
"検索文字列に大文字が含まれている場合は区別して検索する
set smartcase
"検索時に最後まで行ったら最初に戻る
set wrapscan
" 検索で色をつける
set hlsearch
"検索文字列入力時に順次対象文字列にヒットさせない
set noincsearch
"タブ文字の表示
set list
set listchars=tab:>-,trail:\ 
"set listchars=tab:\ \ ,trail:\ 
"
" コメント行が連続するときはコメントに
set formatoptions+=r
"入力中のコマンドをステータスに表示する
set showcmd
"括弧入力時の対応する括弧を表示
set showmatch
"ステータスラインを常に表示
set laststatus=2
" ステータスラインの表示
let g:gitCurrentBranch = ''
set statusline=%<[%n]%m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).':'.&ff}%{g:gitCurrentBranch}%{']'}%y\ %F%=%l,%c%V%8P
" コマンドライン補間をシェルっぽく
set wildmode=list:longest
" バッファが編集中でもその他のファイルを開けるように
set hidden
" 外部のエディタで編集中のファイルが変更されたら自動で読み直す
set autoread

" svn/git での文字エンコーディング設定
autocmd FileType svn :set fileencoding=utf-8
autocmd FileType git :set fileencoding=utf-8

set ambiwidth=double 

" タグファイルの自動セット
if has("autochdir")
  set autochdir
  set tags=tags;
else
  set tags=./tags,./../tags,./*/tags,./../../tags,./../../../tags,./../../../../tags,./../../../../../tags
endif

" tags のキーマッピングが C-t だと screen とかぶるので C-z に
nnoremap <C-z> <C-t>

" 辞書ファイルからの単語補間
set complete+=k

" include ファイルは無視
" set complete-=i

" C-]でtjumpと同等の効果
nnoremap <C-]> g<C-]>

" CD.vim example:// は適用しない
" autocmd BufEnter * if bufname("") !~ "^\[A-Za-z0-9\]*://" | execute ":try | lcd " . escape(expand("%:p:h"), ' ') . ' | catch | endtry '  | endif

if &term =~ "screen"
  " screen Buffer 切り替えで screen にファイル名を表示
  autocmd BufEnter * if bufname("") !~ "^\[A-Za-z0-9\]*://" | silent! exe '!echo -n "kv:%\\"' | endif
endif

" command line で command window 開く
set cedit=<C-O>

"表示行単位で行移動する
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk

" + - でバッファウィンドウサイズ変更
" nnoremap + <C-W>+
" nnoremap - <C-W>-

" 前回終了したカーソル行に移動
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif

" Functions 
",e でそのファイルを実行
function! ShebangExecute()
  let m = matchlist(getline(1), '#!\(.*\)')
  if(len(m) > 2)
    execute '!'. m[1] . ' %'
  else
    execute '!' &ft ' %'
  endif
endfunction

if has('win32')
  nnoremap ,e :execute '!' &ft ' %'<CR>
else
  nnoremap ,e :call ShebangExecute()<CR>
end

:function! HtmlEscape() 
silent s/&/\&amp;/eg 
silent s/</\&lt;/eg 
silent s/>/\&gt;/eg 
:endfunction 

:function! HtmlUnEscape() 
silent s/&lt;/</eg 
silent s/&gt;/>/eg 
silent s/&amp;/\&/eg 
:endfunction 

set t_Co=16
set t_Sf=[3%dm
set t_Sb=[4%dm

if !has('win32')
  " 補完候補色
  hi Pmenu ctermbg=8
  hi PmenuSel ctermbg=12
  hi PmenuSbar ctermbg=0
endif

if !has('macunix')
  highlight Visual ctermbg=0
else
  highlight Visual ctermbg=8
end

highlight SpecialKey ctermbg=2
highlight MatchParen cterm=none ctermbg=15 ctermfg=0
highlight Search ctermbg=5 ctermfg=0

" highlight 上書き
autocmd VimEnter,WinEnter * highlight SpecialKey ctermbg=0
autocmd VimEnter,WinEnter * highlight PmenuSel ctermbg=12

" encoding
nnoremap <silent> eu :set fenc=utf-8<CR>
nnoremap <silent> ee :set fenc=euc-jp<CR>
nnoremap <silent> es :set fenc=cp932<CR>
" encode reopen encoding
nnoremap <silent> eru :e ++enc=utf-8 %<CR>
nnoremap <silent> ere :e ++enc=euc-jp %<CR>
nnoremap <silent> ers :e ++enc=cp932 %<CR>

" paste/nopaste
nnoremap ep :set paste<CR>
nnoremap enp :set nopaste<CR>

" yanktmp.vim
noremap <silent> sy :call YanktmpYank()<CR>
noremap <silent> sp :call YanktmpPaste_p()<CR>
noremap <silent> sP :call YanktmpPaste_P()<CR>

" for rails
autocmd BufNewFile,BufRead app/**/*.rhtml set fenc=utf-8
autocmd BufNewFile,BufRead app/**/*.erb set fenc=utf-8
autocmd BufNewFile,BufRead app/**/*.haml set fenc=utf-8
autocmd BufNewFile,BufRead app/**/*.rb set fenc=utf-8

" rails.vim
let g:rails_level=4
let g:rails_statusline=1
" ruby omin complete
"let g:rubycomplete_classes_in_global = 1
let g:rubycomplete_rails = 1

" cofs's fsync
autocmd BufNewFile,BufRead /mnt/c/* set nofsync

" YankRing.vim
nnoremap ,y :YRShow<CR>

" delete input line
cnoremap <C-U> <C-E><C-U>

" fold 使わない
set nofoldenable

" folding keymap
nnoremap zz za
nnoremap zZ zA

" htmlomni 
" autocmd FileType html set filetype=xhtml

" str2numchar.vim
" 範囲選択してる文字列を変換
vnoremap <silent> sn :Stn2NumChar<CR> " あ => &#12354;
vnoremap <silent> sh :Str2HexLiteral<CR> " あ => \\xE3\\x81\\x82

" surround.vim
let g:surround_103 = "_('\r')"  " 103 = g
let g:surround_71 = "_(\"\r\")" " 71 = G
" Ruby
" http://d.hatena.ne.jp/ursm/20080402/1207150539
let g:surround_{char2nr('%')} = "%(\r)"
let g:surround_{char2nr('w')} = "%w(\r)"
let g:surround_{char2nr('#')} = "#{\r}"
let g:surround_{char2nr('e')} = "begin \r end"
let g:surround_{char2nr('i')} = "if \1if\1 \r end"
let g:surround_{char2nr('u')} = "unless \1unless\1 \r end"
let g:surround_{char2nr('c')} = "class \1class\1 \r end"
let g:surround_{char2nr('m')} = "module \1module\1 \r end"
let g:surround_{char2nr('d')} = "def \1def\1\2args\r..*\r(&)\2 \r end"
let g:surround_{char2nr('p')} = "\1method\1 do \2args\r..*\r|&| \2\r end"
let g:surround_{char2nr('P')} = "\1method\1 {\2args\r..*\r|&|\2 \r }"

nnoremap g' cs'g
nnoremap g" cs"G

" 前のバッファに移動を Space に
nnoremap <Space> <C-^>

" nomatchparent
if !has('gui')
  let g:loaded_matchparen = 1
end

" insert 時の削除等のマッピング
inoremap <BS>  <C-G>u<BS>
inoremap <C-H> <C-G>u<C-H>
inoremap <C-W> <C-G>u<C-W>
inoremap <C-U> <C-G>u<C-U>

" gh で hilight を消す
nnoremap <silent> gh :let @/=''<CR>

set grepprg=internal

" 検索レジストリに入ってる文字で現在のファイルを検索し、quickfix で開く
nnoremap <unique> g/ :exec ':vimgrep /' . getreg('/') . '/j %\|cwin'<CR>
" G/ ではすべてのバッファ
" nnoremap <unique> G/ :silent exec ':cexpr "" \| :bufdo vimgrepadd /' . getreg('/') . '/j %'<CR>\|:silent cwin<CR>

" なんだれこれ…
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif

" バッファから検索
function! Bgrep(word)
  cexpr '' " quickfix を空に
  silent exec ':bufdo | try | vimgrepadd ' . a:word . ' % | catch | endtry'
  silent cwin
endfunction
command! -nargs=1 Bgrep :call Bgrep(<f-args>)

" 引数の文字列を、ディレクトリ配下から再帰的に検索
function! Findgrep(arg)
  let findgrep_cmd = 'find . -type f ! -regex ".*\.svn.*" ! -regex ".*\.git.*" ! -regex ".*\.sw.*" ! -regex ".*tags" -print0 |xargs -0 grep -n '
  cgetexpr system(findgrep_cmd . a:arg)
  silent cwin
endfunction
command! -nargs=1 Findgrep :call Findgrep(<f-args>)

" changelog
let g:changelog_username = "Yuichi Tateno"
let g:changelog_dateformat = '== %Y-%m-%d'
let g:changelog_new_entry_format= '  * %c'

" fuf.vim
nnoremap <unique> <silent> <C-S> :FufBuffer!<CR>
nnoremap <unique> <silent> ef :FufFile!<CR>
nnoremap <silent> eub :FufBuffer!<CR>
nnoremap <silent> eff :FufFile!<CR>
nnoremap <silent> ee :FufFileWithCurrentBuffer!<CR>
nnoremap <silent> efm :FufMruFile!<CR>
autocmd FileType fuf nmap <C-c> <ESC>
let g:fuf_splitPathMatching = ' '
let g:fuf_patternSeparator = ' '
let g:fuf_modesDisable = ['mrucmd']
let g:fuf_mrufile_exclude = '\v\~$|\.bak$|\.swp|\.howm$'
let g:fuf_mrufile_maxItem = 10000
let g:fuf_enumeratingLimit = 20
let g:fuf_previewHeight = 20

" Visualモードのpで上書きされたテキストをレジスタに入れない 
vnoremap p "_c<C-r>"<ESC>

" acp.vim
let g:acp_behaviorHtmlOmniLength = -1
let g:acp_behaviorRubyOmniMethodLength = -1
let g:acp_behaviorRubyOmniSymbolLength = -1

autocmd CmdwinEnter * AutoComplPopDisable
autocmd CmdwinLeave * AutoComplPopEnable

" Insert モード抜けたら nopaste
autocmd InsertLeave * set nopaste

" ack.vim
let g:AckAllFiles=0

" もとの ga を gA に割り当て
nnoremap gA ga
" ga を / レジスタで :Ack 検索、
nnoremap ga :silent exec ':Ack ' . substitute(getreg('/'), '\v\\\<(.*)\\\>', "\\1", '')<CR>

" ウィンドウの高さを選択範囲と同じになるよう調整
vnoremap <silent> _ <Esc>`<zt:execute (line("'>") - line("'<") + 1) 'wincmd' '_'<Return>

" :Source で選択部分だけ vimscript る
" http://subtech.g.hatena.ne.jp/motemen/20080313/1205336864
command! -range=% Source split `=tempname()` | call append(0, getbufline('#', <line1>, <line2>)) | write | source % | bdelete
" autoread 時に source しなおす
" autocmd BufWritePost,FileWritePost {*.vim,*vimrc} if &autoread | source <afile> | endif

" - も fname に含む
autocmd BufRead * setlocal isfname+=- " どこかの plugin で上書きされてる？
set isfname+=-

" QuickFix のサイズ調整,自動で抜ける 
function! s:autoCloseQuickFix()
  let qllen = min([10, len(getqflist())])
  cclose
  if qllen
    execute 'cw' . qllen
    normal <C-W><C-W>
  endif
  redraw
endfunction

autocmd QuickFixCmdPost * :call s:autoCloseQuickFix()

" fugitive.vim
nnoremap <unique> gG :exec ':silent Ggrep ' . expand('<cword>')<CR>

" quickfix を閉じる
nnoremap <unique> ec :cclose<CR>

" jptemplate.vim
let g:jpTemplateKey = '<Tab>'

" 適当なテンポラリファイルの作成
command! -nargs=0 NewTmp :new `=tempname().'.vim'`

" 適当に CSS を JS ぽく変換
function! CSSToJS(sLine, eLine)
  let prefix = ':'  . a:sLine . ',' . a:eLine  . 'substitute'
  let cmd = prefix . '/\v\-([a-z])/\u\1/g'
  silent execute cmd
  let cmd =  prefix . '/\v;?$/";'
  silent execute cmd
  let cmd = prefix . '/\v:\s*/ = "/'
  silent execute cmd
endfunction
command! -range CSSToJS :call CSSToJS(<line1>, <line2>)


noremap! <C-b> <Left>
noremap! <C-f> <Right>
noremap! <C-k> <Up>
noremap! <C-j> <Down>
noremap! <C-a> <Home>
noremap! <C-e> <End>
inoremap <silent> <expr> <C-e> (pumvisible() ? "\<C-e>" : "\<End>")
noremap! <C-d> <Del>

" {{{ QFixHowm.vim
let QFixHowm_Key = 'g'
if has('win32')
  let howm_dir             = 'c:/dropbox/My Dropbox/howm'
  let QFixHowm_MruFile     = 'c:/dropbox/My Dropbox/howm/.howm-mru'
else
  let howm_dir             = '~/Dropbox/howm'
  let QFixHowm_MruFile     = '~/Dropbox/howm/.howm-mru'
end
let howm_filename        = '%Y/%m/%Y-%m-%d-%H%M%S.howm'
let howm_fileencoding    = 'utf-8'
let howm_fileformat      = 'unix'
let QFixHowm_MruFileMax = 50
let QFixHowm_Title = '='
" let disable_MyQFix = 1

"タイトルに何も書かれていない場合、エントリ内から適当な文を探して設定する。
""文字数は半角換算で最大 QFixHowm_Replace_Title_len 文字まで使用する。0なら何もしない。
"let QFixHowm_Replace_Title_Len = 64

"対象になるのは QFixHowm_Replace_Title_Pattern
"の正規表現に一致するタイトルパターン。
""デフォルトでは次の正規表現が設定されている。
"let QFixHowm_Replace_Title_Pattern = '^'.g:QFixHowm_Title.'\s*$'

"新規エントリの際、本文から書き始める。
"let QFixHowm_Cmd_New = "i".QFixHowm_Title." \<CR>\<C-r>=strftime(\"[%Y-%m-%d%H:%M]\")\<CR>\<CR>\<ESC>$"
"",Cで挿入される新規エントリのコマンド
"let QFixHowm_Key_Cmd_C = "o<ESC>".QFixHowm_Cmd_New

" }}}

" omnifunc を適当に有効化
" if has("autocmd") && exists("+omnifunc")
"   autocmd Filetype *
"         \   if &omnifunc == "" |
"         \           setlocal omnifunc=syntaxcomplete#Complete |
"         \   endif
" endif

" noexpandtab するディレクトリを指定
autocmd BufNewFile,BufRead */chromekeyconfig/* setlocal noexpandtab 

" debuglet
autocmd BufWritePost */debuglet.js silent! execute '!debuglet.rb %'
autocmd BufNewFile */debuglet.js silent! execute 'r!debuglet.rb'

" NeoCompleCache.vim
let g:neocomplcache_enable_at_startup = 1 
let g:neocomplcache_enable_auto_select = 1 

" Use smartcase.
let g:neocomplcache_enable_smart_case = 1
" Use camel case completion.
let g:neocomplcache_enable_camel_case_completion = 1
" Use underbar completion.
let g:neocomplcache_enable_underbar_completion = 1
" Set minimum syntax keyword length.
let g:neocomplcache_min_syntax_length = 3 

imap <expr><TAB> neocomplcache#sources#snippets_complete#expandable() ? "\<Plug>(neocomplcache_snippets_expand)" : pumvisible() ? "\<C-n>" : "\<TAB>" 
" <CR>: close popup and save indent.
" inoremap <expr><CR>  neocomplcache#smart_close_popup() . (&indentexpr != '' " ? "\<C-f>\<CR>X\<BS>":"\<CR>")
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><C-y>  neocomplcache#close_popup()
inoremap <expr><C-e>  neocomplcache#cancel_popup() 

" load ~/.vimrc.local
if filereadable(expand('$HOME/.vimrc.local'))
  source ~/.vimrc.local
endif




