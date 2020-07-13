# fdinspect.rb
# Inspect Window of FormDesigner
#
# Programmed by yukimi_sake@mbi.nifty.com
# Copyright 2001-2003 Yukio Sakaue

require 'vr/vruby'
require 'vr/sysmod'
require 'vr/vrcontrol'
require 'vr/vrcomctl'
require 'vr/vrhandler'
require 'vr/clipboard'
require 'vr/vrmgdlayout'
require 'fdvr/fddialogs'

class PnEvt < VRPanel
  include VRResizeable
  def construct
    messageBox self.to_s
    addControl VRListbox,"evtList",""
    @evtList.move 0,0,100,100
  end

  def self_resize(w,h)
    messageBox w.to_s
    r=cleientrect
    @evtList.move 0,0,w,h
  end
end

class PnMtd < VRPanel
  include VRResizeable
  attr :inspectView
  def construct
    addControl VRButton,"bt1","bt1",0,0,100,25
    addControl VRListview ,"inspectView", "",0,0,100,100
    @inspectView.reportview
    @inspectView.addColumn("name")
    @inspectView.addColumn("value")
    @inspectView.setColumnWidthOf(1,78)
    @inspectView.visible=true
  end
  
  def self_resize(w,h)
    @inspectView.move(0,0,w,h)
  end
end

class EditableListview <  EDListview

  include VRParent
  include VRStdControlContainer
  include VRMarginedFrameUseable
  attr_accessor :ed, :btArray
  
  BevelConst = ['None','Groove1','Groove2','Raise1','Raise2','Sunken1','Sunken2']
  def construct
    self.lvexstyle=1
    addControl InplaceEdit,"ed","ed",0,0,10,10,0x80
    #create inplace editor
    addControl VRButton,"btStyle","...",0,0,10,10
    addControl VRButton,"btExStyle","...",0,0,10,10
    addControl VRCombobox,"btFont","...",0,0,10,10
    addControl VRButton,"btModule","...",0,0,10,10
    addControl VRButton,"btArray","...",0,0,10,10
    addControl VRButton,"btTab","...",0,0,10,10
    addControl VRCombobox,"cbTF",'true',0,0,10,40
    addControl VRCombobox,"cbOwnDraw",'true',0,0,10,50
    addControl VRCombobox,"cbBevel",'None',0,0,10,50
    addControl VRButton,"btLayout","...",0,0,10,10
    
    @ed.setFont $SysFont
    @btStyle.setFont $SysFont
    @btExStyle.setFont $SysFont
    @btFont.setFont $SysFont
    @btModule.setFont $SysFont
    @btArray.setFont $SysFont
    @btTab.setFont $SysFont
    @cbTF.setFont $SysFont
    @cbOwnDraw.setFont $SysFont
    @cbBevel.setFont $SysFont
    @btLayout.setFont $SysFont
    @ed.visible=false
    @btStyle.visible=false
    @btExStyle.visible=false
    @btFont.visible=false
    @btFont.setListStrings ['new','default']
    @btModule.visible=false
    @btArray.visible=false
    @btTab.visible=false
    @cbTF.setListStrings ['true','false']
    @cbTF.visible=false
    @cbOwnDraw.visible=false
    @cbBevel.setListStrings BevelConst
    @cbBevel.visible=false
    @btLayout.visible=false
  end

  def setFont(font)
    super
    @ed.setFont(font)
  end
  
  def hideAllContorls
    @controls.each{|i,j| j.visible=false}
  end
  
  def self_lbuttondown(shift,x,y)
    hideAllContorls
    @idx,@subitem,left,top,width,height = *hittest3(x,y)
    selectItem(@idx,false)
    if  @subitem!=1 then
      width = getColumnWidthOf(1)
      left = getColumnWidthOf(0)
      @subitem = 1
    end
    case getItemTextOf(@idx,2)
    when "nil"
      # do nothing
    when "_btStyle"
      @btStyle.move(left+width-height,top,height,height)
      @btStyle.show
    when "_btExStyle"
      @btExStyle.move(left+width-height,top,height,height)
      @btExStyle.show
    when "_btFont"
      s=getItemTextOf(@idx,1)
      @btFont.move(left,top-4,width,height+40)
      @btFont.select s=='default' ? 1 : 0
      @btFont.show
    when "_btModule"
      @btModule.move(left+width-height,top,height,height)
      @btModule.show
    when "_btArray"
      @btArray.move(left+width-height,top,height,height)
      @btArray.show
    when "_btTab"
      @btTab.move(left+width-height,top,height,height)
      @btTab.show
    when "_cbTF"
      s=getItemTextOf(@idx,1)
      @cbTF.move(left,top-4,width,height+40)
      @cbTF.select s=='true' ? 0 : 1
      @cbTF.show
    when "_cbOwnDraw"
      owndrwConst=FDOwnerDraw::ODConst[@parent.parent.designfrm.focused.class]
      if owndrwConst && fowndrw=owndrwConst.keys then
        @cbOwnDraw.clearStrings
        @cbOwnDraw.setListStrings(a = ['not used'] + fowndrw)
        s=getItemTextOf(@idx,1)
        @cbOwnDraw.move(left,top-4,width,height+64)
        @cbOwnDraw.select a.index(s)
        @cbOwnDraw.show
      end
    when "_cbBevel"
      s=getItemTextOf(@idx,1)
      @cbBevel.move(left,top-4,width,height+96)
      @cbBevel.select BevelConst.index(s)
      @cbBevel.show
    when "_btLayout"
      @btLayout.move(left+width-height,top,height,height)
      @btLayout.show
    else
      s=getItemTextOf(@idx,1)
      @ed.move(left-1,top-1,width+2,height+2)
      @ed.text=getItemTextOf(@idx,@subitem)
      @ed.show
      @ed.focus
    end
  end

  def update
    return if getItemTextOf(@idx,1) == @ed.text
    if @idx == 0 && @parent.parent.designfrm.names.index(@ed.text) then
      messageBox "already used name : '#{@ed.text}'",'name definition eror',16
      return
    end
    setItemTextOf(@idx,1,@ed.text)
    @parent.updateCont
  end
  
  def btStyle_clicked
    @parent.parent.designfrm.setWinStyle
  end
  
  def btExStyle_clicked
    @parent.parent.designfrm.setExStyle
  end
  
  def btFont_selchanged
    svalue = @btFont.getTextOf(@btFont.selectedString)
    @parent.parent.designfrm.ctrl_setFont(svalue == 'default')
  end
  
  def btModule_clicked
    @parent.parent.designfrm.setModules
  end
  
  def btArray_clicked
    @parent.parent.designfrm.focused.instance_eval("#{getItemTextOf(@idx,0)}")
  end
  
  def btTab_clicked
    @parent.parent.designfrm.ctrl_Tab_orders
  end
  
  def cbTF_selchanged
    str = getItemTextOf(@idx,0) #"sizebox" or "maximizebox"
    svalue = @cbTF.getTextOf(@cbTF.selectedString) #"true" or "false"
    @parent.parent.designfrm.setTrueFalse(str,svalue)
    setItemTextOf(@idx,1,svalue)
  end
  
  def cbOwnDraw_selchanged
    #str = getItemTextOf(@idx,0) #always "owndraw"
    svalue = @cbOwnDraw.getTextOf(@cbOwnDraw.selectedString)
    @parent.parent.designfrm.focused.set_owndraw(svalue)
    setItemTextOf(@idx,1,svalue)
    @parent.parent.designfrm.refreshInspect(@parent.parent.designfrm.focused)
  end
  
  def cbBevel_selchanged
    svalue = @cbBevel.getTextOf(@cbBevel.selectedString)
    @parent.parent.designfrm.focused.substance.bevel =
    { 'None'=>VRMgdTwoPaneFrame::BevelNone,
      'Groove1'=>VRMgdTwoPaneFrame::BevelGroove1,
      'Groove2'=>VRMgdTwoPaneFrame::BevelGroove2,
      'Raise1'=>VRMgdTwoPaneFrame::BevelRaise1,
      'Raise2'=>VRMgdTwoPaneFrame::BevelRaise2,
      'Sunken1'=>VRMgdTwoPaneFrame::BevelSunken1,
      'Sunken2'=>VRMgdTwoPaneFrame::BevelSunken2}[svalue]
    setItemTextOf(@idx,1,svalue)
    @parent.parent.designfrm.focused.parent.refresh
    @parent.parent.designfrm.refreshInspect(@parent.parent.designfrm.focused)
  end
  
  def btLayout_clicked
    @parent.parent.designfrm.registerLayout
  end
end

class FDListboxExt < VRListbox

  def vrinit
    super
    addCommandHandler(WMsg::LBN_DBLCLK, "dblclicked",MSGTYPE::ARGNONE,nil)
  end
end

module FDInspect
  include VRMessageHandler
  include VRResizeable
  include VRDestroySensitive
  include VRStatusbarDockable
  include VRClosingSensitive
  
  attr_reader :inspectView
  attr_accessor :cbControl, :evtList, :mthdList, :stb2, :skip_ctrl_name
  
  def vrinit
    super
    addHandler(WMsg::WM_ACTIVATE,"activate", MSGTYPE::ARGINTINT,0)
    addHandler(WMsg::WM_MOVE,"move", MSGTYPE::ARGLINTINT,0)
    acceptEvents([WMsg::WM_ACTIVATE,WMsg::WM_MOVE])
  end

  def construct
    begin SWin::Application.setAccel(self,@parent) ;rescue ;end
    addControl VRTabControl,"tab1","tab1"
    @tab1.setFont $SysFont
    @tab1.insertTab(0,"Attr")
    @tab1.insertTab(1,"Event")
    @tab1.insertTab(2,"Mthd")
    @stb2 = addStatusbar
    addControl FDListboxExt,"evtList",""
    addControl FDListboxExt,"mthdList",""
    @evtList.setFont $SysFont
    @mthdList.setFont $SysFont
    addControl VRCombobox,"cbControl","ComboBox1"
    @cbControl.setFont($SysFont)
    @cbControl.setListStrings(["1","2","4","8","16"])
    @cbControl.select(0)
    @evtList.setListStrings([])
    @evtList.visible=false
    @mthdList.visible=false
    addControl EditableListview ,"inspectView", ""
    @inspectView.reportview
    @inspectView.setFont($SysFont)
    @inspectView.addColumn("name")
    @inspectView.addColumn("value")
    @inspectView.addColumn("option")
    @inspectView.setColumnWidthOf(1,78)
    @inspectView.setColumnWidthOf(2,0)
    @inspectView.enabled=true
  end

  def self_created
    
  end

  def updateCont
    n = @inspectView.countItems
    s = ""
    if @parent.designfrm.focused.class == FDContainer then
      arg = [@inspectView.getItemTextOf(0,1),@inspectView.getItemTextOf(1,1)]
      arg << @inspectView.getItemTextOf(2,1).to_i
      arg << @inspectView.getItemTextOf(3,1).to_i
      arg = arg + [24,24]
      4.upto(n-1){|i|
        s0 = @inspectView.getItemTextOf(i,0)
        s1 = @inspectView.getItemTextOf(i,1)
        s2 = @inspectView.getItemTextOf(i,2)
        if  s2 == "numnil"
          s = (s1 =~ /^\d+$/) ?  s1 : "nil"
          arg << ["self."+s0,s]
        elsif s2 == ""
          s = (s1 =~ /^\d+$/) ?  s1 : s1.inspect
          arg << [ "@" + s0,s]
        elsif s2 == "num"
          s = (s1 =~ /^\d+$/) ?  s1 : "0"
          arg << ["self."+s0,s]
        elsif !(s2 == "nil") && !(s2 =~ /^_.*/)
          s = (s1 =~ /^[+-]?\d+\.?\d*$/) ?  s1 : s1.inspect
          arg <<  [s2,s]
        else
        end
      } if n > 4
    else
      arg = [@inspectView.getItemTextOf(0,1),@inspectView.getItemTextOf(1,1)]
      2.upto(5){|i|
        arg << @inspectView.getItemTextOf(i,1).to_i
      }
      6.upto(n-1){|i|
        s0 = @inspectView.getItemTextOf(i,0)
        s1 = @inspectView.getItemTextOf(i,1)
        s2 = @inspectView.getItemTextOf(i,2)
        if  s2 == "numnil"
          s = (s1 =~ /^\d+$/) ?  s1 : "nil"
          arg << ["self."+s0,s]
        elsif s2 == ""
          s = (s1 =~ /^\d+$/) ?  s1 : s1.inspect
          arg << [ "@_" + s0,s]
        elsif s2 == "num"
          s = (s1 =~ /^\d+$/) ?  s1 : "0"
          arg << ["self."+s0,s]
        elsif !(s2 == "nil") && !(s2 =~ /^_.*/)
          s = (s1 =~ /^[+-]?\d+\.?\d*$/) ?  s1 : s1.inspect
          arg <<  [s2,s]
        else
        end
      } if n > 6
    end
    @parent.designfrm.update_target(*arg)
  end

  def self_activate(wParam,hwnd)
    @inspectView.hideAllContorls if LOWORD(wParam) == 0
  end

  def self_resize(w,h)
    a=windowrect
    @tab1.move(0,20,w,20)
    @cbControl.move(0,0,w,200)
    @evtList.move(0,40,w,h-60)
    @mthdList.move(0,40,w,h-60)
    @inspectView.move(0,40,w,h-60)
    $ini.write "inspect","top",a[1]
    $ini.write "inspect","left",a[0]
    $ini.write "inspect","width",a[2]
    $ini.write "inspect","height",a[3]
  end

  def tab1_selchanged
    case @tab1.selectedTab
    when 0
      @evtList.visible=false
      @mthdList.visible=false
      @inspectView.visible=true
    when 1
      @evtList.visible=true
      @mthdList.visible=false
      @inspectView.visible=false
    when 2
      @mthdList.visible=true
      @evtList.visible=false
      @inspectView.visible=false
    end
    @stb2.caption = ""
  end

  def self_destroy
    a=windowrect
    $ini.write "inspect","x",a[0]
    $ini.write "inspect","y",a[1]
    $ini.write "inspect","w",a[2]
    $ini.write "inspect","h",a[3]
    $ini.write "inspect","viewCol_0",@inspectView.getColumnWidthOf(0)
    $ini.write "inspect","viewCol_1",@inspectView.getColumnWidthOf(1)
    parent.inspectShow.checked = false
    @controls.each{|i,c| 
      deleteControl(c)
    }
    $ini.flash
  end

  def self_close
    SKIP_DEFAULTHANDLER
  end

  def setItems(a)
    @inspectView.clearItems
    a.each do |item|
      @inspectView.addItem(item)
    end
  end
  
  
  def evtList_selchanged
    if tt=@evtList.getTextOf(@evtList.selectedString)
      unless (tt=~/^self_\w+/) || (@skip_ctrl_name) || (tt=~/^ownerdraw.+/)
        ctl = @parent.designfrm.focused
        nm = ""
        if !ctl
          nm = "self_"
        elsif (prnt=ctl.parent).modules.index(VRMessageParentRelayer)
          nm = prnt.name + '_' + ctl.name + '_'
          while (prnt=prnt.parent).modules.index(VRMessageParentRelayer)
            nm[0,0] =  prnt.name + '_'
          end
        else
          nm = ctl.name + '_'
        end
      end
      tt="  def #{nm}#{tt}\n  \n  end\n\n"
      @stb2.caption = "Copied to ClipBoard"
      clb1=Clipboard.open(self.hWnd)
      clb1.setText(tt)
      clb1.close
    end
  end
  
  def evtList_dblclicked
    parent.show_editor
  end
   
  def mthdList_selchanged
    if t=@mthdList.getTextOf(@mthdList.selectedString) then
      if @parent.designfrm.focused.class == FDContainer then
        tt = @parent.designfrm.focused.createMthodStr(t)
      elsif !@parent.designfrm.focused
        n=@parent.designfrm.name.capitalize1
        case t
        when 'modelessform'
          if @parent.designfrm.type_of_form == VRModelessDialog
            tt=FDSources::StartOfMdlsDlg
          else
            tt=FDSources::StartOfModeless
          end
          tt += n + FDSources::StartOfModeless2
        when 'start'
          tt = FDSources::StartOfForm + n
        when 'openModalDialog','openModelessDialog'
          tt = "@screen.#{t}(self,nil,#{n})"
        else
          tt = t
        end
      else
        n = @parent.designfrm.focused.name
        case t
        when /(\A[a-z_]\w*)\s*=\s*(.+)/
          t1 = $1; t2 = "="
        when /(\A[a-z_]\w*)\s*(\(.*\))/
          t1 = $1; t2 = $2  #"(#{$2.gsub(/[^,]/,"")})" which do you like?
        when /(\A[a-z_]\w*)/
          t1 = $1 ; t2 = ""
        end
        tt="@#{n}.#{t1}#{t2}"
      end
      @stb2.caption = "Copied to ClipBoard"
      clb1=Clipboard.open(self.hWnd)
      clb1.setText(tt)
      clb1.close
    end
  end
  
  def mthdList_dblclicked
    parent.show_editor
  end

  def cbControl_selchanged
    @inspectView.hideAllContorls
    s=@cbControl.getTextOf(@cbControl.selectedString).sub(/(.+):.+/,'\1')
    @parent.designfrm.changeFocuse(s)
  end
  
  def self_move(x,y)
    if $ini.read("settings","dock",'true')=='true' then
      sx,sy,sw,sh=self.windowrect
      px,py,pw,ph=parent.windowrect
      self.move(px,py+ph,sw,sh)
    end
  end
end

