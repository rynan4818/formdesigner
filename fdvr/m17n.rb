# m17n.rb
# Multilingualization Module
#
# Programmed by yukimi_sake@mbi.nifty.com
# Copyright 2001-2004 Yukio Sakaue

require 'vr/vrcontrol'
require 'vr/vrcomctl'

module EN
  
  HTML_Help=File.dirname(__FILE__).gsub(/\//,'\\')+'\doc\vrswin-en.chm'
  module FDItems
    FDMenuTemplate=
    [
      ["&File",   [ ["&New\tCtrl+N","new"],
                    ["&Open","open"],
                    ["&Save","save"],
                    ["Save&As","saveas"],
                    VRMenu::SEPARATOR,
                    ["E&xit","exit"]]],
      ["&Edit",   [ ["&Delete","doDelete"],
                    ["Cu&t","cut"],
                    ["&Copy","copy"],
                    ["&Paste","paste"]]],
      ["&Help",   [ ["Versio&n","version"]]]
    ]
    FDPopupMenuTemplate=[["&Delete\tDelete","doDelete"],VRMenu::SEPARATOR,
                  ["&Copy\tCtrl+C","doCopy"],["&Paste\tCtrl+V","doPaste"]]
    FDToolbarTemplate =
       [['toolButton1'],
        ['toolButton2',WConst::TBSTYLE_SEP],
        ['toolButton3',WConst::TBSTYLE_CHECKGROUP],
        ['toolButton4',WConst::TBSTYLE_CHECKGROUP],
        ['toolButton5',WConst::TBSTYLE_CHECKGROUP]]
  
    FDDlgFilterTemplate=[["all(*.*)","*.*"]]

  end

  module FDMenuItems
    FDMainmenu=[
    ["&File",   [ ["&NewForm\tCtrl+N",
                    [ ["Form","new_form"],
                      ["ModelessForm","new_modeless_form"],
                      ["ModelessDialog","new_modeless_dlg"]]],
                    ["&Open\tCtrl+O","open"],
                    ["OpenWith&RDE\tCtrl+R","open_rde"],
                    ["ChangeMainformType",
                      [ ["Form","change_to_mainform"],
                        ["ModelessForm","change_to_modeless_mainform"],
                        ["ModelessDialog","change_to_modeless_maindlg"]]],
                    ["&Save\tCtrl+S","save"],
                    ["Save&As",
                      [ ["FormsOnly","saveas_form"],
                        ["ProjectWithSeparated Forms","saveas_proj_part"],
                        ["ProjectWithBuiltForms","saveas_proj_mono"]]],
                    VRMenu::SEPARATOR,
                    ["&EditProject\tCtrl+E","run_editor"],
                    ["Update&Project","update_proj"],
                    VRMenu::SEPARATOR,
                    ["E&xit\tAlt+F4","exit"]]],
      ["&Insert", [ ["Form","insert_form"],
                    ["Mode&lessForm","insert_modelessform"],
                    ["&ModalForm","insert_modalform"],
                    ["ChangeFormType",
                      [ ["Form","change_to_form"],
                        ["ModelessForm","change_to_modeless_form"],
                        ["ModalForm","change_to_modal_form"]]],
                    VRMenu::SEPARATOR,
                    ["ReadFromFile","insert_form_from_file"],
                    ["SaveThisForm","save_this_form"],
                    VRMenu::SEPARATOR,
                    ["&DeleteThisForm","delete_this_form"]]],
      ["&Edit",   [ ["&Delete\tDelete","doDelete"],
                    VRMenu::SEPARATOR,
                    ["Cu&t\tCtrl+X","doCut"],
                    ["&Copy\tCtrl+C","doCopy"],
                    ["&Paste\tCtrl+V","doPaste"],
                    VRMenu::SEPARATOR,
                    ["&BackToParent\tHome","back_to_parent"]]],
      ["&Window", [  VRMenu::SEPARATOR,
                    ["&Inspect","inspectShow",VRMenuItem::CHECKED]]],
      ["&Run",    [ ["E&xecute\tF5","execute"],
                    ["Examine","examine"]]],
      ["&Option", [ ["&Preferences","prefer"],
                    VRMenu::SEPARATOR,
                    ["Grid","gridState",VRMenuItem::CHECKED]]],
      ["&Tool",   [ ["Bmp2Str","bmp2str"]]],
      ["&Help",   [ ["&Show topic\tF1","show_topic"],
                    ["&Show SDKtopic\tF2","show_SDK_topic"],
                    ["Versio&n","version"]]]
    ]
  
    FDPopupmenu=[ ["&Delete\tDelete","doDeletepop"],
                  VRMenu::SEPARATOR,
                  ["Cu&t\tCtrl+X","doCutpop"],
                  ["&Copy\tCtrl+C","doCopypop"],
                  ["&Paste\tCtrl+V","doPastepop"],
                  VRMenu::SEPARATOR,
                  ["&BackToParent\tHome","back_to_parentpop"]]
  end
  
  module FDMsgItems
    Sorry="Sorry just moment"
    NoChosen = "Nothing is chosen."
    NoFileError=["#{ARGV[0]} is not exist","No file error",16]
    OptionError=["too many arguments","Option error" ,16]
    DoYouSave="Do you save this file?"
    OpenPreare="Open file"
    FileNotExist=[" is not exist","File not exist",16]
    FileWasModified=["This working file was modifyed by other apprication."+
    "\r\nDo you read new file?","Working file was modifyed" ,0x0003]
    SaveBeforeEdit=["Please save befor editing","This is new project",0x30]
    SaveFromEditor=["Have you saved Project from Editor?",
    "Updating Project ",0x31]
    ThisIsMain=["This is Main Form.", "Cannot Change",16]
    OerationCannotUndo=["This operation cannot UNDO.\r\n\r\nDo you delete anyway?",
    "Delete this form",0x34]
    GridMustBe=["Grid span must be in 2 to 100" ,"Warning!!",16]
    Base64Finish="Base64 string was copied into clipboard"
    SaveBrforeExit=["Do you save this file?","Exit FormDesigner",0x1023]
    InDDEmode=["Here is in DDE mode. Do you exit realy?","Exit FormDesigner",0x1034]
    Modified="Modified"
    Saved=" was saved."
    Noform=["There is none to raed or old file","Read form from file",16]
    NoPaste=["Cannot paste to this parent","Invalid parent",16]
    DialogRunning=[" dialog is running. ","Running dialog",0x30]
  end
  
  module FDPrfItems
    Preferences="Preferences"
    CROnly="CR Only"
    CgwinLS="Cygwin's line separator"
    Gridsize="Glid Size"
    DockInspect='Dock inspect window'
    Editor="Editor"
    UseJp='Use Japanese'
    Font="Font"
    NextStart='(Enable next starting)'
    Verbose='Output comments of caution'
    OK="O   K"
    Cancel="Cancel"
  end
  
  module FDNewProjectItem
    NewProject=" is new project"
    Prompt="Please select type which you'd like"
  end
  
  module FDProjectTypes
    Apart="project with separated forms"
    Form="forms only"
    Mono="project with built forms"
  end
end

module JA
  HTML_Help=File.dirname(__FILE__).gsub(/\//,'\\')+'\doc\vrswin-ja.chm'
  module FDItems
    FDMenuTemplate=
      [
        ["ファイル(&F)",   [
                    ["新規作成(&N)\tCtrl+N","new"],
                    ["開く(&O)","open"],
                    ["保存(&S)","save"],
                    ["名前を付けて保存(&A)","saveas"],
                    VRMenu::SEPARATOR,
                    ["終了(&X)","exit"]]],
        ["編集(&E)",   [ ["削除(&D)","doDelete"],
                    ["カット(&T)","cut"],
                    ["コピー(&C)","copy"],
                    ["貼り付け(&P)","paste"]]],
        ["ヘルプ(&H)",   [ ["バージョン情報","version"]]]
      ]
    FDPopupMenuTemplate=[["削除(&D)\tDelete","doDelete"],VRMenu::SEPARATOR,
                  ["コピー(&C)\tCtrl+C","doCopy"],["貼り付け(&P)\tCtrl+V","doPaste"]]
    FDToolbarTemplate =
       [['toolButton1'],
        ['toolButton2',WConst::TBSTYLE_SEP],
        ['toolButton3',WConst::TBSTYLE_CHECKGROUP],
        ['toolButton4',WConst::TBSTYLE_CHECKGROUP],
        ['toolButton5',WConst::TBSTYLE_CHECKGROUP]]
  
    FDDlgFilterTemplate=[["全て(*.*)","*.*"]]

  end

  module FDMenuItems
    FDMainmenu=[
      ["ファイル(&F)",[
                    ["新規フォーム",
                      [ ["フォーム","new_form"],
                        ["モードレスフォーム","new_modeless_form"],
                        ["モードレスダイアログ","new_modeless_dlg"]]],
                    ["開く(&O)\tCtrl+O","open"],
                    ["RDEで開く(&R)\tCtrl+R","open_rde"],
                    ["メインフォーム種別を変更",
                      [ ["フォーム","change_to_mainform"],
                        ["モードレスフォーム","change_to_modeless_mainform"],
                        ["モードレスダイアログ","change_to_modeless_maindlg"]]],
                    ["上書き保存(&S)\tCtrl+S","save"],
                    ["名前を付けて保存(&A)",
                      [ ["フォームだけ","saveas_form"],
                        ["フォーム分離型プロジェクト","saveas_proj_part"],
                        ["フォーム内蔵型プロジェクト","saveas_proj_mono"]]],
                    VRMenu::SEPARATOR,
                    ["(&E)プロジェクトを編集\tCtrl+E","run_editor"],
                    ["(&U)プロジェクトをアップデート\tCtrl+U","update_proj"],
                    VRMenu::SEPARATOR,
                    ["終了(&X)\tAlt+F4","exit"]]],
      ["挿入(&I)",   [
                       ["フォーム","insert_form"],
                       ["モードレスフォーム","insert_modelessform"],
                       ["モーダルフォーム","insert_modalform"],
                       ["フォーム種別を変更",
                         [ ["フォーム","change_to_form"],
                           ["モードレスフォーム","change_to_modeless_form"],
                           ["モーダルフォーム","change_to_modal_form"]]],
                       VRMenu::SEPARATOR,
                       ["ファイルから","insert_form_from_file"],
                       ["このフォームを保存","save_this_form"],
                       VRMenu::SEPARATOR,
                       ["このフォームを削除","delete_this_form"],
                     ]],
      ["編集(&E)",   [ ["削除(&D)\tDelete","doDelete"],
                    VRMenu::SEPARATOR,
                    ["カット(&T)\tCtrl+X","doCut"],
                    ["コピー(&C)\tCtrl+C","doCopy"],
                    ["貼り付け(&P)\tCtrl+V","doPaste"],
                    VRMenu::SEPARATOR,
                    ["親ウインドウへ移動(&B)\tHome","back_to_parent"]]],
      ["ウインドウ(&W)", [
                    VRMenu::SEPARATOR,
                    ["&Inspect","inspectShow",VRMenuItem::CHECKED]]],
      ["実行(&R)",    [ ["実行(&X)\tF5","execute"],
                    ["コード表示","examine"]]],
      ["オプション(&O)", [ ["設定(&P)","prefer"],
                    VRMenu::SEPARATOR,
                    ["グリッド","gridState",VRMenuItem::CHECKED]]],
      ["ツール(&T)",   [ ["Bmp2Str","bmp2str"]]],
      ["ヘルプ(&H)",   [ ["トピックの表示\tF1","show_topic"],
                         ["SDKトピックの表示\tF2","show_SDK_topic"],
                         ["バージョン情報(&N)","version"]]]]
  
    FDPopupmenu=[ ["削除(&D)\tDelete","doDeletepop"],
                  VRMenu::SEPARATOR,
                  ["カット(&X)\tCtrl+X","doCutpop"],
                  ["コピー(&C)\tCtrl+C","doCopypop"],
                  ["貼り付け(&P)\tCtrl+V","doPastepop"],
                  VRMenu::SEPARATOR,
                  ["親ウインドウへ移動(&B)\tHome","back_to_parentpop"]]
  end
  
  module FDMsgItems
    Sorry="ちょっと待ってね"
    NoChosen = "無選択"
    NoFileError=["#{ARGV[0]} は存在しません","ファイルがありません",16]
    OptionError=["引数が多すぎます","オプションエラー" ,16]
    DoYouSave="このファイルを保存しますか？"
    OpenPreare="ファイルを開く"
    FileNotExist=[" が存在しません","ファイルが存在しません",16]
    FileWasModified=["この作業ファイルは他のアプリケーションによって書き換えられました。"+
    "\r\n新しいファイルを読み込みますか？","作業ファイルが変更されました" ,0x0003]
    SaveBeforeEdit=["編集の前にプロジェクトを保存してください","新規プロジェクト",0x30]
    SaveFromEditor=["エディタからプロジェクトを保存しましたか？",
    "プロジェクトをアップデート",0x31]
    ThisIsMain=["メインフォームは削除できません.", "削除不可",16]
    OerationCannotUndo=["アンドゥできませんが、本当に削除しますか？",
    "このフォームを削除",0x34]
    GridMustBe=["グリッドは 2 から 100までの整数でなければなりません" ,"警告!!",16]
    Base64Finish="Base64 文字列がクリップボードに保存されました"
    SaveBrforeExit=["ファイルを保存しますか？","FormDesignerの終了",0x1023]
    InDDEmode=["DDEモードです。本当に終了しますか？","FormDesignerの終了",0x1034]
    Modified="変更あり"
    Saved=" を保存済み"
    Noform=["読めるフォームが無いか、古いファイルです","ファイルから挿入",16]
    NoPaste=["この親ウインドウに貼り付けることは出来ません","無効な親ウインドウ",16]
    DialogRunning=[" ダイアログを実行中です","ダイアログ実行中",0x30]
  end
  
  module FDPrfItems
    Preferences="設定"
    CROnly="CR のみ"
    CgwinLS="Cygwinでの改行記号"
    Gridsize="グリッド幅"
    DockInspect='インスペクトウインドウをドック'
    Editor="エディタ"
    UseJp='日本語を使用'
    Font="フォント"
    NextStart='(次回の起動で有効)'
    Verbose='警告コメントを出力'
    OK="O   K"
    Cancel="キャンセル"
  end
  
  module FDNewProjectItem
    NewProject=" は新規プロジェクトです"
    Prompt="いずれかのタイプを選択してください"
  end
    
  module FDProjectTypes
    Apart="フォーム分離型プロジェクト"
    Form="フォームだけ"
    Mono="フォーム内蔵型プロジェクト"
  end
end

if $Lang=="JA"
  include JA
else
  include EN
end

