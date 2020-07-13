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
        ["�t�@�C��(&F)",   [
                    ["�V�K�쐬(&N)\tCtrl+N","new"],
                    ["�J��(&O)","open"],
                    ["�ۑ�(&S)","save"],
                    ["���O��t���ĕۑ�(&A)","saveas"],
                    VRMenu::SEPARATOR,
                    ["�I��(&X)","exit"]]],
        ["�ҏW(&E)",   [ ["�폜(&D)","doDelete"],
                    ["�J�b�g(&T)","cut"],
                    ["�R�s�[(&C)","copy"],
                    ["�\��t��(&P)","paste"]]],
        ["�w���v(&H)",   [ ["�o�[�W�������","version"]]]
      ]
    FDPopupMenuTemplate=[["�폜(&D)\tDelete","doDelete"],VRMenu::SEPARATOR,
                  ["�R�s�[(&C)\tCtrl+C","doCopy"],["�\��t��(&P)\tCtrl+V","doPaste"]]
    FDToolbarTemplate =
       [['toolButton1'],
        ['toolButton2',WConst::TBSTYLE_SEP],
        ['toolButton3',WConst::TBSTYLE_CHECKGROUP],
        ['toolButton4',WConst::TBSTYLE_CHECKGROUP],
        ['toolButton5',WConst::TBSTYLE_CHECKGROUP]]
  
    FDDlgFilterTemplate=[["�S��(*.*)","*.*"]]

  end

  module FDMenuItems
    FDMainmenu=[
      ["�t�@�C��(&F)",[
                    ["�V�K�t�H�[��",
                      [ ["�t�H�[��","new_form"],
                        ["���[�h���X�t�H�[��","new_modeless_form"],
                        ["���[�h���X�_�C�A���O","new_modeless_dlg"]]],
                    ["�J��(&O)\tCtrl+O","open"],
                    ["RDE�ŊJ��(&R)\tCtrl+R","open_rde"],
                    ["���C���t�H�[����ʂ�ύX",
                      [ ["�t�H�[��","change_to_mainform"],
                        ["���[�h���X�t�H�[��","change_to_modeless_mainform"],
                        ["���[�h���X�_�C�A���O","change_to_modeless_maindlg"]]],
                    ["�㏑���ۑ�(&S)\tCtrl+S","save"],
                    ["���O��t���ĕۑ�(&A)",
                      [ ["�t�H�[������","saveas_form"],
                        ["�t�H�[�������^�v���W�F�N�g","saveas_proj_part"],
                        ["�t�H�[�������^�v���W�F�N�g","saveas_proj_mono"]]],
                    VRMenu::SEPARATOR,
                    ["(&E)�v���W�F�N�g��ҏW\tCtrl+E","run_editor"],
                    ["(&U)�v���W�F�N�g���A�b�v�f�[�g\tCtrl+U","update_proj"],
                    VRMenu::SEPARATOR,
                    ["�I��(&X)\tAlt+F4","exit"]]],
      ["�}��(&I)",   [
                       ["�t�H�[��","insert_form"],
                       ["���[�h���X�t�H�[��","insert_modelessform"],
                       ["���[�_���t�H�[��","insert_modalform"],
                       ["�t�H�[����ʂ�ύX",
                         [ ["�t�H�[��","change_to_form"],
                           ["���[�h���X�t�H�[��","change_to_modeless_form"],
                           ["���[�_���t�H�[��","change_to_modal_form"]]],
                       VRMenu::SEPARATOR,
                       ["�t�@�C������","insert_form_from_file"],
                       ["���̃t�H�[����ۑ�","save_this_form"],
                       VRMenu::SEPARATOR,
                       ["���̃t�H�[�����폜","delete_this_form"],
                     ]],
      ["�ҏW(&E)",   [ ["�폜(&D)\tDelete","doDelete"],
                    VRMenu::SEPARATOR,
                    ["�J�b�g(&T)\tCtrl+X","doCut"],
                    ["�R�s�[(&C)\tCtrl+C","doCopy"],
                    ["�\��t��(&P)\tCtrl+V","doPaste"],
                    VRMenu::SEPARATOR,
                    ["�e�E�C���h�E�ֈړ�(&B)\tHome","back_to_parent"]]],
      ["�E�C���h�E(&W)", [
                    VRMenu::SEPARATOR,
                    ["&Inspect","inspectShow",VRMenuItem::CHECKED]]],
      ["���s(&R)",    [ ["���s(&X)\tF5","execute"],
                    ["�R�[�h�\��","examine"]]],
      ["�I�v�V����(&O)", [ ["�ݒ�(&P)","prefer"],
                    VRMenu::SEPARATOR,
                    ["�O���b�h","gridState",VRMenuItem::CHECKED]]],
      ["�c�[��(&T)",   [ ["Bmp2Str","bmp2str"]]],
      ["�w���v(&H)",   [ ["�g�s�b�N�̕\��\tF1","show_topic"],
                         ["SDK�g�s�b�N�̕\��\tF2","show_SDK_topic"],
                         ["�o�[�W�������(&N)","version"]]]]
  
    FDPopupmenu=[ ["�폜(&D)\tDelete","doDeletepop"],
                  VRMenu::SEPARATOR,
                  ["�J�b�g(&X)\tCtrl+X","doCutpop"],
                  ["�R�s�[(&C)\tCtrl+C","doCopypop"],
                  ["�\��t��(&P)\tCtrl+V","doPastepop"],
                  VRMenu::SEPARATOR,
                  ["�e�E�C���h�E�ֈړ�(&B)\tHome","back_to_parentpop"]]
  end
  
  module FDMsgItems
    Sorry="������Ƒ҂��Ă�"
    NoChosen = "���I��"
    NoFileError=["#{ARGV[0]} �͑��݂��܂���","�t�@�C��������܂���",16]
    OptionError=["�������������܂�","�I�v�V�����G���[" ,16]
    DoYouSave="���̃t�@�C����ۑ����܂����H"
    OpenPreare="�t�@�C�����J��"
    FileNotExist=[" �����݂��܂���","�t�@�C�������݂��܂���",16]
    FileWasModified=["���̍�ƃt�@�C���͑��̃A�v���P�[�V�����ɂ���ď����������܂����B"+
    "\r\n�V�����t�@�C����ǂݍ��݂܂����H","��ƃt�@�C�����ύX����܂���" ,0x0003]
    SaveBeforeEdit=["�ҏW�̑O�Ƀv���W�F�N�g��ۑ����Ă�������","�V�K�v���W�F�N�g",0x30]
    SaveFromEditor=["�G�f�B�^����v���W�F�N�g��ۑ����܂������H",
    "�v���W�F�N�g���A�b�v�f�[�g",0x31]
    ThisIsMain=["���C���t�H�[���͍폜�ł��܂���.", "�폜�s��",16]
    OerationCannotUndo=["�A���h�D�ł��܂��񂪁A�{���ɍ폜���܂����H",
    "���̃t�H�[�����폜",0x34]
    GridMustBe=["�O���b�h�� 2 ���� 100�܂ł̐����łȂ���΂Ȃ�܂���" ,"�x��!!",16]
    Base64Finish="Base64 �����񂪃N���b�v�{�[�h�ɕۑ�����܂���"
    SaveBrforeExit=["�t�@�C����ۑ����܂����H","FormDesigner�̏I��",0x1023]
    InDDEmode=["DDE���[�h�ł��B�{���ɏI�����܂����H","FormDesigner�̏I��",0x1034]
    Modified="�ύX����"
    Saved=" ��ۑ��ς�"
    Noform=["�ǂ߂�t�H�[�����������A�Â��t�@�C���ł�","�t�@�C������}��",16]
    NoPaste=["���̐e�E�C���h�E�ɓ\��t���邱�Ƃ͏o���܂���","�����Ȑe�E�C���h�E",16]
    DialogRunning=[" �_�C�A���O�����s���ł�","�_�C�A���O���s��",0x30]
  end
  
  module FDPrfItems
    Preferences="�ݒ�"
    CROnly="CR �̂�"
    CgwinLS="Cygwin�ł̉��s�L��"
    Gridsize="�O���b�h��"
    DockInspect='�C���X�y�N�g�E�C���h�E���h�b�N'
    Editor="�G�f�B�^"
    UseJp='���{����g�p'
    Font="�t�H���g"
    NextStart='(����̋N���ŗL��)'
    Verbose='�x���R�����g���o��'
    OK="O   K"
    Cancel="�L�����Z��"
  end
  
  module FDNewProjectItem
    NewProject=" �͐V�K�v���W�F�N�g�ł�"
    Prompt="�����ꂩ�̃^�C�v��I�����Ă�������"
  end
    
  module FDProjectTypes
    Apart="�t�H�[�������^�v���W�F�N�g"
    Form="�t�H�[������"
    Mono="�t�H�[�������^�v���W�F�N�g"
  end
end

if $Lang=="JA"
  include JA
else
  include EN
end

