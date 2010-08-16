"=============================================================================
"    Description: 拡張Quickfixに対応したhowm
"         Author: fuenor <fuenor@gmail.com>
"                 http://sites.google.com/site/fudist/Home/qfixhowm
"  Last Modified: 2010-08-05 22:08
"        Version: 2.31
"=============================================================================
scriptencoding utf-8

"キーマップリーダーが g の場合、「新規ファイルを作成」は g,c です。
"簡単な使い方はg,Hのヘルプで、詳しい使い方は以下のサイトを参照してください。
"http://sites.google.com/site/fudist/Home/qfixhowm
"
"----------以下は変更しないで下さい----------

if exists('disable_MyQFix') && disable_MyQFix == 1
  finish
endif
if exists('disable_MyHowm') && disable_MyHowm
  finish
endif
if exists("loaded_MyHowm") && !exists('fudist')
  finish
endif
if v:version < 700 || &cp
  finish
endif
let loaded_MyHowm = 1
if !has('quickfix')
  finish
endif

if !exists('howm_dir')
  let howm_dir          = '~/howm'
endif
if !exists('howm_filename')
  let howm_filename     = '%Y/%m/%Y-%m-%d-%H%M%S.howm'
endif
if !exists('howm_fileencoding')
  let howm_fileencoding = &enc
endif
if !exists('howm_fileformat')
  let howm_fileformat   = &ff
endif
if !exists('howm_glink_pattern')
  let howm_glink_pattern = '>>>'
endif
if !exists('howm_clink_pattern')
  let howm_clink_pattern = '<<<'
endif

"howmファイルの拡張子
let g:QFixHowm_FileExt = fnamemodify(g:howm_filename,':e')
"howmファイルタイプ
if !exists('g:QFixHowm_FileType')
  let g:QFixHowm_FileType = 'howm_memo'
endif

"キーマップリーダー
if !exists('g:QFixHowm_Key')
  if exists('g:howm_mapleader')
    let g:QFixHowm_Key = howm_mapleader
  else
    let g:QFixHowm_Key = 'g'
  endif
endif
"2ストローク目キーマップ
if !exists('g:QFixHowm_KeyB')
  let g:QFixHowm_KeyB = ','
endif
let s:QFixHowm_Key = g:QFixHowm_Key . g:QFixHowm_KeyB

"キーマップを使用する
if !exists('g:QFixHowm_Default_Key')
  let g:QFixHowm_Default_Key = 1
endif
if !exists('g:QFixHowm_Default_KeyCmd')
  let g:QFixHowm_Default_KeyCmd  = 1
endif

"ファイル読込の際に、ファイルエンコーディングを指定する/しない
if !exists('g:QFixHowm_ForceEncoding')
  let g:QFixHowm_ForceEncoding = 1
endif

"タイトル行識別子
if !exists('g:QFixHowm_Title')
  if exists('howm_title_pattern')
    let g:QFixHowm_Title = howm_title_pattern
  else
    let g:QFixHowm_Title = '='
  endif
endif
"タイトル検索のエスケープパターン
if !exists('g:QFixHowm_EscapeTitle')
  let g:QFixHowm_EscapeTitle = '~*.\'
endif
if !exists('g:QFixHowm_DefaultTag')
  let g:QFixHowm_DefaultTag = ''
endif

"howm検索対象指定
if !exists('g:QFixHowm_SearchHowmFile')
  let g:QFixHowm_SearchHowmFile = '**/*.*'
endif
"検索時にカーソル位置の単語を拾う
if !exists('g:QFixHowm_DefaultSearchWord')
  let g:QFixHowm_DefaultSearchWord = 1
endif
"最近更新ファイル検索日数
if !exists('g:QFixHowm_RecentDays')
  let g:QFixHowm_RecentDays = 5
endif
"Wikiスタイルリンク定義も検索で一番上にする
if !exists('g:QFixHowm_WikiLink_AtTop')
  let g:QFixHowm_WikiLink_AtTop = 0
endif
",aコマンドでソートを使用する/しない
if !exists('g:QFixHowm_AllTitleSearchSort')
  let g:QFixHowm_AllTitleSearchSort = 0
endif
"QFixHowm_RecentMode > 0で howmタイムスタンプソートを使用する/しない
if !exists('g:QFixHowm_HowmTimeStampSort')
  let g:QFixHowm_HowmTimeStampSort = 0
endif
"タイトルフィルタ用正規表現
if !exists('g:QFixHowm_TitleFilterReg')
  let g:QFixHowm_TitleFilterReg = ''
endif
"ファイルリスト最大表示数
if !exists('g:QFixHowm_FileListMax')
  let g:QFixHowm_FileListMax = 0
endif
"ファイルリストのglobパラメータ
if !exists('g:QFixHowm_FileList')
  let g:QFixHowm_FileList = '**/[0-9]*-000000.'.g:QFixHowm_FileExt
endif

"ランダム表示保存ファイル
if !exists('g:QFixHowm_RandomWalkFile')
  let g:QFixHowm_RandomWalkFile = '~/.howm-random'
endif
"乱数の発生方法(うまく動かない場合 0 に)
if !exists('g:QFixHowm_RandomWalkMode')
  let g:QFixHowm_RandomWalkMode = 1
endif
"ランダム表示保存ファイル更新間隔
if !exists('g:QFixHowm_RandomWalkUpdate')
  let g:QFixHowm_RandomWalkUpdate = 10
endif
"ランダム表示数
if !exists('g:QFixHowm_RandomWalkColumns')
  let g:QFixHowm_RandomWalkColumns = 10
endif

"連結表示で使用するセパレータ
if !exists('g:QFixHowm_MergeEntrySeparator')
  let g:QFixHowm_MergeEntrySeparator = "=========================="
endif
"連結表示をスクラッチバッファとして使用する
if !exists('g:QFixHowm_MergeEntryMode')
  let g:QFixHowm_MergeEntryMode = 1
endif
"連結表示を固定名単一バッファで使用する
"空白なら連結表示は複数作成される
if !exists('g:QFixHowm_MergeEntryName')
  let g:QFixHowm_MergeEntryName = ''
endif

"MRUを使用する/しない
if !exists('g:QFixHowm_UseMRU')
  let g:QFixHowm_UseMRU = 1
endif
"MRUファイル
if !exists('g:QFixHowm_MruFile')
  let g:QFixHowm_MruFile = '~/.howm-mru'
endif
"MRUに登録しないファイル名
if !exists('g:QFixHowm_MRU_Ignore')
  let g:QFixHowm_MRU_Ignore = '0000-00-00-000000.howmd$'
endif
"MRU最大登録数
if !exists('g:QFixHowm_MruFileMax')
  let g:QFixHowm_MruFileMax = 30
endif
"MRUのタイトル表示設定
if !exists('g:QFixHowm_MRU_SummaryMode')
  let g:QFixHowm_MRU_SummaryMode = 3
endif
"MRUジャンプ先変更
if !exists('g:QFixHowm_MRU_SummaryLineMode')
  let g:QFixHowm_MRU_SummaryLineMode = 1
endif

"howmのキーワードファイル
if !exists('g:QFixHowm_keywordfile')
  if exists('g:howm_keywordfile')
    let g:QFixHowm_keywordfile = g:howm_keywordfile
  else
    let g:QFixHowm_keywordfile = '~/.howm-keys'
  endif
endif
"howmリンクパターン
if !exists('g:QFixHowm_Link')
  let g:QFixHowm_Link = '\('.g:howm_clink_pattern.'\|'.g:howm_glink_pattern.'\)'
endif
"実験用
if !exists('g:QFixHowm_clink_type')
  let g:QFixHowm_clink_type = ''
endif
"howmpath
if !exists('g:QFixHowm_RelPath')
  let g:QFixHowm_RelPath = g:howm_dir
endif

"スプリットで開く
if !exists('g:QFixHowm_SplitMode')
  let g:QFixHowm_SplitMode = 0
endif
"サブウィンドウを出す方向
if !exists('g:SubWindow_Dir')
  let g:SubWindow_Dir = "topleft vertical"
endif
"サブウィンドウのファイル名
if !exists('g:SubWindow_Title')
  let g:SubWindow_Title = "~/__submenu__.howm"
endif
"サブウィンドウのサイズ
if !exists('g:SubWindow_Width')
  let g:SubWindow_Width = 30
endif

"更新時間を管理する
if !exists('g:QFixHowm_RecentMode')
  let g:QFixHowm_RecentMode = 0
endif
"QFixHowm_RecentModeに関わらずhowmタイムスタンプで最近更新したファイルを検索する
if !exists('g:QFixHowm_RecentSearchMode')
  let g:QFixHowm_RecentSearchMode = 0
endif
"更新時間埋め込み
if !exists('g:QFixHowm_SaveTime')
  let g:QFixHowm_SaveTime = 0
endif

"howmファイルの自動整形を使用する
if !exists('g:QFixHowm_Autoformat')
  let g:QFixHowm_Autoformat = 1
endif
if !exists('g:QFixHowm_NoBOM')
  let g:QFixHowm_NoBOM = 0
endif
"行頭にQFixHowm_Titleがある行は全てタイトルとみなして整形する
if !exists('g:QFixHowm_Autoformat_TitleMode')
  let g:QFixHowm_Autoformat_TitleMode = 1
endif
"オートタイトル文字数
if !exists('g:QFixHowm_Replace_Title_Len')
  let g:QFixHowm_Replace_Title_Len = 64
endif
"オートタイトル正規表現
if !exists('g:QFixHowm_Replace_Title_Pattern')
  let g:QFixHowm_Replace_Title_Pattern = '^'.escape(g:QFixHowm_Title, g:QFixHowm_EscapeTitle).'\s*\(\[[^\]]*\]\s*\)*\s*$'
endif

"日付のアクションロック種類
if !exists('g:QFixHowm_DateActionLockDefault')
  let g:QFixHowm_DateActionLockDefault = 1
endif
"カーソル位置のファイルを開くアクションロック
if !exists('g:QFixHowm_OpenURIcmd')
  if !exists('g:MyOpenURI_cmd')
    let g:QFixHowm_OpenURIcmd = ""
    if has('unix')
      let g:QFixHowm_OpenURIcmd = "call system('firefox %s &')"
    else
      "Internet Explorer
      let g:QFixHowm_OpenURIcmd = '!start "C:/Program Files/Internet Explorer/iexplore.exe" %s'
    endif
  else
    let g:QFixHowm_OpenURIcmd = g:MyOpenURI_cmd
  endif
endif

"はてなのhttp記法のゴミを取り除く
if !exists('g:QFixHowm_removeHatenaTag')
  let g:QFixHowm_removeHatenaTag = 1
endif
"ファイルリンクのうちvimで開くファイル
if !exists('g:QFixHowm_OpenVimExtReg')
  if !exists('g:MyOpenVim_ExtReg')
    let g:QFixHowm_OpenVimExtReg = '\.txt$\|\.vim$'
  else
    let g:QFixHowm_OpenVimExtReg = g:MyOpenVim_ExtReg
  endif
endif

"メニューファイルディレクトリ
if !exists('g:QFixHowm_MenuDir')
  let g:QFixHowm_MenuDir = ''
endif
"メニューファイル名
if !exists('g:QFixHowm_Menufile')
  let g:QFixHowm_Menufile = 'Menu-00-00-000000.'.g:QFixHowm_FileExt
endif

"予定・TODOを検索するルートディレクトリ
if !exists('g:QFixHowm_ScheduleSearchDir')
  let g:QFixHowm_ScheduleSearchDir = ''
endif
"予定・TODOを検索するファイル
if !exists('g:QFixHowm_ScheduleSearchFile')
  let g:QFixHowm_ScheduleSearchFile = ''
endif
"予定・TODOを検索する時vimgrepを使用する
if !exists('g:QFixHowm_ScheduleSearchVimgrep')
  let g:QFixHowm_ScheduleSearchVimgrep = 0
endif
"予定やTodoのプライオリティレベルが、これ未満のエントリは削除する
if !exists('g:QFixHowm_RemovePriority')
  let g:QFixHowm_RemovePriority = 1
endif
"予定やTodoのプライオリティレベルが、今日よりこれ以下なら削除する。
if !exists('g:QFixHowm_RemovePriorityDays')
  let g:QFixHowm_RemovePriorityDays = 0
endif
"メニュー画面にTODO一覧表示
if !exists('g:QFixHowm_ShowTodoOnMenu')
  let g:QFixHowm_ShowTodoOnMenu = 1
endif
",y の予定表示日数
if !exists('g:QFixHowm_ShowSchedule')
  let g:QFixHowm_ShowSchedule = 10
endif
",t の予定表示日数
if !exists('g:QFixHowm_ShowScheduleTodo')
  let g:QFixHowm_ShowScheduleTodo = -1
endif
",,の予定表示日数
if !exists('g:QFixHowm_ShowScheduleMenu')
  let g:QFixHowm_ShowScheduleMenu = 10
endif
",y で表示する予定・TODO
if !exists('g:QFixHowm_ListReminder_ScheExt')
  let g:QFixHowm_ListReminder_ScheExt = '[@!.]'
endif
",t で表示する予定・TODO
if !exists('g:QFixHowm_ListReminder_TodoExt')
  let g:QFixHowm_ListReminder_TodoExt = '[-@+!~.]'
endif
"menuで表示する予定・TODO
if !exists('g:QFixHowm_ListReminder_MenuExt')
  let g:QFixHowm_ListReminder_MenuExt = '[-@+!~.]'
endif

"予定・TODOでプレビュー表示を有効にする
if !exists('g:QFixHowm_SchedulePreview')
  let g:QFixHowm_SchedulePreview = 1
endif
"予定・TODOのソート優先順
if !exists('g:QFixHowm_ReminderPriority')
  let g:QFixHowm_ReminderPriority = ['@', '!', '+', '-', '~', '.']
endif
"予定・TODOの同一日、同一種類のソート正順/逆順
if !exists('g:QFixHowm_ReminderSortMode')
  let g:QFixHowm_ReminderSortMode = 0
endif
"同一日、同一内容の予定・TODOは一つにまとめる
if !exists('g:QFixHowm_RemoveSameSchedule')
  let g:QFixHowm_RemoveSameSchedule = 1
endif
"予定を表示する際、曜日も表示する
if !exists('g:QFixHowm_ShowScheduleDayOfWeek')
  let g:QFixHowm_ShowScheduleDayOfWeek = 1
endif
"予定・TODOに今日の日付を表示
if !exists('g:QFixHowm_ShowTodayLine')
  let g:QFixHowm_ShowTodayLine = 1
endif
"予定・TODOの今日の日付表示用セパレータ
if !exists('g:QFixHowm_ShowTodayLineStr')
  let g:QFixHowm_ShowTodayLineStr = '------------------------------'
endif
"予定・TODOの今日の日付表示のファイルネーム
if !exists('g:QFixHowm_TodayFname')
  let g:QFixHowm_TodayFname = '-'
endif

"予定やTODOのデフォルト値
if !exists('g:QFixHowm_ReminderDefault_Deadline')
  let g:QFixHowm_ReminderDefault_Deadline = 7
endif
if !exists('g:QFixHowm_ReminderDefault_Schedule')
  let g:QFixHowm_ReminderDefault_Schedule = 1
endif
if !exists('g:QFixHowm_ReminderDefault_Reminder')
  let g:QFixHowm_ReminderDefault_Reminder = 1
endif
if !exists('g:QFixHowm_ReminderDefault_Todo')
  let g:QFixHowm_ReminderDefault_Todo = 7
endif
if !exists('g:QFixHowm_ReminderDefault_UD')
  let g:QFixHowm_ReminderDefault_UD  = 30
endif
"リマインダの継続期間のオフセット
if !exists('g:QFixHowm_ReminderOffset')
  let g:QFixHowm_ReminderOffset = 0
endif
"終了日指定のオフセット
if !exists('g:QFixHowm_EndDateOffset')
  let g:QFixHowm_EndDateOffset = 0
endif
"休日定義ファイル
if !exists('g:QFixHowm_HolidayFile')
  let g:QFixHowm_HolidayFile = 'Sche-Hd-0000-00-00-000000.*'
endif
"休日名
if !exists('g:QFixHowm_ReminderHolidayName')
  let g:QFixHowm_ReminderHolidayName = '元日\|成人の日\|建国記念の日\|昭和の日\|憲法記念日\|みどりの日\|こどもの日\|海の日\|敬老の日\|体育の日\|文化の日\|勤労感謝の日\|天皇誕生日\|春分の日\|秋分の日\|振替休日\|国民の休日\|日曜日'
endif
"休日・祝日の予定もエクスポート対象にする
if !exists('g:QFixHowmExportHoliday')
  let g:QFixHowmExportHoliday = 0
endif

"起動時コマンド出力ファイル名
if !exists('g:QFixHowm_VimEnterFile')
  let g:QFixHowm_VimEnterFile = '~/.vimenter.qf'
endif
"起動時コマンド
if !exists('g:QFixHowm_VimEnterCmd')
  let g:QFixHowm_VimEnterCmd=''
endif
"起動時コマンド基準時間
if !exists('g:QFixHowm_VimEnterTime')
  let g:QFixHowm_VimEnterTime='07:00'
endif

"ユーザーマクロアクションロックの識別子
if !exists('g:QFixHowm_MacroActionPattern')
  let g:QFixHowm_MacroActionPattern = '<|>'
endif
"ユーザーマクロアクションのキーマップ
if !exists('g:QFixHowm_MacroActionKey')
  let g:QFixHowm_MacroActionKey = 'M'
endif

"クイックメモファイル名
if !exists('g:QFixHowm_QuickMemoFile')
  let g:QFixHowm_QuickMemoFile = 'Qmem-00-0000-00-00-000000.'.g:QFixHowm_FileExt
endif
let g:QFixHowm_QMF = g:QFixHowm_QuickMemoFile

"日記メモファイル名
if !exists('g:QFixHowm_DiaryFile')
  let g:QFixHowm_DiaryFile = matchstr(g:howm_filename, '^.*/').'%Y-%m-%d-000000.'.g:QFixHowm_FileExt
endif

"QFixHowmが自動生成するファイル
if !exists('g:QFixHowm_GenerateFile')
  let g:QFixHowm_GenerateFile = '%Y-%m-%d-%H%M%S.'.g:QFixHowm_FileExt
endif

"折りたたみを有効にする。
if !exists('g:QFixHowm_Folding')
  let g:QFixHowm_Folding = 1
endif
"折りたたみに ワイルドカードチャプターを使用する
if !exists('g:QFixHowm_WildCardChapter')
  let g:QFixHowm_WildCardChapter = 0
endif
"階層付きテキストもワイルドカードチャプター変換の対象にする
if !exists('g:QFixHowm_WildCardChapterMode')
  let g:QFixHowm_WildCardChapterMode = 1
endif
"チャプターのタイトル行を折りたたみに含める/含めない
if !exists('g:QFixHowm_FoldingChapterTitle')
  let g:QFixHowm_FoldingChapterTitle = 0
endif
"折りたたみのパターン
if !exists('g:QFixHowm_FoldingPattern')
  let g:QFixHowm_FoldingPattern = '^[=.*]'
endif
"折りたたみのレベル設定
if !exists('g:QFixHowm_FoldingMode')
  let g:QFixHowm_FoldingMode = 0
endif

"オートリンクのタグジャンプを有効にする。
if !exists('g:QFixHowm_UseAutoLinkTags')
  let g:QFixHowm_UseAutoLinkTags = 0
endif
"オートリンク用tagsを作成するディレクトリ
if !exists('g:QFixHowm_TagsDir')
  let g:QFixHowm_TagsDir = g:howm_dir
endif

"strftime()の基準年
if !exists('g:YearStrftime')
  let g:YearStrftime = 1970
endif
"strftime()の基準日数
if !exists('g:DateStrftime')
  let g:DateStrftime = 719162
endif
"GMTとの時差
if !exists('g:QFixHowm_ST')
  let g:QFixHowm_ST = -9
endif

"ユーザアクションロックの最大数
if !exists('g:QFixHowm_UserSwActionLockMax')
  let g:QFixHowm_UserSwActionLockMax = 64
endif
"howm_dirの最大数
if !exists('g:QFixHowm_howm_dir_Max')
  let g:QFixHowm_howm_dir_Max = 8
endif

"タブで編集
if !exists('QFixHowm_Edit')
  let QFixHowm_Edit = ''
endif

let s:QFixHowm_Helpfile = 'QFixHowmHelp.'.g:QFixHowm_FileExt
"正規表現パーツ
if !exists('g:QFixHowm_DatePattern')
  let g:QFixHowm_DatePattern = '%Y-%m-%d'
endif
let s:hts_date     = g:QFixHowm_DatePattern
let s:hts_time     = '%H:%M'
let s:hts_dateTime = s:hts_date . ' '. s:hts_time

"let s:sch_date     = '\d\{4}-\d\{2}-\d\{2}'
let s:sch_date     = s:hts_date
let s:sch_date     = substitute(s:sch_date, '%Y', '\\d\\{4}', '')
let s:sch_date     = substitute(s:sch_date, '%m', '\\d\\{2}', '')
let s:sch_date     = substitute(s:sch_date, '%d', '\\d\\{2}', '')
let g:QFixHowm_Date = s:sch_date

let s:sch_printfDate = s:hts_date
let s:sch_printfDate = substitute(s:sch_printfDate, '%Y', '%4.4d', '')
let s:sch_printfDate = substitute(s:sch_printfDate, '%m', '%2.2d', '')
let s:sch_printfDate = substitute(s:sch_printfDate, '%d', '%2.2d', '')

let s:sch_ExtGrep = s:hts_date. ' ' . s:hts_time
let s:sch_ExtGrep = substitute(s:sch_ExtGrep, '%Y', '[0-9]{4}', '')
let s:sch_ExtGrep = substitute(s:sch_ExtGrep, '%m', '[0-9]{2}', '')
let s:sch_ExtGrep = substitute(s:sch_ExtGrep, '%d', '[0-9]{2}', '')
let s:sch_ExtGrep = substitute(s:sch_ExtGrep, '%H', '[0-9]{2}', '')
let s:sch_ExtGrep = substitute(s:sch_ExtGrep, '%M', '[0-9]{2}', '')

let s:sch_ExtGrepS = s:hts_date. '( ' . s:hts_time . ')?'
let s:sch_ExtGrepS = substitute(s:sch_ExtGrepS, '%Y', '[0-9]{4}', '')
let s:sch_ExtGrepS = substitute(s:sch_ExtGrepS, '%m', '[0-9]{2}', '')
let s:sch_ExtGrepS = substitute(s:sch_ExtGrepS, '%d', '[0-9]{2}', '')
let s:sch_ExtGrepS = substitute(s:sch_ExtGrepS, '%H', '[0-9]{2}', '')
let s:sch_ExtGrepS = substitute(s:sch_ExtGrepS, '%M', '[0-9]{2}', '')

"let s:sch_time     = '\d\{2}:\d\{2}'
let s:sch_time = s:hts_time
let s:sch_time = substitute(s:sch_time, '%H', '\\d\\{2}', '')
let s:sch_time = substitute(s:sch_time, '%M', '\\d\\{2}', '')

let s:sch_dateT    = '\['.s:sch_date.'\( '.s:sch_time.'\)\?\]'
let s:sch_dateTime = '\['.s:sch_date.' '.s:sch_time.'\]'
let s:sch_dow      = '\c\(Sun\|Mon\|Tue\|Wed\|Thu\|Fri\|Sat\|Hdy\)'
let s:sch_ext      = '-@!+~.'
let s:sch_Ext      = '['.s:sch_ext.']'
let s:sch_notExt   = '[^'.s:sch_ext.']'
let s:sch_dateCmd  = s:sch_dateT . s:sch_Ext . '\{1,3}\(([0-9]*[-+*]\?'.s:sch_dow.'\?)\)\?[0-9]*'
let s:sch_cmd      = s:sch_Ext . '\{1,3}\(([0-9]*[-+*]\?'.s:sch_dow.'\?)\)\?[0-9]*'
let s:Recentmode_Date   = '(\d\{12})'

"コマンド定義
if !exists('g:QFixHowm_Cmd_NewEntry')
  let g:QFixHowm_Cmd_NewEntry = "$a"
endif

let g:QFixHowm_LastFilename = ''
"howm://を使用する/しない
if !exists('g:QFixHowm_LastFilenameMode')
  let g:QFixHowm_LastFilenameMode = 1
endif
let g:QFixHowm_KeywordList = []
let g:QFix_SearchPathEnable = 1
let g:QFix_FileOpenMode = 0

"
"howmキーマップ
"

"最近"更新"したファイルの検索
if !exists('g:QFixHowm_Key_SearchRecent')
  let g:QFixHowm_Key_SearchRecent  = 'l'
endif

"最近"作成" したファイルの検索
if !exists('g:QFixHowm_Key_SearchRecentAlt')
  let g:QFixHowm_Key_SearchRecentAlt = 'L'
endif

"最近"更新/閲覧"したファイルの検索
if !exists('g:QFixHowm_Key_SearchMRU')
  let g:QFixHowm_Key_SearchMRU     = 'm'
endif

"Quickfixウィンドウ上でハイライトする曜日
if !exists('g:QFixHowm_DayOfWeekReg')
  let g:QFixHowm_DayOfWeekReg = '\c\(Sun\|Mon\|Tue\|Wed\|Thu\|Fri\|Sat\)'
endif
"Quickfixウィンドウ上での曜日変換表示
if exists('g:QFixHowm_JpDayOfWeek') && g:QFixHowm_JpDayOfWeek
  let g:QFixHowm_DayOfWeekDic = {'Sun' : "日", 'Mon' : "月", 'Tue' : "火", 'Wed' : "水", 'Thu' : "木", 'Fri' : "金", 'Sat' : "土"}
  let g:QFixHowm_DayOfWeekReg = '\c\(Sun\|Mon\|Tue\|Wed\|Thu\|Fri\|Sat\|日\|月\|火\|水\|木\|金\|土\)'
endif

if g:QFixHowm_Default_Key > 0
  exec 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.g:QFixHowm_Key_SearchRecent.' :QFixHowmListRecent<CR>'
  exec 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.g:QFixHowm_Key_SearchRecentAlt.' :QFixHowmListRecentC<CR>'
  if g:QFixHowm_UseMRU
    exec 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.g:QFixHowm_Key_SearchMRU.' :<C-u>call QFixHowmMru(0)<CR>'
    exec 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.'r'.g:QFixHowm_Key_SearchMRU.' :<C-u>call QFixHowmMru(1)<CR>'
  endif

  exec 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.'c :<C-u>call QFixHowmCreateNewFile()<CR>'
  exec 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.'u :QFixHowmOpenQuickMemo<CR>'
  "if g:QFixHowm_QuickMemoFile != g:QFixHowm_QuickMemoFile1
    exec 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.'U :<C-u>let g:QFixHowm_QMF = g:QFixHowm_QuickMemoFile<CR>:QFixHowmOpenQuickMemo<CR>'
  "endif
  exec 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.'<Space> :<C-u>call QFixHowmOpenQuickMemo(g:QFixHowm_DiaryFile)<CR>'
  exec 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.'s :<C-u>call QFixHowmSearchInput("QFixHowm FGrep : ", 0)<CR>'
  exec 'silent! vnoremap <unique> <silent> '.s:QFixHowm_Key.'s :<C-u>call QFixHowmSearchInput("QFixHowm FGrep : ", 0, "visual")<CR>'
  exec 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.'g :<C-u>call QFixHowmSearchInput("QFixHowm Grep : ", 1)<CR>'
  exec 'silent! vnoremap <unique> <silent> '.s:QFixHowm_Key.'g :<C-u>call QFixHowmSearchInput("QFixHowm Grep : ", 1, "visual")<CR>'
  exec 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.'\g :<C-u>call QFixHowmVSearchInput("QFixHowm VGrep : ", 1)<CR>'
  exec 'silent! vnoremap <unique> <silent> '.s:QFixHowm_Key.'\g :<C-u>call QFixHowmVSearchInput("QFixHowm VGrep : ", 1, "visual")<CR>'
  exec 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.'a :<C-u>call QFixHowmListAllTitle(g:QFixHowm_Title, 0)<CR>'
  exec 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.'rr :QFixHowmRandomWalk<CR>'
  exec 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.'rR :call QFixHowmRebuildRandomWalkFile(g:QFixHowm_RandomWalkFile)<CR>:QFixHowmRandomWalk<CR>'
  exec 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.'A :QFixHowmFileList<CR>'
  exec 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.'rA :<C-u>let g:QFixHowm_FileListMax = 0\|QFixHowmFileList<CR>'
  exec 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.'rk :<C-u>call QFixHowmRebuildKeyword()<CR>'
  exec 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.'t  :QFixHowmListReminderTodo<CR>'
  exec 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.'y  :QFixHowmListReminderSche<CR>'
  exec 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.',  :QFixHowmOpenMenu<CR>z.'
  exec 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.'i  :<C-u>call ToggleQFixSubWindow()<CR>'
  exec 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.'j  :<C-u>call ToggleQFixSubWindow()<CR>'
  exec 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.'Y  :QFixHowmAlarmReadFile!<CR>'
  exec 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.'H  :call QFixHowmHelp()<CR>'
  exec "silent! nnoremap <unique> <silent> ".s:QFixHowm_Key."z :call CnvWildcardChapter()<CR>"
  exec "silent! vnoremap <unique> <silent> ".s:QFixHowm_Key."z :call CnvWildcardChapter('visual')<CR>"

  exec 'silent! nmap     <silent> <expr> '.s:QFixHowm_Key.'e expand("%:e") !~ "'.g:QFixHowm_FileExt.'" ? ":QFGrep!<CR>"  : "'.s:QFixHowm_Key.'g"'
  exec 'silent! nmap     <silent> <expr> '.s:QFixHowm_Key.'f expand("%:e") !~ "'.g:QFixHowm_FileExt.'" ? ":QFFGrep!<CR>" : "'.s:QFixHowm_Key.'s"'
  exec 'silent! nmap     <silent> <expr> '.s:QFixHowm_Key.'v expand("%:e") !~ "'.g:QFixHowm_FileExt.'" ? ":QFVGrep!<CR>" : "'.s:QFixHowm_Key.'\\g"'
  exec 'silent! vmap     <silent> <expr> '.s:QFixHowm_Key.'e expand("%:e") !~ "'.g:QFixHowm_FileExt.'" ? ":call Grep(\"\", -1, \"Grep\", 0)<CR>"  : "'.s:QFixHowm_Key.'g"'
  exec 'silent! vmap     <silent> <expr> '.s:QFixHowm_Key.'f expand("%:e") !~ "'.g:QFixHowm_FileExt.'" ? ":call FGrep(\"\", -1, 0)<CR>" : "'.s:QFixHowm_Key.'s"'
  exec 'silent! vmap     <silent> <expr> '.s:QFixHowm_Key.'v expand("%:e") !~ "'.g:QFixHowm_FileExt.'" ? ":call VGrep(\"\", -1, 0)<CR>" : "'.s:QFixHowm_Key.'\\g"'
  exec "silent! nnoremap <unique> <silent> ".s:QFixHowm_Key."d :call QFixHowmInsertDate('Date')<CR>"
  exec "silent! nnoremap <unique> <silent> ".s:QFixHowm_Key."T :call QFixHowmInsertDate('Time')<CR>"
endif

"howmバッファローカルキーマップ
if g:QFixHowm_Default_KeyCmd > 0
  augroup QFixHowm_Key
    autocmd!
    exec "autocmd BufWinEnter  *.".g:QFixHowm_FileExt." call s:SetbuflocalKey()"
    autocmd BufWinEnter  quickfix exec "silent! nnoremap <silent> <buffer> " . s:QFixHowm_Key . ". :call QFixHowmMoveTodayReminder()<CR>"
    autocmd BufWinEnter  quickfix exec "silent! nnoremap <silent> <buffer> " . g:QFixHowm_Key . ". :call QFixHowmMoveTodayReminder()<CR>"
  augroup END
endif

"
"howmバッファローカルキーマップ
"
function! s:SetbuflocalKey()
  if g:QFixHowm_UseAutoLinkTags
    exec "silent! nnoremap <silent> <buffer> <C-]> :<C-u>if !QFixHowmOpenClink() <Bar> exec 'normal! <C-]>' <Bar> endif<CR>"
    exec "silent! vnoremap <silent> <buffer> <C-]> :<C-u>if !QFixHowmOpenClink() <Bar> exec 'normal! <C-]>' <Bar> endif<CR>"
    exec "silent! nnoremap <silent> <buffer> g<C-]> :<C-u>if !QFixHowmOpenClink() <Bar> exec 'normal! <C-]>' <Bar> endif<CR>"
    exec "silent! vnoremap <silent> <buffer> g<C-]> :<C-u>if !QFixHowmOpenClink() <Bar> exec 'normal! <C-]>' <Bar> endif<CR>"
  endif
  exec "silent! nnoremap <unique> <silent> <buffer> <CR> :<C-u>call QFixHowmActionLock()<CR>"
  exec "silent! nnoremap <unique> <silent> <buffer> ".s:QFixHowm_Key."C :call QFixHowmInsertEntry('cnext')<CR>"
  exec "silent! nnoremap <unique> <silent> <buffer> ".s:QFixHowm_Key."n :QFixHowmCursor next<CR>:call QFixHowmInsertEntry('next')<CR>"
  exec "silent! nnoremap <unique> <silent> <buffer> ".s:QFixHowm_Key."N :QFixHowmCursor bottom<CR>:call QFixHowmInsertEntry('bottom')<CR>"
  exec "silent! nnoremap <unique> <silent> <buffer> ".s:QFixHowm_Key."p :QFixHowmCursor prev<CR>:call QFixHowmInsertEntry('prev')<CR>"
  exec "silent! nnoremap <unique> <silent> <buffer> ".s:QFixHowm_Key."P :QFixHowmCursor top<CR>:call QFixHowmInsertEntry('top')<CR>"
  exec "silent! nnoremap <unique> <silent> <buffer> ".s:QFixHowm_Key."o :call QFixHowmOutline()<CR>"
  exec "silent! nnoremap <unique> <silent> <buffer> ".s:QFixHowm_Key."S :call QFixHowmInsertLastModified(1)<CR>"
  exec "silent! nnoremap <unique> <silent> <buffer> ".s:QFixHowm_Key."x :call QFixHowmDeleteEntry()<CR>"
  exec "silent! nnoremap <unique> <silent> <buffer> ".s:QFixHowm_Key."rx :call QFixHowmDeleteEntry()<CR>"
  exec "silent! nnoremap <unique> <silent> <buffer> ".s:QFixHowm_Key."X :call QFixHowmDeleteEntry('move')<CR>"
  exec "silent! nnoremap <unique> <silent> <buffer> ".s:QFixHowm_Key."w :call QFixHowmBufLocalSave()<CR>"
  exec "silent! nnoremap <unique> <silent> <buffer> ".s:QFixHowm_Key."W :call QFixHowmDivideEntry()<CR>"
  exec "silent! vnoremap <unique> <silent> <buffer> ".s:QFixHowm_Key."W :call QFixHowmDivideEntry()<CR>"
  exec "silent! nnoremap <unique> <silent> <buffer> ".s:QFixHowm_Key."rd :QFixHowmGenerateRepeatDate<CR>"
  exec "silent! nnoremap <unique> <silent> <buffer> ".s:QFixHowm_Key."rs :call QFixHowmSortEntry('normal')<CR>"
  exec "silent! nnoremap <unique> <silent> <buffer> ".s:QFixHowm_Key."rS :call QFixHowmSortEntry('reverse')<CR>"
endfunction

"メニューへの登録
if !exists('QFixHowm_MenuBar')
  let QFixHowm_MenuBar = 2
endif

if QFixHowm_MenuBar
  let s:QFixHowm_Key = escape(s:QFixHowm_Key, '\\')
    let s:menu = '&Tools.QFixHowm(&H)'
  if QFixHowm_MenuBar == 2
    let s:menu = 'Howm(&O)'
  elseif QFixHowm_MenuBar == 3 || MyGrep_MenuBar == 3
    let s:menu = 'QFixApp(&Q).QFixHowm(&H)'
  endif
  exec 'amenu <silent> 41.332 '.s:menu.'.CreateNew(&C)<Tab>'.s:QFixHowm_Key.'c  :<C-u>call QFixHowmCreateNewFile()<CR>'
  exec 'amenu <silent> 41.332 '.s:menu.'.Diary(&D)<Tab>'.s:QFixHowm_Key.'<Space>  :call QFixHowmOpenQuickMemo(g:QFixHowm_DiaryFile)<CR>'
  exec 'amenu <silent> 41.332 '.s:menu.'.QuickMemo(&U)<Tab>'.s:QFixHowm_Key.'u  :QFixHowmOpenQuickMemo<CR>'
  exec 'amenu <silent> 41.332 '.s:menu.'.-sep1-			<Nop>'
  if g:QFixHowm_UseMRU
    exec 'amenu <silent> 41.332 '.s:menu.'.MRU(&M)<Tab>'.s:QFixHowm_Key.g:QFixHowm_Key_SearchMRU.' :<C-u>call QFixHowmMru(0)<CR>'
  endif
    exec 'amenu <silent> 41.332 '.s:menu.'.ListRecent(&L)<Tab>'.s:QFixHowm_Key.g:QFixHowm_Key_SearchRecent.' :<C-u>QFixHowmListRecent<CR>'
    exec 'amenu <silent> 41.332 '.s:menu.'.ListRecent(&2)<Tab>'.s:QFixHowm_Key.g:QFixHowm_Key_SearchRecentAlt.' :<C-u>QFixHowmListRecentC<CR>'
    exec 'amenu <silent> 41.332 '.s:menu.'.ListAll(&A)<Tab>'.s:QFixHowm_Key.'a  :<C-u>call QFixHowmListAllTitle(g:QFixHowm_Title, 0)<CR>'
    exec 'amenu <silent> 41.332 '.s:menu.'.-sep2-			<Nop>'
    exec 'amenu <silent> 41.332 '.s:menu.'.FGrep(&S)<Tab>'.s:QFixHowm_Key.'s  :<C-u>call QFixHowmSearchInput("QFixHowm FGrep : ", 0)<CR>'
    exec 'amenu <silent> 41.332 '.s:menu.'.Grep(&G)<Tab>'.s:QFixHowm_Key.'g  :<C-u>call QFixHowmSearchInput("QFixHowm Grep : ", 1)<CR>'
    exec 'amenu <silent> 41.332 '.s:menu.'.Vimgrep(&V)<Tab>'.s:QFixHowm_Key.'\\g  :<C-u>call QFixHowmVSearchInput("QFixHowm VGrep : ", 1)<CR>'
    exec 'amenu <silent> 41.332 '.s:menu.'.-sep3-			<Nop>'
    exec 'amenu <silent> 41.332 '.s:menu.'.Schedule(&Y)<Tab>'.s:QFixHowm_Key.'y  :<C-u>QFixHowmListReminderSche<CR>'
    exec 'amenu <silent> 41.332 '.s:menu.'.Todo(&T)<Tab>'.s:QFixHowm_Key.'t  :<C-u>QFixHowmListReminderTodo<CR>'
    exec 'amenu <silent> 41.332 '.s:menu.'.Menu(&,)<Tab>'.s:QFixHowm_Key.',  :<C-u>QFixHowmOpenMenu<CR>z.'
    exec 'amenu <silent> 41.332 '.s:menu.'.-sep4-			<Nop>'
    exec 'amenu <silent> 41.332 '.s:menu.'.RandomWalk(&R)<Tab>'.s:QFixHowm_Key.'rr/<F5>  :QFixHowmRandomWalk<CR>'
    exec 'amenu <silent> 41.332 '.s:menu.'.-sep5-			<Nop>'
    exec 'amenu <silent> 41.332 '.s:menu.'.howm\ Buffer\ Local(&B).Date(&D)<Tab>'.s:QFixHowm_Key.'d :call QFixHowmInsertDate("Date")<CR>'
    exec 'amenu <silent> 41.332 '.s:menu.'.howm\ Buffer\ Local(&B).Time(&T)<Tab>'.s:QFixHowm_Key.'T :call QFixHowmInsertDate("Time")<CR>'
    exec 'amenu <silent> 41.332 '.s:menu.'.howm\ Buffer\ Local(&B).-sep50-			<Nop>'
    exec 'amenu <silent> 41.332 '.s:menu.'.howm\ Buffer\ Local(&B).Outline(&O)<Tab>'.s:QFixHowm_Key.'o  :call QFixHowmOutline()<CR>'
    exec 'amenu <silent> 41.332 '.s:menu.'.howm\ Buffer\ Local(&B).-sep51-			<Nop>'
    exec 'amenu <silent> 41.332 '.s:menu.'.howm\ Buffer\ Local(&B).NewEntry(&1)<Tab>'.s:QFixHowm_Key.'P :QFixHowmCursor top<CR>:call QFixHowmInsertEntry("top")<CR>'
    exec 'amenu <silent> 41.332 '.s:menu.'.howm\ Buffer\ Local(&B).NewEntry(&P)<Tab>'.s:QFixHowm_Key.'p :QFixHowmCursor prev<CR>:call QFixHowmInsertEntry("prev")<CR>'
    exec 'amenu <silent> 41.332 '.s:menu.'.howm\ Buffer\ Local(&B).NewEntry(&N)<Tab>'.s:QFixHowm_Key.'n :QFixHowmCursor next<CR>:call QFixHowmInsertEntry("next")<CR>'
    exec 'amenu <silent> 41.332 '.s:menu.'.howm\ Buffer\ Local(&B).NewEntry(&B)<Tab>'.s:QFixHowm_Key.'N :QFixHowmCursor bottom<CR>:call QFixHowmInsertEntry("bottom")<CR>'
    exec 'amenu <silent> 41.332 '.s:menu.'.howm\ Buffer\ Local(&B).-sep52-			<Nop>'
    exec 'amenu <silent> 41.332 '.s:menu.'.howm\ Buffer\ Local(&B).DeleteEntry(&X)<Tab>'.s:QFixHowm_Key.'x  :call QFixHowmDeleteEntry()<CR>'
    exec 'amenu <silent> 41.332 '.s:menu.'.howm\ Buffer\ Local(&B).MoveEntry(&M)<Tab>'.s:QFixHowm_Key.'X  :call QFixHowmDeleteEntry("move")<CR>'
    exec 'amenu <silent> 41.332 '.s:menu.'.-sep6-			<Nop>'
    exec 'amenu <silent> 41.332 '.s:menu.'.RebuildKeywordFile(&F)<Tab>'.s:QFixHowm_Key.'rk  :<C-u>call QFixHowmRebuildKeyword()<CR>'
    exec 'amenu <silent> 41.332 '.s:menu.'.RebuildRandomWalkFile(&F)<Tab>'.s:QFixHowm_Key.'rR  :<C-u>call QFixHowmRebuildRandomWalkFile(g:QFixHowm_RandomWalkFile)<CR>:QFixHowmRandomWalk<CR>'
    exec 'amenu <silent> 41.332 '.s:menu.'.-sepH-			<Nop>'
    exec 'amenu <silent> 41.332 '.s:menu.'.Help(&H)<Tab>'.s:QFixHowm_Key.'H  :<C-u>call QFixHowmHelp()<CR>'
  if MyGrep_MenuBar != 1 && QFixHowm_MenuBar == 1
    exec 'amenu <silent> 40.333 &Tools.-sepend-			<Nop>'
  endif
  let s:QFixHowm_Key = g:QFixHowm_Key . g:QFixHowm_KeyB
endif

let s:mru_list_locked = 0
augroup QFixHowm
  autocmd!
  exec "autocmd BufReadPre   *.".g:QFixHowm_FileExt." silent! call QFixHowmInit()"
  exec "autocmd BufReadPost  *.".g:QFixHowm_FileExt." silent! call QFixHowmBufReadPost_()"
  exec "autocmd BufRead,BufNewFile *.".g:QFixHowm_FileExt." exec 'setlocal filetype='.g:QFixHowm_FileType.'| call QFixHowmHighlight()'"
  exec "autocmd BufWritePre  *.".g:QFixHowm_FileExt." call QFixHowmInsertLastModified()|call QFixHowmBufWritePre()"
  exec "autocmd BufWritePost *.".g:QFixHowm_FileExt." call s:QFixHowmBufWritePost()|call QFixHowmBufWritePost()"
  autocmd BufWinEnter quickfix call QFixHowmSetup()
  autocmd VimLeave * silent! call delete(s:uricmdfile)
augroup END

function! QFixHowmBufReadPost_()
  if g:QFixHowm_NoBOM && &bomb
    set nobomb
    "write!
  endif
  if g:QFixHowm_ForceEncoding
    exec 'edit! ++enc='.g:howm_fileencoding.' ++ff='.g:howm_fileformat
  endif
  call QFixHowmBufReadPost()
endfunction

augroup QFixHowmMRU
  autocmd!
  autocmd VimLeave * if s:QFixHowm_Init | call QFixHowmSaveMru(0)| call QFixHowmSaveMru(2) | endif
  exec "autocmd BufRead,BufNewFile,BufEnter    *.".g:QFixHowm_FileExt." call QFixHowmMRUBufEnter()"
  exec "autocmd BufLeave    *.".g:QFixHowm_FileExt." call QFixHowmMRUBufLeave()"
  exec "autocmd CursorMoved *.".g:QFixHowm_FileExt." call QFixHowmMRUCursorMoved()"
  autocmd QuickFixCmdPre  *vimgrep* let s:mru_list_locked = 1
  autocmd QuickFixCmdPost *vimgrep* let s:mru_list_locked = 0
augroup END

function! QFixHowmMRUBufEnter()
  let b:howm_moved = 0
endfunction

function! QFixHowmMRUBufLeave()
  call QFixHowmSaveMru(0)
endfunction

function! QFixHowmMRUCursorMoved()
  if b:howm_moved == 0
    call QFixHowmSaveMru(0)
    let b:howm_moved = 1
  endif
endfunction

"BufReadPost
silent! function QFixHowmBufReadPost()
  call QFixHowmDecode()
endfunction

"BufWritePre
silent! function QFixHowmBufWritePre()
  call QFixHowmEncode()
endfunction

"BufWritePost
silent! function QFixHowmBufWritePost()
  call QFixHowmDecode()
endfunction

silent! function QFixHowmEncode()
endfunction

silent! function QFixHowmDecode()
endfunction

function! QFixHowmSetup(...)
  if &buftype != 'quickfix'
    return
  endif
  if g:QFix_MyJump == 0
    return
  endif
  silent! syntax clear howm*
  let pattern = s:sch_dateT
  let dowpat = '\s*'. g:QFixHowm_DayOfWeekReg . '\?'
  "シンタックスファイルで定義されているhowmSchedule等の色を読み込むためfiletypeを指定
  exec 'setlocal ft='.g:QFixHowm_FileType
  setlocal ft=qf
  exec 'syntax match howmSchedule display "'.pattern.'@\d*' .dowpat.'"'
  exec 'syntax match howmDeadline display "'.pattern.'!\d*' .dowpat.'"'
  exec 'syntax match howmTodo     display "'.pattern.'+\d*' .dowpat.'"'
  exec 'syntax match howmReminder display "'.pattern.'-\d*' .dowpat.'"'
  exec 'syntax match howmTodoUD   display "'.pattern.'\~\d*'.dowpat.'"'
  exec 'syntax match howmFinished display "'.pattern.'\."'
  let pattern = ' \?'. g:QFixHowm_ReminderHolidayName
  exec 'syntax match howmHoliday display "'.pattern .'"'
  if exists('g:QFixHowm_UserHolidayName')
    let pattern = ' \?'.g:QFixHowm_UserHolidayName
    exec 'syntax match howmHoliday display "'.pattern .'"'
  endif
  if exists('g:QFixHowm_UserSpecialdayName')
    let pattern = ' \?'.g:QFixHowm_UserSpecialdayName
    exec 'syntax match howmSpecial display "'.pattern .'"'
  endif
  if a:0
    return
  endif

"  vnoremap <buffer> <silent> <CR>    :call QFixHowmCmd_CR(0)<CR>
"  vnoremap <buffer> <silent> <S-CR>  :call QFixHowmCmd_CR(1)<CR>
  if exists("*QFixHowmExportSchedule")
    nnoremap <buffer> <silent> !  :call QFixHowmCmd_ScheduleList()<CR>
    vnoremap <buffer> <silent> !  :call QFixHowmCmd_ScheduleList('visual')<CR>
  endif
  nnoremap <buffer> <silent> @  :call QFixHowmCmd_AT('normal')<CR><ESC>
  vnoremap <buffer> <silent> @  :call QFixHowmCmd_AT('visual')<CR><ESC>
  nnoremap <buffer> <silent> &  :call QFixHowmCmd_AT('user')<CR><ESC>:call QFixHowmUserCmd(g:QFixHowm_MergeList)<CR>
  vnoremap <buffer> <silent> &  :call QFixHowmCmd_AT('user visual')<CR><ESC>:call QFixHowmUserCmd(g:QFixHowm_MergeList)<CR>
  nnoremap <buffer> <silent> x  :call QFixHowmCmd_X()<CR>
"  vnoremap <buffer> <silent> x  :call QFixHowmCmd_X()<CR>
  nnoremap <buffer> <silent> X  :call QFixHowmCmd_X('move')<CR>
"  vnoremap <buffer> <silent> X  :call QFixHowmCmd_X('move')<CR>
  nnoremap <buffer> <silent> S  :call QFixHowmCmd_Sort()<CR>
  nnoremap <buffer> <silent> D  :call QFixHowmCmd_RD('Delete')<CR>
  vnoremap <buffer> <silent> D  :call QFixHowmCmd_RD('Delete')<CR>
  nnoremap <buffer> <silent> R  :call QFixHowmCmd_RD('Remove')<CR>
  vnoremap <buffer> <silent> R  :call QFixHowmCmd_RD('Remove')<CR>
  nnoremap <buffer> <silent> #  :call QFixHowmCmd_Replace('remove')<CR>
  nnoremap <buffer> <silent> %  :call QFixHowmCmd_Replace('title')<CR>
  nnoremap <buffer> <silent> <F5>  :QFixHowmRandomWalk<CR>
  exec 'silent! nnoremap <buffer> <silent> '.s:QFixHowm_Key.'w :MyGrepWriteResult<CR>'
endfunction

"howmファイルのセーブ後処理
function! s:QFixHowmBufWritePost()
  if getfsize(expand('%:p')) <= 0
    call delete(expand('%:p'))
    return
  endif
  call QFixHowmAddKeyword()
  call QFixHowmSaveMru(-1)
  call QFixHowmSaveMru(0)
endfunction

"書き込み時の日付更新用フラグ
let g:QFixHowm_WriteUpdateTime = 1

"Howmファイルの書き込み時に更新時間を書き込む。
"TODO:編集位置を自分で全て探して自動で変更する。
function! QFixHowmInsertLastModified(...)
  let saved_reg = @/
  if g:QFixHowm_RecentMode == 0 && g:QFixHowm_SaveTime == -1
    let g:QFixHowm_WriteUpdateTime = 0
  endif
  call s:Autoformat()
  let save_cursor = getpos('.')
  let l:QFixHowm_Title = escape(g:QFixHowm_Title, g:QFixHowm_EscapeTitle)
  let l:QFixHowm_Title = l:QFixHowm_Title.'\(\s\|$\)'
  if g:QFixHowm_WriteUpdateTime > 0 || a:0
    "タイトルのみのエントリに自動で更新時刻を付加する。
    call cursor('1', '1')
    let fline = search('^'.l:QFixHowm_Title, 'ncW')
    if fline > 0
      call cursor(fline, '1')
      while 1
        let endline = search('^'.l:QFixHowm_Title, 'nW')
        if endline == 0
          let endline = line('$')
        endif
        let pattern = '^'.s:sch_dateTime.'\('.s:sch_notExt.'\|$\)'
        if g:QFixHowm_RecentMode == 3 || g:QFixHowm_RecentMode == 4
"          let pattern = '^'.s:sch_dateTime.' '. s:Recentmode_Date.'$'
        endif
        let timeline = search(pattern, 'nW')
        if timeline == 0 || timeline > endline
          silent! put='['.strftime(s:hts_dateTime).']'
        endif
        if search('^'.l:QFixHowm_Title, 'W') == 0
          break
        endif
      endwhile
    endif
    if g:QFixHowm_RecentMode > 0 || g:QFixHowm_SaveTime > 0 || a:0
      call setpos('.', save_cursor)
      call s:GetChanges(a:0)
      call setpos('.', save_cursor)
    endif
  endif
  let g:QFixHowm_WriteUpdateTime = 1
  "空白のタイトル行に適当な文字列設定。
  if g:QFixHowm_Replace_Title_Len > 0
    call cursor('1', '1')
    while 1
      let pattern = g:QFixHowm_Replace_Title_Pattern
      if search(pattern, 'cW') == 0
        break
      endif
      let title = substitute(getline('.'), '\s*$', '', '')
      let tline = line('.')
      while 1
        call cursor(line('.')+1, '1')
        let str = getline('.')
        if str =~ '^' . l:QFixHowm_Title
          let str = ''
          break
        endif
"        if str !~ '^\[\d\{4}-\d\{2}-\d\{2}' && str !~ '^\s*$'
        if str !~ '^\s*'.s:sch_dateT && str !~ '^\s*$'
          break
        endif
        let str = ''
        if line('.') == line('$')
          break
        endif
      endwhile
      if str != ''
        call cursor(tline, '1')
        let len = strlen(str)
        let str = substitute(str, '\%>'.g:QFixHowm_Replace_Title_Len.'v.*','','')
        "let str = matchstr(str, '.\{'.g:QFixHowm_Replace_Title_Len/2.'}')
        if strlen(str) != len
          let str = str . '...'
        endif
        let pstr = getline('.')
        let rstr = title. ' '.str
        if pstr !~ escape(rstr, '[].*~\')
"          delete _
"          silent! -1put=rstr
          let sline = line('.')
          call setline(sline, [rstr])
        endif
      endif
      call cursor(tline+1, '1')
    endwhile
    call setpos('.', save_cursor)
  endif
  let @/ = saved_reg
  call setpos('.', save_cursor)
  "エントリ間の連続空白行を消去
  if g:QFixHowm_Autoformat > 1
    call cursor('1', '1')
    let n = search('^=', 'ncW')+1
    if n > 1
      silent! exec n.',$s/^=/\r=/'
      silent! exec '%s/\_s*[\n\r]=/\r\r=/'
    endif
  endif
  call setpos('.', save_cursor)
  unlet saved_reg
  unlet save_cursor
  return ''
endfunction

"
"howmファイルの自動整形
"
function! s:Autoformat()
  if g:QFixHowm_NoBOM
    set nobomb
  endif
  if g:QFixHowm_Autoformat == 0
    return
  endif
  let file = expand('%:t')
  if file =~ g:QFixHowm_Menufile
    return
  endif
  let save_cursor = getpos('.')
  let l:QFixHowm_Title = escape(g:QFixHowm_Title, g:QFixHowm_EscapeTitle)
  "ファイル先端からの連続空白行を消去
"    silent! exec 's/\_s*//'
  for i in range(line('$'))
    if getline(1) =~ '^\s*$'
      exec '1delete _'
    else
      break
    endif
  endfor
  let save_cursor[1] = save_cursor[1]-i
  call setpos('.', save_cursor)

  "一行しかなくて、空白行なら終了。
  if line('$') == 1 && getline('.') =~ '^\s*$'
    exec '1delete _'
    silent! setlocal binary noendofline
    return
  endif
  "予定やTODOの行と空白しかないなら終了
  let spattern = '^'.s:sch_dateT.s:sch_Ext.'\|^\s*$'
  call cursor(1, 1)
  while 1
    if getline('.') !~ spattern
      break
    endif
    let endline = search('^.\+$', 'W')
    if endline == 0
      call s:deleteNullLines()
      call setpos('.', save_cursor)
      return
    endif
  endwhile
  let pattern = g:QFixHowm_MergeEntrySeparator
  let pattern = '^\(' . l:QFixHowm_Title . '\{2,}'. '\|' .g:QFixHowm_MergeEntrySeparator . '\)'

  "１行目は必ずタイトル行にする
  let l:eQFixHowm_Title = escape(g:QFixHowm_Title, '&/')
  call cursor(1, 1)
  if getline('.') !~ '^'.l:QFixHowm_Title && getline('.') !~ pattern && getline('.') !~ spattern
    exec "0put='".g:QFixHowm_Title . " '"
  else
    "一行目のみ、ちゃんとタイトル＋空白になってなかったら整形
    if getline('.') !~ '^'.l:QFixHowm_Title. ' ' && getline('.') !~ pattern
"      silent! exec 's/^'.l:QFixHowm_Title.'/'.l:eQFixHowm_Title.' /'
"      silent! exec 's/^'.l:QFixHowm_Title.'\s*/'.l:eQFixHowm_Title.' /'
      let rstr = substitute(getline('.'), l:QFixHowm_Title.'\s*', l:eQFixHowm_Title.' ', '')
"      silent! put=rstr
"      -1delete _
      let sline = line('.')
      call setline(sline, [rstr])
    endif
  endif
  call setpos('.', save_cursor)
  "全てのタイトル行を整形
  if g:QFixHowm_Autoformat_TitleMode == 1
    call cursor(1, 1)
    "カレントエントリのみなら
  "  call search('^'.l:QFixHowm_Title, 'cbW')
    while 1
      if getline('.') !~ '^'.l:QFixHowm_Title. ' ' && getline('.') !~ pattern
"        silent! exec 's/^'.l:QFixHowm_Title.'/'.l:eQFixHowm_Title.' /'
"        silent! exec 's/^'.l:QFixHowm_Title.'\s*/'.l:eQFixHowm_Title.' /'
        let rstr = substitute(getline('.'), l:QFixHowm_Title.'\s*', l:eQFixHowm_Title.' ', '')
"        silent! put=rstr
"        -1delete _
        let sline = line('.')
        call setline(sline, [rstr])
      endif
      "カレントエントリのみならここで終了
      if search('^'.l:QFixHowm_Title.'\S', 'W') == 0
        break
      endif
    endwhile
  endif

  "ファイル末尾を空白一行に
  call s:deleteNullLines()
  call setpos('.', save_cursor)
endfunction

function! s:deleteNullLines()
  "ファイル末尾を空白一行に
  call cursor(line('$'), 1)
  let endline = line('.')
  if getline('.') !~ '^$'
    exec "put=''"
  else
    let firstline = search('^.\+$', 'nbW')
    if firstline == 0
      return
    endif
    if firstline < endline - 1
      call cursor(firstline+1, 1)
      silent! exec 's/\_s*//'
    endif
  endif
endfunction

"
"エントリ内の時間を更新
"
function! s:GetChanges(amode)
  let amode = 1
  let mode = 1
  let pattern = '^'.s:sch_dateTime.'\('.s:sch_notExt.'\|$\)'
  if g:QFixHowm_RecentMode == 0
    if g:QFixHowm_SaveTime == 0 || g:QFixHowm_SaveTime == 2 || g:QFixHowm_SaveTime == 4
      let amode = 0
    endif
    if g:QFixHowm_SaveTime == 3 || g:QFixHowm_SaveTime == 4
      let mode = 2
    endif
  endif
  if g:QFixHowm_RecentMode == 2 || g:QFixHowm_RecentMode == 4
    let amode = 0
  endif
  if a:amode
    let amode = 0
  endif
  if g:QFixHowm_RecentMode == 3 || g:QFixHowm_RecentMode == 4
    let mode = 2
  endif
  if mode == 2
    let pattern = '\(^'.s:sch_dateTime.'\)\s*\('.s:Recentmode_Date.'\)\?'
  endif
  let l:QFixHowm_Title = escape(g:QFixHowm_Title, g:QFixHowm_EscapeTitle)
  let l:QFixHowm_Title = l:QFixHowm_Title.'\(\s\|$\)'

  let save_cursor = getpos('.')
  call search('^'.l:QFixHowm_Title, 'cbW')
  if amode
    call cursor(1, 1)
    if search('^'.l:QFixHowm_Title, 'cW') == 0
      call cursor(line('$'), 1)
    endif
  endif
  while 1
    if line('.') == line('$')
      break
    endif
    let endline = search('^'.l:QFixHowm_Title, 'nW')
    if endline == 0
      let endline = line('$')
    endif
    let timeline = search(pattern, 'W')
    if timeline && timeline < endline
      if mode == 1
"        let cmd = 's/'.escape(pattern, '/').'/'.'['.escape(strftime(s:hts_dateTime), '/').']\1'.'/e'
"        silent! exec cmd
        let rstr = substitute(getline('.'), pattern, '['.strftime(s:hts_dateTime).']\1', '')
"        silent! put=rstr
"        -1delete _
        let sline = line('.')
        call setline(sline, [rstr])
      elseif mode == 2
        let rpattern = '\(^'.s:sch_dateTime.'\) \('.s:Recentmode_Date.'\)'
        "let cmd  = 's/'.rpattern.'/'.'\1'.'/e'
        let rstr = substitute(getline('.'), rpattern, '\1', '')
        let rpattern = '\(^'.s:sch_dateTime.'\)\('.s:sch_notExt.'\|$\)'
"        let cmd2 = 's/'.rpattern.'/'.'\1 ('.strftime('%Y%m%d%H%M').')\2'.'/e'
        let rstr = substitute(rstr,  rpattern, '\1 ('.strftime('%Y%m%d%H%M').')\2', '')
"        silent! exec cmd
"        silent! exec cmd2
"        silent! put=rstr
"        -1delete _
        let sline = line('.')
        call setline(sline, [rstr])
      endif
    endif
    if amode == 0
      break
    endif
    call cursor(endline, '1')
  endwhile
  call setpos('.', save_cursor)
endfunction

"
"検索のフロントエンド
"
function! QFixHowmVSearchInput(title, isRegxp, ...)
  let g:MyGrep_UseVimgrep = 1
  let mode = ''
  if a:0
    let mode = 'visual'
  endif
  return QFixHowmSearchInput(a:title, a:isRegxp, mode)
endfunction

function! QFixHowmSearchInput(title, isRegxp, ...)
  let pattern = expand("<cword>")
  let text = getline('.')
  let link = match(text, '\('.g:howm_clink_pattern.'\|'.g:howm_glink_pattern.'\)')
  if link > -1 && col('.') > link
    let pattern = matchstr(text, '\('.g:howm_clink_pattern.'\|'.g:howm_glink_pattern.'\)\s*.*$')
    let pattern = substitute(pattern, '^\('.g:howm_clink_pattern.'\|'.g:howm_glink_pattern.'\)\s*', '', '')
  endif
  if a:0 && a:1 == 'visual'
    exec 'normal! vgvy'
    let pattern = input(a:title, @0)
  else
    if g:QFixHowm_DefaultSearchWord == 0
      let pattern = ''
    endif
    let pattern = input(a:title, pattern)
  endif
  if pattern == ''
    let MyGrep_UseVimgrep = 0
    return
  endif
  call QFixHowmSearch(pattern, a:isRegxp)
endfunction

function! QFixHowmSearch(pattern, isRegxp)
  let g:MyGrep_Regexp = a:isRegxp
  call QFixHowmListAll(a:pattern, 0)
endfunction

"
"patternをhowm_dirから検索して、現在からdays日以内のnum件を登録。
"days,numともに0ならすべて。
"
function! QFixHowmListAllTitle(pattern, days, ...)
  let pattern = escape(g:QFixHowm_Title, g:QFixHowm_EscapeTitle)
  if !exists('g:mygrepprg') || g:mygrepprg == 'internal' || g:mygrepprg == ''
    let pattern = '^'. pattern . '\(\s\|$\)'
  elseif g:mygrepprg == 'findstr'
    let pattern = '^'. pattern . '[ \t]'
  else
    let pattern = '^'. pattern . '([ 	]|$)'
  endif
  let s:QFixHowm_FileListSort = g:QFixHowm_AllTitleSearchSort
  if a:0
    let s:QFixHowm_FileListSort = a:1
  endif
  let s:UseTitleFilter = 1
  call QFixHowmListAll(pattern, a:days)
endfunction

let s:QFixHowm_FileListSort = 1
function! QFixHowmListAll(pattern, days)
  if QFixHowmInit()
    return
  endif
"  call QFixSaveHeight(0)
  let attop = 0
  let addflag = 0
  let pattern = a:pattern
  if match(pattern, '\C[A-Z]') != -1
    let g:MyGrep_Ignorecase = 0
  endif
  if a:pattern =~ '^'.g:howm_glink_pattern
    let attop = 1
    let pattern = substitute(pattern, '^'.g:howm_glink_pattern, '', '')
  endif
  if a:pattern =~ '^'.g:howm_clink_pattern
    let attop = 1
    let pattern = substitute(pattern, '^'.g:howm_clink_pattern, '', '')
  endif
  let @/=pattern
  if exists('+autochdir')
    let saved_ac = &autochdir
"    set noautochdir
  endif
  let prevPath = getcwd()
  let prevPath = escape(prevPath, ' ')
  let l:howm_dir = g:howm_dir
  silent exec 'lchdir ' . escape(l:howm_dir, ' ')
  let gpattern = pattern
  if a:days
    let g:MyGrep_FileListWipeTime = localtime() - a:days*24*60*60
  endif
  CloseQFixWin
  redraw|echo 'QFixHowm : Searching...'
  let addflag = MultiHowmDirGrep(gpattern, l:howm_dir, g:QFixHowm_SearchHowmFile, g:howm_fileencoding, addflag)
  silent exec 'lchdir ' . escape(l:howm_dir, ' ')
  call MyGrep(gpattern, l:howm_dir, g:QFixHowm_SearchHowmFile, g:howm_fileencoding, addflag)
  let wlist = []
  let clist = []
  if s:QFixHowm_FileListSort == -1
    let sq = reverse(getqflist())
    let s:QFixHowm_FileListSort = 1
  elseif s:QFixHowm_FileListSort == 0
    let sq = QFixHowmSort('mtime', a:days)
    let s:QFixHowm_FileListSort = 1
  else
    if g:QFixHowm_RecentMode && g:QFixHowm_HowmTimeStampSort
      let sq = QFixHowmSort('howmtime', a:days)
    else
      let sq = QFixHowmSort('mtime', a:days)
    endif
    let attop = 1
    let l:QFixHowm_Title = escape(g:QFixHowm_Title, g:QFixHowm_EscapeTitle)
    let l:QFixHowm_Title = l:QFixHowm_Title.'\(\s\|$\)'
    if a:pattern =~ '\^'.l:QFixHowm_Title
      let attop = 0
    endif
      "<<<自身は必ず先頭へ
    let tpattern = pattern
    if a:0 == 0
      let tpattern = escape(pattern, '[].*~\')
    endif
    if attop == 1
      let idx = 0
      for d in sq
        if d.text =~ '\[\[\s*'.tpattern.'\s*\]\]'
          if g:QFixHowm_WikiLink_AtTop > 0
            let top = remove(sq, idx)
            call add(wlist, top)
            continue
          endif
        endif
        if d.text =~ g:howm_clink_pattern.'\s*'.tpattern
          let top = remove(sq, idx)
          call add(clist, top)
          continue
        endif
        let idx = idx + 1
      endfor
    endif
  endif
  let sq = clist + wlist + sq
  call QFixHowmTitleFilter(sq)
  call MyGrepSetqflist(sq)
  silent exec 'lchdir ' . escape(g:howm_dir, ' ')
  if empty(sq)
    redraw | echo 'QFixHowm : Not found!'
  else
    QFixCopen
    redraw|echo ''
  endif
  if g:MyGrep_ErrorMes != ''
    echohl ErrorMsg
    redraw | echo g:MyGrep_ErrorMes
    echohl None
  endif
  if exists('+autochdir')
    let &autochdir = saved_ac
  endif
"  silent exec 'lchdir ' . prevPath
  if g:QFix_PreviewUpdatetime == 0
    call QFixPreview()
  endif
endfunction

"
"ソート関数、days日前より古いのは破棄
"
function! QFixHowmSort(cmd, days)
  let lasttime = localtime() - a:days*24*60*60
  let cmd = a:cmd
  redraw|echo 'QFixHowm : ('.cmd.')'.' Sorting...'
  if a:days == 0
    let lasttime = 0
  endif
  let save_qflist = getqflist()
  let bname = ''
  let bmtime = 0
  let idx = 0
  if cmd == 'howmtime'
    if g:QFixHowm_RecentMode > 0
      let pattern = '^'.s:sch_dateTime
      if g:QFixHowm_RecentMode == 3 || g:QFixHowm_RecentMode == 4
        let pattern = s:Recentmode_Date
      endif
"      let start = reltime()
      call QFixHowmSetTtime(save_qflist, pattern)
"      echom reltimestr(reltime(start))
      let save_qflist = sort(save_qflist, "QFixHowmCompareTime")
      let g:QFix_Sort = 'mtime'
      let g:QFix_SelectedLine = 1
      redraw | echo ''
      return save_qflist
    endif
    let cmd = 'mtime'
  endif
  if cmd == 'mtime'
    for d in save_qflist
      if bname == bufname(d.bufnr)
        let d['mtime'] = bmtime
      else
        let d['mtime'] = getftime(bufname(d.bufnr))
      endif
      let bname  = bufname(d.bufnr)
      let bmtime = d.mtime
      if d.mtime < lasttime
        call remove(save_qflist, idx)
      else
        let idx = idx + 1
      endif
    endfor
    let save_qflist = sort(save_qflist, "QFixCompareTime")
    let g:QFix_Sort = 'mtime'
  elseif cmd == 'ttime'
    if g:QFixHowm_RecentMode > 0
      let pattern = s:sch_dateTime
      if g:QFixHowm_RecentMode == 3 || g:QFixHowm_RecentMode == 4
        let pattern = s:Recentmode_Date
      endif
      for d in save_qflist
        let t = matchstr(d.text, pattern)
        let t = substitute(t, '[^0-9]', '', 'g')
        let d['time'] = t
      endfor
      let save_qflist = sort(save_qflist, "QFixHowmCompareTime")
    else
      let save_qflist = sort(save_qflist, "QFixCompareText")
      let save_qflist = reverse(save_qflist)
    endif
    let g:QFix_Sort = 'mtime'
  elseif cmd == 'text'
    let save_qflist = sort(save_qflist, "QFixCompareText")
    let g:QFix_Sort = 'text'
  elseif cmd == 'name'
    let save_qflist = sort(save_qflist, "QFixCompareName")
    let g:QFix_Sort = 'name'
  endif
  let g:QFix_SelectedLine = 1
  redraw | echo ''
  return save_qflist
endfunction

"
"QFixHowm_RecentMode > 0 の更新時間ソート
"
function! QFixHowmCompareTime(v1, v2)
  if a:v1.time == a:v2.time
    if bufname(a:v1.bufnr) == bufname(a:v2.bufnr)
      return (a:v1.lnum > a:v2.lnum?1:-1)
    else
      return (bufname(a:v1.bufnr) < bufname(a:v2.bufnr)?1:-1)
    endif
  endif
  return (a:v1.time < a:v2.time?1:-1)
endfunction

"
" 過去days日以内のエントリの検索
" 実行時にカウントが指定されていたら、カウント日以内のエントリを検索する。
"
command! -count -nargs=* QFixHowmListRecent if count > 0|let g:QFixHowm_RecentDays = count|endif|call QFixHowmListRecent(g:QFixHowm_Title, g:QFixHowm_RecentDays)
command! -count -nargs=* QFixHowmListRecentC if count > 0|let g:QFixHowm_RecentDays = count|endif|call QFixHowmListRecent(g:QFixHowm_Title, g:QFixHowm_RecentDays, 'Last Create')
function! QFixHowmListRecent(pattern, days, ...)
  if QFixHowmInit()
    return
  endif
  let addflag = 0
  let days = a:days
  let pattern = a:pattern
  let s:UseTitleFilter = 1
"  echo a:pattern a:days a:num pattern days
  let mtime_mode = 0
  if g:QFixHowm_RecentMode == 0 && g:QFixHowm_RecentSearchMode == 0
    let mtime_mode = 1
  endif
  if a:0
    let mtime_mode = !mtime_mode
  endif
  if mtime_mode || g:mygrepprg == 'findstr'
    let l:QFixHowm_HowmTimeStampSort = g:QFixHowm_HowmTimeStampSort
    if (g:QFixHowm_RecentMode != 0 || g:QFixHowm_RecentSearchMode != 0) && a:0
      let g:QFixHowm_HowmTimeStampSort = 0
    endif
    call QFixHowmListAllTitle(pattern, days, 1)
    if g:mygrepprg == 'findstr'
      let sq = QFixHowmSort('howmtime', days)
      "call MyGrepSetqflist(sq)
    endif
    let g:QFixHowm_HowmTimeStampSort = l:QFixHowm_HowmTimeStampSort
    return
  endif
  let pattern = '^'.a:pattern
"  call QFixSaveHeight(0)
  if exists('+autochdir')
    let saved_ac = &autochdir
"    set noautochdir
  endif
  CloseQFixWin
  let prevPath = getcwd()
  let prevPath = escape(prevPath, ' ')
  let l:howm_dir = g:howm_dir
  silent exec 'lchdir ' . escape(g:howm_dir, ' ')
  if !exists('g:mygrepprg') || g:mygrepprg == 'internal' || g:mygrepprg == ''
    if g:QFixHowm_RecentMode == 3 || g:QFixHowm_RecentMode == 4
      let searchWord = '^'.s:sch_dateTime.' (\('.strftime('%Y%m%d')
      for day in range(1,l:days-1,1)
        let searchWord = searchWord . '\|' . strftime('%Y%m%d', localtime()-(day*24*60*60))
      endfor
      let searchWord = searchWord . '\)'
    else
      let searchWord = '^\[\('.strftime(s:hts_date)
      for day in range(1,l:days-1,1)
        let searchWord = searchWord . '\|' . strftime(s:hts_date, localtime()-(day*24*60*60))
      endfor
      let searchWord = searchWord . '\) \('.s:sch_time.'\)*\]\('.s:sch_notExt.'\|$\)'
    endif
    let g:MyGrep_UseVimgrep = 1
  else
    if g:QFixHowm_RecentMode == 3 || g:QFixHowm_RecentMode == 4
"      let searchWord = '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}\] \(('.strftime('%Y%m%d')
      let searchWord = '^\['.s:sch_ExtGrep.'\] \(('.strftime('%Y%m%d')
      for day in range(1,l:days-1,1)
        let searchWord = searchWord . '|'.strftime('%Y%m%d', localtime()-(day*24*60*60))
      endfor
      let searchWord = searchWord.')'
    else
      let searchWord = '^\[('.strftime(s:hts_date)
      for day in range(1,l:days-1,1)
        let searchWord = searchWord . '|'.strftime(s:hts_date, localtime()-(day*24*60*60))
      endfor
"      let searchWord = searchWord.') ([0-9]{2}:[0-9]{2})?]([^-@+!~.]|$)'
      let searchWord = searchWord.') ([0-9]{2}:[0-9]{2})?]('.s:sch_notExt.'|$)'
    endif
  endif
  redraw|echo 'QFixHowm : Searching...'
  let addflag = MultiHowmDirGrep(searchWord, g:howm_dir, g:QFixHowm_SearchHowmFile, g:howm_fileencoding, addflag)
  silent exec 'lchdir ' . escape(g:howm_dir, ' ')
  call MyGrep(searchWord, g:howm_dir, g:QFixHowm_SearchHowmFile, g:howm_fileencoding, addflag)

  let sq = QFixHowmSort('ttime', days)
  let idx = 0
  let s:prevfname = ''
  let h = g:QFix_Height
  silent! exec 'split '
  silent! exec 'silent! edit '.s:howmtempfile
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  for d in sq
    let tpat = escape(l:pattern, g:QFixHowm_EscapeTitle)
    let ret = QFixHowmListRecentReplaceTitle(bufname(d.bufnr), tpat, d.lnum)

    if ret[0] != ''
      let d.text = ret[0]
      let d.lnum = ret[1]
    endif
    let idx = idx + 1
  endfor
  silent! exec 'silent! edit '.s:howmtempfile
  setlocal buftype=nofile
"  silent! exec 'silent! normal! 9999999999u'
  silent! bd!
  let g:QFix_Height = h
  call QFixHowmTitleFilter(sq)
  call MyGrepSetqflist(sq)
  silent exec 'lchdir ' . escape(g:howm_dir, ' ')
"  QFixCopen
"  silent exec 'lchdir ' . prevPath
  if g:QFix_SearchPathEnable && g:QFix_SearchPath != ''
    silent exec 'lchdir ' . escape(g:QFix_SearchPath, ' ')
  endif
  if exists('+autochdir')
    let &autochdir = saved_ac
  endif
  let g:howm_dir = l:howm_dir
  if empty(sq)
    CloseQFixWin
    redraw | echo 'QFixHowm : Not found!'
  else
    QFixCopen
    redraw|echo ''
  endif
  if g:QFix_PreviewUpdatetime == 0
    call QFixPreview()
  endif
  return
endfunction

"
"サマリー表示用のタイトル行を探す。
"
let s:prevfname = ''
function! QFixHowmListRecentReplaceTitle(file, pattern, lnum)
  let text = ''
  let lnum = a:lnum
  let retval = [text, lnum]

  let prevPath = getcwd()
  let prevPath = escape(prevPath, ' ')
  let tmpfile = fnamemodify(a:file, ':p')
  if s:prevfname != tmpfile
    silent! %delete _
    if bufloaded(tmpfile) "バッファが存在する場合
      let glist = getbufline(tmpfile, 1, '$')
      call setline(1, glist)
    else
      let tmpfile = escape(tmpfile, ' #%')
      if g:QFixHowm_ForceEncoding
        silent! exec '0read ++enc='.g:howm_fileencoding.' ++ff='.g:howm_fileformat.' '.tmpfile
      else
        silent! exec '0read '.tmpfile
      endif
    endif
  endif
  let s:prevfname = fnamemodify(a:file, ':p')
  call cursor(a:lnum, 1)
  let l:QFixHowm_Title = escape(g:QFixHowm_Title, g:QFixHowm_EscapeTitle)
  let l:QFixHowm_Title = l:QFixHowm_Title.'\(\s\|$\)'
  let pattern = '^'.l:QFixHowm_Title
  call search(pattern, 'cbW')
  let text = getline('.')
  let tlnum = line('.')
  let ext = s:sch_Ext
  let pattern = '^\s*'.s:sch_dateT.ext
  if match(text, '[^[:blank:]\[\]'.g:QFixHowm_Title.']') == -1
    for lnum in range(tlnum + 1, line('$'))
      let alttext = getline(lnum)
      if alttext =~ '^'.l:QFixHowm_Title
        break
      endif
      if match(alttext, '[^-0-9:.@!~+^()* \[\]'.l:QFixHowm_Title.']') > -1
        if match(alttext, pattern) > -1
          continue
        endif
        let text = alttext
        let lnum = line('.')
        let retval = [text, lnum]
        silent exec 'lchdir ' . prevPath
        return retval
        return text
      endif
    endfor
  endif
  if text =~ a:pattern
    let lnum = line('.')
    let retval = [text, lnum]
    silent exec 'lchdir ' . prevPath
    return retval
    return text
  endif
  let lnum = line('.')
  let retval = [text, lnum]
  silent exec 'lchdir ' . prevPath
  return retval
endfunction

"
"カレントバッファのエントリリストを得る
"
function! QFixHowmGetEntryList()
  let save_cursor = getpos('.')
  let l:QFixHowm_Title = escape(g:QFixHowm_Title, g:QFixHowm_EscapeTitle)
  let l:QFixHowm_Title = l:QFixHowm_Title.'\(\s\|$\)'
  let elist = []
  call cursor('1', '1')
  let fline = search('^'.l:QFixHowm_Title, 'ncW')
  if fline > 0
    call cursor(fline, '1')
    while 1
      let endline = search('^'.l:QFixHowm_Title, 'nW')-1
      if endline <= 0
        let endline = line('$')
      endif
      let pattern = '^'.s:sch_dateTime. '\('.s:sch_notExt.'\|[\n\r]\)'
      let timeline = search(pattern, 'nW')
      if timeline == 0 || timeline > endline
        "ここでQFixHowm_RecentModeで場合分けして更新時間をゲット
        let tline = 0
      else
        let tline = getline(timeline)
        if g:QFixHowm_RecentMode == 0 || g:QFixHowm_RecentMode == 1 || g:QFixHowm_RecentMode == 2
          let pattern = '^'.s:sch_dateTime
        elseif g:QFixHowm_RecentMode == 3 || g:QFixHowm_RecentMode == 4
          let pattern = s:Recentmode_Date
        endif
        let tline = matchstr(tline, pattern)
        let tline = substitute(tline, '[^0-9]', '', 'g')
        if tline == ''
          let tline = 0
        endif
      endif
      let text = ''
      for i in range(fline, endline)
        let text = text . getline(i) . "\<NL>"
      endfor
      let ttext = getline(fline)
      let mydict = {'fline':fline, 'eline':endline, 'mtime':tline, 'text':text, 'title':ttext}
      call add(elist, mydict)
      let fline = endline+1
      if search('^'.l:QFixHowm_Title, 'W') == 0
        break
      endif
    endwhile
    call setpos('.', save_cursor)
    return elist
  endif
  call setpos('.', save_cursor)
  return []
endfunction

"
"カレントバッファのエントリを更新時間順にソート
"
function! QFixHowmSortEntry(mode)
  let elist = QFixHowmGetEntryList()
  if elist == []
    return
  endif
  "ソートする
  if a:mode == 'normal'
    let elist = sort(elist, "QFixHowmSortEntryMtime")
  else
    let elist = sort(elist, "QFixHowmSortEntryMtimeR")
  endif
  "書き換え
  silent! %delete _
  for d in elist
    silent! put=d.text
  endfor
  call cursor(1, 1)
  silent! delete _
  let g:QFixHowm_WriteUpdateTime = 0
  write
  unlet! elist
endfunction

function! QFixHowmSortEntryMtime(v1, v2)
  return (a:v1.mtime <= a:v2.mtime?1:-1)
endfunction
function! QFixHowmSortEntryMtimeR(v1, v2)
  return (a:v1.mtime >= a:v2.mtime?1:-1)
endfunction
"
"カーソル位置のエントリを削除
"
function! QFixHowmDeleteEntry(...)
  let l:QFixHowm_Title = escape(g:QFixHowm_Title, g:QFixHowm_EscapeTitle)
  let l:QFixHowm_Title = l:QFixHowm_Title.'\(\s\|$\)'
  let startline = search('^'.l:QFixHowm_Title, 'ncbW')
  let endline = search('^'.l:QFixHowm_Title, 'nW')-1
  if endline <= 0
    let endline = line('$')
  endif
  let pattern = '^\s*'.s:sch_dateCmd
  let sstartline = search(pattern, 'ncbW')
  if sstartline > startline
    let startline = sstartline
    let sendline = search(pattern, 'nW')-1
    if sendline > 0 && sendline < endline
      let endline = sendline
    elseif getline(endline) == ''
      let endline = endline - 1
    endif
  endif
  let lline = endline
  if lline < startline
    let lline = startline
  endif
  let mod = &modified
  silent exec startline.','.lline.'d'
  if &hidden == 0
    let g:QFixHowm_WriteUpdateTime = 0
    write!
  endif
  if a:0
    let l:howm_filename = g:howm_filename
    let g:howm_filename = matchstr(g:howm_filename, '^.*/').g:QFixHowm_GenerateFile
    call QFixHowmCreateNewFile()
    let g:howm_filename = l:howm_filename
    silent! %delete _
    silent! 0put
    silent! $delete _
    call cursor(1,1)
    call feedkeys("\<ESC>")
    let g:QFixHowm_WriteUpdateTime = 0
    write!
  endif
endfunction

""""""""""""""""""""""""""""""
"QFix拡張コマンド
"""""""""""""""""""""""""""""
function! QFixHowmCmd_CR(mode) range
  let loop = 1
  if a:firstline == a:lastline
    let choice = 1
  else
    let mes = printf("Open files")
    let choice = confirm(mes, "&Yes\n&Cancel", 2)
    if choice != 1
      return
    endif
    let loop = a:lastline - a:firstline + 1
  endif
  let save_cursor = getpos('.')
  let prevPath = getcwd()
  let prevPath = escape(prevPath, ' ')
  for index in range(1, loop)
    if choice == 1
      silent exec 'chdir ' . prevPath
      let lnum = line('.')
      let file = QFixGet('file')
      call cursor(lnum+1, 1)
      let saved_fom = g:QFix_FileOpenMode
      if a:firstline != a:lastline
        let g:QFix_FileOpenMode = 1
      endif
      if g:QFix_SearchPathEnable && g:QFix_SearchPath != ''
        silent exec 'lchdir ' . escape(g:QFix_SearchPath, ' ')
      endif
      call QFixHowmEditFile(getcwd().'/'.file)
      let g:QFix_FileOpenMode = saved_fom
      call Move2QFixWin()
    endif
  endfor
  silent exec 'lchdir ' . prevPath
  call setpos('.', save_cursor)
  wincmd p
endfunction

""""""""""""""""""""""""""""""
function! QFixHowmCmd_X(...) range
  let lnum = QFixGet('lnum')
  let qf = getqflist()
  if len(qf) == 0
    return
  endif
  let l = line('.') - 1
  let lnum = qf[l]['lnum']
  let file = bufname(qf[l]['bufnr'])
  let mes = "!!!Delete Entry!"
  if a:0 > 0
    let mes = "!!!Move Entry!"
  endif
  let choice = confirm(mes, "&Yes\n&Cancel", 2, "W")
  if choice == 1
    call QFixHowmEditFile(file)
"    wincmd p
    call cursor(lnum, 1)
    if a:0 > 0
      call QFixHowmDeleteEntry('move')
    else
      call QFixHowmDeleteEntry()
    endif
    let g:QFixHowm_WriteUpdateTime = 0
    write!
    wincmd p
    let qf = getqflist()
    call remove(qf, l)
    call MyGrepSetqflist(qf)
    call cursor(l+1, 1)
  endif
endfunction

""""""""""""""""""""""""""""""
function! QFixHowmCmd_Sort()
  let mes = 'Sort type? (r:reverse)+(m:mtime, n:name, t:text, h:howmtime) : '
  let pattern = input(mes, '')
  if pattern =~ 'r\?h'
    "CloseQFixWin
    call QFixPclose()
    let qf = QFixHowmSort('howmtime', 0)
    if pattern =~ 'r.*'
      let qf = reverse(qf)
    endif
    call MyGrepSetqflist(qf)
    let g:QFix_SelectedLine = 1
    let g:QFix_SearchResult = []
    QFixCopen
    redraw|echo 'Sorted by HowmTime.'
    return
  endif
  return QFixSortExec(pattern)
endfunction

""""""""""""""""""""""""""""""
function! QFixHowmCmd_RD(cmd) range
  let loop = 1
  if a:firstline != a:lastline
    if a:cmd == 'Delete'
      let mes = "!!!Delete file(s)"
    else
      let mes = "!!!Remove to (~howm_dir)"
    endif
    let choice = confirm(mes, "&Yes\n&Cancel", 2, "W")
    if choice != 1
      return
    endif
    let loop = a:lastline - a:firstline + 1
  endif
  let save_cursor = getpos('.')
  let qf = getqflist()
  let idx = line('.')-1
  for index in range(1, loop)
    let file = QFixGet('file')
    if a:firstline == a:lastline
      if a:cmd == 'Delete'
        let mes = "!!!Delete : ".file
      else
        let mes = "!!!Remove to (~howm_dir) : ".file
      endif
      let choice = confirm(mes, "&Yes\n&Cancel", 2, "W")
    endif
    if choice != 1
      return
    endif
    let dst = substitute(file, '.*/', escape(g:howm_dir, ' ').'/', '')
    let dst = expand(dst)
    let prevPath = getcwd()
    let prevPath = escape(prevPath, ' ')
    if g:QFix_SearchPathEnable && g:QFix_SearchPath != ''
      silent exec 'lchdir ' . escape(g:QFix_SearchPath, ' ')
    endif
    if a:cmd == 'Delete'
      call delete(file)
    else
      call rename(file, dst)
    endif
    call remove(qf, idx)
    call cursor(line('.')+1, 1)
    silent exec 'lchdir ' . prevPath
  endfor
  setlocal modifiable
  silent! exec 'normal! 9999999999u'
  setlocal nomodifiable
  call MyGrepSetqflist(qf)
  QFixCopen
  call setpos('.', save_cursor)
  call QFixPclose()
endfunction

""""""""""""""""""""""""""""""
function! QFixHowmCmd_AT(mode) range
  let save_cursor = getpos('.')
  let prevPath = getcwd()
  let prevPath = escape(prevPath, ' ')
  if exists('+autochdir')
    let saved_ac = &autochdir
"    set noautochdir
  endif

  let flist = []
  let llist = []
  let g:QFixHowm_MergeList = []

  let RegisterBackup = [@0, @1, @2, @3, @4, @5, @6, @7, @8, @9, @/, @", @"]
  if has('gui')
    let RegisterBackup[12] = @*
  endif
  let cnt = line('$')
  let g:QFixHowm_UserCmdline = 0
  let firstline = a:firstline
  if a:firstline != a:lastline || a:mode =~ 'visual'
    let cnt = a:lastline - a:firstline + 1
  else
    let g:QFixHowm_UserCmdline = a:firstline
    let firstline = 1
  endif

  for n in range(cnt)
    call cursor(firstline+n, 1)
    let file = QFixGet('file')
    call add(flist, file)
    let lnum = QFixGet('lnum')
    call add(llist, lnum)
  endfor
  CloseQFixWin
  let rez = []
  let h = g:QFix_Height
  silent! exec 'split '
  silent! exec 'silent! edit '.s:howmtempfile
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal bufhidden=hide
  setlocal nobuflisted
  if g:QFix_SearchPathEnable && g:QFix_SearchPath != ''
    silent exec 'lchdir ' . escape(g:QFix_SearchPath, ' ')
  endif
  for n in range(cnt)
"    echo flist[n] llist[n]
    let [entry, llist[n]] = QFixHowmATCombine(flist[n], llist[n])
    for s in range(n-1, -1, -1)
      if s == -1
        break
      endif
      if flist[n] == flist[s] && llist[n] == llist[s]
        break
      endif
    endfor
    if s == -1
      let str = g:QFixHowm_MergeEntrySeparator.g:howm_glink_pattern.' '. flist[n]
      let entry = insert(entry, str, 0)
      let rez = extend(rez, entry)
    endif
  endfor
  silent! exec 'silent! edit '.s:howmtempfile
  setlocal buftype=nofile
  silent! bd!
  let g:QFix_Height = h
  silent! exec 'lchdir ' . escape(g:howm_dir, ' ')
  if g:QFixHowm_MergeEntryName != ''
    let lname = strftime(g:QFixHowm_MergeEntryName)
  else
    let lname = strftime(g:QFixHowm_GenerateFile)
  endif
  let file = escape(g:howm_dir.'/'.lname, ' ')
  if a:mode =~ 'user'
    for n in range(10)
      silent! exec 'let @'.n.'=RegisterBackup['.n.']'
    endfor
    let @/ = RegisterBackup[10]
    let @" = RegisterBackup[11]
    if has('gui')
      let @* = RegisterBackup[12]
    endif
    unlet! RegisterBackup
    unlet! flist
    unlet! llist
    if exists('+autochdir')
      let &autochdir = saved_ac
    endif
    silent exec 'lchdir ' . prevPath
    let g:QFix_SelectedLine = save_cursor[1]
    return
  endif
  if g:QFixHowm_MergeEntryName != ''
    if filewritable(file) == 1
      call QFixHowmEditFile(file)
    else
      call QFixHowmCreateNewFile(lname)
    endif
  else
    call QFixHowmCreateNewFile(lname)
  endif
  call feedkeys("\<ESC>")
  silent! exec 'setlocal filetype='.g:QFixHowm_FileType
  if g:QFixHowm_MergeEntryMode
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
  endif
  silent! %delete _
  call setline(1, rez)
  silent! exec 'normal! gg'
  for n in range(10)
    silent! exec 'let @'.n.'=RegisterBackup['.n.']'
  endfor
  let @/ = RegisterBackup[10]
  let @" = RegisterBackup[11]
  if has('gui')
    let @* = RegisterBackup[12]
  endif
  unlet! RegisterBackup
  unlet! flist
  unlet! llist
  if exists('+autochdir')
    let &autochdir = saved_ac
  endif
  silent exec 'lchdir ' . prevPath
  call QFixHowmHighlight()
  QFixCopen
  call setpos('.', save_cursor)
  exec 'normal! z.'
  wincmd p
endfunction

silent! function QFixHowmUserCmd(list)
  "Quickfixウィンドウを開く
  OpenQFixWin
endfunction

""""""""""""""""""""""""""""""
function! QFixHowmATCombine(file, lnum)
  setlocal modifiable
  silent! %delete _
  if g:QFix_SearchPathEnable && g:QFix_SearchPath != ''
    silent exec 'lchdir ' . escape(g:QFix_SearchPath, ' ')
  endif
  let file = a:file
  let tmpfile = escape(a:file, ' #%')
  if g:QFixHowm_ForceEncoding
    silent! exec '0read ++enc='.g:howm_fileencoding.' ++ff='.g:howm_fileformat.' '.tmpfile
  else
    silent! exec '0read '.tmpfile
  endif
  silent! $delete _
  let lnum = a:lnum
  let l:QFixHowm_Title = escape(g:QFixHowm_Title, g:QFixHowm_EscapeTitle)
  let l:QFixHowm_Title = l:QFixHowm_Title.'\(\s\|$\)'
  let head = '^'. l:QFixHowm_Title
  call cursor(lnum,1)
  call search(head, 'cbW')
  let start = line('.')
  let end  = search(head, 'nW') - 1
  if end == -1
    let end = line('$')
  endif
  let line = end - start + 1
  "silent! exec 'normal! '. line .'Y'
  let file = fnamemodify(file, ':p')
  let list = {'lnum':lnum - start+1, 'title':getline(start), 'filename':file, 'start':start, 'end':end, 'text':getline(start+1, end)}
  call add(g:QFixHowm_MergeList, list)
  return [getline(start, end), start]
endfunction

""""""""""""""""""""""""""""""
function! QFixHowmCmd_Replace(mode)
  let prevPath = getcwd()
  let prevPath = escape(prevPath, ' ')
  if exists('+autochdir')
    let saved_ac = &autochdir
"    set noautochdir
  endif
"  call QFixSaveHeight(0)
  CloseQFixWin
  let h = g:QFix_Height
  silent! exec 'split '
  silent! exec 'silent! edit '.s:howmtempfile
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  silent exec 'lchdir ' . escape(g:howm_dir, ' ')
  let idx = 0
  let sq = getqflist()
  for d in sq
    let ret = QFixHowmListRecentReplaceTitle(bufname(d.bufnr), '', d.lnum)
    if ret[0] != ''
      let d.text = ret[0]
      if a:mode != 'title'
        let d.lnum = ret[1]
      endif
    endif
  endfor
  silent! exec 'silent! edit '.s:howmtempfile
  setlocal buftype=nofile
  silent! bd!
  let g:QFix_Height = h
  if a:mode == 'remove'
    let max = len(sq)-1
    for idx in range(max, 1, -1)
      for j in range(0, idx-1)
        if sq[idx]['lnum'] == sq[j]['lnum'] && sq[idx]['text'] == sq[j]['text'] && bufname(sq[idx]['bufnr']) == bufname(sq[j]['bufnr'])
          call remove(sq, idx)
          break
        endif
      endfor
    endfor
  endif
  let s:UseTitleFilter = 1
  call QFixHowmTitleFilter(sq)
  cexpr ''
  call MyGrepSetqflist(sq)
  if empty(sq)
    CloseQFixWin
    redraw | echo 'QFixHowm : Not found!'
  else
    QFixCopen
"    call SetModifiable('save')
"    setlocal modifiable
"    silent! exec 'normal! 9999999999u'
"    call SetModifiable('restore')
  endif
  silent exec 'lchdir ' . prevPath
  if exists('+autochdir')
    let &autochdir = saved_ac
  endif
  exec 'normal! gg'
  return
endfunction
"
"QFixHowm_keywordfileからオートリンクを読み込む
"
function! QFixHowmLoadKeyword()
  if !filereadable(expand(g:QFixHowm_keywordfile))
    return
  endif
  let g:QFixHowm_keyword = ''
  let g:QFixHowm_KeywordList = []
  let g:howm_keyword = ''
  for keyword in readfile(expand(g:QFixHowm_keywordfile))
    if keyword =~ '^\s*$'
      continue
    endif
    call add(g:QFixHowm_KeywordList, keyword)
    let keyword = substitute(keyword, '\s*$', '', '')
    let keyword = substitute(keyword, '^\s*', '', '')
"    let keyword = substitute(keyword, '[()^|{}\.*]', '', 'g')
    if g:QFixHowm_clink_type == 'word'
      let keyword = escape(keyword, '<>\')
      let g:QFixHowm_keyword = g:QFixHowm_keyword.'\<'.keyword.'\>\|'
    else
      let g:QFixHowm_keyword = g:QFixHowm_keyword.''.keyword.'\|'
    endif
    let g:howm_keyword = g:howm_keyword.''.keyword.'\|'
  endfor
  let g:QFixHowm_keyword = substitute(g:QFixHowm_keyword, '\\|\\|', '\\|', '')
  let g:QFixHowm_keyword = substitute(g:QFixHowm_keyword, '\\|\s*$', '', '')
  let g:QFixHowm_keyword = substitute(g:QFixHowm_keyword, '^\\|', '', '')
  let g:howm_keyword = substitute(g:howm_keyword, '\\|\s*$', '', '')
endfunction

"
"現在のファイルからQFixHowm_keywordfileへオートリンクを保存
"
let s:KeywordDic = []
function! QFixHowmAddKeyword()
  let save_cursor = getpos('.')
  if filereadable(expand(g:QFixHowm_keywordfile))
    let s:KeywordDic = readfile(expand(g:QFixHowm_keywordfile))
  else
    let s:KeywordDic = []
  endif
  let kdic = deepcopy(s:KeywordDic)
  let idx = 0
  for str in s:KeywordDic
    if str =~ '^\s*$'
      call remove(s:KeywordDic, idx)
      continue
    endif
    let idx += 1
  endfor
  call cursor('1','1')
  let [lnum, stridx] = searchpos(g:howm_clink_pattern, 'cW')
  let cmode = 1
  while 1
    if stridx == 0 && lnum == 0
      break
    endif
    call cursor(lnum, stridx)
    let text = getline('.')
    let keyword = strpart(text, stridx-1)
    let keyword = substitute(keyword, g:howm_clink_pattern.'\s*', '', '')
    let keyword = substitute(keyword, '\s*$', '', '')
    if count(s:KeywordDic, keyword) == 0 && keyword !~ '^\s*$'
      call add(s:KeywordDic, keyword)
    endif
"    let etext = g:howm_clink_pattern.'\s*'.'\V'.escape(keyword, '[].*+~{}\')
    let etext = g:howm_clink_pattern.'\s*'.'\V'.escape(keyword, '/')
    if getline('.') =~ etext
      call QFixHowmSaveAutolinkTag(keyword, expand('%:p'), lnum, cmode)
      let cmode = 0
    endif
    let [lnum, stridx] = searchpos(g:howm_clink_pattern, 'W')
  endwhile
  for lnum in range(1, line('$'))
    let text = getline(lnum)
    while 1
      let stridx = match(text, '\[\[')
      let pairpos = matchend(text, ']]')
      if stridx == -1 || pairpos == -1
        break
      endif
      let keyword = strpart(text, stridx+2, pairpos-stridx-strlen('[[]]'))
      let keyword = substitute(keyword, '^\s*', '', '')
      let keyword = substitute(keyword, '\s*$', '', '')
      if count(s:KeywordDic, keyword) == 0 && keyword !~ '^\s*$'
        call add(s:KeywordDic, keyword)
      endif
      call QFixHowmSaveAutolinkTag(keyword, expand('%:p'), lnum, cmode)
      let cmode = 0
      let text = strpart(text, pairpos)
    endwhile
  endfor
  call sort(s:KeywordDic)
  call reverse(s:KeywordDic)
  if s:KeywordDic != kdic
    call writefile(s:KeywordDic, expand(g:QFixHowm_keywordfile))
  endif
  call QFixHowmLoadKeyword()
  call QFixHowmHighlight()
  call setpos('.', save_cursor)
endfunction

"
"QFixHowm_keywordfileを再作成
"
function! QFixHowmRebuildKeyword()
  CloseQFixWin
  let tfile = expand(g:QFixHowm_TagsDir . '/tags')
  silent! call delete(tfile)
  let l:howm_dir = g:howm_dir
  let prevPath = getcwd()
  let prevPath = escape(prevPath, ' ')
  if exists('+autochdir')
    let saved_ac = &autochdir
"    set noautochdir
  endif
  silent! cexpr ''
  let s:KeywordDic = []
  echo "QFixHowm : Rebuilding..."
  let file = g:QFixHowm_Menufile
  if g:QFixHowm_MenuDir == ''
    silent exec 'lchdir ' . escape(l:howm_dir, ' ')
  else
    silent exec 'lchdir ' . escape(g:QFixHowm_MenuDir, ' ')
  endif
  silent! exec 'vimgrepadd /\('.g:howm_clink_pattern.'\|'.'\[\[[^\]]\+\]\]'.'\)/j '. file
  silent exec 'lchdir ' . escape(l:howm_dir, ' ')
  if !exists('g:mygrepprg') || g:mygrepprg == 'internal' || g:mygrepprg == '' || g:mygrepprg == 'findstr'
    silent! exec 'vimgrepadd /\('.g:howm_clink_pattern.'\|'.'\[\[[^\]]\+\]\]'.'\)/j **/*.'.g:QFixHowm_FileExt
  else
    let searchWord = '('.g:howm_clink_pattern.'|'.'\[\[[^]]+\]\]'.')'
    call MyGrep(searchWord, '', '**/*.'.g:QFixHowm_FileExt , g:howm_fileencoding, 1)
  endif
  let prevbufname = ''
  let prevbufnr = -1
  let save_qflist = getqflist()
  for d in save_qflist
    let file = bufname(d.bufnr)
    if file == prevbufname
      continue
    endif
    let fbuf = readfile(file)
    let lnum = 0
    for text in fbuf
      let lnum = lnum + 1
      if text !~ g:howm_clink_pattern
        continue
      endif
      let keyword = substitute(text, '.*'.g:howm_clink_pattern.'\s*', '', '')
      let keyword = substitute(keyword, '\s*$', '', '')
      if count(s:KeywordDic, keyword) == 0 && keyword !~ '^\s*$'
        call add(s:KeywordDic, keyword)
      endif
"      let etext = g:howm_clink_pattern.'\s*'.'\V'.escape(keyword, '[].*+~{}\')
      let etext = g:howm_clink_pattern.'\s*'.'\V'.escape(keyword, '/')
      if text =~ etext
        let cmode = 0
        if prevbufnr != d.bufnr
          let cmode = 1
        endif
        let prevbufnr = d.bufnr
        call QFixHowmSaveAutolinkTag(keyword, fnamemodify(file, ":p"), lnum, cmode)
      endif
    endfor
    "wiki style link
    let lnum = 0
    for text in fbuf
      let lnum = lnum + 1
      if text !~ '\[\['
        continue
      endif
      while 1
        let stridx = match(text, '\[\[')
        let pairpos = matchend(text, ']]')
        if stridx == -1 || pairpos == -1
          break
        endif
        let keyword = strpart(text, stridx+2, pairpos-stridx-strlen('[[]]'))
        let keyword = substitute(keyword, '^\s*', '', '')
        let keyword = substitute(keyword, '\s*$', '', '')
        let text    = strpart(text, pairpos)
        if count(s:KeywordDic, keyword) == 0 && keyword !~ '^\s*$'
          call add(s:KeywordDic, keyword)
          let cmode = 0
          if prevbufnr != d.bufnr
            let cmode = 1
          endif
          let prevbufnr = d.bufnr
          call QFixHowmSaveAutolinkTag(keyword, fnamemodify(file, ":p"), lnum, cmode)
        endif
      endwhile
    endfor
    let prevbufname = bufname(d.bufnr)
  endfor
  call sort(s:KeywordDic)
  call reverse(s:KeywordDic)
  call writefile(s:KeywordDic, expand(g:QFixHowm_keywordfile))
  call QFixHowmLoadKeyword()
  call QFixHowmHighlight()
  silent exec 'lchdir ' . prevPath
  if exists('+autochdir')
    let &autochdir = saved_ac
  endif
  QFixCopen
  redraw | echo "QFixHowm : Completed."
  return
endfunction

"
"クイックメモを開く
"
command! -count QFixHowmOpenQuickMemo if count|silent! exec 'let g:QFixHowm_QMF = g:QFixHowm_QuickMemoFile'.count|endif|call QFixHowmOpenQuickMemo(g:QFixHowm_QMF)
function! QFixHowmOpenQuickMemo(qfname)
  if QFixHowmInit()
    return
  endif
  let hfile = strftime(a:qfname)
  let sfile = g:howm_dir.'/'.hfile

  let winnr = bufwinnr(bufnr(expand(sfile)))
  if filereadable(expand(sfile))
    if winnr > -1
      exec winnr.'wincmd w'
    else
      let winnr = QFixWinnr()
      if winnr < 1 || g:QFixHowm_SplitMode
        split
      else
        exec winnr.'wincmd w'
      endif
      exe "e " . escape(expand(sfile), ' ')
    endif
  else
    call QFixHowmCreateNewFile(hfile)
  endif
endfunction

"
"新規howmファイル作成
"
function! QFixHowmCreateNewFile(...)
  if QFixHowmInit()
    return
  endif
  let file = escape(g:howm_dir, ' ') .'/'. strftime(g:howm_filename)
  let mode = ''
  if g:QFixHowm_SplitMode
    let mode = 'split'
  endif

  let winnr = QFixWinnr()
  if winnr < 1
    split
    let mode = ''
  elseif mode == 'split'
  else
    exec winnr.'wincmd w'
  endif

  let g:QFixHowm_LastFilename=''
  let l:MyOpenVim_ExtReg = '\.'.g:QFixHowm_FileExt.'$'
  if g:QFixHowm_OpenVimExtReg != ''
    let l:MyOpenVim_ExtReg = l:MyOpenVim_ExtReg.'\|'.g:QFixHowm_OpenVimExtReg
  endif
  if expand('%') =~ l:MyOpenVim_ExtReg
    let lfile = expand('%:p')
    if g:QFixHowm_LastFilenameMode == 1
      let lfile = substitute(lfile, escape(g:howm_dir, '\\').'[/\\]\?', 'howm://', '')
    endif
    let g:QFixHowm_LastFilename = ' ' . g:howm_glink_pattern . ' ' . lfile
  endif
  if a:0 > 0
    let file = escape(g:howm_dir, ' ') .'/'.a:1
  endif
  if filewritable(file) == 1
    call QFixHowmEditFile(file, mode)
    return
  endif
  if mode == 'split'
    split
  endif
  let dir = matchstr(file, '.*/')
  let dir = substitute(dir, '/$', '', '')
  let dir = expand(dir)
  if isdirectory(dir) == 0
    call mkdir(dir, 'p')
  endif
  let opt = '++enc=' . g:howm_fileencoding . ' ++ff=' . g:howm_fileformat . ' '
  if g:QFix_FileOpenMode == 0
    silent exec g:QFixHowm_Edit.'edit '. opt . file
  else
    silent exec g:QFixHowm_Edit.'new '. opt . file
  endif
  call QFixHowmInsertEntry('New')
  silent! exec 'normal! '. g:QFixHowm_Cmd_NewEntry
  if g:QFixHowm_Cmd_NewEntry =~ 'a$'
    startinsert!
  endif
  if g:QFixHowm_Cmd_NewEntry =~ 'i$'
    startinsert
  endif
  call QFixHowmHighlight()
  return
endfunction

"
"Howmのイニシャライズ
"
let s:QFixHowm_Init  = 0
function! QFixHowmInit()
  let s:howm_command = 1
  if s:QFixHowm_Init
    return
  endif
  let dir = g:howm_dir
  if isdirectory(expand(dir)) == 0
    let mes = printf("!!!Create howm_dir? (%s)", dir)
    let choice = confirm(mes, "&Yes\n&Cancel", 2, "W")
    if choice == 1
      let dir = expand(dir)
      call mkdir(dir, 'p')
    else
      return 1
    endif
  endif

  let s:QFixHowm_Init = 1
  let s:howmtempfile = tempname()
  call QFixHowmLoadKeyword()
  call QFixHowmLoadMru()
  call QFixHowmHighlight()
  let title = substitute(g:SubWindow_Title, '^.*/', '', '')
  let cmd = ':call ToggleQFixSubWindow()'
  let g:QFixHowm_MRU_Ignore = title . '$\|'. g:QFixHowm_MRU_Ignore

  for i in range(g:QFixHowm_howm_dir_Max, 2,-1)
    if g:QFixHowm_howm_dir_Max < 2
      break
    endif
    if !exists('g:howm_dir'.i)
      continue
    endif
    exec 'let hdir = g:howm_dir'.i
    if isdirectory(expand(hdir)) == 0
      continue
    endif
    if exists('g:howm_fileencoding'.i)
      exec 'let l:howm_fileencoding = g:howm_fileencoding'.i
    endif
    if g:howm_fileencoding != l:howm_fileencoding
      let g:QFixHowm_ForceEncoding = 0
      break
    endif
  endfor
  "乱数
  if g:QFixHowm_RandomWalkMode == 1
    if has('unix')
      silent! call libcallnr("", "srand", localtime())
    else
      silent! call libcallnr("msvcrt.dll", "srand", localtime())
    endif
  endif
endfunction

"
"アクションロック用ハイライト
"
let g:QFixHowm_keyword = ''
function! QFixHowmHighlight()
  let ext = expand('%:e')
  if ext !~ g:QFixHowm_FileExt || &syntax == ''
    return
  endif
  silent! syntax clear actionlockKeyword
  if g:QFixHowm_keyword != ''
"    exe 'syntax match actionlockKeyword display "\V\%('.g:QFixHowm_keyword.'\)"'
    exe 'syntax match actionlockKeyword display "\V'.g:QFixHowm_keyword.'"'
  endif
endfunction

if !exists('g:QFixHowm_ScheduleSwActionLock')
  let g:QFixHowm_ScheduleSwActionLock= ['Sun)', 'Mon)', 'Tue)', 'Wed)', 'Thu)', 'Fri)', 'Sat)', 'Hdy)']
endif

if exists('g:QFixHowmSwitchListActionLock')
  let g:QFixHowm_SwitchListActionLock = g:QFixHowmSwitchListActionLock
endif
if !exists('g:QFixHowm_SwitchListActionLock')
  let g:QFixHowm_SwitchListActionLock = ['{ }', '{*}', '{-}']
endif
"
"アクションロック実行
"
let s:QFixHowmALSPat = ''
"TODO:strを取得しない形に修正する
function! QFixHowmActionLock()
  let RegisterBackup = [@0, @1, @2, @3, @4, @5, @6, @7, @8, @9, @/, @", @"]
  if has('gui')
    let RegisterBackup[12] = @*
  endif
  let s:QFixHowmMA = 0
  let str = QFixHowmActionLockStr()
  if s:QFixHowmMA
    exec 'normal '. str
  elseif str == "\<CR>"
    silent exec "normal! \<CR>"
  elseif str == "\<ESC>"
  else
    let str = substitute(str, "\<CR>", "|", "g")
    let str = substitute(str, "|$", "", "")
    silent exec str
  endif
  for n in range(10)
    silent! exec 'let @'.n.'=RegisterBackup['.n.']'
  endfor
  let @/ = RegisterBackup[10]
  let @" = RegisterBackup[11]
  if has('gui')
    let @* = RegisterBackup[12]
  endif
  return
endfunction

function! QFixHowmActionLockStr()
  let save_cursor = getpos('.')
  call setpos('.', save_cursor)
  let ret = QFixHowmMacroAction()
  if ret != "\<CR>"
    let s:QFixHowmMA = 1
    return ret
  endif
  call setpos('.', save_cursor)
  let ret = QFixHowmOpenCursorline()
  if ret == 1
    return "\<ESC>"
  elseif ret == -1
    let glink = g:howm_glink_pattern
    let file = matchstr(getline('.'), glink.'.*$', '', '')
    let file = substitute(file, glink.'\s*', '', '')
    if filereadable(expand(file))
"      let file = escape(file, ' ')
      let file = escape(file, '\')
      return ":exec 'call QFixHowmEditFile(\"".file."\")'\<CR>"
      return "\<ESC>"
    endif
    silent exec 'normal! gf'
    return "\<ESC>"
  endif
  call setpos('.', save_cursor)
  let text = getline('.')
  let stridx = match(text, g:QFixHowm_Link)
  if stridx > -1 && col('.') > stridx
    let pattern = matchstr(text, g:QFixHowm_Link.'\s*.*$')
    let pattern = substitute(pattern, '^'.g:QFixHowm_Link.'\s*', '', '')
    let s:QFixHowmALSPat = pattern
    call QFixHowmActionLockSearch(0)
    return "\<ESC>"
  endif
  call setpos('.', save_cursor)
  let ret = QFixHowmDateActionLock()
  if ret != "\<CR>"
    return ret
  endif
  call setpos('.', save_cursor)
  let ret = QFixHowmTimeActionLock()
  if ret != "\<CR>"
    return ret
  endif
  call setpos('.', save_cursor)
  let ret = QFixHowmSwitchActionLock(g:QFixHowm_ScheduleSwActionLock, 1)
  if ret != "\<CR>"
    return ret
  endif
  call setpos('.', save_cursor)
  let ret = QFixHowmRepeatDateActionLock()
  if ret != "\<CR>"
    return ret
  endif
  call setpos('.', save_cursor)
  let ret = QFixHowmKeywordLinkSearch()
  if ret != "\<CR>"
    return ret
  endif
  call setpos('.', save_cursor)
  let ret = QFixHowmSwitchActionLock(g:QFixHowm_SwitchListActionLock)
  if ret != "\<CR>"
    return ret
  endif
  call setpos('.', save_cursor)
  let ret = QFixHowmSwitchActionLock(['{_}'])
  if ret != "\<CR>"
    return ret
  endif
  call setpos('.', save_cursor)
  if exists('g:QFixHowm_UserSwActionLock')
    let ret = QFixHowmSwitchActionLock(g:QFixHowm_UserSwActionLock)
    if ret != "\<CR>"
      return ret
    endif
  endif
  call setpos('.', save_cursor)

  for i in range(2, g:QFixHowm_UserSwActionLockMax)
    if !exists('g:QFixHowm_UserSwActionLock'.i)
      continue
    endif
    call setpos('.', save_cursor)
    exec 'let action = '.'g:QFixHowm_UserSwActionLock'.i
    if action != []
      let ret = QFixHowmSwitchActionLock(action)
      if ret != "\<CR>"
        return ret
      endif
    endif
  endfor
  call setpos('.', save_cursor)
  return "\<CR>"
endfunction

"
"スイッチアクションロック
"
function! QFixHowmSwitchActionLock(list, ...)
  let prevline = line('.')
  let prevcol = 0
  if a:0 > 0
    let prevcol = col('.')
  endif
  let max = len(a:list)
  let didx = 0
  for d in a:list
    let pattern = d
    let didx = didx + 1
    if didx >= max
      let didx = 0
    endif
    let cpattern = a:list[didx]
    let nr = 1
    while 1
      if byteidx(pattern, nr) == -1
        break
      endif
      let nr = nr + 1
    endwhile
    let nr = nr - 1
    let pattern = escape(pattern, '*[.~')
    let start = col('.') - strlen(matchstr(pattern, '^.\{'.nr.'}')) + strlen(matchstr(pattern, '^.\{1}')) - 1
    if start < 0
      let start = 0
    endif
    let end = col('.') + strlen(matchstr(pattern, '.\{'.nr.'}$'))-1
    let str = strpart(getline('.'), start, end-start)
    if str !~ pattern
      continue
      return "\<CR>"
    endif
    let start = start + match(str, pattern) + 1
    if a:0 == 0
      let prevcol = start
    endif
    if str =~ '{_}'
      let cpattern = strftime('['.s:hts_dateTime.'].')
    endif
    return ":call cursor(line('.'),".start.")\<CR>:exec 'normal! c".nr."l".cpattern."'\<CR>:call cursor(".prevline.",".prevcol.")\<CR>"
  endfor
  return "\<CR>"
endfunction

"
"繰り返し予定のアクションロック
"
function! QFixHowmRepeatDateActionLock()
  let prevline = line('.')
  let prevcol = col('.')
  let start = 2
  let cpattern = strftime(s:hts_date)
  let len = strlen(cpattern)
  let searchWord = '^\s*'.s:sch_dateCmd
  let text = matchstr(getline('.'), searchWord)
  if text == "" || col('.') > strlen(text)
    return "\<CR>"
  endif
  let str = matchstr(text, '^\s*\['.s:sch_date)
  let str = substitute(str, '^\s*\[', '', '')
  let searchWord = ']'.s:sch_cmd
  let cmd = matchstr(getline('.'), searchWord)
  let cmd = substitute(cmd, '^]', '', '')
  if cmd =~ '^\.'
    return "\<CR>"
  endif
  let opt = matchstr(cmd, '[0-9]*$')
  let clen = matchstr(cmd, '^'.s:sch_Ext.'\+')
  let ccmd = matchstr(cmd, s:sch_Ext.'(')
  if strlen(ccmd) == 0 && strlen(clen) == 1
    let searchWord = '^\s*'.s:sch_dateT
    let len = matchend(getline('.'), searchWord) + 1
    return ":call cursor(line('.'),".len.")\<CR>:exec 'normal! r.'\<CR>:call cursor(".prevline.",".prevcol.")\<CR>"
  endif
  let cpattern = s:CnvRepeatDate(cmd, opt, str, -1)
  let start = 2 + match(getline('.'), s:sch_dateT)
  return ":call cursor(line('.'),".start.")\<CR>:exec 'normal! c".len."l".cpattern."'\<CR>:call cursor(".prevline.",".prevcol.")\<CR>"
endfunction

"
"繰り返し予定を展開する
"
command! -count QFixHowmGenerateRepeatDate call QFixHowmGenerateRepeatDate(count)
function! QFixHowmGenerateRepeatDate(count)
  let save_cursor = getpos('.')
  let loop = a:count
  if loop == 0
    let loop = 1
  endif

  let ptext = matchstr(getline('.'), '^\s*')
"  let cpattern = '0000-00-00'
  let searchWord = '^\s*'.s:sch_dateCmd
  let text = matchstr(getline('.'), searchWord)
  if text == ""
    return
  endif
  let tstr = matchstr(text, '^\s*\['.s:sch_date)
  let tstr = substitute(tstr, '^\s*\[', '', '')
  let searchWord = ']'.s:sch_cmd
  let cmd = matchstr(getline('.'), searchWord)
  let cmd = substitute(cmd, '^]', '', '')

  "単発予定は一日繰り返しにする
  let pattern = '^\('.s:sch_Ext.'\)\(\d\|$\)'
  if cmd =~ pattern
    let cmd = substitute(cmd, pattern, '\1(1)\2', '')
  endif
  let pattern = '^\('.s:sch_Ext.'(\)\([-+]'.s:sch_dow.')\)'
  if cmd =~ pattern
    let cmd = substitute(cmd, pattern, '\11\2', '')
  endif

  let opt = matchstr(cmd, '[0-9]*$')
  let cpattern = s:CnvRepeatDate(cmd, opt, tstr, -1)
  let str = getline('.')
  let pstr = ''
  for n in range(loop)
    let cpattern = s:CnvRepeatDate(cmd, opt, tstr, -1)
    let str = substitute(str, '^\s*\['.s:sch_date, '['.cpattern, '')
    let tstr = matchstr(str, '^\s*\['.s:sch_date)
    let tstr = substitute(tstr, '^\s*\[', '', '')
    let ostr = str
    "単発予定に変換
    let dstr = matchstr(ostr, s:sch_date)
    let dstr = s:DayOfWeekShift(cmd, dstr)
    let ostr = substitute(ostr, s:sch_date, dstr, '')
    let ostr = substitute(ostr, '\(]\)\('.s:sch_Ext.'\)\{1,3}', '\1\2', '')
    let ostr = substitute(ostr, '\(]'.s:sch_Ext.'\)'.'([0-9]*[-+*]\?'.s:sch_dow.'\?)', '\1', '')
    let pstr = pstr . "\<NL>" . ptext .ostr
  endfor
  let pstr = substitute(pstr, "^\<NL>", '', '')
  put=pstr
  call setpos('.', save_cursor)
  return
endfunction

"
"時間のアクションロック
"
function! QFixHowmTimeActionLock()
  let prevline = line('.')
  let prevcol = col('.')

  let pattern = ' '.s:sch_time.']'
  let len = 7 "sizeof pattern
  let start = col('.') - len
  if start < 0
    let start = 0
  endif
  let end = col('.') + len
  let str = strpart(getline('.'), start, end-start)
  if str !~ pattern
    return "\<CR>"
  endif
  let start = start + match(str, pattern) + 1
  if col('.') < start
    return "\<CR>"
  endif

  let pattern = s:sch_time
  let len = 5 "sizeof pattern
  let start = col('.') - len
  if start < 0
    let start = 0
  endif
  let end = col('.') + len
  let str = strpart(getline('.'), start, end-start)
  if str !~ pattern
    return "\<CR>"
  endif
  let start = start + match(str, pattern) + 1
  if col('.') < start
    return "\<CR>"
  endif

"  let prevcol = prevcol+start
  let dpattern = matchstr(str, pattern)
  let pattern = input(' 01-059, 60-999, 01000-02359, 2400- ([+-]min), hhmm/0-59 (set), . (current) : ', '')
  if pattern == ''
    return "\<ESC>"
  elseif pattern == '.'
    let cpattern = strftime(s:hts_time)
  elseif pattern =~ '^\d\{2}:\d\{2}'
    let sec = QFixHowmDate2Int(strftime(s:hts_date).' '.pattern)
    let cpattern = strftime(s:hts_time, sec)
  elseif pattern =~ '[-+]\?\d\+'
    let num = substitute(pattern, '^[0+]*', '', '')
    if pattern =~ '^\d\{4}$' && num < 2400
      let sec = QFixHowmDate2Int(strftime(s:hts_date).' '.pattern)
      let sec = sec
      let cpattern = strftime(s:hts_time, sec)
    elseif pattern =~ '^\d$' || (pattern =~ '^\d\{2}$' && num < 60 && num == pattern)
      let cpattern = substitute(dpattern, '\d\d$', '', '') . printf('%2.2d', num)
    else
      let sec = QFixHowmDate2Int(strftime(s:hts_date).' '.dpattern)
      let sec = sec + num*60
      let cpattern = strftime(s:hts_time, sec)
    endif
  else
    return ":call cursor(".prevline.",".prevcol.")\<CR>"
  endif
  return ":call cursor(line('.'),".start.")\<CR>:exec 'normal! c".len."l".cpattern."'\<CR>:call cursor(".prevline.",".prevcol.")\<CR>"
endfunction

"
"日付のアクションロック
"
function! QFixHowmDateActionLock()
  let prevline = line('.')
  let prevcol = col('.')
  let pattern = s:sch_date
  let len = strlen(strftime(s:hts_date))
  let start = col('.') - len
  if start < 0
    let start = 0
  endif
  let end = col('.') + len
  let str = strpart(getline('.'), start, end-start)
  if str !~ pattern
    return "\<CR>"
  endif
  let start = start + match(str, pattern) + 1
  if col('.') < start
    return "\<CR>"
  endif
"  let prevcol = prevcol+start
  let dpattern = matchstr(str, pattern)
  let pattern = input(' 01-031,32-999 ([+-]day), yymmdd/mmdd/1-31 (set), . (today) : ', '')
  if pattern == ''
    let pattern = dpattern
    if g:QFixHowm_DateActionLockDefault == 0
      return "\<ESC>"
    endif
    if g:QFixHowm_DateActionLockDefault == 1
      "TODO:vimgrepだったら/をエスケープ
      let patten = escape(pattern, '/')
      let s:QFixHowmALSPat = pattern
      call QFixHowmActionLockSearch(1, 'QFixHowm Grep : ')
      return "\<ESC>"
    endif
    if g:QFixHowm_DateActionLockDefault == 2
      call QFixHowmListReminder('schedule')
      return "\<ESC>"
    endif
    if g:QFixHowm_DateActionLockDefault == 3
      call QFixHowmListReminder('todo')
      return "\<ESC>"
    endif
    return "\<CR>"
  elseif pattern == '.'
    let cpattern = strftime(s:hts_date)
  elseif pattern =~ '^[-+]\d\+$'
    let pattern = substitute(pattern, '^[+0]*', '', '')
    let sec = pattern * 24*60*60
    let sec = sec + QFixHowmDate2Int(dpattern.' 00:00')
    let cpattern = strftime(s:hts_date, sec)
  elseif pattern =~ '^\d\{8}$' || pattern =~ '^'.s:sch_date.'$'
    let pattern = substitute(pattern, '[^0-9]', '', 'g')
    let sec = QFixHowmDate2Int(pattern.' 00:00')
    let cpattern = strftime(s:hts_date, sec)
    let year = strpart(pattern, 0, 4)
    if cpattern !~ s:sch_date || year < g:YearStrftime
      let month = strpart(pattern, 4, 2)
      let day = strpart(pattern, 6, 2)
      let cpattern = substitute(g:QFixHowm_DatePattern, '%Y', year, '')
      let cpattern = substitute(cpattern, '%m', month, '')
      let cpattern = substitute(cpattern, '%d', day, '')
    endif
  elseif pattern =~ '^\d\{6}$'
    let sec = QFixHowmDate2Int('20'.pattern.' 00:00')
    let cpattern = strftime(s:hts_date, sec)
    if cpattern !~ s:sch_date
      let year  = '20' . strpart(pattern, 0, 2)
      let month = strpart(pattern, 2, 2)
      let day   = strpart(pattern, 4, 2)
      let cpattern = substitute(g:QFixHowm_DatePattern, '%Y', year, '')
      let cpattern = substitute(cpattern, '%m', month, '')
      let cpattern = substitute(cpattern, '%d', day, '')
    endif
  elseif pattern =~ '^\d\{4}$'
    let head = matchstr(dpattern, '\d\{4}')
    let sec = QFixHowmDate2Int(head . pattern.' 00:00')
    let cpattern = strftime(s:hts_date, sec)
  elseif pattern =~ '^\d\{1,3}$'
    if pattern[0] != '0' && pattern < 32
"      let head = matchstr(dpattern, '\d\{4}-\d\{2}-')
      let head = substitute(dpattern, '\d\{2}$', '', '')
      let cpattern = head . printf('%2.2d', pattern)
      let sec = QFixHowmDate2Int(cpattern .' 00:00')
    else
      if pattern + 0 == 0
        let cpattern = strftime(s:hts_date)
        let sec = QFixHowmDate2Int(cpattern.' 00:00')
      else
        let pattern = substitute(pattern, '^[+0]*', '', '')
        let sec = pattern * 24*60*60
        let sec = sec + QFixHowmDate2Int(dpattern.' 00:00')
      endif
    endif
    let cpattern = strftime(s:hts_date, sec)
  else
    return ":call cursor(".prevline.",".prevcol.")\<CR>"
  endif
  return ":call cursor(line('.'),".start.")\<CR>:exec 'normal! c".len."l".cpattern."'\<CR>:call cursor(".prevline.",".prevcol.")\<CR>"
endfunction

"
"キーワードリンクだったら検索
"
function! QFixHowmKeywordLinkSearch()
  let save_cursor = getpos('.')
  let l:QFixHowm_keyword = g:QFixHowm_keyword
  let col = col('.')
  let lstr = getline('.')

  for word in g:QFixHowm_KeywordList
    let len = strlen(word)
    let pos = match(lstr, '\V'.word)
    if pos == -1 || col < pos+1
      continue
    endif
    let str = strpart(lstr, col-len, 2*len)
    if matchstr(str, '\V'.word) == word
      let s:QFixHowmALSPat = word
      call QFixHowmActionLockSearch(0)
      return "\<ESC>"
    endif
  endfor
  return "\<CR>"
endfunction

"
"アクションロック用サーチ
"
function! QFixHowmActionLockSearch(regmode, ...)
  let g:MyGrep_Regexp = a:regmode
  let pattern = s:QFixHowmALSPat
  if a:0 > 0
    let pattern = input(a:1, pattern)
  endif
  if pattern == ''
    return "\<CR>"
  endif
  call histadd('@', pattern)
  call QFixHowmListAll(pattern, 0)
endfunction

"
"カーソル位置のファイルを開くアクションロック
"
function! s:OpenUri(uri)
  let cmd = ''
  let bat = 0

  let uri = a:uri
  if g:QFixHowm_removeHatenaTag
    let uri = substitute(a:uri, ':\(\(title\|image\)=[^\]]\+\)\?$', '', '')
  endif
  if has('win32') || has('win64')
    if &enc != 'cp932' && uri =~ '^file://' && uri =~ '[^[:print:]]'
      let bat = 1
    endif
  endif
  if g:QFixHowm_OpenURIcmd != ''
    let cmd = g:QFixHowm_OpenURIcmd
    if g:QFixHowm_OpenURIcmd =~ 'iexplore\(\.exe\)\?' && uri =~ '^file://'
    else
      let uri = s:EncodeURL(uri, &enc)
    endif
    "Windowsで &encが cp932以外か !start cmd /c が指定されていたらバッチ化して実行
    if bat || cmd =~ '^!start\s*cmd\(\.exe\)\?\s*/c'
      let cmd = substitute(cmd, '^[^"]\+', '', '')
      let uri = substitute(uri, '&', '"\&"', 'g')
      let uri = substitute(uri, '%', '%%', 'g')
      let cmd = substitute(cmd, '%s', escape(uri, '&'), '')
      let cmd = iconv(cmd, &enc, 'cp932')
      let s:uricmdfile = fnamemodify(s:howmtempfile, ':p:h') . '/uricmd.bat'
      call writefile([cmd], s:uricmdfile)
      let cmd = '!start cmd /c "'.s:uricmdfile.'"'
      silent exec cmd
      return 1
    endif
    let cmd = substitute(cmd, '%s', escape(uri, '&'), '')
    let cmd = escape(cmd, '%#')
    silent exec cmd
    return 1
  endif
  return 0
endfunction

"URIエンコード
function! s:EncodeURL(str, ...)
  let to_enc = 'utf8'
  if a:0
    let to_enc = a:1
  endif
  let str = iconv(a:str, &enc, to_enc)
  let save_enc = &enc
  let &enc = to_enc
  "FIXME:本当は'[^-0-9a-zA-Z._~]'を変換？
  let str = substitute(str, '[^[:print:]]', '\=s:URLByte2hex(s:URLStr2byte(submatch(0)))', 'g')
  let str = substitute(str, ' ', '%20', 'g')
  let &enc = save_enc
  return str
endfunction

function! s:URLStr2byte(str)
  return map(range(len(a:str)), 'char2nr(a:str[v:val])')
endfunction

function! s:URLByte2hex(bytes)
  return join(map(copy(a:bytes), 'printf("%%%02X", v:val)'), '')
endfunction

"
"カーソル行のユーザーマクロを実行するアクションロック
"
let s:QFixHowm_MacroActionCmd = ''
function! QFixHowmMacroAction()
  if g:QFixHowm_MacroActionKey == '' || g:QFixHowm_MacroActionPattern == ''
    return "\<CR>"
  endif
  if expand('%:t') !~ g:QFixHowm_Menufile
"    return "\<CR>"
  endif
  let text = getline('.')
  if text !~ g:QFixHowm_MacroActionPattern
    return "\<CR>"
  endif
  let text = substitute(text, '.*'.g:QFixHowm_MacroActionPattern, "", "")
  let s:QFixHowm_MacroActionCmd = text
  exec "nmap <silent> " . s:QFixHowm_Key . g:QFixHowm_MacroActionKey . " " . ":<C-u>call QFixHowmSaveMru(0)<CR>:CloseQFixWin<CR>" .substitute(s:QFixHowm_MacroActionCmd, '^\s*', '', '')
  return s:QFixHowm_Key . g:QFixHowm_MacroActionKey
endfunction

"
"カーソル位置のファイルを開くアクションロック
"
command! QFixHowmOpenCursorline call QFixHowmOpenCursorline()
command! Gfq call QFixHowmOpenCursorline()
command! Qgf call QFixHowmOpenCursorline()
function! QFixHowmOpenCursorline()
  let prevcol = col('.')
  let prevline = line('.')
  let str = getline('.')

  " >>>
  let pos = match(str, g:howm_glink_pattern)
  if pos > -1 && col('.') >= pos
    let str = strpart(str, pos)
    let str = substitute(str, '^\s*\|\s*$', '', 'g')
    let str = substitute(str, '^'.g:howm_glink_pattern.'\s*', '', '')
    let relpath = g:QFixHowm_RelPath . (str =~ 'rel://[^/\\]' ? '/' : '')
    let str = substitute(str, 'rel://', relpath, 'g')
    let relpath = g:howm_dir . (str =~ 'howm://[^/\\]' ? '/' : '')
    let str = substitute(str, 'howm://', relpath, 'g')
    let imgsfx   = '\(\.jpg\|\.jpeg\|\.png\|\.bmp\|\.gif\)$'
    if str =~ imgsfx
      let str = substitute(str, '^&', '', '')
    endif
    return s:openstr(str)
  endif

  "カーソル位置の文字列を拾う[:c:/temp/test.jpg:]や[:http://example.com:(title=hoge)]形式
  let pathhead = '\([A-Za-z]:[/\\]\|\~/\)'
  let urireg = '\(\(howm\|rel\|http\|https\|file\|ftp\)://\|'.pathhead.'\)'
  let [lnum, colf] = searchpos('\[:\?&\?'.urireg, 'bc', line('.'))
  if lnum != 0 && colf != 0
    let str = strpart(getline('.'), colf-1)
    let lstr = substitute(str, '\[:\?&\?'.urireg, '', '')
    let len = matchend(lstr, ':[^\]]*]')
    if len < 0
      let str = ''
    else
      let len += matchend(str, '\[:\?&\?'.urireg)
      let str = strpart(str, 0, len)
    endif
    call cursor(prevline, prevcol)
    if str != ''
      if str =~ '^\[:\?'
        let str = substitute(str, ':\(title=\|image[:=]\)\([^\]]*\)\?]$', ':]', '')
        let str = substitute(str, ':[^:\]]*]$', '', '')
      endif
      let str = substitute(str, '^\[:\?&\?', '', '')
      let relpath = g:QFixHowm_RelPath . (str =~ 'rel://[^/\\]' ? '/' : '')
      let str = substitute(str, 'rel://', relpath, 'g')
      let relpath = g:howm_dir . (str =~ 'howm://[^/\\]' ? '/' : '')
      let str = substitute(str, 'howm://', relpath, 'g')
      return s:openstr(str)
    endif
  endif

  "カーソル位置の文字列を拾う
  let pathchr = '[-{}!#%&+,./0-9:;=?@A-Za-z_~\\]'
  let pathhead = '\([A-Za-z]:[/\\]\|\~/\)'
  let urireg = '\(\(howm\|rel\|http\|https\|file\|ftp\)://\|'.pathhead.'\)'
  let [lnum, colf] = searchpos(urireg, 'bc', line('.'))
  if colf == 0 && lnum == 0
    return "\<CR>"
  endif
  let str = strpart(getline('.'), colf-1)
  let str = matchstr(str, pathchr.'\+')
  call cursor(prevline, prevcol)

  let str = substitute(str, ':$\|\(|:title=\|:image\|:image[:=]\)'.pathchr.'*$', '', '')
  if str != ''
    let relpath = g:QFixHowm_RelPath . (str =~ 'rel://[^/\\]' ? '/' : '')
    let str = substitute(str, 'rel://', relpath, 'g')
    let relpath = g:howm_dir . (str =~ 'howm://[^/\\]' ? '/' : '')
    let str = substitute(str, 'howm://', relpath, 'g')
    return s:openstr(str)
  endif
  return "\<CR>"
endfunction

function! s:openstr(str)
  let str = a:str
  let str = substitute(str, '[[:space:]]*$', '', '')
  let l:MyOpenVim_ExtReg = '\.'.g:QFixHowm_FileExt.'$'
  if g:QFixHowm_OpenVimExtReg != ''
    let l:MyOpenVim_ExtReg = l:MyOpenVim_ExtReg.'\|'.g:QFixHowm_OpenVimExtReg
  endif

  "vimか指定のプログラムで開く
  let pathhead = '\([A-Za-z]:[/\\]\|\~/\|/\)'
  if str =~ '^'.pathhead
    if str !~ l:MyOpenVim_ExtReg
      let ext = fnamemodify(str, ':e')
      if exists('g:QFixHowm_Opencmd_'.ext)
        exec 'let cmd = g:QFixHowm_Opencmd_'.ext
        let str = expand(str)
        if has('unix')
          let str = escape(str, ' ')
        endif
        let cmd = substitute(cmd, '%s', escape(str, '&\'), '')
        let cmd = escape(cmd, '%#')
        silent exec cmd
        return 1
      endif
    else
      let str = escape(str, ' ')
      exec g:QFixHowm_Edit.'edit '.str
      return 1
    endif
    if fnamemodify(str, ':e') == ''
      let str = escape(str, ' ')
      exec g:QFixHowm_Edit.'edit '.str
      return 1
    endif
  endif

  let pathchr = '[-{}!#%&+,./0-9:;=?@ A-Za-z_~\\]'
  let urireg = '\(\(https\|http\|file\|ftp\)://\|'.pathhead.'\)'
  if str !~ '^'.urireg
    return "\<CR>"
  endif
  "あとはブラウザで開く
  let uri = str
  if uri =~ '^file://'
    let uri = substitute(uri, '^file://', '', '')
    let uri = expand(uri)
    let uri = 'file://'.uri
  endif
  if uri =~ '^'.pathhead
    let uri = expand(uri)
    let uri = 'file://'.uri
  endif
  let uri = substitute(uri, '\', '/', 'g')
  if uri == ''
    return "\<CR>"
  endif
  return s:OpenUri(uri)
endfunction

"
"howm専用のMRU
"
let s:MruDic = []
let s:PrevMruDic = []
function! QFixHowmLoadMru()
  if g:QFixHowm_UseMRU == 0
    return
  endif
  if !filereadable(expand(g:QFixHowm_MruFile))
    let s:MruDic = []
    let s:PrevMruDic = []
    return
  endif
  let mdic = readfile(expand(g:QFixHowm_MruFile))
  let s:MruDic = []
  for d in mdic
    let buf = d
    let idx = match(d, '|')
    let file = strpart(d, 0, idx)
    let file = expand(file)
    let file = fnamemodify(file, "%:p")
    let d = strpart(d, idx+1)
    let idx = match(d, '|')
    let lnum = strpart(d, 0, idx)
    let d = strpart(d, idx+1)
    let text = d
    "let text = iconv(text, g:howm_fileencoding, &enc)
    let usefile = {'filename':file, 'lnum':lnum, 'text':text}
    call add(s:MruDic, usefile)
  endfor
  let s:PrevMruDic = deepcopy(s:MruDic)
endfunction

"MRU表示
function! QFixHowmMru(delete)
  if g:QFixHowm_UseMRU == 0
    return
  endif
  if QFixHowmInit()
    return
  endif
  let prevPath = getcwd()
  let prevPath = escape(prevPath, ' ')
"  CloseQFixWin
  let s:PrevMruDic = deepcopy(s:MruDic)

  silent exec 'lchdir ' . escape(g:howm_dir, ' ')
  let mruidx = 0

  let h = g:QFix_Height
  silent! exec 'split '
  silent! exec 'silent! edit '.s:howmtempfile
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  let g:QFix_SearchPath = g:howm_dir
  silent exec 'lchdir ' . escape(g:howm_dir, ' ')
  let s:prevfname = ''
  let l:QFixHowm_Title = escape(g:QFixHowm_Title, g:QFixHowm_EscapeTitle)
  for d in s:MruDic
    let file = d['filename']
    if !filereadable(file) && !bufexists(file)
      call remove(s:MruDic, mruidx)
      continue
    endif
    if a:delete
      if d.text =~ '^'.l:QFixHowm_Title.'\?\s*$'
        call remove(s:MruDic, mruidx)
        continue
      endif
    endif
    let [min, max] = QFixHowmEntryRange(expand(file), d['text'])
    if min == 0
      call remove(s:MruDic, mruidx)
      continue
    endif
    if d.text !~ '^'.l:QFixHowm_Title.'\?\s*$'
      if d.lnum < min || d.lnum > max
        let d.lnum = min
      endif
    endif
    let mruidx = mruidx + 1
  endfor
  let g:QFix_MyJump = 1
  let g:QFix_SearchPath = g:howm_dir
  call MyGrepSetqflist(s:MruDic)
  silent! exec 'silent! edit '.s:howmtempfile
  setlocal buftype=nofile
  silent! bd!
  let g:QFix_Height = h
  let g:QFix_SearchResult = []
  QFixCopen
"  silent exec 'lchdir ' . prevPath
"  call SetModifiable('save')
"  setlocal modifiable
"  silent! exec 'normal! 9999999999u'
"  call SetModifiable('restore')
  call cursor(1,1)
  if g:QFix_PreviewUpdatetime == 0
    call QFixPreview()
  endif
endfunction

function! QFixHowmEntryRange(file, title)
  if g:QFix_SearchPathEnable && g:QFix_SearchPath != ''
    silent exec 'lchdir ' . escape(g:QFix_SearchPath, ' ')
  endif
  if s:prevfname != a:file
    silent! %delete _
    let tmpfile = a:file
    if bufloaded(tmpfile) "バッファが存在する場合
      let glist = getbufline(tmpfile, 1, '$')
      call setline(1, glist)
    else
      let tmpfile = escape(a:file, ' #%')
      if g:QFixHowm_ForceEncoding
        silent! exec '0read ++enc='.g:howm_fileencoding.' ++ff='.g:howm_fileformat.' '.tmpfile
      else
        silent! exec '0read '.tmpfile
      endif
      silent! $delete _
    endif
  endif
  let s:prevfname = a:file
  call cursor(1, 1)
  let title = escape(a:title, '[].*~\')
  let min = search(title, 'cW')
  let l:QFixHowm_Title = escape(g:QFixHowm_Title, g:QFixHowm_EscapeTitle)
  let l:QFixHowm_Title = l:QFixHowm_Title.'\(\s\|$\)'
  let pattern = '^'.l:QFixHowm_Title
  let max = search(pattern, 'W') - 1
  if max < 1
    let max = line('$')
  endif
  return [min,max]
endfunction

function! QFixHowmSaveMru(write)
  let l:write = a:write
  if g:QFixHowm_UseMRU == 0 || s:mru_list_locked
    return
  endif
  if QFixHowmInit()
    return
  endif
  "改変チェック
  if l:write == -1
    let qf = getqflist()
    let mqf = s:PrevMruDic
    let n = len(mqf)
    if n > 0 && len(qf) == n && qf[n-1]['text'] == mqf[n-1]['text']
      for n in range(len(mqf))
        let mfile = substitute(mqf[n]['filename'], '\\', '/', 'g')
        let bfile = substitute(bufname(qf[n]['bufnr']), '\\', '/', 'g')
        if mqf[n]['text'] != qf[n]['text'] || mfile !~ bfile
          return
          break
        endif
        let mqf[n]['lnum'] = qf[n]['lnum']
      endfor
    endif
    let s:MruDic = mqf
    return
  endif
  if l:write == 2
    let mlist = []
    for d in s:MruDic
      let mline = d['filename'].'|'.d['lnum'].'|'.d['text']
      call add(mlist, mline)
    endfor
    let file = expand(g:QFixHowm_MruFile)
    silent! let ostr = readfile(file)
    if mlist != ostr
      call writefile(mlist, file)
    endif
    "call writefile(mlist, expand(g:QFixHowm_MruFile))
    return
  endif
  let prevPath = getcwd()
  let prevPath = escape(prevPath, ' ')
  let ext = expand('%:e')
  if ext !~ g:QFixHowm_FileExt
    return
  endif
  let file = expand('%:p')
  let file = substitute(file, '\\', '/', 'g')
  let file = substitute(file, '/\+', '/', 'g')
  if file =~ s:QFixHowm_Helpfile || file =~ g:QFixHowm_Menufile || file =~ g:QFixHowm_MRU_Ignore
    return
  endif
  let lnum = line('.')
  let text = getline('.')
  let dfile = expand(file)
  if !filereadable(file) && !bufexists(file)
    return
  endif
  if g:QFixHowm_MRU_SummaryLineMode == 1
    let sline = line('.')
    let pattern = '^'.s:sch_dateTime.'\(\s*'.s:Recentmode_Date.'\|\s*$\)'
    let text = getline(sline)
    if text =~ '^\s*$' || text =~ pattern
      let sline = search('[^-\[\]() \t0-9:]\+', 'cnbW')
      if sline > 0
"        let text = getline(sline)
        let lnum = sline
      endif
    endif
  endif
  let l:QFixHowm_Title = escape(g:QFixHowm_Title, g:QFixHowm_EscapeTitle)
  let pattern = '^'.l:QFixHowm_Title.'\(\s\|$\)'
  let sline2 = search(pattern, 'cnbW')
  let text = getline(sline2)
  if g:QFixHowm_MRU_SummaryLineMode == 2
    let lnum = sline2
  endif

  let mru = {'filename':file, 'lnum':lnum, 'text':text}
  let etext = escape(text, '[].*~\')
  let idx = 0
  let cfile = escape(substitute(file, '\\', '/', 'g'), '[]')
  for d in s:MruDic
    let dfilename = substitute(d['filename'], '\\', '/', 'g')
    if dfilename =~ cfile && d['text'] == text
      silent! call remove(s:MruDic, idx)
      continue
    endif
    if dfilename =~ cfile && d['lnum'] == lnum
      silent! call remove(s:MruDic, idx)
      continue
    endif
    let idx = idx+1
  endfor
  call insert(s:MruDic, mru)
  if len(s:MruDic) > g:QFixHowm_MruFileMax
    call remove(s:MruDic, g:QFixHowm_MruFileMax, -1)
  endif
"  call MyGrepSetqflist(s:MruDic)
  if l:write > 0
    let mlist = []
    for d in s:MruDic
      let mline = d['filename'].'|'.d['lnum'].'|'.d['text']
      call add(mlist, mline)
    endfor
    let file = expand(g:QFixHowm_MruFile)
    silent! let ostr = readfile(file)
    if mlist != ostr
      call writefile(mlist, file)
    endif
    "call writefile(mlist, expand(g:QFixHowm_MruFile))
  endif
  silent exec 'lchdir ' . prevPath
  return
endfunction

"
" ShowReminder
"
command! -count -nargs=* QFixHowmListReminderSche if count > 0|let g:QFixHowm_ShowSchedule = count|endif|call QFixHowmListReminder("schedule")
command! -count -nargs=* QFixHowmListReminderTodo if count > 0|let g:QFixHowm_ShowScheduleTodo = count|endif|call QFixHowmListReminder("todo")
command! -count -nargs=* QFixHowmOpenMenu if count > 0|let g:QFixHowm_ShowScheduleMenu = count|endif|call QFixHowmOpenMenu()
function! QFixHowmListReminder(mode)
  if QFixHowmInit()
    return
  endif
  if a:mode !~ 'holiday'
    let s:HolidayList = []
    call QFixHowmListReminder('holiday')
  endif
"  call QFixSaveHeight(0)
  let addflag = 0
  let l:howm_dir = g:howm_dir
  if g:QFixHowm_ScheduleSearchDir != ''
    let l:howm_dir = g:QFixHowm_ScheduleSearchDir
  endif
  let l:SearchFile = g:QFixHowm_SearchHowmFile
  if g:QFixHowm_ScheduleSearchFile != ''
    let l:SearchFile = g:QFixHowm_ScheduleSearchFile
  endif
  if exists('+autochdir')
    let saved_ac = &autochdir
"    set noautochdir
  endif
  CloseQFixWin
  let prevPath = getcwd()
  let prevPath = escape(prevPath, ' ')
  silent exec 'lchdir ' . escape(l:howm_dir, ' ')
  let ext = s:sch_Ext
  if a:mode =~ 'todo'
    let ext = g:QFixHowm_ListReminder_TodoExt
    if g:QFixHowm_ShowScheduleTodo < 0
      let ext = substitute(ext, '@', '', '')
    endif
  elseif a:mode =~ 'schedule'
    let ext = g:QFixHowm_ListReminder_ScheExt
    if g:QFixHowm_ShowSchedule < 0
      let ext = substitute(ext, '@', '', '')
    endif
  elseif a:mode =~ 'menu'
    let ext = g:QFixHowm_ListReminder_MenuExt
    if g:QFixHowm_ShowScheduleMenu < 0
      let ext = substitute(ext, '@', '', '')
    endif
  elseif a:mode =~ 'holiday'
    let s:HolidayList = []
    let l:QFixHowm_ShowTodayLine = g:QFixHowm_ShowTodayLine
    let g:QFixHowm_ShowTodayLine = 0
    let ext = '[@]'
    let fname = expand(g:QFixHowm_HolidayFile)
    if !filereadable(fname)
      let fname = l:howm_dir .'/'. g:QFixHowm_HolidayFile
    endif
    let l:howm_dir = fnamemodify(fname, ':p:h')
    let l:SearchFile = fnamemodify(fname, ':p:t')
  endif
  if g:QFixHowm_RemovePriority > -1
    let ext = substitute(ext, '\.', '', '')
  endif
  if !exists('g:mygrepprg') || g:mygrepprg == 'internal' || g:mygrepprg == '' || g:QFixHowm_ScheduleSearchVimgrep || a:mode =~ 'holiday'
    let g:MyGrep_UseVimgrep = 1
    let searchWord = '^\s*'.s:sch_dateT.ext
  elseif g:mygrepprg == 'findstr'
    let searchWord = s:hts_date
    let searchWord = substitute(searchWord, '%Y', '[0-9][0-9][0-9][0-9]', '')
    let searchWord = substitute(searchWord, '%m', '[0-9][0-9]', '')
    let searchWord = substitute(searchWord, '%d', '[0-9][0-9]', '')
    let searchWord = '^[ \t]*\['.searchWord.'[0-9: ]*\]'.ext
  else
"    let searchWord = '^[ 	]*\[[0-9]{4}-[0-9]{2}-[0-9]{2}( [0-9]{2}:[0-9]{2})?]'.ext
    let searchWord = '^[ 	]*\['.s:sch_ExtGrepS.']'.ext
  endif
  let searchPath = l:howm_dir
  if g:QFixHowm_ScheduleSearchDir == ''
    let addflag = MultiHowmDirGrep(searchWord, searchPath, l:SearchFile, g:howm_fileencoding, addflag)
  else
    let addflag = MultiHowmDirGrep(searchWord, searchPath, l:SearchFile, g:howm_fileencoding, addflag, 'g:QFixHowm_ScheduleSearchDir')
  endif
  silent exec 'lchdir ' . escape(searchPath, ' ')
  call MyGrep(searchWord, searchPath, l:SearchFile, g:howm_fileencoding, addflag)
  let sq = getqflist()
  let s:UseTitleFilter = 1
  call QFixHowmTitleFilter(sq)
  let sq = QFixHowmSortReminder(sq, a:mode)
  if a:mode =~ 'holiday'
    let sq = s:MakeHolidayList(sq)
    let g:QFixHowm_ShowTodayLine = l:QFixHowm_ShowTodayLine
    silent! cexpr ''
    call MyGrepSetqflist(sq)
  elseif empty(sq)
    redraw | echo 'QFixHowm : Not found!'
  else
    call MyGrepSetqflist(sq)
    QFixCopen
    if g:QFixHowm_SchedulePreview == 0 && g:QFix_PreviewEnable == 1
      let g:QFix_PreviewEnable = -1
    endif
  endif
  if exists('+autochdir')
    let &autochdir = saved_ac
  endif
  silent exec 'lchdir ' . prevPath
  return
endfunction

"休日のみを取りだしてリストを作成する。
function! s:MakeHolidayList(sq)
  let s:HolidayList = []
  for d in a:sq
    let day = QFixHowmDate2Int(d['text'])
    call add(s:HolidayList, day)
  endfor
  return a:sq
endfunction

" リマインダーにpriorityをセットしてソートする
let s:QFixHowmReminderTodayLine = 0
function! QFixHowmSortReminder(sq, mode)
  let qflist = a:sq
  let today = QFixHowmDate2Int(strftime(s:hts_date))
  let tsec = localtime()
  if exists('g:QFixHowmToday')
    let today = QFixHowmDate2Int(g:QFixHowmToday)
    let tsec  = QFixHowmDate2Int(g:QFixHowmToday . ' 00:00')
  endif

  let idx = 0
  for d in qflist
    let d.text = substitute(d.text, '\s*', '','')
    let estr = matchstr(d.text, '&'.s:sch_dateT.'\.')
    let estr = substitute(estr, '^&', '','')
    let elen = strlen(estr)
    if elen > 14
      let esec = QFixHowmDate2Int(estr)
      if estr != '' && tsec > esec
        call remove(qflist, idx)
        continue
      endif
    else
      let eday = QFixHowmDate2Int(estr)
      if estr != '' && today > eday + g:QFixHowm_EndDateOffset
        call remove(qflist, idx)
        continue
      endif
    endif

    let str = matchstr(d.text, '^\['.s:sch_date)
    let str = substitute(str, '^\[', '', '')
    let searchWord = ']'.s:sch_cmd
    let cmd = matchstr(d.text, searchWord)
    let cmd = substitute(cmd, '^]', '', '')
    let opt = matchstr(cmd, '[0-9]*$')
    let str = s:CnvRepeatDate(cmd, opt, str)
    let d.text = '[' . str . strpart(d.text, 11)
    let desc  = escape(cmd[0], '~')
    let dow = ''
    if g:QFixHowm_ShowScheduleDayOfWeek
      let dow = ' '.s:DoW[QFixHowmDate2Int(str)%7]
    endif
    if cmd =~ '@' && opt > 1 && opt >= 2
      let dow = opt . dow
    endif
    let d.text = substitute(d.text, ']'.escape(cmd, '~*'),  ']'. desc . dow, '')
    let cmd = cmd[0]
    if opt == ''
      if cmd =~ '^-'
        let opt = g:QFixHowm_ReminderDefault_Reminder
      elseif cmd =~ '^+'
        let opt = g:QFixHowm_ReminderDefault_Todo
      elseif cmd =~ '^\!'
        let opt = g:QFixHowm_ReminderDefault_Deadline
      elseif cmd =~ '^\~'
        let opt = g:QFixHowm_ReminderDefault_UD
      elseif cmd =~ '^@'
        let opt = g:QFixHowm_ReminderDefault_Schedule
        let opt = -1
      elseif cmd =~ '^\.'
        let opt = 0
      endif
    endif
    let priority = QFixHowmDate2Int(str)
    let priority = QFixHowmGetPriority(priority, cmd, opt, today)
    let d['priority'] = priority
    let d['typepriority'] = index(g:QFixHowm_ReminderPriority, cmd)
    let showSchedule = g:QFixHowm_ShowSchedule
    if a:mode == 'todo'
      let showSchedule = g:QFixHowm_ShowScheduleTodo
    elseif a:mode == 'menu'
      let showSchedule = g:QFixHowm_ShowScheduleMenu
    endif
    let showSchedule = showSchedule - 1
    if showSchedule > -1
      let ext = '[@]'
      let searchWord = s:sch_dateT.ext
      let dowpat = searchWord . '\s*'.s:sch_dow.'\? '
      if d.text =~ searchWord
        if d.priority > today+showSchedule || d.priority < 0
          call remove(qflist, idx)
          continue
        endif
      endif
    endif
    if exists('g:QFixHowmToday')
      let d.text = d.text . "\t\t(" . priority . ")"
    else
      if priority < g:QFixHowm_RemovePriority
        call remove(qflist, idx)
        continue
      endif
      if g:QFixHowm_RemovePriorityDays && priority < today - g:QFixHowm_RemovePriorityDays
        call remove(qflist, idx)
        continue
      endif
    endif
    let d.text = substitute(d.text, '\s*&'.s:sch_dateT.'\.\s*', ' ', '')
    let d.text = substitute(d.text, '\s*$', '', '')
    let idx = idx + 1
  endfor
  let todayfname = g:QFixHowm_TodayFname
  let todaypriority = index(g:QFixHowm_ReminderPriority, '@')
  let sepdat = {"priority":today, "text": strftime('['.s:hts_dateTime.']$'), "typepriority":todaypriority, "filename":todayfname, "lnum":0, "bufnr":-1}
  call add(qflist, sepdat)
  let qflist = sort(qflist, "QFixComparePriority")

  let idx = 0
  let s:QFixHowmReminderTodayLine = 0
  let prevtext = ''
  let prevpriority = -1

  for d in qflist
    if d.priority < today
      break
    endif
    if d.priority == prevpriority && d.text == prevtext && g:QFixHowm_RemoveSameSchedule == 1
      call remove(qflist, s:QFixHowmReminderTodayLine)
      continue
    endif
    if d.priority == prevpriority && d.text == prevtext && g:QFixHowm_RemoveSameSchedule == 1
      call remove(qflist, s:QFixHowmReminderTodayLine)
      continue
    endif
    let prevtext = d.text
    let prevpriority = d.priority
    let s:QFixHowmReminderTodayLine = s:QFixHowmReminderTodayLine + 1
  endfor

  let ttime = (today - g:DateStrftime) * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60) "JST = -9
  let str = strftime('['.s:hts_date.']')
  let dow = ' '
  if g:QFixHowm_ShowScheduleDayOfWeek
    let dow = ' '.s:DoW[QFixHowmDate2Int(str)%7] . ' '
  endif
  if g:QFixHowm_ShowTodayLine == 2
    let str = strftime('['.s:hts_date.']')
  endif
  let str = strftime('['.s:hts_dateTime.']')
  let file = g:howm_dir . '/' . g:QFixHowm_ShowTodayLineStr
  let lnum = '0'
  let text = str . dow . '||'.g:QFixHowm_ShowTodayLineStr
  let file = todayfname
  let text = g:QFixHowm_ShowTodayLineStr . ' ' . str . dow . g:QFixHowm_ShowTodayLineStr
  let sep = {"filename": file, "lnum": lnum, "text": text, "bufnr":0}
  if g:QFixHowm_ShowTodayLine > 0
    call insert(qflist, sep, s:QFixHowmReminderTodayLine)
  endif

  let str = strftime('['.s:hts_dateTime.']')
  let text = g:QFixHowm_ShowTodayLineStr . ' ' . str . dow . g:QFixHowm_ShowTodayLineStr
  let text = g:QFixHowm_ShowTodayLineStr . strftime(' '.s:hts_time .' ') .g:QFixHowm_ShowTodayLineStr
  for idx in range(len(qflist))
    if qflist[idx].bufnr == -1
      if g:QFixHowm_ShowTodayLine == 2 && idx+1 != s:QFixHowmReminderTodayLine
        let qflist[idx].bufnr = 0
        let qflist[idx].text = text
      else
        call remove(qflist, idx)
        break
      endif
    endif
  endfor

  if !exists('g:QFixHowm_DayOfWeekDic')
    return qflist
  endif
  let pattern = '^' . s:sch_dateT . s:sch_Ext . ' '.s:sch_dow.' '
  for idx in range(len(qflist))
    let text = qflist[idx].text
    let dow = matchstr(text, pattern)
    let dow = matchstr(text, s:sch_dow)
    if dow == ''
      continue
    endif
    let to_dow = g:QFixHowm_DayOfWeekDic[dow]
    let qflist[idx].text = substitute(text, dow, to_dow, '')
  endfor

  return qflist
endfunction

"
" 繰り返す予定のプライオリティをセットする。
"
function! s:CnvRepeatDateR(cmd, opt, str, done)
  let cmd = a:cmd
  let opt = a:opt
  if opt == ''
    let opt = 0
  endif
  let str = a:str
  let pstr = str
  let today = QFixHowmDate2Int(strftime(s:hts_date))
  if exists('g:QFixHowmToday')
    let today = QFixHowmDate2Int(g:QFixHowmToday)
  endif
  let done = a:done
  let actday = QFixHowmDate2Int(str)

  let desc  = escape(cmd[0], '~')
  let desc0 = '^'. desc . '\{1,3}'.'\c([1-5]\*'.s:sch_dow.')'
  let desc1 = '^'. desc . '\c([0-9]\+\([-+]\?'.s:sch_dow.'\)\?)'
  let desc2 = '^'. desc . '\{2}'
  let desc3 = '^'. desc . '\{3}'
  let ttime = (today - g:DateStrftime) * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60) "JST = -9
  "次のアクティベートタイム
  let nstr = s:CnvRepeatDateN(cmd, opt, str, done)
  let nactday = QFixHowmDate2Int(nstr)
  if cmd =~ desc0
    "曜日指定の繰り返し
    let stoday = QFixHowmDate2Int(nstr)
    let sttime = (stoday - g:DateStrftime) * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60)
    let syear  = strftime('%Y', sttime)
    let smonth = strftime('%m', sttime)
    let sday   = strftime('%d', sttime)
    if cmd =~ desc.'\{3}'
      let syear = syear - 1
    elseif cmd =~ desc.'\{2}'
      let smonth = smonth - 1
      if smonth < 1
        let syear = syear - 1
        let smonth = 12
      endif
    endif
    let sttime = (stoday - g:DateStrftime) * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60)

    let dow = matchstr(cmd, s:sch_dow)
    let sft = matchstr(cmd, '[0-9]')
    if sft == ''
      let sft = 1
    endif

    let sday = s:CnvDoW(syear, smonth, sft, dow)
    let sttime = (sday - g:DateStrftime) * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60)
    let pstr = strftime(s:hts_date, sttime)
  elseif cmd =~ desc1
    "間隔指定の繰り返し
    let step  = matchstr(cmd, '\d\+')
    "曜日シフトされていない間隔指定日を求める
    let ncmd = substitute(cmd, '\c[-+]'.s:sch_dow,'','')
    let nnstr = s:CnvRepeatDateN(ncmd, opt, str, done)
    let nnactday = QFixHowmDate2Int(nstr)

    let pday = nnactday - step
    let tday = pday - g:DateStrftime
    let ttime = tday * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60) "JST = -9
    let pstr = strftime(s:hts_date, ttime)
  elseif cmd =~ desc3
    "年単位の繰り返し
    let year = matchstr(nstr, '^\d\{4}') - 1
    let pstr = printf("%4.4d", year) . strpart(str, 4)
  elseif cmd =~ desc2
    "月単位の繰り返し
    let year = matchstr(nstr, '^\d\{4}')
    let month = strpart(substitute(nstr, '[^0-9]', '', 'g'), 4, 2) - 1
    if month < 1
      let month = 12
      let year = year - 1
    endif
    let day  = matchstr(a:str, '\d\{2}$')
    let monthdays = [31,28,31,30,31,30,31,31,30,31,30,31]
    if year%4 == 0 && year%100 != 0 || year%400 == 0
      let monthdays[1] = 29
    endif
    if monthdays[month-1] < day
      let day = monthdays[month]
    endif
"    let pstr = printf("%4.4d-%2.2d-%2.2d", year, month, day)
    let pstr = printf(s:sch_printfDate, year, month, day)
    let pfsec = QFixHowmDate2Int(pstr.' 00:00')
    let pstr = strftime(s:hts_date, pfsec)
  endif
  "ここで曜日チェックしてずらす
  let pstr = s:DayOfWeekShift(cmd, pstr)
  let pactday = QFixHowmDate2Int(pstr)
  if cmd =~ '^@'
    if pactday >= today || pactday+opt > today
      return pstr
    else
      return nstr
    endif
  endif
  if cmd =~ '^-'
    if nactday == today
      return nstr
    endif
    if pactday >= actday
      return pstr
    endif
  endif
  if cmd =~ desc0
    let stoday = QFixHowmDate2Int(a:str)
    let sttime = (stoday - g:DateStrftime) * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60)
    let syear  = strftime('%Y', sttime)
    let smonth = strftime('%m', sttime)
    let sday   = strftime('%d', sttime)

    let dow = matchstr(cmd, s:sch_dow)
    let sft = matchstr(cmd, '[0-9]')
    if sft == ''
      let sft = 1
    endif

    let sday = s:CnvDoW(syear, smonth, sft, dow)
    let sttime = (sday - g:DateStrftime) * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60)
    let pstr = strftime(s:hts_date, sttime)
    return pstr
  endif
  let str = s:DayOfWeekShift(cmd, str)
  return str
endfunction

"
" 繰り返す予定のプライオリティをセットする。
"
function! s:CnvRepeatDate(cmd, opt, str, ...)
  let cmd = a:cmd
  let opt = a:opt
  if opt == ''
    let opt = 0
  endif
  let str = a:str
  let done = 0
  if a:0 > 0
    let done = 1
  endif
  if done == 0
    return s:CnvRepeatDateR(cmd, opt, str, done)
  endif
  return s:CnvRepeatDateN(cmd, opt, str, done)
endfunction

"
" 次の繰り返し予定日
"
function! s:CnvRepeatDateN(cmd, opt, str, done)
  let cmd = a:cmd
  let opt = a:opt
  if opt == ''
    let opt = 0
  endif
  let str = a:str
  let pstr = a:str
  let nstr = a:str
  let done = a:done

  let actday = QFixHowmDate2Int(str)
  let today  = QFixHowmDate2Int(strftime(s:hts_date))
  if exists('g:QFixHowmToday')
    let today = QFixHowmDate2Int(g:QFixHowmToday)
  endif
  let ttime = (today - g:DateStrftime) * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60) "JST = -9

  let desc  = escape(cmd[0], '~')
  let desc0 = '^'. desc . '\{1,3}'.'([1-5]\*'.s:sch_dow.')'
  let desc1 = '^'. desc . '\c([0-9]\+\([-+]\?'.s:sch_dow.'\)\?)'
  let desc2 = '^'. desc . '\{2}'
  let desc3 = '^'. desc . '\{3}'

  "曜日指定
  if cmd =~ desc0
    let ayear  = matchstr(str, '^\d\{4}')
    let amonth = strpart(substitute(str, '[^0-9]', '', 'g'), 4, 2)
    let aday   = matchstr(substitute(a:str, '[^0-9]', '', 'g'), '\d\{2}$')
    let atoday = QFixHowmDate2Int(a:str) + 1

    let stoday = QFixHowmDate2Int(strftime(s:hts_date))
    if exists('g:QFixHowmToday')
      let stoday = QFixHowmDate2Int(g:QFixHowmToday)
    endif
    if atoday > stoday
      let stoday = atoday
    endif
    if done
      let st = atoday + 1
      if st > stoday
        let stoday = st
      endif
    endif
    let sttime = (stoday - g:DateStrftime) * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60)

    let syear  = strftime('%Y', sttime)
    let smonth = strftime('%m', sttime)
    let sday   = strftime('%d', sttime)

    let dow = matchstr(cmd, s:sch_dow)
    let sft = matchstr(cmd, '[0-9]')
    if sft == ''
      let sft = 1
    endif

    let year  = syear
    let month = amonth
    if cmd =~ desc.'\{3}'
    elseif cmd =~ desc.'\{2}'
      let month = smonth
    endif

    let sday = s:CnvDoW(year, month, sft, dow)
    let sttime = (sday - g:DateStrftime) * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60)
    let year  = strftime('%Y', sttime)
    let month = strftime('%m', sttime)
    let sstr = strftime(s:hts_date, sttime)

    if sday > stoday
      let nstr = strftime(s:hts_date, sttime)
      let pstr = strftime(s:hts_date, sttime)
    else
      let pstr = strftime(s:hts_date, sttime)
      if cmd =~ desc.'\{3}'
        let year = year + 1
        let month = amonth
      elseif cmd =~ desc.'\{2}'
        let month = month + 1
      endif
      if month > 12
        let year = year + 1
        let month = 1
      endif
      let sday = s:CnvDoW(year, month, sft, dow)
      let sttime = (sday - g:DateStrftime) * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60)
      let nstr = strftime(s:hts_date, sttime)
    endif
    let pday = QFixHowmDate2Int(pstr)
    let nday = QFixHowmDate2Int(nstr)
    if done
      return nstr
    endif
    if cmd =~ '^@'
      if pday >= stoday || pday+opt > stoday
        return pstr
      else
        return nstr
      endif
    endif
    if stoday == pday
      return pstr
    else
      return nstr
    endif
  endif
  "間隔指定の繰り返し
  if cmd =~ desc1
    let step = matchstr(cmd, '\d\+')
    if step == 0
      let str = s:DayOfWeekShift(cmd, str)
      return str
    endif
    if step == 1
      if actday < today
        let tday = today
      else
        let tday = actday + step
      endif
    else
      if actday < today
        let tday = actday + step * (1 + ((today - actday - 1) / step))
      else
        let tday = actday + step
      endif
    endif
    let tday = tday - g:DateStrftime
    let ttime = tday * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60) "JST = -9
    let str = strftime(s:hts_date, ttime)
    if done
      return str
    endif
    let str = s:DayOfWeekShift(cmd, str)
    let sday = QFixHowmDate2Int(str)
    if sday < today
      let tday = tday + step
      let ttime = tday * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60) "JST = -9
      let str = strftime(s:hts_date, ttime)
    endif
    return str
  endif

  "年単位の繰り返し
  if cmd =~ desc3
    "曜日シフトで前日の予定が今日の予定の場合
    let sstr = s:DayOfWeekShift(cmd, str)
    let sday = QFixHowmDate2Int(sstr)
    if sday >= today
      if done
        "return str
      else
        return sstr
      endif
    endif
    if today >= actday && done == 0
      let year = strftime('%Y', ttime)
      let sstr = printf("%4.4d", year) . strpart(str, 4)
      let ssstr = s:DayOfWeekShift(cmd, sstr)
      let sday = QFixHowmDate2Int(ssstr)
      if sday < today
        let year = strftime('%Y', ttime) + 1
        let sstr = printf("%4.4d", year) . strpart(str, 4)
      endif
      let str = sstr
    else
      let year = matchstr(str, '^\d\{4}') + 1
      if year < strftime('%Y', ttime)
        let year = strftime('%Y', ttime)
      endif
      let sstr = printf("%4.4d", year) . strpart(str, 4)
      let ssstr = s:DayOfWeekShift(cmd, sstr)
      let sday = QFixHowmDate2Int(ssstr)
      if sday < today
        let year = strftime('%Y', ttime) + 1
        let sstr = printf("%4.4d", year) . strpart(str, 4)
      endif
      let str = sstr
    endif
    if done
      return str
    endif
    let sstr = s:DayOfWeekShift(cmd, str)
    let sday = QFixHowmDate2Int(sstr)
    return sstr
  endif

  "月単位の繰り返し
  if cmd =~ desc2
    let year  = strftime('%Y', ttime)
    let month = strftime('%m', ttime)
    let day   = strftime('%d', ttime)
    let ayear = matchstr(str, '^\d\{4}')
    let amonth = strpart(substitute(str, '[^0-9]', '', 'g'), 4, 2)
    let aday  = matchstr(substitute(a:str, '[^0-9]', '', 'g'), '\d\{2}$')
    let str = a:str

    if today > actday
      let ofs =0
      if month == amonth
        let ofs = 1
      endif
"      let tstr = printf("%4.4d-%2.2d-%2.2d", year, month + ofs, aday)
      let tstr = printf(s:sch_printfDate, year, month + ofs, aday)
      let pfsec = QFixHowmDate2Int(tstr.' 00:00')
      let tstr = strftime(s:hts_date, pfsec)
      let sstr = s:DayOfWeekShift(cmd, tstr)
      let tday = QFixHowmDate2Int(sstr)
      if tday >= today
        if done > 0
          return tstr
        else
          return sstr
        endif
      endif
"      let tstr = printf("%4.4d-%2.2d-%2.2d", year, month, aday)
      let tstr = printf(s:sch_printfDate, year, month, aday)
      let sec = QFixHowmDate2Int(tstr.' 00:00')
      let tstr = strftime(s:hts_date, sec)
      let sstr = s:DayOfWeekShift(cmd, tstr)
      let tday = QFixHowmDate2Int(sstr)
      if tday >= today
        if done > 0
          return tstr
        else
          let sstr = s:DayOfWeekShift(cmd, tstr)
          return sstr
        endif
      else
"        let tstr = printf("%4.4d-%2.2d-%2.2d", year, month+1, aday)
        let tstr = printf(s:sch_printfDate, year, month+1, aday)
        let sec = QFixHowmDate2Int(tstr.' 00:00')
        let tstr = strftime(s:hts_date, sec)
        return tstr
      endif
    else
"      let tstr = printf("%4.4d-%2.2d-%2.2d", ayear, amonth+1, aday)
      let tstr = printf(s:sch_printfDate, ayear, amonth+1, aday)
      let sec = QFixHowmDate2Int(tstr.' 00:00')
      let tstr = strftime(s:hts_date, sec)
      if done > 0
        return tstr
      else
        let sstr = s:DayOfWeekShift(cmd, tstr)
        return sstr
      endif
    endif
  endif

  "ここで曜日チェックしてずらす
  if done == 0
    return s:DayOfWeekShift(cmd, str)
  endif
  return str
endfunction

"
"指定月のsft回目のdow曜日を返す
"
function! s:CnvDoW(year, month, sft, dow)
  let year = a:year
  let month = a:month
  let sft = a:sft
  if sft == 0 || sft == ''
    let sft = 1
  endif
  let dow = a:dow
"  let sstr = printf("%4.4d-%2.2d-01", year, month)
  let sstr = printf(s:sch_printfDate, year, month, 1)
  let pfsec = QFixHowmDate2Int(sstr.' 00:00')
  let sstr = strftime(s:hts_date, pfsec)
  let fday = QFixHowmDate2Int(sstr)
  let fdow = fday%7
  let day = fday - fday%7
  let tday = day + (sft-1) * 7 + index(s:DoW, dow)

  let day = tday - g:DateStrftime - (sft-1) * 7
  let ttime = day * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60) "JST = -9
  let month = strftime('%m', ttime)
  if month != a:month
    let tday = tday + 7
  endif
  return tday
endfunction

"
"曜日シフト
"
let s:DoW = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Hdy']
function! s:DayOfWeekShift(cmd, str)
  let cmd = a:cmd
  let str = a:str
  let actday = QFixHowmDate2Int(str)

  let dow = matchstr(cmd, '[-+*]\?'.s:sch_dow)
  let sft = matchstr(dow, '[-+*]')
  if sft == '' || sft == '*'
    return str
  endif
  let dow = substitute(dow, '[-+]', '', 'g')

  "休日シフト
  if dow == 'Hdy' && exists('s:HolidayList') && s:HolidayList != []
    while 1
      if count(s:HolidayList, actday) == 0  && '\c'.s:DoW[actday%7] !~ 'Sun'
        break
      endif
      let sec = QFixHowmDate2Int(str.' 00:00')
      let sec = sec + (sft == '-' ? -1: 1) * 24 *60 *60
      let str = strftime(s:hts_date, sec)
      let actday = QFixHowmDate2Int(str)
    endwhile
    return str
  endif

  if '\c'.s:DoW[actday%7] =~ dow && dow != ''
    let sec = QFixHowmDate2Int(str.' 00:00')
    let sec = sec + (sft == '-' ? -1: 1) * 24 *60 *60
    let str = strftime(s:hts_date, sec)
  endif
  return str
endfunction

"
"日付からプライオリティをセットする。
"todayを基準値とし、コマンドとオプションによってプライオリティ値が計算される。
"
function! QFixHowmGetPriority(priority, cmd, opt, today)
  let priority = a:priority
  let cmd = a:cmd
  let opt = a:opt
  let today = a:today
  let days = 1

  if cmd =~ '^-'
    "* 指定日に浮きあがり, 以後は徐々に沈む
    "* 指定日までは底に潜伏
    "  沈むのを遅くするには, 猶予日数で指定(デフォルト 1 日)
    "  継続期間は 1+猶予日数
    if today >= priority
      if (today > priority + (opt-1+g:QFixHowm_ReminderOffset) * days)
        let priority = priority + (opt-1+g:QFixHowm_ReminderOffset) * days
      else
        let priority = today
      endif
    else
      let priority = 0
    endif
  elseif cmd =~ '^+'
    "* 指定日から, 徐々に浮きあがってくる
    "* 指定日までは底に潜伏
    "  浮きあがる速さは, 猶予日数で指定(デフォルト 7 日)
    if priority  <= today
      let priority = today - opt * days + today - priority
      if priority > today
        let priority = today
      endif
    else
      let priority = 0
    endif
  elseif cmd =~ '^\!'
    "# 指定日が近づくと, 浮きあがってくる
    "# 指定日以降は, 一番上に浮きっぱなし
    "  何日前から浮きはじめるかは, 猶予日数で指定(デフォルト 7 日)
    if today + opt * days >= priority
      let priority = today - (priority - today)
    else
      let priority = 0
    endif
  elseif cmd =~ '^\~'
    "# 指定日から, 浮き沈みをくりかえす
    "# 指定日までは底に潜伏
    let cycle = opt / 2
    if priority <= today
      let term = priority - today
      let len = term % cycle
      if (term / opt) % 2
        let priority = today - len
      else
        let priority = today - cycle + len
      endif
    else
      let priority = 0
    endif
  elseif cmd =~ '^@'
    "todo一覧ではなく, 予定表に表示
    let postshow = g:QFixHowm_ReminderDefault_Schedule
    if opt == 0
      let postshow = opt
    endif
    if opt <= 1
      let opt = 0
    endif
    if today > priority + opt + postshow
      let priority = -1
    endif
    if opt > 1
      if today > priority && today < priority + opt
        let priority = today
      endif
    endif
  elseif cmd =~ '^\.'
    "実行済で常に底
    let priority = -1
  endif
  return priority
endfunction

"
"priorityソート関数
"
function! QFixCompareRev(v1, v2)
  return (a:v1.text > a:v2.text?1:-1)
endfunction

function! QFixComparePriority(v1, v2)
  if a:v1.priority != a:v2.priority
    return (a:v1.priority <= a:v2.priority?1:-1)
  endif
  if a:v1.typepriority != a:v2.typepriority
    return (a:v1.typepriority >= a:v2.typepriority?1:-1)
  endif
  if a:v1.text != a:v2.text
    if g:QFixHowm_ReminderSortMode == 0
      return (a:v1.text < a:v2.text?1:-1)
    else
      return (a:v1.text >= a:v2.text?1:-1)
    endif
  endif
  return (bufname(a:v1.bufnr) . a:v1.lnum> bufname(a:v2.bufnr).a:v2.lnum?1:-1)
endfunction

"
" 今日の日付まで移動
"
function! QFixHowmMoveTodayReminder()
  let save_cursor = getpos('.')
  call cursor(1,1)
  let str = strftime('['.s:hts_date)
  let str = g:QFixHowm_ShowTodayLineStr . ' ' . str
  let [lnum, col] = searchpos(str, 'cW')
  if lnum == 0 && col == 0
"    redraw | echo 'QFixHowm : Not found!'
    call setpos('.', save_cursor)
    return
  endif
  call cursor(lnum, 1)
  exec 'normal! zz'
endfunction

"
" 日付を今日までの日数に変換
"
function! QFixHowmDate2Int(str)
  let str = a:str
  let retval = 'time'
  "422(22)フォーマット前提の ザ・決め打ち
  let str   = substitute(str, '[^0-9]','', 'g')
  let year  = matchstr(str, '\d\{4}')
  let str   = substitute(str, '\d\{4}','', '')
  let month = matchstr(str, '\d\{2}')
  let str   = substitute(str, '\d\{2}','', '')
  let day   = matchstr(str, '\d\{2}')
  let str   = substitute(str, '\d\{2} \?','', '')
  let hour  = matchstr(str, '\d\{2}')
  let str   = substitute(str, '\d\{2}:\?','', '')
  let min   = matchstr(str, '\d\{2}')
  if hour == '' || min == ''
    let retval = 'date'
    let hour  = strftime('%H', localtime())
    let min   = strftime('%M', localtime())
  endif

  " 1・2月 → 前年の13・14月
  if month <= 2
    let year = year - 1
    let month = month + 12
  endif
  let dy = 365 * (year - 1) " 経過年数×365日
  let c = year / 100
  let dl = (year / 4) - c + (c / 4)  " うるう年分
  let dm = (month * 979 - 1033) / 32 " 1月1日から month 月1日までの日数
  let today = dy + dl + dm + day - 1

  if retval =~ 'date'
    return today
  endif

  let today = today - g:DateStrftime
  let sec = today * 24*60*60 + g:QFixHowm_ST * (60 * 60) "JST = -9
  let sec = sec + hour * (60 * 60) + min * 60

"  echo strftime(s:hts_date, localtime()) localtime()
  return sec
endfunction

function! QFixHowmHelp()
  if g:QFixHowm_MenuDir == ''
    let hdir = escape(expand(g:howm_dir), ' ')
  else
    let hdir = escape(expand(g:QFixHowm_MenuDir), ' ')
  endif
  silent! exec 'split ' . hdir .'/'. s:QFixHowm_Helpfile
  setlocal buftype=nofile
"  setlocal bufhidden=wipe
  setlocal noswapfile
"  setlocal nobuflisted
  call setline(1, g:QFixHowmHelpList)
  silent! exec 'setlocal filetype='.g:QFixHowm_FileType
  call cursor(1,1)
endfunction

"
"メニューファイルを開く
"
function! QFixHowmOpenMenu()
  if g:QFixHowm_MenuDir== ''
    let file = g:howm_dir. '/'.g:QFixHowm_Menufile
  else
    let file = g:QFixHowm_MenuDir  . '/' . g:QFixHowm_Menufile
  endif
  let file = substitute(file, '\\', '/', 'g')
  let file = substitute(file, '/\+', '/', 'g')

  let file = expand(file)
  let dfile = expand(file)
  let efile = fnamemodify(file, "%:p")
  let file = escape(file, " ")
  let efile = escape(efile, " ")

  if !filereadable(dfile)
    let ddfile = substitute(dfile, '\\', '/', 'g')
    let ddfile = substitute(ddfile, '/\+', '/', 'g')
    let dir = matchstr(ddfile, '.*/')
    let dir = substitute(dir, '/$', '', '')
"    let dir = expand(dir)
    if isdirectory(dir) == 0 && dir != ''
      call mkdir(dir, 'p')
    endif
    exec 'edit '.efile
    silent exec 'setlocal fenc=' . g:howm_fileencoding
    silent exec 'setlocal ff='. g:howm_fileformat
"    silent! 0put=g:QFixHowmMenuList
    call setline(1, g:QFixHowmMenuList)
    silent exec 'w! '
    silent exec '0'
  else
"    let file = escape(file, ' ')
  endif
  if g:QFixHowm_ShowTodoOnMenu == 1
    call QFixHowmListReminder("menu")
    if exists('g:QFix_Win')
      silent! wincmd p
    endif
  elseif g:QFixHowm_ShowTodoOnMenu == 2
    QFixHowmRandomWalk
  endif
  call QFixHowmEditFile(efile)
endfunction

"
"一ファイル複数メモを分割保存する
"
function! QFixHowmDivideEntry() range
  let s:mru_list_locked = 1
  let firstline = a:firstline
  let lastline = a:lastline
  if firstline == lastline
    let firstline = 1
    let lastline = line('$')
  endif
  silent! exec firstline.','.lastline.'y'
  let openwin = 0
  if exists('g:QFix_Win') && bufwinnr(g:QFix_Win)
    let openwin = 1
    CloseQFixWin
  endif
  let h = g:QFix_Height
  silent! exec 'split '
  silent! exec 'silent! edit '.s:howmtempfile
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  silent! %delete _
  silent! 0put
  silent! exec '%s/^' . g:QFixHowm_MergeEntrySeparator.g:howm_glink_pattern. '.*$' . '\n=/=/g'

  let cnt = 0
  call cursor(1,1)
  let l:QFixHowm_Title = escape(g:QFixHowm_Title, g:QFixHowm_EscapeTitle)
  let l:QFixHowm_Title = l:QFixHowm_Title.'\(\s\|$\)'
  let fline = search('^'.l:QFixHowm_Title, 'cW')
  while 1
    let lline = search('^'.l:QFixHowm_Title, 'W')
    if lline == 0
      let lline = line('$')
    endif
    let text = ''
    for d in range(fline, lline-1)
      let text = text . getline(d) . "\<NL>"
    endfor
    call s:QFixHowmSaveDividedEntry(text, cnt)
    let cnt = cnt + 1
    if lline == line('$')
      break
    endif
    let fline = lline
  endwhile
  silent! exec 'silent! edit '.s:howmtempfile
  setlocal buftype=nofile
  silent! bd!
  let g:QFix_Height = h
  if openwin == 1
    QFixCopen
    wincmd p
  endif
  let s:mru_list_locked = 0
  redraw | echo "QFixHowm : Completed."
endfunction

"
"SaveEntry
"
function! s:QFixHowmSaveDividedEntry(text, cnt)
  let g:QFixHowm_WriteUpdateTime = 0
  let l:howm_filename = strftime(g:QFixHowm_GenerateFile, localtime()+a:cnt)
  let file = escape(g:howm_dir.'/'.l:howm_filename, ' ')
  let dir = matchstr(file, '.*/')
  let dir = substitute(dir, '/$', '', '')
  let dir = expand(dir)
  let opt = '++enc=' . g:howm_fileencoding . ' ++ff=' . g:howm_fileformat . ' '
  silent exec 'new '. opt . file

  silent exec 'setlocal fenc=' . g:howm_fileencoding
  silent exec 'setlocal ff='. g:howm_fileformat
  silent! %delete _
  silent! 0put=a:text
  silent exec 'normal! G'
  while 1
    if getline('.') !~ '^$' || line('.') == 1
      break
    endif
    silent exec 'normal! dd'
  endwhile
  silent exec "normal! Go\<ESC>"
  silent exec 'normal! gg'
  silent exec 'w! '
  silent exec 'bd'
  let g:QFixHowm_WriteUpdateTime = 1
endfunction

"
"オートリンク定義へタグジャンプする
"
function! QFixHowmOpenClink()
  if g:QFixHowm_UseAutoLinkTags == 0
    return 0
  endif
  silent exec 'lchdir ' . escape(g:QFixHowm_TagsDir, ' ')
  "TODO:ここにタグジャンプを実装する
  return 0
  exec 'normal! <C-]>'
  return 1
endfunction

"
"オートリンクtagジャンプファイルを作成する
"tags互換
"
function! QFixHowmSaveAutolinkTag(keyword, file, lnum, mode)
  if g:QFixHowm_UseAutoLinkTags == 0 || a:keyword =~ '^\s*$'
    return
  endif
  let tdir = expand(g:QFixHowm_TagsDir)
  let tdir = substitute(tdir, '\\', '/', 'g').'/'
  let tdir = substitute(tdir, '/\+', '/', 'g')
  let tfile = tdir . 'tags'

  let file = expand(a:file)
  let file = substitute(file, '\\', '/', 'g')
  let file = substitute(file, '/\+', '/', 'g')

  let relfname = './' . substitute(file, tdir, '', '')
  let relfname = file
  if filereadable(tfile)
    let tdic = readfile(tfile)
  else
    let tdic = []
  endif
  let otdic = deepcopy(tdic)
  if a:mode
    "fileと同じファイル名のリストを全削除
    let idx = 0
    for d in tdic
      if d =~ '\V'.relfname
        silent! call remove(tdic, idx)
      else
        let idx = idx+1
      endif
    endfor
  endif
  let keyword = a:keyword
  "keyword, relfname, lnumを登録
  let tline = keyword . "\t" . relfname . "\t" . a:lnum
  call add(tdic, tline)

  let skeyword = matchstr(keyword, '[^ ]*')
  if skeyword != keyword
    let tline = skeyword . "\t" . relfname . "\t" . a:lnum
    call add(tdic, tline)
  endif
  let tdic = sort(tdic)
  if otdic != tdic
    call writefile(tdic, tfile)
  endif
endfunction

"
"カーソルをエントリを先頭行・末尾行へ移動
"
command! -count -nargs=1 QFixHowmCursor if count > 0|call QFixHowmCursor(<q-args>, count)|else|call QFixHowmCursor(<q-args>)|endif
function! QFixHowmCursor(pos, ...)
  if a:pos == 'top'
    call cursor(1, 1)
  elseif a:pos == 'bottom'
    call cursor(line('$'), 1)
  else
    let l:QFixHowm_Title = escape(g:QFixHowm_Title, g:QFixHowm_EscapeTitle)
    let l:QFixHowm_Title = l:QFixHowm_Title.'\(\s\|$\)'
    let cnt = 1
    if a:0
      let cnt = a:1
    endif
    for i in range(1,cnt)
      if a:pos == 'next'
        let fline = search('^'.l:QFixHowm_Title, 'nW')
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
        let fline = search('^'.l:QFixHowm_Title, opt)
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

"
"アウトライン呼び出し
"
silent! function QFixHowmOutline()
  silent exec "normal! zi"
endfunction

"
"フォールディングレベル計算
"
let s:schepat = '^\s*'.s:sch_dateT.s:sch_Ext
let s:titlepat = '^'.escape(g:QFixHowm_Title, g:QFixHowm_EscapeTitle).'\([^'.g:QFixHowm_Title.']\|$\)'
silent! function QFixHowmFoldingLevel(lnum)
  let text = getline(a:lnum)
  if text =~ s:titlepat || text =~ s:schepat
    if g:QFixHowm_Folding == 1
      return '>1'
    endif
    return '0'
  endif
  "カードチャプターに応じて折りたたみレベルを設定する
  let wild = '\(\(\d\+\|\*\)\.\)\+\(\d\+\|\*\)\?'
  let str = matchstr(text, '^\s*'.wild.'\s*')
  let str = substitute(str, '\d\+', '*', 'g')
  let level = strlen(substitute(str, '[^*]', '' , 'g'))
  if level == 0 && g:QFixHowm_FoldingPattern != ""
    let str = matchstr(text, g:QFixHowm_FoldingPattern.'\+')
    let str = substitute(str, '[^'.str[0].'].*$', '', 'g')
    let level = strlen(str)
  endif
  if g:QFixHowm_FoldingMode == 0
    if level
      if g:QFixHowm_FoldingChapterTitle == 0
        return '>1'
      endif
      return '0'
    endif
    return '1'
  elseif g:QFixHowm_FoldingMode == 1
    if level
      return '>'.level
    endif
    return 'a'
  endif
  return '1'
endfunction

"エントリを折りたたむ
augroup QFixHowmFolding
  autocmd!
  if g:QFixHowm_Folding
    exec "autocmd BufNewFile,BufRead *.".g:QFixHowm_FileExt." setlocal nofoldenable"
    exec "autocmd BufNewFile,BufRead *.".g:QFixHowm_FileExt." setlocal foldmethod=expr"
    if g:QFixHowm_WildCardChapter
      exec "autocmd BufNewFile,BufRead *.".g:QFixHowm_FileExt." setlocal foldexpr=QFixHowmFoldingLevel(v:lnum)"
    else
      exec "autocmd BufNewFile,BufRead *.".g:QFixHowm_FileExt." setlocal foldexpr=getline(v:lnum)=~'".g:QFixHowm_FoldingPattern."'?'>1':'1'"
    endif
  endif
augroup END

"折りたたみ範囲をコピー/削除
function! QFixHowmFoldText(cmd)
  let saved_fen = &foldenable
  let save_cursor = getpos('.')
  setlocal foldenable
  let c = count > 1 ? count : 1
  for n in range(1, c)
    silent! exec 'normal! zczj'
  endfor
  call setpos('.', save_cursor)
  if foldlevel(line('.'))
    exec 'normal! ' .c. a:cmd
  else
    echohl ErrorMsg
    echo 'No fold found!'
    echohl None
  endif
  let &foldenable = saved_fen
  if a:cmd == 'yy'
    call setpos('.', save_cursor)
  endif
endfunction

"
"バッファローカル用Saveコマンド
"
function! QFixHowmBufLocalSave()
  let g:QFixHowm_WriteUpdateTime = 0
  if &buftype == 'nofile'
    setlocal buftype=
  endif
  write!
endfunction

"
"ファイルを開く
"
function! QFixHowmOpenFile(file, fenc, ff)
  let file = a:file
  let fenc = a:fenc
  let ff   = a:ff
  let winnum = bufwinnr('' . file . '$')
  if winnum != -1
    if winnum != winnr()
      exec winnum . 'wincmd w'
    endif
  else
    let winnr = QFixWinnr()
    if winnr < 1
      split
    else
      exec winnr.'wincmd w'
    endif
    exec g:QFixHowm_Edit.'edit ++enc='. fenc .' ++ff='. ff .' ' . file
  endif
endfunction

"
"Listをフォーマット変換
"
function! QFixHowmCnvTextListFormat(textlist, fenc, ff)
  let idx = 0
  for d in a:textlist
    let a:textlist[idx] = QFixHowmCnvTextFormat(d, a:fenc, a:ff)
    let idx = idx + 1
  endfor
  return a:textlist
endfunction

"
"テキストをフォーマット変換
"
function! QFixHowmCnvTextFormat(text, fenc, ff)
  let text = a:text
  if &enc != a:fenc
    let text = iconv(text, &enc, a:fenc)
  endif
  if a:ff == 'dos'
    let text = substitute(text, '$', "\<CR>", 'g')
  endif
  return text
endfunction

"
"Quickfixウィンドウの定義部分を取り出す
"
function! QFixHowmCmd_ScheduleList(...) range
  if !exists("*QFixHowmExportSchedule")
    return
  endif
  let prevPath = getcwd()
  let prevPath = escape(prevPath, ' ')

  let firstline = 1
  let cnt = line('$')
  if a:firstline != a:lastline || a:0 > 0
    let cnt = a:lastline - a:firstline + 1
    let firstline = a:firstline
  endif

  let schlist = []
  let l:QFixHowm_Title = '\d\+| '.s:sch_dateT.s:sch_Ext
  let save_cursor = getpos('.')
  for n in range(cnt)
    call cursor(firstline+n, 1)
    let qfline = getline('.')
    if qfline !~ l:QFixHowm_Title
      continue
    endif
    let holiday = g:QFixHowm_ReminderHolidayName
    if exists('g:QFixHowm_UserHolidayName')
      let holiday = g:QFixHowm_ReminderHolidayName . '\|' .g:QFixHowm_UserHolidayName
    endif
    let hdreg = '^'.s:sch_dateTime .'@ '.g:QFixHowm_DayOfWeekReg.' \?'.'\('.holiday.'\)'
    if qfline =~ holiday && g:QFixHowmExportHoliday == 0
      continue
    endif
    let file = QFixGet('file')
    if g:QFix_SearchPathEnable && g:QFix_SearchPath != ''
"      let file = escape(g:QFix_SearchPath, ' ') . '/' .file
    endif
    let lnum = QFixGet('lnum')
    let ddat = {"qffile": file, "qflnum": lnum, "qfline": qfline}
    call add(schlist, ddat)
  endfor
  call setpos('.', save_cursor)

  CloseQFixWin
  let h = g:QFix_Height
  silent! exec 'split '
  silent! exec 'silent! edit '.s:howmtempfile
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal bufhidden=hide
  setlocal nobuflisted
  for d in schlist
    call s:QFixHowmMakeScheduleList(d)
  endfor
  silent! exec 'silent! edit '.s:howmtempfile
  setlocal buftype=nofile
  silent! bd!
  let g:QFix_Height = h
  if schlist != []
    call s:QFixHowmParseScheduleList(schlist)
    call QFixHowmExportSchedule(schlist)
  else
    QFixCopen
  endif
  silent exec 'lchdir ' . prevPath
  return schlist
endfunction

"
"定義ファイルから定義部分と内容を取り出す
"
function! s:QFixHowmMakeScheduleList(sdic)
  setlocal modifiable
  silent! %delete _
  let file = a:sdic['qffile']
  let lnum = a:sdic['qflnum']
  if g:QFix_SearchPathEnable && g:QFix_SearchPath != ''
    silent exec 'lchdir ' . escape(g:QFix_SearchPath, ' ')
  endif
  let tmpfile = escape(file, ' #%')
  if g:QFixHowm_ForceEncoding
    silent! exec '0read ++enc='.g:howm_fileencoding.' ++ff='.g:howm_fileformat.' '.tmpfile
  else
    silent! exec '0read '.tmpfile
  endif
  silent! $delete _
  call cursor(lnum,1)
  let a:sdic['orgline'] = getline(lnum)

  let l:QFixHowm_Title = escape(g:QFixHowm_Title, g:QFixHowm_EscapeTitle)
  let l:QFixHowm_Title = '\('.s:sch_dateT.s:sch_Ext.'\|'.l:QFixHowm_Title.'\(\s\|$\)\)'
  let head = '^'. l:QFixHowm_Title

"  call search(head, 'cbW')
  let start = lnum+1
  let end   = search(head, 'nW')-1
  if end == -1
    let end = line('$')
  endif
  let a:sdic['Description'] = getline(start, end)
  return a:sdic['Description']
endfunction

"
"定義部分から各種パラメータを取り出す。
"
function! s:QFixHowmParseScheduleList(sdic)
  for d in a:sdic
    let pattern = '.*'.s:sch_dateT.s:sch_Ext.'\d*\s*'.g:QFixHowm_DayOfWeekReg.'\?\s*'
    let d['Summary'] = substitute(d['qfline'], pattern, '', '')
    let pattern = '\['.s:sch_date
    let d['StartDate'] = strpart(matchstr(d['qfline'], pattern), 1)
    let pattern = '\['.s:sch_date . ' '. s:sch_time
    let d['StartTime'] = strpart(matchstr(d['qfline'], pattern), 12)
    let pattern = '&\['.s:sch_date
    let d['EndDate'] = strpart(matchstr(d['orgline'], pattern), 2)
    let pattern = '&\['.s:sch_date.' '. s:sch_time
    let d['EndTime'] = strpart(matchstr(d['orgline'], pattern), 13)
    if d['EndTime'] == ''
      let d['EndDate'] = s:QFixHowmAddDate(d['EndDate'], g:QFixHowm_EndDateOffset)
    endif

    let pattern = s:sch_dateCmd
    let d['define']  = strpart(matchstr(d['orgline'], pattern), 0)
    let pattern = ']'.s:sch_cmd
    let d['command'] = strpart(matchstr(d['orgline'], pattern), 1)
    let d['duration'] = matchstr(d['command'], '\d\+$')

    let duration = d['duration']
    let cmd = d['command'][0]
    if duration == ''
      if cmd == '@'
        "@のデフォルトオプションは表示だけに関係する
        let duration = 1
      elseif cmd == '!'
        let duration = g:QFixHowm_ReminderDefault_Deadline
      elseif cmd == '-'
        let duration = g:QFixHowm_ReminderDefault_Reminder
      elseif cmd == '+'
        let duration = g:QFixHowm_ReminderDefault_Todo
      elseif cmd == '~'
        let duration = g:QFixHowm_ReminderDefault_UD
      else
        let duration = 0
      endif
    else
      "@のオプションは0,1の継続期間が同じ
      if cmd == '@'
        if duration < 2
          let duration = 1
        endif
      endif
    endif
    "-の継続期間は duration+1日
    if cmd == '-'
      let duration = duration + g:QFixHowm_ReminderOffset
    endif
    let d['duration'] = duration
  endfor
endfunction

function! s:QFixHowmAddDate(date, param)
  let day = QFixHowmDate2Int(a:date) + a:param
  let sttime = (day - g:DateStrftime) * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60)
  let str = strftime(s:hts_date, sttime)
  return matchstr(str, s:sch_date)
endfunction

"
"タイトルと予定・TODOで指定文字列を含むものを非表示にする
"
let s:UseTitleFilter = 0
function! QFixHowmTitleFilter(sq)
  if s:UseTitleFilter == 0 || g:QFixHowm_TitleFilterReg == ''
    return
  endif
  let s:UseTitleFilter = 0
  let idx = 0
  for d in a:sq
    if d.text =~ g:QFixHowm_TitleFilterReg
      call remove(a:sq, idx)
      continue
    endif
    let idx = idx + 1
  endfor
endfunction

"サブウィンドウを常駐モードにする。
if !exists('g:QFix_PermanentWindow')
  let g:QFix_PermanentWindow = []
endif

"サブウィンドウのトグル
function! ToggleQFixSubWindow()
  let bufnum = bufnr(g:SubWindow_Title)
  let winnum = bufwinnr(g:SubWindow_Title)
  if bufnum != -1 && winnum != -1
    exec "bd ". bufnum
  else
    call s:OpenQFixSubWin()
  endif
endfunction

function! s:OpenQFixSubWin()
  let winnum = bufwinnr(g:SubWindow_Title)
  if winnum != -1
    if winnr() != winnum
      exec winnum . 'wincmd w'
    endif
    return
  endif
  let windir = g:SubWindow_Dir
  let winsize = g:SubWindow_Width

  let bufnum = bufnr(g:SubWindow_Title)
  if bufnum == -1
    let wcmd = g:SubWindow_Title
  else
    let wcmd = '+buffer' . bufnum
  endif
  exec 'silent! ' . windir . ' ' . winsize . 'split ' . wcmd
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nowrap
  setlocal foldcolumn=0
  setlocal nolist
  setlocal winfixwidth
  nnoremap <silent> <buffer> q :close<CR>
endfunction

let s:prevgepname = ''
function! QFixHowmSetTtime(qf, pattern)
  if g:QFixHowm_RecentMode == 0
    return a:qf
  endif
  let idx = 0
  let s:prevgepname = ''
  for d in a:qf
    let file = bufname(d.bufnr)
    let t = s:GetPatternInEntry(file, a:pattern, d.lnum)
    let d['time'] = t
    let idx = idx + 1
  endfor
  return a:qf
endfunction

"エントリ内からパターンを探して返す
function! s:GetPatternInEntry(file, pattern, lnum)
  let file = fnamemodify(a:file, ':p')
  let pattern = a:pattern
  let lnum = a:lnum
  let tfmt = '%Y%m%d%H%M'
  if s:prevgepname != file
    "検索対象は半角なのでiconvしない
    silent! let s:tempfilebuf = readfile(file)
    let s:prevgepname = file
  endif
  let l:QFixHowm_Title = escape(g:QFixHowm_Title, g:QFixHowm_EscapeTitle)
  let l:QFixHowm_Title = l:QFixHowm_Title.'\(\s\|$\)'
  let idx = lnum - 1
  for n in range(idx, 0, -1)
    let idx = n
    if s:tempfilebuf[n] =~ '^'.l:QFixHowm_Title || n == 0
      break
    endif
  endfor
  let idx = idx + 1
  let end = len(s:tempfilebuf) - 1
  let text = ''
  for n in range(idx, end)
    if s:tempfilebuf[n] =~ pattern
      let text = matchstr(s:tempfilebuf[n], pattern)
      break
    endif
    if s:tempfilebuf[n] =~ '^'.l:QFixHowm_Title || n == end
      let idx = -1
    endif
  endfor
  if text == ''
    return strftime(tfmt, getftime(file))
  else
    let text = matchstr(text, pattern)
    let text = substitute(text, '[^0-9]', '', 'g')
    let text = matchstr(text, '\d\{12}')
    return text
  endif
endfunction

silent! function QFixHowmCreateNewFileWithTag(tag)
  let title = g:QFixHowm_Title. ' '. a:tag
  call QFixHowmCreateNewFile()
  stopinsert
  call setline(1, [title])
  call cursor(1, 1)
  exec 'normal! 0w'
endfunction

"
"quickfixのリストにタイトルを付加
"
function! QFixHowmFLaddtitle(path, list)
  let prevPath = getcwd()
  let prevPath = escape(prevPath, ' ')
  let h = g:QFix_Height
  silent! exec 'split '
  silent! exec 'silent! edit '.s:howmtempfile
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  silent exec 'lchdir ' . escape(a:path, ' ')
  let prevfname = ''
  for d in a:list
    let file = d.filename
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
  silent! exec 'silent! edit '.s:howmtempfile
  setlocal buftype=nofile
  silent! bd!
  let g:QFix_Height = h
endfunction

"
"ファイルリストをquickfixに登録
"
function! QFixHowmShowFileList(path, list)
  if QFixHowmInit()
    return
  endif
  let prevPath = getcwd()
  let prevPath = escape(prevPath, ' ')
  let g:QFix_MyJump = 1
  let g:QFix_Modified = 1
  let g:QFix_SelectedLine = 1
  let g:QFix_SearchResult = []
  let g:QFix_SearchPath = a:path
  CloseQFixWin
  silent exec 'lchdir ' . escape(g:QFix_SearchPath, ' ')
  call MyGrepSetqflist(a:list)
  QFixCopen
  silent exec 'lchdir ' . prevPath
endfunction

"ファイルリストを作成して登録
command! -count -nargs=* QFixHowmFileList if count > 0|let g:QFixHowm_FileListMax = count|endif|call QFixHowmFileListMultiDir(g:QFixHowm_FileList)
function! QFixHowmFileList(path, file)
  let path = expand(a:path)
  if path == ''
    let path = expand("%:p:h")
  endif
  if !isdirectory(path)
    echoe '"' . a:path.'" does not exist!'
    return
  endif
  let list = QFixHowmGetFileList(path, a:file)
  let cnt = g:QFixHowm_FileListMax
  if count
    let cnt = count
  endif
  if cnt
    silent! call remove(list, cnt, -1)
  endif
  "サマリーを付加
  call QFixHowmFLaddtitle(path, list)
  call QFixHowmShowFileList(path, list)
endfunction

function! QFixHowmFileListMultiDir(file)
  let basename    = 'g:howm_dir'
  let tlist =  QFixHowmGetFileList(g:howm_dir, a:file)
  call QFixHowmFLaddtitle(g:howm_dir, tlist)
  for i in range(2, g:QFixHowm_howm_dir_Max)
    if g:QFixHowm_howm_dir_Max < 2
      break
    endif
    if !exists(basename.i)
      continue
    endif
    exec 'let hdir = '.basename.i
    if isdirectory(expand(hdir)) == 0
      continue
    endif
    let l:howm_fileencoding = g:howm_fileencoding
    if exists('g:howm_fileencoding'.i)
      exec 'let l:howm_fileencoding = g:howm_fileencoding'.i
    endif
    if l:howm_fileencoding != g:howm_fileencoding
      let g:QFixHowm_ForceEncoding = 0
    endif
    let list = QFixHowmGetFileList(hdir, a:file)
    call QFixHowmFLaddtitle(hdir, list)
    let tlist = extend(tlist, list)
  endfor
  let cnt = g:QFixHowm_FileListMax
  if count
    let cnt = count
  endif
  if cnt
    silent! call remove(tlist, cnt, -1)
  endif
  "サマリーを付加
  exec 'lchdir ' . escape(g:howm_dir, ' ')
  call QFixHowmShowFileList(g:howm_dir, tlist)
endfunction

"ファイルリストの作成
function! QFixHowmGetFileList(path, file)
  let prevPath = getcwd()
  let prevPath = escape(prevPath, ' ')
  exec 'lchdir ' . escape(a:path, ' ')
  let files = split(glob(a:file), '\n')
  let list = []
  let lnum = 1
  let text = ''
  if g:MyGrep_ExcludeReg == ''
    let g:MyGrep_ExcludeReg = '^$'
  endif
  for n in files
    let n = a:path . '/'. n
    if !isdirectory(n)
      if n =~ g:MyGrep_ExcludeReg
        continue
      endif
      let usefile = {'filename':n, 'lnum':lnum, 'text':text}
      call insert(list, usefile)
    endif
  endfor
  silent! exec 'lchdir ' . prevPath
  return list
endfunction

" *. 形式のワイルドカードチャプターを数字に変換
silent! function CnvWildcardChapter(...) range
  let firstline = a:firstline
  let lastline = a:lastline
  if a:0 == 0
    let firstline = 1
    let lastline = line('$')
  endif
  let top = 0
  let wild = '\(\*\.\)\+\*\?\s*'
  if g:QFixHowm_WildCardChapterMode
    let wild = wild . '\|^\.\+\s*'
  endif
  let nwild = '\(\d\+\.\)\+\(\d\+\)\?'
  let chap = [top, 0, 0, 0, 0, 0, 0, 0]
  let plevel = 1
  let save_cursor = getpos('.')
  for l in range(firstline, lastline)
    let str = matchstr(getline(l), '^\s*'.nwild.'\s*')
    if str != ''
      for c in range(8)
        let ch = matchstr(str,'\d\+', 0 ,c+1)
        let chap[c] = 0
        if ch != ''
          let chap[c] = ch
        endif
      endfor
      continue
    endif
    let str = matchstr(getline(l), '^\s*'.wild)
    let len = strlen(str)
    if str[0] == '.'
      let str = substitute(str, '\.', '*.', 'g')
      if strlen(substitute(str, '\s*$', '', '')) > 2
        let str = substitute(str, '\.\(\s*\)$', '\1', 'g')
      endif
    endif
    let level = strlen(substitute(str, '[^*]', '' , 'g'))
    if level == 0
      continue
    endif
    let chap[level-1] = chap[level-1] + 1
    if level < plevel
      for n in range(level, 8-1)
        let chap[n] = 0
      endfor
    endif
    let plevel = level
    for n in range(level)
      let str = substitute(str, '\*', chap[n], '')
    endfor
    let nstr = str . strpart(getline(l), len)
"    exec l.'put=nstr'
"    -1delete _
    let sline = line('.')
    call setline(l, [nstr])
  endfor
  call setpos('.', save_cursor)
endfunction

"ランダムウォーク
command! -count QFixHowmRandomWalk :call QFixHowmRandomWalk()
let s:randomresulttime = 0
function! QFixHowmRandomWalk()
  redraw|echo 'QFixHowm : Random Walk...'
  if exists('g:QFix_Win') && bufwinnr(g:QFix_Win)
    let h = winheight(bufwinnr(g:QFix_Win))
    if g:QFixHowm_RandomWalkColumns < h
      let g:QFixHowm_RandomWalkColumns = h
    endif
  endif
  if count
    let g:QFixHowm_RandomWalkColumns = count
  endif
  let len = g:QFixHowm_RandomWalkColumns

"  CloseQFixWin
  call QFixPclose()
  let file = g:QFixHowm_RandomWalkFile
  if !filereadable(expand(file))
    call QFixHowmRebuildRandomWalkFile(file)
  endif
  if g:QFixHowm_RandomWalkUpdate && localtime() - getftime(expand(file)) > g:QFixHowm_RandomWalkUpdate * 24*60*60
    call QFixHowmRebuildRandomWalkFile(file)
  endif
  if s:randomresulttime != getftime(expand(file))
    let s:randomresult = readfile(expand(file))
    let s:randomresultpath = substitute(s:randomresult[0], '|.*$', '','')
    let g:QFix_SelectedLine = 1
    call remove(s:randomresult, 0)
    let s:randomresulttime = getftime(expand(file))
  endif
  let result = QFixHowmRandomList(s:randomresult, len)
  " MyQFixライブラリを使用可能にする。
  call QFixEnable(s:randomresultpath)
  silent exec 'lchdir ' . escape(g:QFix_SearchPath, ' ')
  let saved_efm = &efm
  set errorformat=%f\|%\\s%#%l\|%m
    cgetexpr result
"    silent! execute 'silent! cgetfile ' . file
  let &errorformat = saved_efm
  redraw|echo ''
  QFixCopen
endfunction

"ランダムウォークリスト作成
function! QFixHowmRandomList(list, len)
  let len  = a:len
  let list = deepcopy(a:list)
  if exists('g:QFixHowm_RandomWalkExclude')
    let exclude = g:QFixHowm_RandomWalkExclude
    if exclude != ''
      call filter(list, "v:val !~ '".exclude."'")
    endif
  endif
  let range = len(list)
  let result = []
  if len >= range
    return list
  endif
  while 1
    let range = len(list)
    if range <= 0 || len <= 0
      break
    endif
    let r = QFixHowmRandom(range)
    call add(result, list[r])
    call remove(list, r)
    let len -= 1
  endwhile
  return result
endfunction

"乱数発生
"unixでは echo $RANDOM を使用するべきかも
"Windowsの echo %RANDOM%はsystem(cmd)だと種が初期化されるので加工する必要がある。
silent! function QFixHowmRandom(range)
  if g:QFixHowm_RandomWalkMode == 1
    if has('unix')
      let r = libcallnr("", "rand", -1) % a:range
    else
      let r = libcallnr("msvcrt.dll", "rand", -1) % a:range
    endif
    return r
  endif
  let r = reltimestr(reltime())
  let r = substitute(r, '^.*\.','','') % a:range
  "生命、宇宙、そして万物についての（究極の疑問の）答えを使用する
  sleep 42m
  return r
endfunction

"ランダムウォークファイル再作成
function! QFixHowmRebuildRandomWalkFile(file)
  let file = a:file
  call QFixHowmListAllTitle(g:QFixHowm_Title, 0)
  call MyGrepWriteResult(0, g:QFixHowm_RandomWalkFile)
  CloseQFixWin
endfunction

let s:QFixHowmVimEnter = s:QFixHowm_Key.QFixHowm_VimEnterCmd

augroup QFixHowmVimEnter
  autocmd!
  autocmd VimEnter   * call QFixHowmVimEnter(1)
augroup END

function! QFixHowmVimEnter(mode)
  if g:QFixHowm_VimEnterCmd == ''
    return
  endif
  "今日の日付じゃなかったら起動時コマンド実行
  if exists('g:loaded_MyHowm')
    let file = expand(g:QFixHowm_VimEnterFile)
    let ftime = getftime(file)
    let etime = QFixHowmDate2Int(strftime('%Y-%m-%d') . ' '.g:QFixHowm_VimEnterTime)
    if ftime > etime && a:mode
      return
    endif

    let ltime = localtime()
    let etime = QFixHowmDate2Int(strftime('%Y-%m-%d', ltime - 24*60*60) . ' '.g:QFixHowm_VimEnterTime)
    let time = ltime - etime -24*60*60 - 1
    if time < 0 && a:mode
      return
    endif

    if exists('g:QFixHowm_VimEnterMsg')
      let mes = g:QFixHowm_VimEnterMsg
      let choice = confirm(mes, "&OK\n&Cancel", 1, "Q")
      if choice == 1
      else
        call MyGrepWriteResult(0, file)
        redraw
        return
      endif
    endif

    call feedkeys(s:QFixHowmVimEnter, 't')
    call MyGrepWriteResult(0, file)
    if exists("*QFixHowmExportSchedule") && exists('g:fudist')
      call QFixHowmCmd_ScheduleList()
    endif
  endif
endfunction

function! MultiHowmDirGrep(pattern, dir, filepattern, enc, addflag, ...)
  let pattern     = a:pattern
  let filepattern = a:filepattern
  let hdir        = a:dir
  let enc         = a:enc
  let addflag     = a:addflag
  let basename    = 'g:howm_dir'
  if a:0 > 0
    let basename = a:1
  endif
  for i in range(g:QFixHowm_howm_dir_Max, 2, -1)
    if g:QFixHowm_howm_dir_Max < 2
      break
    endif
    if !exists(basename.i)
      continue
    endif
    exec 'let hdir = '.basename.i
    if isdirectory(expand(hdir)) == 0
      continue
    endif
    let l:howm_fileencoding = enc
    if exists('g:howm_fileencoding'.i)
      exec 'let l:howm_fileencoding = g:howm_fileencoding'.i
    endif
    if g:howm_fileencoding != l:howm_fileencoding
      let g:QFixHowm_ForceEncoding = 0
    endif
    "silent exec 'lchdir ' . escape(expand(hdir), ' ')
    call MyGrep(pattern, hdir, filepattern, l:howm_fileencoding, addflag)
    let addflag = 1
  endfor
  return addflag
endfunction

""""""""""""""""""""""""""""""
"ファイルが存在するので開く
"追加パラメータが'split'ならスプリットで開く
""""""""""""""""""""""""""""""
function! QFixHowmEditFile(file,...)
  let file = fnamemodify(a:file, ':p')
  let mode = ''
  if a:0 > 1
    let mode = a:2
  endif
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
  let dir = expand(dir)
  if isdirectory(dir) == 0
    call mkdir(dir, 'p')
  endif
  let opt = ''
  exec g:QFixHowm_Edit.'edit ' . opt . escape(expand(file), ' ')
endfunction

function! QFixHowmInsertDate(fmt)
  let fmt = s:hts_dateTime
  if a:fmt == 'Date'
    let fmt = s:hts_date
  endif
  let str = strftime('['.fmt.']')
  silent! put=str
  call cursor(line('.'), col('$'))
  startinsert
endfunction

if !exists('g:QFixHowm_Template')
  let g:QFixHowm_Template = [
    \QFixHowm_Title." %TAG%",
    \"%DATE%",
    \""
  \]
endif

function! QFixHowmInsertEntry(cmd, ...)
  let s:QFixHowm_Template = deepcopy(g:QFixHowm_Template)
  call add(s:QFixHowm_Template, "")
  call map(s:QFixHowm_Template, 'substitute(v:val, "%TAG%", g:QFixHowm_DefaultTag, "g")')
  let date = strftime("[".s:hts_dateTime."]")
  call map(s:QFixHowm_Template, 'substitute(v:val, "%DATE%", date, "g")')
  call map(s:QFixHowm_Template, 'substitute(v:val, "%LASTFILENAME%", g:QFixHowm_LastFilename, "g")')
  if a:cmd == 'New'
    silent! call setline(1, s:QFixHowm_Template)
    $delete _
    call cursor(1, 1)
    return
  endif
  let nl = ""
  let len = len(g:QFixHowm_Template)-1
  let l = line('.')
  if a:cmd =~ 'next'
    if getline(line('.')) != ''
      silent! put=nl
    endif
    silent! put=s:QFixHowm_Template
    call cursor(line('.')-len, 1)
  elseif a:cmd == 'prev'
    silent! -1put=s:QFixHowm_Template
    call cursor(line('.')-len, 1)
  elseif a:cmd == 'top'
    silent! -1put=s:QFixHowm_Template
    call cursor(1, 1)
  elseif a:cmd == 'bottom'
    if getline(line('$')) != ''
      silent! put=nl
    endif
    silent! $put=s:QFixHowm_Template
    call cursor(line('.')-len, 1)
  endif
  silent! exec 'normal! '. g:QFixHowm_Cmd_NewEntry
  if g:QFixHowm_Cmd_NewEntry =~ 'a$'
    startinsert!
  elseif g:QFixHowm_Cmd_NewEntry =~ 'i$'
    startinsert
  endif
endfunction

