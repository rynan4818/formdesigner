# fdmain.rb
# The main window of FormDesiner
#
# Programmed by yukimi_sake@mbi.nifty.com
# Copyright 2001-2004 Yukio Sakaue

require 'vr/contrib/inifile'

$program_dir = File.dirname(__FILE__)
Dir.chdir $program_dir
$ini=Inifile.new("FormDesigner.ini")
$Lang=$ini.read("settings","language","EN")
$Ver='060501'

require 'set'
require 'zlib'
require 'swin'
require 'win32ole'
require 'vr/vruby'
require 'vr/vrcontrol'
require 'vr/vrcomctl'
require 'vr/vrhandler'
require 'vr/vrtooltip'
require 'vr/vrtimer'
require 'vr/contrib/msgboxconst'
require 'vr/vrmgdlayout'
require 'vr/vrdde'
require 'fdvr/fdwin32'
require 'fdvr/fdresources'
require 'fdvr/SDKTopic'

module WConst
  WS_CAPTION=0x00c00000
  WS_SYSMENU=0x00080000
  DS_SETFONT=0x40
  DS_MODALFRAME=0x80
  LBS_NODATA  = 0x2000
  LBS_NOTIFY  = 0x0001
  LBS_OWNERDRAWFIXED = 0x0010
end

class String
  def capitalize1(); self[0,1].upcase + self[1,self.size-1] ; end
end

class ArrayedToolbar < VRToolbar
  def insertArrayedbutton(num,name,tbStyle=TBSTYLE_BUTTON)
    r = insertButton(num,name+"#{num}",tbStyle)
    @parent.registerControlAsArrayed(num,r,name,r.etc)
  end

  def addArrayedbutton(num,name,tbStyle=TBSTYLE_BUTTON)
    r = addButton(name+"#{num}",tbStyle)
    @parent.registerControlAsArrayed(num,r,name,r.etc)
  end
end

module FDPanelExt
  include VRToolbarUseable
  attr :items
  def setToolbar(items)
    @items = items
    addControl ArrayedToolbar,'tb','tb',0,0,100,40,2048
    @tb.addButton "btnoselect",WConst::TBSTYLE_BUTTON
    @tb.insertButton 1,"btsep",WConst::TBSTYLE_SEP
    items.each_index{|i|
      @tb.addArrayedbutton(i, "bt",WConst::TBSTYLE_CHECKGROUP)
    }
    iml=imagelistCreate(items)
    @tb.setImagelist(imagelistCreate(items))
    @tb.autoSize
    2.upto(@tb.countButtons-1){|i|
      $tooltip.addTool @_vr_toolbar_buttons[@tb.getButton(i)[1]],items[i-2].info
    }
    self.refresh
  end

  def imagelistCreate(a)
    r=@screen.factory.newimagelist(23,23,1)
    bmp=SWin::Bitmap.loadString FDBmps::BmpNoselect
    r.addmasked(bmp,0x00808000)
    if a then
      a.each do |item|
        bmp=SWin::Bitmap.loadString item.bmp
        r.addmasked(bmp,0x00808000)
      end
    end
    r
  end

  def noselection
    for i in 0..@tb.countButtons - 1
      @tb.setButtonStateOf(@tb.indexToCommand(i),4)
      parent.parent.setcontrol nil
    end
  end

  def bt_clicked(i)
    parent.parent.setcontrol @items[i]
  end

  def btnoselect_clicked
    noselection
  end

end

class FDTabbedPanel < VRTabControl #setup Pallets
  include VRParent
  attr :panels

  def vrinit
    super
    @panels = []
    @pallets = []
  end

  def addPanel(pallet)
    i = countTabs
    insertTab i, pallet.title
    x1,y1,w1,h1 = adjustRect(0,0,self.w,self.h,false)
    @pallets << pallet
    @panels << addControl(VRPanel,"panel#{i}","panel#{i}",x1,y1,w1-x1,h1-y1)
    @panels.last.extend VRContainersSet
    @panels.last.extend(FDPanelExt).setToolbar(pallet.items)
    @panels.last.containers_init
    @panels.last.show 0
    @_vr_prevpanel=0
    selectTab 0
  end

  def selectTab(i)
    super
    selchanged
  end

  def selchanged
    @panels[@_vr_prevpanel].show(0) if @_vr_prevpanel
    t=selectedTab
    @panels[t].show
    @_vr_prevpanel=t
    @panels[t].refresh
    @panels[t].noselection
  end

  def noselectAll
    @panels.each {|i| i.noselection}
  end

end

module Toolbarhandler
  def imagelistCreate(a)
    @iml=@screen.factory.newimagelist(23,23,1)
    bmp=SWin::Bitmap.loadString $noselectbmp
    @iml.addmasked(bmp,0x00808000)
    if a then
      a.each { |item|
        bmp=SWin::Bitmap.loadString item.bmp
        @iml.addmasked(bmp,0x00808000)
      }
    end
  end
end

$newclass = VRLocalScreen.factory.registerWinClass("designfrm",nil,nil,nil,0)

class DesignForm < VRForm
  def DesignForm.winclass
    $newclass
  end
end

class FDControlSelection < VRForm # As Main Form
  attr :inspectfrm
  attr :designfrm,1
  attr :forms
  attr :tab
  attr :formShow
  attr :inspectShow
  attr :mainmenu
  attr :amenu
  attr :afont,1
  attr :dialog_running,1
  
  include VRStatusbarDockable
  include VRMenuUseable
  include VRToolbarUseable
  include VRClosingSensitive
  include VRDestroySensitive
  include VRCommonDialog
  include VRResizeable
  include VRTimerFeasible
  include User32
  include Shell32
  include Hhctrl
  include WConst
  include Base64dumper
  if defined?(VRDdeRequestServer) then
    include VRDdeExecuteServer
    include VRDdePokeServer
    include VRDdeRequestServer
  end
  
  HH_INITIALIZE     = 0x001C  # Initializes the help system.
  HH_UNINITIALIZE   = 0x001D
  HH_DISPLAY_TOC    = 0x1
  HH_DISPLAY_INDEX  = 0x2
  HH_DISPLAY_SEARCH = 0x3
  HH_HELP_CONTEXT   = 0xF  
  Start_Of_FrmID   = 0x1000
  
  begin
    SDKDocument = WIN32OLE.new 'DExplore.AppObj'
  rescue
    SDKDocument = nil
  end
  SDKDocument.SetCollection FDSDK::DE_Prefix,'' if SDKDocument
  
  def self_wmcommand(msg)
    if (frmID=LOWORD(msg.wParam))>=Start_Of_FrmID then
      select_form(frmID)
    else
      super
    end
  end
  
### initialize
  
  def vrinit
    super
    addHandler(WMsg::WM_ACTIVATEAPP,"activateapp", MSGTYPE::ARGINTINT,0)
    addHandler(WMsg::WM_MOVE,"move", MSGTYPE::ARGLINTINT,0)
    acceptEvents([WMsg::WM_ACTIVATEAPP,WMsg::WM_MOVE])
    @fd_cookie=nil
    @forms=[]
    @project_type=nil
    @dialog_running=nil
  end

  def preferdlgcreate
    tpl=VRDialogTemplate.new
    tpl.style = WS_CAPTION | DS_MODALFRAME | WS_SYSMENU | DS_SETFONT
    tpl.fontname = "MS Gothic"
    tpl.fontsize = 11
    tpl.caption=FDPrfItems::Preferences
    stt=tpl.addDlgControl(VRStatic,FDPrfItems::GridSize,7,4,40,12)
    stt2=tpl.addDlgControl(VRStatic,FDPrfItems::Editor,7,18,30,12)
    btok=tpl.addDlgControl(VRButton,FDPrfItems::OK,5,50,40,12)
    btcan=tpl.addDlgControl(VRButton,FDPrfItems::CANCEL,50,50,40,12)
    btbrowse=tpl.addDlgControl(VRButton,"...",142,16,14,12)
    ed1=tpl.addDlgControl(VREdit,"8",50,2,20,12,0x0880000)
    ed2=tpl.addDlgControl(VREdit,"",40,16,100,12,0x0880000)
    st1=tpl.addDlgControl(VRStatic,"cygwin's line separator:",7,32,100,12)
    chb1=tpl.addDlgControl(VRCheckbox,"LF Only",110,30,50,12)
    @prdlg=PrDlg.new(VRLocalScreen,tpl)
    @prdlg.options ={"target"=>ed1,"target2"=>ed2,"okbutton"=>btok,
      "cancelbutton"=>btcan,"browsebutton"=>btbrowse,"checkbox"=>chb1,
      "default"=>"8","default2"=>"notepad.exe","check"=>false}
  end
  
  def examindlgcreate
    tpl = VRDialogTemplate.new
    tpl.style = WS_CAPTION | WS_SYSMENU | DS_MODALFRAME | DS_SETFONT
    tpl.fontname = "MS Gothic"
    tpl.fontsize = 10
    tpl.caption="Examine"
    btok = tpl.addDlgControl(VRButton,"O   K",140,204,40,12,0x00010000)
    ed1 = tpl.addDlgControl(VRText,"",6,4,320,200,0x00200840)
    @examinedlg=ExamineModalDlg.new(@screen,tpl)
    @examinedlg.options ={"target"=>ed1,"okbutton"=>btok,"default" => [["",0]]}
  end
  

  def construct
    HtmlHelp.call(0,nil,HH_INITIALIZE,@fd_cookie)
    addDDEAppTopic("FormDesigner","Edit") if defined?(addDDEAppTopic)
    self.sizebox=false
    self.maximizebox=false
    clear_modified
    $main=self
    require 'fdvr/m17n'
    fon=$ini.read("settings","font","MS UI Gothic,12").split(',')
    $SysFont=@screen.factory.newfont(fon[0],fon[1].to_f)
    top=$ini.read("mainform","top",0).to_i
    left=$ini.read("mainform","left",0).to_i
    self.move left,top,640,124
    
    $editor=$ini.read("settings","editor","notepad.exe")
    if RUBY_PLATFORM =~ /^\w+-cygwin/ &&
                       $ini.read("settings",'LFOnly','false')=='false' then
      $n="\r\n"
    else
      $n="\n"
    end
    if $ini.read("settings","dock",'true')=='true' then
      @inspect_x=left
      @inspect_y=top+124
    else
      @inspect_x=$ini.read("inspect","x",left).to_i
      @inspect_y=$ini.read("inspect","y",top+124).to_i
    end
    @inspect_w=$ini.read("inspect","w",140).to_i
    @inspect_h=$ini.read("inspect","h",400).to_i
    
    examindlgcreate
    @inspectfrm=@screen.newform(self)
    @inspectfrm.extend FDInspect
    @inspectfrm.move @inspect_x,@inspect_y,@inspect_w,@inspect_h
    @inspectfrm.caption="Inspect"
    @inspectfrm.create.show
    @inspectfrm.inspectView.setColumnWidthOf(0,
      $ini.read("inspect","viewCol_0",50))
    @inspectfrm.inspectView.setColumnWidthOf(1,
      $ini.read("inspect","viewCol_1",78))
    @amenu=newMenu(true).set(FDMenuItems::FDPopupmenu)
    # Set Menu
    setMenu @mainmenu=newMenu.set(FDMenuItems::FDMainmenu) ,true
    new_designfrm
    $tooltip = createTooltip
    # Create Pallets
    addControl FDTabbedPanel,"tab","tab",0,0,self.clientrect[2],58
    @tab.setFont $SysFont
    $conf.each{|i| @tab.addPanel(i)}

    SWin::Application.setAccel(@designfrm,self)
    SWin::Application.setAccel(@inspectfrm,self)
    @sb1=addStatusbar
    @running = false
    @hwndEd = 0
    @buffer1 = @buffer2 = ""
    @sb1.setparts(3,[100,480,-1])
    @_dde_line_no = 0
    @_new_project = nil
  end
  
  def create_form(_x,_y,_w,_h,s)
    frm = @screen.newform(self,nil,DesignForm)
    frm.extend FDControlDesign
    frm.createinit
    frm.move(_x,_y,_w,_h)
    frm.caption=s
    frm.create.show
    check_form_menu(true)
    frm
  end
  
  def new_designfrm
    a=self.windowrect
    remove_instance_variable(:@designfrm) if defined?(@designfrm)
    @forms<<create_form(a[0]+@inspectfrm.windowrect[2],a[1]+124,500,400,'form1')
    @forms[0].etc=Start_Of_FrmID
    @mainmenu.menu.insert "form1",Start_Of_FrmID,@inspectShow.etc-1
    @designfrm=@forms[0]
    window_menu_set_check(@designfrm.etc)
    self.caption = "FormDesigner"
    @hwndEd = 0
    @workingfile = nil
    clear_modified
    @class_struct1 = ModStruct.new(nil,nil,nil)
    @forms.reverse_each{|i| @class_struct1.childs <<
                                            i.makeModStruct(i,@class_struct1)}
  end

  def setcontrol(ctrl)
    if @designfrm.creation=ctrl then
      @sb1.setTextOf(0,"#{ctrl.info}") if @sb1
    else
      @sb1.setTextOf(0,FDMsgItems::NoChosen) if @sb1
    end
  end
  
  def self_created
    s = ARGV.shift
    if s == nil
      # default
    elsif s != ''
      if FileTest.exist? s
        open1 s
      else
        messageBox *FDMsgItems::NoFileError
      end
    else
      messageBox *FDMsgItems::OptionError
    end
  end
  
  ### DDE ###
  
  def self_ddeexecute(command,shwnd,appname,topic)
    case command
    when /initiate\s*,\s*(\d*)/
      @hwndEd = $1.to_i
      @new_form.state=1
      @new_modeless_form.state=1
      @new_modeless_dlg.state=1
      @open.state=1
      @save.state=1
      @saveas_form.state=1
      @saveas_proj_part.state=1
      @saveas_proj_mono.state=1
      @run_editor.state=1
      @update_proj.state=1
      @exit.state=1
      inc_modified
      @_dde_mode=true
    when "show"
      self.focus
    else
    end
  end
  
  def self_dderequest(item,shwnd,app,topic)
    clear_modified
    @_dde_result
  end
  
  def self_ddepoke(item,data,cfmt,shwnd,app,topic)
    @_dde_result = ""
    begin
      if @modified==0 then @_dde_result="";  return; end
      @_dde_ed_line_no = item.to_i
      @_dde_line_no = @_dde_ed_line_no
      if @project_type == :mono then
        data.scan(/^#{FDSources::BeginOfFD}.*^#{FDSources::EndOfFD}/m)[0]
        @buffer1=$` ? $` : ""
        @buffer2=$' ? $' : ""
        form_lin_count = $& ? $&.count("\n") : 0
        line_count1 = @buffer1.count("\n")
        line_count2 = @buffer2.count("\n")
        
        if @_dde_line_no <= line_count1
          state=-1
          @_dde_line_no = 0
        elsif (n=@_dde_line_no-form_lin_count-line_count1)>=0
          state=1
          @_dde_line_no = n
        else
          state=0
          @_dde_line_no = 0
        end
        @_a_buffer2=$'.to_a
        @_a_buffer2=[''] if @_a_buffer2.empty?
        @buffer2=update
        if @_new_project then
          @_dde_result="#{@_dde_line_no}\n#! ruby -Ks\n"+
                                                      @buffer1+make_fdvr_source
          unless $ini.read("settings","verbose","true")=="false"
            @_dde_result += FDSources::Follows
          else
             @_dde_result += "\n"
          end
          @_dde_result += @buffer2+
                     "#{FDSources::StartOfForm}#{@forms[0].name.capitalize1}\n"
          @_new_project = nil
        else
          s=make_fdvr_source
          if state < 0
            n=line_count1
          elsif state == 0
            n=line_count1+s.count("\n")
          else
            n=line_count1+s.count("\n")+@_dde_line_no
          end
          
          @_dde_result="#{n}\n"+@buffer1+s+@buffer2
        end
      else
        @buffer1=""
        @buffer2=""
        @_a_buffer2=data.to_a
        @_a_buffer2=[''] if @_a_buffer2.empty?
        @buffer2=update
        save
        if @_new_project then
          @_dde_result="#{@_dde_line_no}\n"+
            "require '#{File.basename(@workingfile)}'\n\n"+
            @buffer2+"#{FDSources::StartOfForm}#{@forms[0].name.capitalize1}\n"
          @_new_project = nil
        else
          @_dde_result="#{@_dde_line_no}\n"+@buffer2
        end
      end
    rescue
      messageBox($!.to_s + "\r\n" + $@.join("\r\n"))
    end
  end
  
  def self_ddeterminate(hwnd)
    self.close
  end
  
  ### File ### 
  
  def close_all_forms
    @forms.each{|i|
      @mainmenu.delete(i.etc)
      i.close
    }
    @forms=[]
    @hinstance=nil
    @designform=nil
    @hwndEd = 0
    @workingfile = nil
    @project_type=nil
    clear_modified
    self.caption = "FormDesigner"
  end
  
  def new_form(ctype)
    unless @designfrm.alive? then
      new_designfrm
      #@formShow.checked = true
    end
    if @modified > 0 then
      if save_prepare_close("New file") then
        close_all_forms
        new_designfrm
      end
    else
      close_all_forms
      new_designfrm
    end
    @designfrm.type_of_form = ctype
    #@hinstance = nil
  end
  
  def check_form_menu(b)
    @change_to_mainform.checked = b
    @change_to_modeless_mainform.checked = !b
  end
  
  def new_form_clicked
    new_form(VRForm)
    @designfrm.refreshCntName
    @designfrm.refreshInspect(nil)
    check_form_menu(true)
  end
  
  def new_modeless_form_clicked
    new_form(VRDialogComponent)
    @designfrm.refreshCntName
    @designfrm.refreshInspect(nil)
    check_form_menu(false)
  end
  
  def new_modeless_dlg_clicked
    new_form(VRModelessDialog)
    @designfrm.refreshCntName
    @designfrm.refreshInspect(nil)
    check_form_menu(false)
  end
  
  
  def change_to_mainform_clicked
    @forms[0].type_of_form = VRForm
    @designfrm.refreshInspect(@designfrm.focused) if designfrm == @forms[0]
    check_form_menu(true)
    inc_modified
  end
  
  def change_to_modeless_mainform_clicked
    @forms[0].type_of_form = VRDialogComponent
    @designfrm.refreshInspect(@designfrm.focused) if designfrm == @forms[0]
    check_form_menu(false)
    inc_modified
  end
  
  def change_to_modeless_maindlg_clicked
    @forms[0].type_of_form = VRModelessDialog
    @designfrm.refreshInspect(@designfrm.focused) if designfrm == @forms[0]
    check_form_menu(false)
    inc_modified
  end
  
  def save_prepare_close(s)
    r = messageBox(FDMsgItems::DoYouSave,s,
        WConst::MB_ICONQUESTION|WConst::MB_YESNOCANCEL|WConst::MB_SYSTEMMODAL)
    case r
    when 6
      if save_clicked then
        r = true
      end
    when 7
      r = true
    else
      r = nil
    end
    r
  end
  
  def scan_project(str)
    case str
    when /^\s*module\s+[A-Z][a-zA-Z0-9_]*/,
      /^\s*class\s+[A-Z][a-zA-Z0-9_]*.*$/
      yield 1,$1
    when /^\s*end/
      yield -1,nil
    end
  end
  
  def parse_project(str)
    
    while true
      str = scan_project(str){|n,s|
      }
      break if str == ""
    end
  end
    
  def open_clicked
    if @modified == 0 || save_prepare_close(FDMsgItems::OpenPreare) then
          wf=openFilenameDialog(
                  [["ruby scripts","*.rb"],["ruby forms","_frm_*.rb"]])
      if wf
        open1(wf)
        clear_modified
      end
    end
  end
  
  def open_by_drop(fn)
    return if @_dde_mode
    return unless File.extname(fn) =~ /\.[rR][bB]/
    if @modified == 0 || save_prepare_close(FDMsgItems::OpenPreare) then
      wf= fn
      if wf
        open1(wf)
        clear_modified
      end
    end
  end
  
  def read_form(s,idx=0)
    def check_selial_name(nm)
      if @forms.find{|i| i.name == nm} then
        check_selial_name(nm.sub(/([0-9]+)$/,'')+($1.to_i+1).to_s)
      else
        nm
      end
    end
    if s0=s.scan(/^#{FDSources::BeginOfFD}.*^#{FDSources::EndOfFD}/m)[0]
      @buffer1=$`
      @buffer2=$'
      close_all_forms if idx==0
      s0.scan(/^class.*?^end/m){|s|
        @forms[idx,0] = create_form(0,0,0,0,"")
        @designfrm = @forms[idx]
        s.match(/^class +([A-Z][a-zA-Z0-9_]*)\s*<\s([A-Z][a-zA-Z0-9_]*).*$/)
        if idx > 0 then
          @designfrm.name=check_selial_name($1[0,1].downcase+$1[1..$1.size-1])
        else
           @designfrm.name=$1[0,1].downcase+$1[1..$1.size-1]
        end
        @designfrm.type_of_form=eval($2)
        check_form_menu(@designfrm.type_of_form <= VRForm)
        @designfrm.oldname=@designfrm.name.dup
        @designfrm.parse_str($')
      }
      @forms[idx..@forms.size-1].each_with_index{|c,i|
        @mainmenu.menu.insert(c.name,Start_Of_FrmID+i+idx,@inspectShow.etc-1)
        c.etc=Start_Of_FrmID+i+idx
      }
      true
    else
      nil
    end
  end
  
  def set_project_type(typ)
    case typ
    when :mono
      @sb1.setTextOf(2,FDProjectTypes::Mono)
    when :apart
      @sb1.setTextOf(2,FDProjectTypes::Apart)
    else
      @sb1.setTextOf(2,FDProjectTypes::Form)
    end
    @project_type=typ
  end
  
  def open1(wf)
    str=''
    tstamp=0
    fobj=nil
    #begin
    open(wf){|f| wf=File.expand_path(wf);tstamp=f.stat.mtime.to_i; str=f.read }
    wf0 = File.basename(wf).sub(/^_frm_(.+)/,'\1')
    unless read_form(str)
      wf1 = File.dirname(wf)+'/_frm_'+ wf0
      if File.exist?(wf1) then
        open(wf1){|f| tstamp=f.stat.mtime.to_i; str=f.read}
      else # new project
        NewProjectDlg.args = wf
        if @screen.openModalDialog(self,nil,NewProjectDlg) then
          set_project_type :apart
          @workingfile=wf1
        else
          set_project_type :mono
          @workingfile=wf
        end
        self.caption=self.caption+" - #{@workingfile.gsub!(/\//,'\\')}"
        @_new_project = true
        return
      end
      
      unless read_form(str)
        #old version
        close_all_forms
        @forms<<create_form(0,0,0,0,"")
        @designfrm=@forms.last
        @designfrm.readfile(str)
      end
      set_project_type :apart
      @workingfile = wf1
    else
      if File.basename(wf) =~ /^_frm_/ then
        set_project_type nil
      else
        set_project_type :mono
      end
      @workingfile = wf
    end
    #rescue
    #  messageBox FDMsgItems::Noform
    #  return
    #end
    $tstamp = tstamp
    @designfrm=@forms[0]
    @designfrm.focus
    window_menu_set_check(@forms[0].etc)
    @designfrm.refreshCntName
    @designfrm.refreshInspect(nil)
    self.caption = "FormDesigner - #{@workingfile.gsub!(/\//,'\\')}"
    @class_struct1 = ModStruct.new(nil,nil,nil)
    @forms.reverse_each do|i|
      x,y,w,h = i.windowrect
      @class_struct1.childs << i.makeModStruct(i,@class_struct1)
    end
    if $RDE
      s = (File.dirname(wf)+"/#{wf0}").tr('/','\\')
      @rde_project = $RDE.newCodeWindow(s)
    end
  end

  def save_clicked
    if @project_type == :mono then
      update_proj_clicked
      return
    end
    if @workingfile then
      save
    else
      saveas_form_clicked
    end
  end

  def saveas_form_clicked
    if r = saveFilenameDialog(["ruby forms","_frm_*.rb"]) then
      case r
      when /(.+)\\(.+)\.rb$/
        d = $1;e = $2
      when /(.+)\\(.+)$/
        d = $1;e = $2
      end
      e.sub!(/^_frm_/,'')
      @workingfile= d + '\\_frm_' +  e + '.rb'
      save
      @project_type = nil
      @sb1.setTextOf(2,FDProjectTypes::Form)
    end
    r
  end

  def saveas_proj_part_clicked
    if r = saveFilenameDialog(["ruby scripts","*.rb"]) then
      case r
      when /(.+)\\(.+)\.rb$/
        d = $1;e = $2
      when /(.+)\\(.+)$/
        d = $1;e = $2
      end
      e.sub!(/^_frm_/,'')
      @workingfile= d + '\\_frm_' +  e + '.rb'
      save
      saveProject(d + '\\' + e + '.rb')
      @project_type = :apart
      @sb1.setTextOf(2,FDProjectTypes::Apart)
    end
  end
  
  def saveas_proj_mono_clicked
    if r = saveFilenameDialog(["ruby scripts","*.rb"]) then
      save1(r,true)
      self.caption = "FormDesigner - #{@workingfile=r}"
      @project_type = :mono
      @sb1.setTextOf(2,FDProjectTypes::Mono)
    end
  end
  
  def self_activateapp(wParam,hwnd)
    return if @_dde_mode
    if LOWORD(wParam) == 1 then
      if @workingfile && File.exist?(@workingfile) then
        r = checkTstamp($tstamp)
      end

      if r then
        rr=messageBox *FDMsgItems::FileWasModified
        case rr
        when 6
          clear_modified
          wf = @workingfile ; ed = @hwndEd
          ctype = @designfrm.type_of_form
          close_all_forms
          @designfrm.type_of_form = ctype
          @workingfile = wf ; @hwndEd =ed
          open1(@workingfile)
          self.caption = "FormDesigner - #{@workingfile}"
        else
          $tstamp=File.stat(@workingfile).mtime.to_i
        end

      end
    else
      if @editorStarting then
        @hwndEd = 0
        @hwndEd = GetForegroundWindow.call until @hwndEd > 0
      end
      @editorStarting = false
    end
  end

  def checkTstamp(time)
    File.stat(@workingfile).mtime.to_i > $tstamp
  end
  
  def make_fdvr_source
    a = []
    s0 = FDSources::BeginOfFD
    unless $ini.read("settings","verbose","true")=="false"
      s0 += FDSources::Caution
    else
      s0 += "\n"
    end
    s1 = ""
    @forms.reverse_each{|i|
      s1 += i.make_executive
      a << 'vrdialog' if i.type_of_form <= VRDialogComponent
      a = a + i.get_require
    }
    a.uniq.each{|i| s0+="require 'vr/#{i}'\n"}
    s = s0 + s1
    s += "\n" + FDSources::EndOfFD
    s
  end
  
  def save1(fname,proj=nil)
    s = make_fdvr_source
    if proj then
      unless $ini.read("settings","verbose","true")=="false"
        s += FDSources::Follows
      else
        s += "\n"
      end
      @forms.reverse_each{|i|
        s +=  modStruct_to_s(i.makeModStruct(i))
      }
      if @forms[0].type_of_form == VRDialogComponent then
        s += FDSources::StartOfModeless+@forms[0].name.capitalize1 + 
                                          FDSources::StartOfModeless2
      elsif @forms[0].type_of_form == VRModelessDialog then
        s += FDSources::StartOfMdlsDlg+@forms[0].name.capitalize1 + 
                                          FDSources::StartOfModeless2
      else
        s += "\n#{FDSources::StartOfForm}#{@forms[0].name.capitalize1}\n"
      end unless (@bufffer1 == "") && (@buffer2 == "")
      @class_struct1 = ModStruct.new(nil,nil,nil)
      @forms.reverse_each{|i| @class_struct1.childs <<
                                      i.makeModStruct(i,@class_struct1)}
        
    end
    open(fname,"w") {|f| f.write s 
      $tstamp=f.stat.mtime.to_i
      clear_modified}
  end

  def save
    r=save1(@workingfile)
    @sb1.setTextOf(1,@workingfile + FDMsgItems::Saved)
    self.caption = "FormDesigner - #{@workingfile}"
    @designfrm.focused = nil
    @designfrm.refreshInspect(nil)
    @designfrm.setFocusRgn(nil)
    r
  end
  
  def modStruct_to_s(st,level=0)
    lv = "  "*level
    s0=lv + "class #{st.name}"
    s = s0 + ' '*(s0.size<68 ? 68-s0.size : 1) + FDSources::TagOfFD + "\n\n"
    st.childs.each{|i|  s += modStruct_to_s(i,level+1)}
    s += "  def self_created\n\n  end\n" if level == 0
    s0 = lv + "end"
    s += s0 + ' '*(s0.size<68 ? 68-s0.size : 1) + FDSources::TagOfFD + "\n\n"
  end
  
  def project_prefix(filepath)
    s = "#! ruby -Ks\n"
    s += "require \'vr/vruby\'\n" 
    s += "require '_frm_#{File.basename(filepath,'.rb')}'\n" unless
                                                       @project_type == :mono
    s
  end
  
  def saveProject(filepath)
    ss = project_prefix(filepath)
    @forms.reverse_each{|i| ss +=  modStruct_to_s(i.makeModStruct(i))}
    ss += "\n#{FDSources::StartOfForm}#{@forms[0].name.capitalize1}\n"
    update_name
    @class_struct1 = ModStruct.new(nil,nil,nil)
    @forms.reverse_each{|i| @class_struct1.childs <<
                                           i.makeModStruct(i,@class_struct1)}
    open(filepath,"w") {|f| f.write ss}
  end
  
  def run_editor_clicked
    unless @workingfile then
      messageBox *FDMsgItems::SaveBeforeEdit
      return
    end
    if @modified > 0
      save1(@workingfile) unless @project_type == :mono
      update_proj_clicked
    end
    ed = IsWindow.call(@hwndEd) if @hwndEd
    if ! ed || ed == 0  then
      fpath = @workingfile.sub(/_frm_(.+\.rb)/,'\1')
      @hinstance = ShellExecute.call(0,"open",$editor, "\"#{fpath}\"", nil,1)
      @editorStarting = true
    else
      SetForegroundWindow.call(@hwndEd)
    end
  end

  def show_editor
    ed = IsWindow.call(@hwndEd) if @hwndEd
    SetForegroundWindow.call(@hwndEd) if ed && (ed != 0)
  end

  def getModulesSet(cnt) #obsolete
    st = Set[]
    unless cnt.is_a? VRForm
      ps = get_parents_str(cnt)
      st << "Cntn#{ps}"
      st << "Extn#{ps}_#{cnt.name}" unless
      cnt.respond_to?(:addControl) || cnt.modules.empty?
    end
    cnt.controls.each{|i,c|
      if c.respond_to? :addControl then
        st = st + getModulesSet(c)
      end
      st << "Extn#{ps}_#{c.name}" unless
         c.is_a?(FDCoverPanel)||c.respond_to?(:addControl) ||
        (c.modules.empty? && (c.owndraw==0))
    }
    st
  end
  
  def update_proj_clicked
    n=messageBox FDMsgItems::SaveFromEditor[0],
    FDMsgItems::SaveFromEditor[0] + "#{@workingfile}",0x31
    return if n > 1
    if @project_type == :mono
      update_proj_mono
    else
      update_proj
    end
  end
  
  def update_name
    def up1(cnt)
      cnt.oldname = cnt.name
      if cnt.respond_to? :addControl
        cnt.controls.each{|i,v| up1(v)}
      end
    end
    @forms.each{|i| up1(i)}
  end
  
  def update
    clin = 0
    compare_struct = lambda do |c1,c2,lv|
      a = []; s=""; lin=0
      c1.childs.each{|i|
        if (j=c2.find(i.oldname)) && j.sline then
          @_a_buffer2[j.sline,1][0].sub!(/#{j.oldname}.*$/,
            i.name+" "*((62-lv*2-i.name.size)>0 ? (62-lv*2-i.name.size) : 2)+
            FDSources::TagOfFD)
          compare_struct.call(i,j,lv+1)
        else
          a << i
        end
      }
      a.each{|i|
        s << modStruct_to_s(i,lv)
      }
      lin = c2.tline ? c2.tline : c2.eline
      lin = 0 unless lin
      clin += s.count("\n") if @_dde_line_no > lin
      @_a_buffer2[lin,1][0][0,0] = s
    end
    class_struct2 = ModStruct.new(nil,nil,nil)
    @forms.each{|i| class_struct2.childs << i.makeModStruct(i,class_struct2)}
    current=@class_struct1
    in_rd=nil
    not_find=nil
    @_a_buffer2.each_with_index{|lin,idx|
      if in_rd && !(lin =~ /^=end/) then next else in_rd=false end
      case lin
      when /^=begin/
        in_rd=true;next
      when /^\s*class\s+([A-Z][a-zA-z0-9_]*)\s+#{FDSources::TagOfFD}$/
        current.tline = idx-@_a_buffer2.size unless current.tline
        unless c = current.find($1) then
          c = ModStruct.new($1,$1,current)
          current.childs << c
        end
        current = c
        current.sline = idx-@_a_buffer2.size
      when /^\s*end\s+#{FDSources::TagOfFD}$/
        current.eline = idx-@_a_buffer2.size
        current = current.parent
      else
      end
    }
    compare_struct.call(class_struct2,@class_struct1,0)
    update_name
    @class_struct1 = ModStruct.new(nil,nil,nil)
    @forms.reverse_each{|i| @class_struct1.childs <<
                                           i.makeModStruct(i,@class_struct1)}
    r = @_a_buffer2.to_s
    @_dde_line_no += clin
    r
  end
  
  def update_proj_mono
    s=""
    unless @workingfile then
      saveas_proj_mono_clicked
      return
    end
    begin
      open(@workingfile,'r'){|f| s = f.read}
    rescue
    end
    s.scan(/^#{FDSources::BeginOfFD}.*^#{FDSources::EndOfFD}/m)[0]
    @buffer1=$` ? $` : ""
    @buffer2=$' ? $' : ""
    @_a_buffer2=@buffer2.empty? ? [""] : $'.to_a
    @buffer2=update
    s = @buffer1+make_fdvr_source+@buffer2
    open(@workingfile,'w'){|f| f.write(s)
      $tstamp=f.stat.mtime.to_i
      clear_modified}
  end
  
  def update_proj
    unless @workingfile then
      unless saveas_proj_part_clicked then return end
    else
      save1(@workingfile) if @modified > 0
    end
    fpath = @workingfile.sub(/_frm_(.+\.rb)/,'\1')#+$1
    if  File.exist?(fpath) then
      open(fpath,'r'){|f| @buffer2=f.read}
      @_a_buffer2=@buffer2.to_a
      @buffer2=update
      open(fpath,'w'){|f| f.write @buffer2 }
      show_editor
    else
      saveProject(fpath)
      show_editor
    end
  end

  def exit_clicked
    self_close
  end
  
  ### Insert ###
  
  def get_serial_name(s0)
    s=s0.sub(/\d*$/,'')
    n=1
    while true
      break if @forms.select{|i| i.name == (s + n.to_s) }.empty?
      n += 1
    end
    s + n.to_s
  end
  
  def insert_form(fname,klass)
    s=get_serial_name(fname)
    @forms<<create_form(@forms.last.x+20,@forms.last.y,500,400,s)
    @forms.last.name=s
    @forms.last.oldname=s
    @mainmenu.menu.insert(s,Start_Of_FrmID+@forms.size-1,@inspectShow.etc-1)
    @forms.last.etc=Start_Of_FrmID+@forms.size-1
    window_menu_set_check(@forms.last.etc)
    @designfrm=@forms.last
    @designfrm.type_of_form = klass
    @designfrm.refreshInspect(nil)
    @designfrm.refreshCntName
    inc_modified
  end
  
  def insert_form_clicked
    insert_form("form",VRForm)
    @designfrm.refreshCntName
    @designfrm.refreshInspect(nil)
  end
  
  def insert_modelessform_clicked
    insert_form("mdlessdlg",VRModelessDialog)
    @designfrm.refreshCntName
    @designfrm.refreshInspect(nil)
  end
  
  def insert_modalform_clicked
    insert_form("modaldlg",VRModalDialog)
    @designfrm.refreshCntName
    @designfrm.refreshInspect(nil)
  end
  
  def change_to_form_clicked
    unless @designfrm == @forms[0]
      @designfrm.type_of_form = VRForm
      @designfrm.refreshCntName
      @designfrm.refreshInspect(@designfrm.focused)
    else
      messageBox *FDMsgItems::ThisIsMain
    end
  end
  
  def change_to_modeless_form_clicked
    unless @designfrm == @forms[0]
      @designfrm.type_of_form = VRModelessDialog
      @designfrm.refreshCntName
      @designfrm.refreshInspect(@designfrm.focused)
    else
      messageBox *FDMsgItems::ThisIsMain
    end
  end
  
  def change_to_modal_form_clicked
    unless @designfrm == @forms[0]
      @designfrm.type_of_form = VRModalDialog
      @designfrm.refreshCntName
      @designfrm.refreshInspect(@designfrm.focused)
    else
      messageBox *FDMsgItems::ThisIsMain
    end
  end
  
  def delete_this_form_clicked
    if @designfrm.etc==Start_Of_FrmID then
      messageBox *FDMsgItems::ThisIsMain
      return nil
    end
    r = messageBox(*FDMsgItems::OerationCannotUndo)
    if r==6 then
      @mainmenu.delete(@designfrm.etc)
      @forms.delete(@designfrm)
      @designfrm.close
      @forms[0].focus
      inc_modified
    end
  end
  
  def insert_form_from_file_clicked
    return unless fname = openFilenameDialog(["ruby scripts","*.rb"])
    open(fname){|f|
      s=f.read
     messageBox *FDMsgItems::Noform  unless read_form(s,@forms.size)
    }
  end
  
  def save_this_form_clicked
    return unless r = saveFilenameDialog(["ruby scripts","*.rb"])
    s0 = FDSources::BeginOfFD +  FDSources::Caution
    s = @designfrm.make_executive
    a=@designfrm.get_require
    a << 'vrdialog' if @designfrm.type_of_form <= VRDialogComponent
    a.uniq.each{|i| s0+="require 'vr/#{i}'\n"}
    open(r,"w"){|f| f.write(s0 + s + "\n" + FDSources::EndOfFD)}
  end
  
  ### Edit ###
  
  def doDelete_clicked
    @designfrm.deleteCont
  end
  
  def doCut_clicked
     @designfrm.cutCont
  end
  
  def doCopy_clicked
    @designfrm.copyCont
  end
  
  def doPaste_clicked
    @designfrm.pasteCont
  end
  
  def back_to_parent_clicked
    @designfrm.backToParent
  end
  
  def setFont_clicked
    @designfrm.ctrl_setFont
  end

  def setWinStyle_clicked
    @designfrm.setWinStyle
  end

  def setWSArray(style)
    a=[] ;s1 =$Style[:win].keys.dup
    s1.each{|i| s = i.dup ;
      a << [s.to_s,((($Style[:win])[i] & style) == 0 ? 0 : 1)]
    }
    a.sort
  end

  def wsArrat2int(a)
    r =0
    a.each{|i|
      r = r | $Style[:win][i[0]]*i[1]
    }
    r
  end

  def examine_clicked
    @examinedlg.options["default"] = @designfrm.make_executive.gsub(/\n/,"\r\n")
    @examinedlg.move 20,20,328,220
    @examinedlg.open(@designfrm)
  end

  def execute_clicked
    unless @running then
      @running=true
      @designfrm.visible = false
      @inspectfrm.visible = false
      s = nil
      s = @designfrm.make_executive
      s.sub!(/(^class +)(\w+)\s*<\s*\w+/,'\1TMP_\2 < VRForm;include ExecuteDesignfrm;')
      s1 = $2
      s << "\nVRLocalScreen.showForm TMP_#{s1}"
      eval s
      self.class.module_eval "remove_const :TMP_#{s1}"
    end
  end

  def exitExec
    @running=false
    @designfrm.visible = true if @designfrm.alive?
    @inspectfrm.visible = true if @inspectfrm.alive?
  end

  def formShow_clicked
    unless @designfrm.alive? then
      new_designfrm
      @formShow.checked = true ; return
    end
    if @designfrm.visible? then
      @formShow.checked = @designfrm.visible = false
    else
      @formShow.checked = @designfrm.visible = true
    end
  end
  
  ## window ##
  def window_menu_set_check(id)
    @forms.each{|i|
      @mainmenu.menu.setChecked(i.etc,i.etc == id)
    }
  end
  
  def select_form(id)
    @forms.select{|i| i.etc==id}[0].focus
  end
  
  def inspectShow_clicked
    unless @inspectfrm.alive? then
      t=$ini.read("inspect","top",0).to_i
      l=$ini.read("inspect","left",0).to_i
      h=$ini.read("inspect","height",400).to_i
      w=$ini.read("inspect","width",140).to_i
      @inspectfrm.move(l,t,w,h)
      @inspectfrm.create.show
      @designfrm.refreshInspect(@designfrm.focused)
      @designfrm.refreshCntName
      @inspectShow.checked = true ; return
    end
    if @inspectfrm.visible? then
      @inspectShow.checked = @inspectfrm.visible = false
    else
      @inspectShow.checked = @inspectfrm.visible = true
    end
  end

  def prefer_clicked
    PreferDlg.arg={:editor=>$ini.read("settings","editor","notepad.exe"),
      :grid=>$ini.read("settings","span",8),
      :cygwin=>$ini.read("settings","LFOnly",'false')=='false' ? false : true,
      :font=>$ini.read("settings","font","MS UI Gothic,12"),
      :dock=>$ini.read("settings","dock",'true')=='true' ? true : false ,
      :verbose=>$ini.read("settings","verbose",'true')=='true' ? true : false}
    if a1=@screen.modalform(self,0x02,PreferDlg) then
      grid, editor, cygwin, font, dock, verbose = *a1
        g=grid.to_i
      if 1 < g  && g < 100  then
        $ini.write("settings","span",@designfrm.span=g)
        @designfrm.refresh
      else
        messageBox *FDMsgItems::GridMustBe
      end
      $editor = editor
      $ini.write("settings","editor",$editor)
      $ini.write("settings","font","#{font}")
      $ini.write("settings","dock","#{dock}")
      $n = RUBY_PLATFORM =~ /\w+-cygwin/ && !cygwin ? "\r\n" : "\n"
      $ini.write("settings","LFOnly",cygwin)
      $ini.write("settings","verbose","#{verbose}")
      sx,sy,sw,sh=self.windowrect
      self_move(sx,sy)
    end
  end
  
  def show_reference_clicked
    HtmlHelp.call(hWnd,HTML_Help,HH_DISPLAY_TOC,0)
  end
  
  def show_topic_clicked
    s = ""
    if @designfrm.creation
      s = @designfrm.creation.klass.name
    elsif @designfrm.focused
      s = @designfrm.focused.class.name
    else
      s = "VRForm"
    end
    HtmlHelp.call(hWnd,HTML_Help,HH_HELP_CONTEXT,FDHelp::HH_hash[s])
  end
  
  def show_SDK_topic_clicked
    return unless SDKDocument
    if (d=FDSDK::DE_Hash[@designfrm.focused.class.name])
      SDKDocument.DisplayTopicFromURL  FDSDK::DE_Prefix + d
    else
      SDKDocument.DisplayTopicFromURL(
       'ms-help://MS.PSDK.1033/shellcc/platform/commctls/wincontrols.htm')
    end
  end
  
  def version_clicked
    VersionDlg.args = $Ver
    @screen.modalform(self,0x02,VersionDlg)
  end

  def gridState_clicked
    if @designfrm.enableGrid then
      @gridState.checked = @designfrm.enableGrid = false
    else
      @gridState.checked = @designfrm.enableGrid = true
    end
    @designfrm.refresh
  end

  def self_resize(w,h)
    @tab.move 0,0,w,58 if @tab
  end
  
### Tool ###

  def bmp2str_clicked
    str=""
    fi=[]
    if fi=openFilenameDialog([["bitmaps","*.bmp"]]) then
      fi.each do |f|
        bmp = SWin::Bitmap.loadFile(fi)
        str = bmp.dumpString
      end
      clb1=Clipboard.open(self.hWnd)
      clb1.setText(str)
      clb1.close
      @designfrm.messageBox FDMsgItems::Base64Finish
    end
  end
  
  def bmp2strz_clicked
    str=""
    fi=[]
    if fi=openFilenameDialog([["bitmaps","*.bmp"]]) then
      fi.each do |f|
        bmp = SWin::Bitmap.loadFile(fi)
        str = [Zlib::Deflate.deflate(Marshal.dump(bmp))].pack("m")
      end
      clb1=Clipboard.open(self.hWnd)
      clb1.setText(str)
      clb1.close
      @designfrm.messageBox FDMsgItems::Base64Finish
    end
  end
  
### event handler
  
  def self_move(x0,y0)
    if @inspectfrm && $ini.read("settings","dock",'true')=='true'then
      sx,sy,sw,sh = self.windowrect
      ix,iy,iw,ih=@inspectfrm.windowrect
      @inspectfrm.move(sx,sy+sh,iw,ih)
    end
  end
  
  def self_close
    if @dialog_running then
      messageBox @dialog_running + FDMsgItems::DialogRunning[0],
                       FDMsgItems::DialogRunning[1],FDMsgItems::DialogRunning[2]
      return SKIP_DEFAULTHANDLER
    end
    
    if @_dde_mode  then
      r = messageBox(*FDMsgItems::InDDEmode)
      if r == 6 then
        close
      else
        return SKIP_DEFAULTHANDLER
      end
    end
    if @modified > 0 then
      n = messageBox(*FDMsgItems::SaveBrforeExit)
      case n
      when 6
        unless save_clicked then
          SKIP_DEFAULTHANDLER
        else
          close
        end
      when 2
        SKIP_DEFAULTHANDLER
      when 7
        close
      end
    else
      close
    end
  end
  
  def self_destroy
    SDKDocument.Close if SDKDocument
    HtmlHelp.call(0,nil,HH_UNINITIALIZE,@fd_cookie)
    $subwnd.close if $subwnd && $subwnd.alive?
    a=windowrect
    $ini.write "settings","language",$Lang
    $ini.write "mainform","left",a[0]
    $ini.write "mainform","top",a[1]
    $ini.write "mainform","width",a[2]
    $ini.write "mainform","height",a[3]
    @controls.clear
    $ini.flash
  end
  
  #popup menu
  def doDeletepop_clicked() doDelete_clicked() end
  def doCopypop_clicked() doCopy_clicked end
  def doPastepop_clicked() doPaste_clicked end
  def doCutpop_clicked() doCut_clicked end
  def back_to_parentpop_clicked() back_to_parent_clicked end
  
  ### Other methods
  def inhibit_paste_menu
    @doDelete.state = 0
    @doCopy.state = 1
    @doPaste.state = 1
    @doCut.state = 1
    @back_to_parent.state = 0
    @doDeletepop.state = 0
    @doCopypop.state = 1
    @doPastepop.state = 1
    @doCutpop.state = 1
    @back_to_parentpop.state = 0
  end
  
  def enable_paste_menu
    @doDelete.state = 0
    @doCopy.state = 0
    @doPaste.state = 0
    @doCut.state = 0
    @back_to_parent.state = 0
    @doDeletepop.state = 0
    @doCopypop.state = 0
    @doPastepop.state = 0
    @doCutpop.state = 0
    @back_to_parentpop.state = 0
  end
  
  def form_edit_menu
    @doDelete.state = 1
    @doCopy.state = 1
    @doPaste.state = 0
    @doCut.state = 1
    @back_to_parent.state = 1
    @doDeletepop.state = 1
    @doCopypop.state = 1
    @doPastepop.state = 0
    @doCutpop.state = 1
    @back_to_parentpop.state = 1
  end
  
  def update_menu(frm)
    @mainmenu.menu.modify(frm.etc,frm.name) 
  end
  
  def inc_modified
    @modified += 1
    if $RDE
      @sb1.setTextOf(1,"RDE Mode") if @sb1
      modify_RDE_text
    else
      @sb1.setTextOf(1,FDMsgItems::Modified) if @sb1
    end
  end

  def clear_modified
    @modified = 0
    return if $RDE
    @sb1.setTextOf(1,"") if @sb1
  end
  
  def modify_RDE_text
    return unless @rde_project
    cw = @rde_project
    lno = cw.row
    cno = cw.col
    data = cw.text
    data, ln = modify_project_buffer(data,lno)
    cw.text = data
    cw.row = ln
    cw.col = cno
  end
  
  def modify_project_buffer(data, org_line_no)
    line_no = org_line_no
    if @project_type == :mono
      data.scan(/^#{FDSources::BeginOfFD}.*^#{FDSources::EndOfFD}/m)[0]
      buffer1=$` ? $` : ""
      buffer2=$' ? $' : ""
      form_lin_count = $& ? $&.count("\n") : 0
      line_count1 = buffer1.count("\n")
      line_count2 = buffer2.count("\n")
      
      if line_no <= line_count1
        state = -1
        line_no = 0
      elsif (n = line_no-form_lin_count-line_count1) >= 0
        state=1
        line_no = n
      else
        state=0
        line_no = 0
      end
      a_buffer = $'.to_a
      a_buffer = [''] if a_buffer2.empty?
      buffer2 = update_project_buffer(a_buff,line_no)
      if @_new_project then
        result = "#! ruby -Ks\n" + buffer1 + make_fdvr_source
        unless $ini.read("settings","verbose","true")=="false"
            result += FDSources::Follows
        else
          result += "\n"
        end
          result += buffer2+
                     "#{FDSources::StartOfForm}#{@forms[0].name.capitalize1}\n"
          @_new_project = nil
        else
        s = make_fdvr_source
        if state < 0
          n = line_count1
        elsif state == 0
          n = line_count1 + s.count("\n")
        else
          n = line_count1 + s.count("\n") + line_no
        end
        result = buffer1 + s + buffer2
        line_no = n
      end
    else
      result =""
      buffer2 = ""
      a_buffer = data.to_a
      a_buffer = [''] if a_buffer.empty?
      buffer2, line_no = update_project_buffer(a_buffer,line_no)
      save1(@workingfile)
      if @_new_project
        result = "require '#{File.basename(@workingfile)}'\n\n"+
            buffer2 + "#{FDSources::StartOfForm}#{@forms[0].name.capitalize1}\n"
        @_new_project = nil
      else
        result = buffer2.to_s
      end
    end
    [result, line_no]
  end
  
  def update_project_buffer(a_buffer,line_no)
    clin = 0
    compare_struct = lambda do |c1,c2,lv|
      a = []; s=""; lin=0
      c1.childs.each{|i|
        if (j=c2.find(i.oldname)) && j.sline then
          a_buffer[j.sline,1][0].sub!(/#{j.oldname}.*$/,
            i.name+" "*((62-lv*2-i.name.size)>0 ? (62-lv*2-i.name.size) : 2)+
            FDSources::TagOfFD)
          compare_struct.call(i,j,lv+1)
        else
          a << i
        end
      }
      a.each{|i|
        s << modStruct_to_s(i,lv)
      }
      lin = c2.tline ? c2.tline : c2.eline
      lin = 0 unless lin
      clin += s.count("\n") if line_no > lin
      a_buffer[lin,1][0][0,0] = s
    end
    class_struct2 = ModStruct.new(nil,nil,nil)
    @forms.each{|i| class_struct2.childs << i.makeModStruct(i,class_struct2)}
    current=@class_struct1
    in_rd=nil
    not_find=nil
    a_buffer.each_with_index{|lin,idx|
      if in_rd && !(lin =~ /^=end/) then next else in_rd=false end
      case lin
      when /^=begin/
        in_rd=true;next
      when /^\s*class\s+([A-Z][a-zA-z0-9_]*)\s+#{FDSources::TagOfFD}/
        current.tline = idx-a_buffer.size unless current.tline
        unless c = current.find($1) then
          c = ModStruct.new($1,$1,current)
          current.childs << c
        end
        current = c
        current.sline = idx-a_buffer.size
      when /^\s*end\s+#{FDSources::TagOfFD}/
        current.eline = idx-a_buffer.size
        current = current.parent
      else
      end
    }
    compare_struct.call(class_struct2,@class_struct1,0)
    update_name
    @class_struct1 = ModStruct.new(nil,nil,nil)
    @forms.reverse_each{|i| @class_struct1.childs <<
                                           i.makeModStruct(i,@class_struct1)}
    r = a_buffer.to_s
    
    [r,clin + line_no]
  end
  
  def sorry
    messageBox FDMsgItems::SORRY
  end
  
end
