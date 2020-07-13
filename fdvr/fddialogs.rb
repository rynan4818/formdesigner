# fddialogs.rb
# Dialogs for formdesigner
#
# Programmed by yukimi_sake@mbi.nifty.com
# Copyright 2001-2003 Yukio Sakaue

require 'vr/vruby'
require 'vr/vrdialog'
require 'vr/vrcomctl'
require 'vr/vrhandler'
require 'vr/vrowndraw'
require 'fdvr/fdwin32'
require 'fdvr/fdresources'
require 'vr/contrib/vrctlcolor'

include SWin
include User32
include GDI32

module DrawFrameConst
  DFC_CAPTION = 1
  DFC_MENU = 2
  DFC_SCROLL = 3
  DFC_BUTTON = 4
  DFCS_CAPTIONCLOSE = 0
  DFCS_CAPTIONMIN = 1
  DFCS_CAPTIONMAX = 2
  DFCS_CAPTIONRESTORE = 3
  DFCS_CAPTIONHELP = 4
  DFCS_MENUARROW = 0
  DFCS_MENUCHECK = 1
  DFCS_MENUBULLET = 2
  DFCS_MENUARROWRIGHT = 4
  DFCS_SCROLLUP = 0
  DFCS_SCROLLDOWN = 1
  DFCS_SCROLLLEFT = 2
  DFCS_SCROLLRIGHT = 3
  DFCS_SCROLLCOMBOBOX = 5
  DFCS_SCROLLSIZEGRIP = 8
  DFCS_SCROLLSIZEGRIPRIGHT = 16
  DFCS_BUTTONCHECK = 0
  DFCS_BUTTONRADIOIMAGE = 1
  DFCS_BUTTONRADIOMASK = 2
  DFCS_BUTTONRADIO = 4
  DFCS_BUTTON3STATE = 8
  DFCS_BUTTONPUSH = 16
  DFCS_INACTIVE = 256
  DFCS_PUSHED = 512
  DFCS_CHECKED = 1024
  DFCS_ADJUSTRECT = 0x2000
  DFCS_FLAT = 0x4000
  DFCS_MONO = 0x8000
end

module EditMsgConst
  EM_CANUNDO = 198
  EM_CHARFROMPOS = 215
  EM_EMPTYUNDOBUFFER = 205
  EM_FMTLINES = 200
  EM_GETFIRSTVISIBLELINE = 206
  EM_GETHANDLE = 189
  EM_GETLIMITTEXT = 213
  EM_GETLINE = 196
  EM_GETLINECOUNT = 186
  EM_GETMARGINS = 212
  EM_GETMODIFY = 184
  EM_GETPASSWORDCHAR = 210
  EM_GETRECT = 178
  EM_GETSEL = 176
  EM_GETTHUMB = 190
  EM_GETWORDBREAKPROC = 209
  EM_LIMITTEXT = 197
  EM_LINEFROMCHAR = 201
  EM_LINEINDEX = 187
  EM_LINELENGTH = 193
  EM_LINESCROLL = 182
  EM_POSFROMCHAR = 214
  EM_REPLACESEL = 194
  EM_SCROLL = 181
  EM_SCROLLCARET = 183
  EM_SETHANDLE = 188
  EM_SETLIMITTEXT = 197
  EM_SETMARGINS = 211
  EM_SETMODIFY = 185
  EM_SETPASSWORDCHAR = 204
  EM_SETREADONLY = 207
  EM_SETRECT = 179
  EM_SETRECTNP = 180
  EM_SETSEL = 177
  EM_SETTABSTOPS = 203
  EM_SETWORDBREAKPROC = 208
  EM_UNDO = 199
  EN_CHANGE = 768
  EN_ERRSPACE = 1280
  EN_HSCROLL = 1537
  EN_KILLFOCUS = 512
  EN_MAXTEXT = 1281
  EN_SETFOCUS = 256
  EN_UPDATE = 1024
  EN_VSCROLL = 1538
end

module ListBoxDlgMessage

  def bt_checked?(id)
    SendDlgItemMessage.call(self.hWnd,id,WMsg::BM_GETCHECK,0,0)
  end

  def bt_setcheck(id)
    SendDlgItemMessage.call(self.hWnd,id,WMsg::BM_SETCHECK,0,0)
  end

  def lb_addString(id,str)
    SendDlgItemMessage2.call(self.hWnd,id,WMsg::LB_ADDSTRING,0,str)
  end
  def lb_insertString(id,nStart,nEnd)
    SendDlgItemMessage2.call(self.hWnd,id,WMsg::LB_INSERTSTRING,nStart,nEnd)
  end
  def lb_getcount(id)
    SendDlgItemMessage.call(self.hWnd,id,WMsg::LB_GETCOUNT,0,0)
  end
  def lb_getsel(id,index)
    SendDlgItemMessage.call(self.hWnd,id,WMsg::LB_GETSEL,index,0)
  end
  def lb_findsel(id)
    lb_getcount(id)
    r = nil
    for i in 0..lb_getcount(id)-1
      unless lb_getsel(id,i) == 0 then
        r = i ; break
      end
    end
    r
  end

  def lb_gettext(id,idx)
    str=" " * SendDlgItemMessage.call(self.hWnd,id,WMsg::LB_GETTEXTLEN,idx.to_i,0)
    SendDlgItemMessage2.call(self.hWnd,id,WMsg::LB_GETTEXT,idx.to_i,str)
    str
  end
  def lb_getitemdata(id,index)
    SendDlgItemMessage.call(self.hWnd,id,WMsg::LB_GETITEMDATA,index,0)
  end
  def lb_setitemdata(id,index,data)
    SendDlgItemMessage.call(self.hWnd,id,WMsg::LB_SETITEMDATA,index,data)
  end
  def lb_replacesel(id,str)
    SendDlgItemMessage2.call(self.hWnd,id,WMsg::EM_REPLACESEL,0,str)
  end
  def lb_setlistStrings(id,a)
    a.each{|i|
      lb_addString(id,i)
    }
  end
  def lb_getlistStrings(id)
    n=lb_getcount(id) ; r = []
    for i in 0 .. n-1
      r << lb_gettext(id,i)
    end
    r
  end

  def cb_addString(id,str)
    SendDlgItemMessage2.call(self.hWnd,id,WMsg::CB_ADDSTRING,0,str)
  end
  def cb_insertString(id,nStart,nEnd)
    SendDlgItemMessage2.call(self.hWnd,id,WMsg::CB_INSERTSTRING,nStart,nEnd)
  end
  def cb_getcount(id)
    SendDlgItemMessage.call(self.hWnd,id,WMsg::CB_GETCOUNT,0,0)
  end
  def cb_getsel(id,index)
    SendDlgItemMessage.call(self.hWnd,id,WMsg::CB_GETSEL,index,0)
  end
  def cb_getitemdata(id,index)
    SendDlgItemMessage.call(self.hWnd,id,WMsg::CB_GETITEMDATA,index,0)
  end
  def cb_setitemdata(id,index,data)
    SendDlgItemMessage.call(self.hWnd,id,WMsg::CB_SETITEMDATA,index,data)
  end
  def cb_selectedString(id)
    SendDlgItemMessage.call(self.hWnd,id,WMsg::CB_GETCURSEL,0,0)
  end

  def cb_select(id,idx)
    SendDlgItemMessage.call(self.hWnd,id,WMsg::CB_SETCURSEL,idx,0)
  end

end

class OwnerDrawModalDlg < VRModalDialog

  WM_DRAWITEM = 0x002B

  def OwnerDrawModalDlg.new(screen,template)
    r=screen.factory.newdialog(template.to_template,self)
    r.parentinit(screen)
    r.options={}
    r.addEvent WMsg::WM_INITDIALOG
    r.addEvent WMsg::WM_COMMAND
    r.addEvent WM_DRAWITEM
    return r
  end
end

class ListBoxDlg < OwnerDrawModalDlg #style Dialog
  include ListBoxDlgMessage
  include DrawFrameConst

  def msghandler(msg)
    case msg.msg
    when WMsg::WM_INITDIALOG
      setListTextData(@options["target"],@options["default"]) if
                                                          @options["target"]
      setCBTextData(@options["target2"],@options["default2"]) if
                                                          @options["target2"]
    when WMsg::WM_COMMAND
      if msg.wParam == @options["okbutton"] then
        close self.getListTextData(@options["target"],@options["target2"])
      elsif msg.wParam==@options["cancelbutton"] then
        close false
      elsif msg.wParam==@options["helpbutton"]
        @parent.parent.class::SDKDocument.DisplayTopicFromURL(
                                  FDSDK::DE_Prefix +  FDSDK::WND_STYLE_DOC)
      elsif HIWORD(msg.wParam) == WMsg::LBN_SELCHANGE &&
                             LOWORD(msg.wParam) == @options["target"] then
        lb_selchange(LOWORD(msg.wParam))
      elsif HIWORD(msg.wParam) == WMsg::CBN_SELCHANGE &&
                             LOWORD(msg.wParam) == @options["target2"] then
        cb_selchange(LOWORD(msg.wParam))
      end
    when WM_DRAWITEM
      drawitem(SWin::Application.cstruct2array(msg.lParam,'UUUUUUUUUUUU'))
    end
  end

  def setListTextData(id,a)
    n = 0
    a.each{|i|
      lb_addString(id,i[0])
      lb_setitemdata(id,n,i[1])
      n += 1
    }
  end

  def setCBTextData(id,a)
    n = 0
    sel = a.shift
    a.each{|i|
      cb_addString(id,i[0])
      cb_setitemdata(id,n,i[1])
      n += 1
    }
    cb_select(id,sel)
  end

  def getListTextData(id1,id2)
    r = []
    r << cb_getitemdata(id2,cb_selectedString(id2)) if @options["target2"]
    for i in 0..lb_getcount(id1)-1
      r << [lb_gettext(id1,i),lb_getitemdata(id1,i)]
    end
    r
  end

  def lb_selchange(id)
     sel=lb_findsel(id)
   unless  lb_getitemdata(id,sel) == 1 then
    lb_setitemdata(id,sel,1)
   else
    lb_setitemdata(id,sel,0)
   end
   self.refresh
  end

  def drawitem(args)
    hdc=args[6];l=args[7];t=args[8];i=args[2];id=args[1]
    SetBkMode.call(hdc,1)
    a = [2,t+1,16,t+15].pack("LLLL")
    if lb_getitemdata(id,i) == 1 then
      DrawFrameControl.call(hdc,a,DFC_BUTTON,DFCS_BUTTONCHECK | DFCS_CHECKED )
    else
      DrawFrameControl.call(hdc,a,DFC_BUTTON,DFCS_BUTTONCHECK)
    end
    s = lb_gettext(id,i)
    TextOut.call(args[6],l+20,t+0,s,s.size)
  end

  def cb_selchange(id)
    #p "cb_selchage"
  end

end


class StyleDlg < VRModalDialog
  @@args = nil
  def self.args=(args) @@args = args end
  include VRContainersSet
  
  DEFAULT_FONT=VRLocalScreen.factory.newfont('Terminal',-13,0,4,0,0,0,1,128)
  def construct
    self.caption = 'Styles'
    self.move(140,124,194,400)
    addControl(VRButton,'btOHelp',"?",128,328,56,20)
    addControl(ListBox1,'listBox1',"listBox1",0,24,184,305,0x50)
    addControl(VRCombobox,'comboBox1',"",0,0,186,80)
    addControl(VRButton,'btOK',"O  K",0,352,72,20)
    addControl(VRButton,'btCancel',"Cancel",112,352,72,20)
    addControl(VRButton,'btCHelp',"?",52,328,72,20)
    addControl(VRButton,'btWHelp',"WStyle?",0,328,48,20)
  end 
  
  def self_created
    setButtonAs(@btOK,IDOK)
    setButtonAs(@btCancel,IDCANCEL)
    @klass,aitems, aoptions, @toggle = *@@args
    @@args = nil
    if FDSDK::CTL_STYLE_DOC[@klass]
      @btCHelp.caption = @klass.name.sub(/^VR/,'') + '?'
    else
       @btCHelp.hide
    end
    aitems.each_with_index{|i, j|
      @listBox1.addString i[0]
      @listBox1.setDataOf j, i[1]
    }
    if aoptions && aoptions.size > 1
      pos = aoptions.shift
      aoptions.each_with_index{|i, j|
        @comboBox1.addString i[0]
        @comboBox1.setDataOf j, i[1]
      }
       @comboBox1.select pos
    else
      @comboBox1.hide
      @btOHelp.hide
      @listBox1.move 0,0,184,330
    end
    toggle_string0(*@toggle) if @toggle
  end
  
  def listBox1_selchanged
    if @listBox1.getDataOf(@listBox1.selectedString) == 0
      @listBox1.setDataOf(@listBox1.selectedString, 1)
    else
      @listBox1.setDataOf(@listBox1.selectedString, 0)
    end
    toggle_string(*@toggle) if @toggle &&
                      @listBox1.getTextOf(@listBox1.selectedString) == @toggle[0]
    @listBox1.refresh
  end
  
  def toggle_string0(key,normal,alt)
    n = @listBox1.findString(key)
    if @listBox1.getDataOf(n) == 0
      pos = @listBox1.findString(alt)
      @listBox1.deleteString(pos)
    else
      pos = @listBox1.findString(normal)
      @listBox1.deleteString(pos)
    end
  end
  
  def toggle_string(key,normal,alt)
    n = @listBox1.findString(key,0)
    if @listBox1.getDataOf(n) == 0
      pos = @listBox1.findString(alt,0)
      @listBox1.deleteString(pos)
      @listBox1.addString(pos,normal)
    else
      pos = @listBox1.findString(normal,0)
      @listBox1.deleteString(pos)
      @listBox1.addString(pos,alt)
    end
  end
  
  def btOK_clicked
    r = []
    r << @comboBox1.getDataOf(@comboBox1.selectedString)
    0.upto(@listBox1.countStrings-1){|i|
      r << [@listBox1.getTextOf(i),@listBox1.getDataOf(i)]
    }
    close r
  end
  
  def btCancel_clicked
    close nil
  end

  def btWHelp_clicked
    @parent.parent.class::SDKDocument.DisplayTopicFromURL(
                                  FDSDK::DE_Prefix +  FDSDK::WND_STYLE_DOC)
  end
  
  def btCHelp_clicked
    @parent.parent.class::SDKDocument.DisplayTopicFromURL(
                           FDSDK::DE_Prefix +  FDSDK::CTL_STYLE_DOC[@klass])
  end
  
  class ListBox1 < VRListbox
    include GDI32
    include User32
    include DrawFrameConst
    def ownerdraw(iid,action,state,hwnd,hdc,left,top,right,bottom,data)
      SetBkMode.call(hdc,1)
      a = [2,top+2,14,top+14].pack("LLLL")
      if self.getDataOf(iid) == 1 then
        DrawFrameControl.call(hdc,a,DFC_BUTTON,DFCS_BUTTONCHECK | DFCS_CHECKED )
      else
        DrawFrameControl.call(hdc,a,DFC_BUTTON,DFCS_BUTTONCHECK)
      end
      s = self.getTextOf(iid)
      TextOut.call(hdc,left+20,top+0,s,s.size)
    end
  end
end

class PrDlg < VRModalDialog # for preferences Dialog
  include VRCommonDialog

  def msghandler(msg)
    if msg.msg == WMsg::WM_INITDIALOG then
      self.setItemTextOf(@options["target"],@options["default"].to_s)
      self.setItemTextOf(@options["target2"],@options["default2"].to_s)
      self.bt_check(@options["checkbox"],@options["check"])
    end

    if msg.msg == WMsg::WM_COMMAND then
      if msg.wParam==@options["okbutton"] then
        close [
          self.getItemTextOf(@options["target"]),
          self.getItemTextOf(@options["target2"]) ,
          self.bt_checked?(@options["checkbox"])
        ]
      elsif msg.wParam==@options["cancelbutton"] then
        close false
      elsif msg.wParam==@options["browsebutton"] then
        if @editpath=openFilenameDialog([["Editor","*.exe"]]) then
          self.setItemTextOf(@options["target2"],@editpath.to_s)
        end
      end
    end
  end
  
  def bt_checked?(id)
    SendDlgItemMessage.call(self.hWnd,id,WMsg::BM_GETCHECK,0,0) == 1 ? true : false
  end
  
  def bt_check(id,v)
    SendDlgItemMessage.call(self.hWnd,id,WMsg::BM_SETCHECK,((v) ? 1 : 0),0)
  end

end

module EditDlgMsg
  include EditMsgConst
  def ed_getSel
    r = SendDlgItemMessage.call self.hWnd,@id,EM_GETSEL,0,0
    return LOWORD(r),HIWORD(r)
  end
  
  def ed_setSel(st,en,noscroll=0)
    SendDlgItemMessage.call self.hWnd,@id,EM_SETSEL,st,en
  end
  
  def ed_setCaret(r)
    ed_setSel(r,r)
  end
  
  def ed_replaceSel(newstr)
    SendDlgItemMessage2.call self.hWnd,@id,EM_REPLACESEL,0,newstr.to_s
  end
  
  def ed_text
    r = ""
    SendDlgItemMessage2.call self.hWnd,@id,WMsg::WM_GETTEXT,2,r
    r
  end

end

=begin
class ArrayEditDialog < VRModalDialog #for menu editor and toolbar editor
  include EditMsgConst
  include EditDlgMsg
  
  def initialize
    super
  end
  
  def msghandler(msg)
    case msg.msg
    when WMsg::WM_INITDIALOG
      setItemTextOf(@options["target"],@options["default"])
      @buff = @options["default"]
      @buff0 = @buff.dup
    when WMsg::WM_COMMAND
      if msg.wParam == @options["okbutton"] then
        close self.getItemTextOf(@options["target"])
      elsif msg.wParam==@options["cancelbutton"] then
        close false
      elsif HIWORD(msg.wParam) == EN_CHANGE  &&
                             LOWORD(msg.wParam) == @options["target"] then
        @id = @options["target"]
        ed_changed unless @supplaceMsg
        @supplaceMsg = nil
      end
    else
    end
  end
  
  def ed_changed
    @buff = self.getItemTextOf(@id)
    if @buff.size-@buff0.size == 1 then
      @supplaceMsg = true
      n=ed_getSel[0]
      case @buff[n-1]
      when '"'[0] 
        ed_replaceSel('"')
      when "'"[0]
        ed_replaceSel("\'")
      when '['[0]
        ed_replaceSel(']')
      end
      ed_setCaret n
    elsif @buff.size-@buff0.size == 2
      @supplaceMsg = true
      n=ed_getSel[0]
      case @buff[n-1]
      when 10
        astr =get_prev_line(n)
        @indent = 0
        @indent = astr[/^ */].size if astr
        s = " " * @indent
        if @buff[n-2] == 13 && @buff[n-3] == '['[0] && @buff[n] == ']'[0] then
          ed_replaceSel "#{s}  \r\n#{s}"
          n += 2 + @indent
        else
          ed_replaceSel(s); n += @indent
        end
      end
      ed_setCaret n
    end
    @buff0 = self.getItemTextOf(@id)
  end
  
  def get_prev_line(n)
    return if n == 0
    i0 = -1
    (n-3).downto(0){|i| if @buff[i] == 10 then i0 = i; break; end}
    if i0 < n-3 then @buff[i0+1..n-3] else nil end
  end
  
end
=end

class ExamineModalDlg < VRModalDialog
  include VRStdControlContainer

  def vrinit
    super
    target = @options["target"]
  end

  def msghandler(msg)
    if msg.msg == WMsg::WM_INITDIALOG then
      self.setItemTextOf(@options["target"],@options["default"].to_s)
    end

    if msg.msg == WMsg::WM_COMMAND then
      if msg.wParam==@options["okbutton"] then
        close true
      elsif msg.wParam==@options["cancelbutton"] then
        close false
      end
    end
  end
end

class EDListview < VRListview
  class InplaceEdit < VREdit
    include VRKeyFeasible
    include VRFocusSensitive

    def self_char(ch,data)
      case ch
      when 13
        @parent.update
      end
    end
    
    def self_lostfocus
      @parent.update
    end
  end
  
  include VRParent
  include VRStdControlContainer
  include VRMouseFeasible
  attr :ed,1
  attr :fixfirstcolumn,1
    
  def construct
    @font= @screen.factory.newfont("ms gothic",14)
    self.setFont(@font)
    self.reportview
    addControl(InplaceEdit,'ed','')
    @ed.setFont(@font)
    @ed.hide
  end
  
  def hittest3(x,y)
    idx = hittest2(x,y)[3]
    w=0;left=0;cw=0
    subitem = 0.upto(countColumns-1){|i| 
      left=w 
      cw=getColumnWidthOf(i)
      break(i) if (w+=cw) > x 
    }
    l1,top,right,bottom = getItemRect(idx)
    [idx,subitem,left,top,cw,bottom-top]
  end
  
  def self_lbuttondown(shift,x,y)
    @ed.hide
    @idx,@subitem,left,top,width,height = *hittest3(x,y)
    selectItem(@idx,false)
    return if @fixfirstcolumn && @subitem==0
    @ed.move(left-1,top-1,width+2,height+2)
    @ed.text=getItemTextOf(@idx,@subitem)
    @ed.show
    @ed.focus
    refresh
  end
  
  def update    
    setItemTextOf(@idx,@subitem,@ed.text)
  end
  
end

class ItemEditDlg < VRModalDialog
  include VRComCtlContainer
  include VROwnerDrawControlContainer
  attr :position,1
  POS=[]
  ADDREMOVE=[] #enable add&remove
  FIXCOLUMN=[]
  TITLES=[]
  ITEMS=[]
  ADDINGNAME=[]
  UPDOWN=[]
  STYLES=[]
  LISTWIDTH=[392]
  DEFAULTSTR = ['']
  def _itemEdit_init
    font = @screen.factory.newfont "Terminal",-13,0,0,0,0,0,1,128,100,0
    self.caption = 'ItemEditor'
    self.move(POS[0][0],POS[0][1],POS[0][2],POS[0][3])
    addControl(EDListview,'listView1','listView1',0,0,LISTWIDTH[0],240,12)
    addControl(VRButton,'btOk','O  K',226,246,80,24)
    addControl(VRButton,'btCan','Cancel',312,246,80,24)
    addControl(VRButton,'btAdd','Add',0,246,80,24) if ADDREMOVE[0]
    addControl(VRButton,'btRemove','Remove',86,246,80,24) if ADDREMOVE[0]
    addControl(Bt_UP,'btUP','',170,246,24,24)
    addControl(Bt_DN,'btDN','',198,246,24,24)
    addArrayedControl(0,VRRadiobutton,'radioBtn',STYLES[0][0],260,32,160,24).setFont(font) if 
                                                                      STYLES[0]&&STYLES[0][0]
    addArrayedControl(1,VRRadiobutton,'radioBtn',STYLES[0][1],260,56,160,24).setFont(font) if
                                                                      STYLES[0]&&STYLES[0][1]
    addArrayedControl(2,VRRadiobutton,'radioBtn',STYLES[0][2],260,80,160,24).setFont(font) if
                                                                      STYLES[0]&&STYLES[0][2]
    addArrayedControl(3,VRRadiobutton,'radioBtn',STYLES[0][3],260,104,160,24).setFont(font) if
                                                                       STYLES[0]&&STYLES[0][3]
    addArrayedControl(4,VRRadiobutton,'radioBtn',STYLES[0][4],260,128,160,24).setFont(font)if 
                                                                       STYLES[0]&&STYLES[0][4]
    addArrayedControl(5,VRRadiobutton,'radioBtn',STYLES[0][5],260,128,160,24).setFont(font)if
                                                                       STYLES[0]&&STYLES[0][5]
    @current_pos = 0
  end

  def construct
    _itemEdit_init
    @listView1.lvexstyle=ADDREMOVE[0]? 33 : 1
    @listView1.reportview
    TITLES[0].each{|i|
      @listView1.addColumn(i[0],i[1])
    }
    0.upto(ITEMS[0].size-1){|i|
      @listView1.addItem(ITEMS[0][i])
    }
    @listView1.fixfirstcolumn=FIXCOLUMN[0]
    @btUP.visible = UPDOWN[0]
    @btDN.visible = UPDOWN[0]
  end
  
  def btOk_clicked
    a=[]
    0.upto(@listView1.countItems-1){|i|
      a1=[]
      0.upto(@listView1.countColumns-1){|j|
        a1 << @listView1.getItemTextOf(i,j)
      }
      a << a1
    }
    @parent._return_val = a
    close 0
  end
  
  def btCan_clicked
    close 1
  end
  
  def btAdd_clicked
    if ADDINGNAME[0] == 'tab' then
      s = ADDINGNAME[0] + (@listView1.countItems+1).to_s
    else
      s = @parent.get_serial_name(ADDINGNAME[0]+'1')
    end
    @listView1.selectItem(@listView1.focusedItem,false)
    @listView1.addItem([DEFAULTSTR[0],s])
    @listView1.setItemStateOf(@listView1.countItems-1,1)
    @listView1.selectItem(@listView1.countItems-1,true)
  end
  
  def btRemove_clicked
    @listView1.deleteItem(@listView1.focusedItem)
    @listView1.setItemStateOf(@listView1.focusedItem,
                              WConst::LVIS_SELECTED|WConst::LVIS_FOCUSED)
  end
  
  def listView1_itemchanged(idx,state)
    @current_pos=@listView1.countItems-1-idx
    n = STYLES[0].index(@listView1.getItemTextOf(idx,0)) if STYLES[0]
    @radioBtn.each{|i| i.check false} if @radioBtn
    @radioBtn[n].check true if n 
  end

  def btUP_clicked
    s = []
    @listView1.ed.hide
    nf = @listView1.focusedItem
    return if nf == 0
    0.upto(@listView1.countColumns-1){|i| s << @listView1.getItemTextOf(nf-1,i)}
    @listView1.insertItem(nf+1,s)
    @listView1.deleteItem(nf-1)
  end

  def btDN_clicked
    s = []
    @listView1.ed.hide
    nf = @listView1.focusedItem
    return if nf == @listView1.countItems-1
    @listView1.selectItem(nf,false)
    0.upto(@listView1.countColumns-1){|i| s << @listView1.getItemTextOf(nf,i)}
    @listView1.insertItem(nf+2,s)
    @listView1.deleteItem(nf)
    @listView1.setItemStateOf(nf+1,WConst::LVIS_SELECTED|WConst::LVIS_FOCUSED)
  end
  
  def radioBtn_clicked(n)
    @listView1.setItemTextOf(@listView1.focusedItem,0,@radioBtn[n].caption) if 
                                     @listView1.focusedItem > -1
  end
  
end

class MenuAnalizer
  attr :colCount
  def maxCol(n)
    @colCount = n if n > colCount
  end
  
  def __analize(ar)
    ar.each{|i|
      if i[1].is_a? Array then
        a = [[""]*@n,i[0].gsub(/\t/,'\t')].flatten
        @ar << a
        @colCount = a.size if a.size > @colCount
        @n += 1
        __analize(i[1])
      else
        a = [[""]*@n,i].flatten.select{|i| i .is_a? String}.collect{|i| i.gsub /\t/,'\t'}
        @colCount = a.size if a.size > @colCount
        @ar << a
      end
    }
    @n -= 1
  end
  
  def analize(ar)
    @ar=[]
    @n = 0
    @colCount=0
    __analize(ar)
    @ar
  end
  
  def __unanalize(s,level=0)
    r = []
    i = 0
    while(i < s.size) do
      l0 = 0
      data=[]
      flag0=nil
      s[i].each{|j|
        if j=="" then
          unless flag0 then l0 += 1 else break end
        else
          data << j.sub(/\\t/,"\t") if j
          flag0 = true
        end
      }
      case l0 <=> level
      when -1
        return r,i-1
      when 0
        if data == ["sep","_vrmenusep"] then 
          r << ["sep","_vrmenusep",2048]
        else
          r << data
        end
      when 1
        a = __unanalize(s[i,s.size-i],l0)
        r.last << a[0]
        i += a[1]
      end
      i += 1
    end #while
    [r,i]
  end
  
  def unanalize(ar)
    __unanalize(ar,0)[0]
  end
  
end

class Bt_UP < VROwnerDrawButton
  
  def drawpushed(left,top,right,bottom,state)
    rect=[left,top,right,bottom].pack("iiii")
    DrawFrameControl.call(hdc,rect,4,0x210)
    drawBitmap(OwnerDrawBtnBmp::BmpUP,5,5)
  end
  
  def drawreleased(left,top,right,bottom,state)
    rect=[left,top,right,bottom].pack("iiii")
    DrawFrameControl.call(hdc,rect,4,0x10)
    drawBitmap(OwnerDrawBtnBmp::BmpUP,4,4)
  end
  
end

class Bt_DN < VROwnerDrawButton
    def drawpushed(left,top,right,bottom,state)
      rect=[left,top,right,bottom].pack("iiii")
      DrawFrameControl.call(hdc,rect,4,0x210)
      drawBitmap(OwnerDrawBtnBmp::BmpDN,5,5)
    end
    
    def drawreleased(left,top,right,bottom,state)
      rect=[left,top,right,bottom].pack("iiii")
      DrawFrameControl.call(hdc,rect,4,0x10)
      drawBitmap(OwnerDrawBtnBmp::BmpDN,4,4)
    end
end

class MnEDListview < EDListview
  attr :level
  attr :items
  attr :ed
  def getItemsAttr(idx)
    items = []
    level = 0
    flag0 = nil
    0.upto(countColumns-1){|i|
      if s=getItemTextOf(idx,i) == "" then
        break if flag0
        level += 1
      else
        items << getItemTextOf(idx,i)
        flag0 = true
      end
    }
    [items,level]
  end
  
  def updateTitle(idx)
     @items,@level=getItemsAttr(idx)
    if @items.size > 1 then
      0.upto(countColumns-1){|i|
        if i == @level then 
          s = 'Item Caption' 
        elsif i == @level+1
          s = 'Item Event' 
        else s = '' end
        setColumnTextOf(i,s)
      }
    else
      0.upto(countColumns-1){|i|
        if i == @level then s = 'Menu Caption' else s = '' end
        setColumnTextOf(i,s)
      }
    end
  end
  
  def self_lbuttondown(shift,x,y)
    @items = []
    @level=0
    flag0 = nil
    @ed.hide
    @idx,@subitem,left,top,width,height = *hittest3(x,y)
    updateTitle(@idx)
    return if @subitem < @level or @subitem >= @level + @items.size 
    selectItem(@idx,false)
    return if @fixfirstcolumn && @subitem==0
    @ed.move(left-1,top-1,width+2,height+2)
    @ed.text=getItemTextOf(@idx,@subitem)
    @ed.show
    @ed.focus
    refresh
  end
end

class MenuEditDlg < VRModalDialog
  include VRComCtlContainer
  include VROwnerDrawControlContainer
  attr :position,1
  POS=[[100,100,464,250]]
  FIXCOLUMN=[]
  TITLES=[]
  ITEMS=[]
  ADDINGNAME=[]
  UPDOWN=[]
  STYLES=[]
  LISTWIDTH=[460]
  def _itemEdit_init
    font = @screen.factory.newfont "Terminal",-13,0,0,0,0,0,1,128,100,0
    self.caption = 'ItemEditor'
    self.move(POS[0][0],POS[0][1],POS[0][2],POS[0][3])
    addControl(MnEDListview,'listView1','listView1',0,0,LISTWIDTH[0],240,12)
    addControl(VRButton,'btAddMnu','AddMnu',0,246,64,24)
    addControl(VRButton,'btAddItm','AddItm',68,246,64,24)
    addControl(VRButton,'btAddSep','AddSep',136,246,64,24)
    addControl(VRButton,'btRemove','Remove',204,246,64,24)
    addControl(Bt_UP,'btUP','',272,246,24,24)
    addControl(Bt_DN,'btDN','',298,246,24,24)
    addControl(VRButton,'btOk','O  K',326,246,64,24)
    addControl(VRButton,'btCan','Cancel',394,246,64,24)
  end

  def construct
    _itemEdit_init
    @listView1.lvexstyle=33
    @listView1.reportview
    TITLES[0].each{|i|
      @listView1.addColumn(i[0],i[1])
    }
    0.upto(ITEMS[0].size-1){|i|
      @listView1.addItem(ITEMS[0][i])
    }
    @listView1.fixfirstcolumn=FIXCOLUMN[0]
  end

  def btOk_clicked
    a=[]
    0.upto(@listView1.countItems-1){|i|
      a1=[]
      0.upto(@listView1.countColumns-1){|j|
        a1 << @listView1.getItemTextOf(i,j)
      }
      a << a1
    }
    @parent._return_val = a
    close 0
  end
  
  def btCan_clicked
    close 1
  end
  
  def find_next(pos)
    pos1 = pos2 = nil
    l1 = i1 = nil
    pos.upto(@listView1.countItems-1){|i|
      itm,lvl=@listView1.getItemsAttr(i)
      if @listView1.level > lvl then
        return pos,nil
      elsif @listView1.level == lvl
        pos1 = i
        if itm.size > 1 then
          pos2 = i
          break
        else
          (i+1).upto(@listView1.countItems-1){|j|
            i2,l2=@listView1.getItemsAttr(j)
            return pos1,j-1 if @listView1.level > l2
            if @listView1.level == l2 then
              pos2 = j-1
              break
            end
          }
          pos2 = @listView1.countItems-1 unless pos2
          break
        end
      else #@listView1.level < lvl
        (i+1).upto(@listView1.countItems-1){|j|
          i1,l1=@listView1.getItemsAttr(j)
          return j,nil if @listView1.level > l1
          if @listView1.level == l1 then
            pos1 = j
            break
          end
        }
        return @listView1.countItems,nil unless pos1
        if i1.size > 1 then
          pos2 = pos1
        else
          (pos1+1).upto(@listView1.countItems-1){|j|
            i2,l2=@listView1.getItemsAttr(j)
            if @listView1.level == l2 then
              pos2 = j-1
              break
            end
          }
          pos2 = @listView1.countItems-1 unless pos2
          break
        end
      end
    }
    pos1 = @listView1.countItems unless pos1
    [pos1,pos2]
  end
  
  def find_prev(pos)
    pos.downto(0){|i|
      itm,lvl=@listView1.getItemsAttr(i)
      if @listView1.level == lvl
        return i
      elsif @listView1.level > lvl
        return i+1
      end
    }
    0
  end
  
  def btAddMnu_clicked
    @listView1.ed.hide
    if @listView1.countItems == 0 
      n1 = 0
      0.upto(2-@listView1.countColumns){
        |i|@listView1.insertColumn(0,'',112)}if @listView1.countColumns < 3
      @listView1.insertItem(n1,['Menu'])
    else
      return unless @listView1.items
      @listView1.selectItem(@listView1.focusedItem,false)
      n1,n2=find_next(@listView1.focusedItem+1)
      @listView1.insertItem(n1,['']*(@listView1.level)+['Menu']) if n1
    end
    @listView1.setItemStateOf(n1,WConst::LVIS_SELECTED|WConst::LVIS_FOCUSED)
    @listView1.updateTitle(@listView1.focusedItem)
  end
  
  def btAddItm_clicked
    @listView1.ed.hide
    if @listView1.countItems == 0 
      0.upto(1-@listView1.countColumns){
        |i|@listView1.insertColumn(0,'',112)}if @listView1.countColumns < 2
      @listView1.insertItem(0,['item','event'])
      n1 = -1
    else
      return unless @listView1.items
      n1 = @listView1.focusedItem
      @listView1.selectItem(n1,false)
      if @listView1.items.size == 1 
        if @listView1.countColumns < @listView1.level+@listView1.items.size+2
          @listView1.insertColumn(@listView1.countColumns,'',112) 
        end
        @listView1.insertItem(n1+1,['']*(@listView1.level+1)+['item','event'])
      else
        @listView1.insertItem(n1+1,['']*(@listView1.level)+['item','event'])
      end
    end
    @listView1.setItemStateOf(n1+1,WConst::LVIS_SELECTED|WConst::LVIS_FOCUSED)
    @listView1.updateTitle(@listView1.focusedItem)
  end

  def btAddSep_clicked
    @listView1.ed.hide
    return if @listView1.countItems==0
    return unless @listView1.items
    n1 = @listView1.focusedItem
    @listView1.selectItem(n1,false)
    if @listView1.items.size == 1 then
      if @listView1.countColumns < @listView1.level+@listView1.items.size+2 then
        @listView1.insertColumn(@listView1.countColumns,'',112) 
      end
      @listView1.insertItem(n1+1,['']*(@listView1.level+1)+['sep','_vrmenusep'])
    else
      @listView1.insertItem(n1+1,['']*(@listView1.level)+['sep','_vrmenusep'])
    end
    @listView1.setItemStateOf(n1+1,WConst::LVIS_SELECTED|WConst::LVIS_FOCUSED)
    @listView1.updateTitle(@listView1.focusedItem)
  end
  
  def btRemove_clicked
    @listView1.ed.hide
    return unless @listView1.items
    nf=@listView1.focusedItem
    @listView1.selectItem(nf,false)
    if @listView1.items.size == 1 then
      n1,n2=find_next(nf+1)
      nf.upto(n1-1){|i|
        @listView1.deleteItem(nf)
      } if n1
    else
      @listView1.deleteItem(nf)
    end
    nf = nf < 0 || nf >= @listView1.countItems ? 0 : nf
    @listView1.setItemStateOf(nf,WConst::LVIS_SELECTED|WConst::LVIS_FOCUSED)
    @listView1.updateTitle(@listView1.focusedItem)
  end
  
  def btUP_clicked
    @listView1.ed.hide
    return unless @listView1.items
    nf=@listView1.focusedItem
    return if nf == 0
    n0=find_prev(nf-1)
    return if nf == n0
    n1,n2 = find_next(n0+1)
    return unless n2
    (n1-1).downto(n0){|i|
      a = []
      0.upto(@listView1.countColumns-1){|j| a << @listView1.getItemTextOf(i,j)}
      @listView1.insertItem(n2+1,a)
    }
    (n1-1).downto(n0){|i|
      @listView1.deleteItem(n0)
    }
  end
  
  def btDN_clicked
    @listView1.ed.hide
    return unless @listView1.items
    nf=@listView1.focusedItem
    n1,n2=find_next(nf+1)
    return unless n2
    @listView1.selectItem(nf,false)
    (n1-1).downto(nf){|i|
      a = []
      0.upto(@listView1.countColumns-1){|j| a << @listView1.getItemTextOf(i,j)}
      @listView1.insertItem(n2+1,a)
    }
    (n1-1).downto(nf){|i|
      @listView1.deleteItem(nf)
    }
    nf = nf + n2 - n1 + 1
    @listView1.setItemStateOf(nf,WConst::LVIS_SELECTED|WConst::LVIS_FOCUSED)
    @listView1.updateTitle(@listView1.focusedItem)
  end
  
end

class PreferDlg < VRModalDialog
  include VRCommonDialog
  PreferDlg_fonts=[
    VRLocalScreen.factory.newfont("Terminal",-13,0,0,0,0,0,1,128,100,0),
    VRLocalScreen.factory.newfont("MS UI Gothic",-15,0,0,0,0,0,50,128,110,0)
  ]
  DEFAULT_FONT=PreferDlg_fonts[0]
  @@args=nil
  def self.arg= (arg); @@arg=arg end

  def construct
    self.caption = FDPrfItems::Preferences
    self.move(139,124,320,240)
    addControl(VRCheckbox,'cbCygwin',FDPrfItems::CROnly,200,116,64,24)
    addControl(VRStatic,'static4', FDPrfItems::CgwinLS,8,120,192,24)
    addControl(VRStatic,'static1',FDPrfItems::Gridsize,8,12,64,20)
    addControl(VRStatic,'static2',FDPrfItems::Editor,8,44,48,24)
    addControl(VREdit,'edGrid','',72,8,48,20)
    addControl(VRCheckbox,'cbLang',FDPrfItems::UseJp,188,8,100,20,0x20)
    addControl(VRButton,'btBrowseFon','...',288,72,24,20)
    addControl(VREdit,'edEditor','notepad',56,40,232,20)
    addControl(VREdit,'edFont','System',56,72,232,20)
    addControl(VRStatic,'static3',FDPrfItems::Font,8,76,48,24)
    addControl(VRStatic,'static5',FDPrfItems::NextStart, 8,96,200,20)
    addControl(VRCheckbox,'cbDock', FDPrfItems::DockInspect,8,140,264,24)
    addControl(VRCheckbox,'cbVerbose', FDPrfItems::Verbose,8,160,264,24)
    addControl(VRButton,'btBrowseEd','...',288,40,24,20)
    addControl(VRButton,'btOK',FDPrfItems::OK,136,188,80,24).setFont(
    PreferDlg_fonts[1])
    addControl(VRButton,'btCan',FDPrfItems::Cancel,224,188,80,24).setFont(
    PreferDlg_fonts[1])
  end
  
  def self_created
    @arg = @@arg
    setButtonAs(@btOK,IDOK)
    setButtonAs(@btCan,IDCANCEL)
    @btOK.focus
    @edEditor.text = @arg[:editor]
    @edGrid.text = @arg[:grid].to_s
    @cbCygwin.check(@arg[:cygwin])
    @edFont.text= @arg[:font]
    @cbDock.check(@arg[:dock])
    @cbVerbose.check(@arg[:verbose])
    @cbLang.check($Lang=='JA')
  end
  
  def btBrowseEd_clicked
    if editpath=openFilenameDialog([["Editor","*.exe"]]) then
      @edEditor.text=editpath.to_s
    end
  end
  
  def btBrowseFon_clicked
    fon=@arg[:font].split(',')
    if @default_font=SWin::CommonDialog.chooseFont(self,[[fon[0],(fon[1].to_f)*4/3,
                                                          0,300,135,0,0,2,128],120,0])
      @edFont.text="#{@default_font[0][0]},#{@default_font[1] / 10}"
    end
  end
  
  def btOK_clicked
    $Lang=@cbLang.checked? ? 'JA' : 'EN'
    close [@edGrid.text,@edEditor.text,@cbCygwin.checked?,@edFont.text,
    @cbDock.checked?,@cbVerbose.checked?]
  end
  
  def btCan_clicked
    close nil
  end
  
end

class TabOrderDlg < VRModalDialog
  include VRComCtlContainer
  include VROwnerDrawControlContainer
  DEFAULT_FONT=VRLocalScreen.factory.newfont('MS UI Gothic',-13,0,4,0,0,0,50,128)
  @@args=nil
  def TabOrderDlg.args= (args); @@args=args end
  def initialize;  super ; @args = @@args end
  def _tabDlg_init
    self.caption = 'TAB order'
    self.move(@args[:x],@args[:y]+124,140,400)
    addControl(VRButton,'btTab',"Use TAB",52,316,80,24,1342177280)
    addControl(VRListview,'listView1',"listView1",0,0,132,308,1342177285)
    addControl(VRButton,'btOK',"OK",0,348,64,24,1342177280)
    addControl(VRButton,'btCan',"Cancel",68,348,64,24,1342177280)
    addControl(Bt_UP,'btUP',"",0,316,24,24)
    addControl(Bt_DN,'btDN',"",24,316,24,24)
    setButtonAs(@btOK,IDOK)
    setButtonAs(@btCan,IDCANCEL)
    @btOK.focus
  end 

  def construct
    @ctlList=[]
    _tabDlg_init
    @listView1.lvexstyle=0x21
    @listView1.addColumn('ord',30)
    @listView1.addColumn('control name',98)
    
    @args[:c].tabOrders.each_with_index{|itm,idx|
      @ctlList << [idx.to_s,@args[:c].controls[itm].name,itm] unless
      itm.is_a?(FDCoverPanel) || itm.is_a?(FDContainer)
      }
    @args[:c].controls.each{|k,itm|
      @ctlList << ["",itm.name,k] unless @args[:c].tabOrders.index(k) unless itm.is_a?(FDCoverPanel) || itm.is_a?(FDContainer)
    }
    @ctlList.each{|i|@listView1.addItem(i[0,2])}
    @tabCount=@args[:c].tabOrders.size
  end
  
  def btUP_clicked
    nf=@listView1.focusedItem
    if nf > 0 then
      s=@listView1.getItemTextOf(nf-1,1)
      @listView1.setItemTextOf(nf-1,1,@listView1.getItemTextOf(nf,1))
      @listView1.setItemTextOf(nf,1,s)
      @listView1.setItemStateOf(nf-1,WConst::LVIS_SELECTED|WConst::LVIS_FOCUSED)
      a1=@ctlList[nf-1][1,2]
      @ctlList[nf-1][1,2]=@ctlList[nf][1,2]
      @ctlList[nf][1,2]=a1
    end
    @listView1.focus
  end

  def btDN_clicked
    nf=@listView1.focusedItem
    if nf < @listView1.countItems-1 then
      s=@listView1.getItemTextOf(nf+1,1)
      @listView1.setItemTextOf(nf+1,1,@listView1.getItemTextOf(nf,1))
      @listView1.setItemTextOf(nf,1,s)
      @listView1.setItemStateOf(nf+1,WConst::LVIS_SELECTED|WConst::LVIS_FOCUSED)
      a1=@ctlList[nf+1][1,2]
      @ctlList[nf+1][1,2]=@ctlList[nf][1,2]
      @ctlList[nf][1,2]=a1
    end
    @listView1.focus
  end

  def btTab_clicked
    if @ctlList[@listView1.focusedItem][0] == "" then
      @ctlList[@listView1.focusedItem][0]="#{@tabCount+=1}"
    else
      @ctlList[@listView1.focusedItem][0]=""
      @tabCount-=1
    end
    @ctlList.sort!{|a,b|
      a1 = a[0] == '' ? 0x100000000 : a[0].to_i
      b1 = b[0] == '' ? 0x100000000 : b[0].to_i
      a1 <=> b1}
    @ctlList.each_with_index{|itm,idx| itm[0] = idx if itm[0] != '' }
    @listView1.clearItems
    @ctlList.each{|i|@listView1.addItem(i)}
    @listView1.focus
  end

  def btOK_clicked
    @args[:c].tabOrders = @ctlList.collect{|i| if i[0]!="" then i[2] end }.select{|i| i}
    close true
  end

  def btCan_clicked
    close nil
  end

  def listView1_itemchanged(idx,state)
    return if state != 0
    if @listView1.getItemTextOf(idx,0)== "" then
      @btTab.caption="Use TAB"
    else
      @btTab.caption="Unuse TAB"
    end
    c0 = @args[:c].controls.select{|k,v| v.name == @listView1.getItemTextOf(idx,1)}[0][1]
    @args[:frm].setFocusRgn(c0)
  end

end

class NewProjectDlg < VRModalDialog
  @@args=nil
  def NewProjectDlg.args=(arg)
    @@args=arg
  end
  
  def construct
    arg=@@args; @@args=nil
    self.caption = arg + FDNewProjectItem::NewProject
    self.move(163,149,400,185)
    addControl(VRRadiobutton,'rbMono',FDProjectTypes::Mono,48,80,280,24)
    addControl(VRButton,'btOK',"O  K",160,120,80,24,0x50000000)
    addControl(VRStatic,'static1',FDNewProjectItem::Prompt,48,16,280,24)
    addControl(VRRadiobutton,'rbApart',FDProjectTypes::Apart,48,48,280,24)
    @rbApart.check true
    setButtonAs(@btOK,IDOK)
  end 
  
  def btOK_clicked
    close @rbApart.checked?
  end

end

class LayoutDlg < VRModalDialog
  include VRComCtlContainer
  include VROwnerDrawControlContainer
  DEFAULT_FONT=VRLocalScreen.factory.newfont('MS UI Gothic',-13,0,4,0,0,0,50,128)
  
  @@args=nil
  def LayoutDlg.args= (args); @@args=args end
  def initialize;  super ; @args = @@args end
  class TabPane < VRTabControl
    include VRComCtlContainer
    include VRMessageParentRelayer
    attr :listView1,1
    def construct
      insertTab(0,"")
      addControl(VRListview,'listView1',"listView1",*adjustRect(x,y,w-4,h))
      @listView1.lvexstyle=0x21
      @listView1.addColumn('*',18)
      @listView1.addColumn('control name',@listView1.w-22)
    end
  end
  
  def _registerDlg_init
    self.caption = 'Register'
    self.move(@args[:x],@args[:y]+124,140,400)
    addControl(TabPane,'tabPane','',0,0,self.w-8,self.h-84,WStyle::TCS_BOTTOM)
    addControl(VRButton,'btRegister',"Register",48,320,84,24)
    addControl(VRButton,'btOK',"OK",0,348,64,24)
    addControl(VRButton,'btCan',"Cancel",68,348,64,24)
    addControl(Bt_UP,'btUP',"",0,320,24,24)
    addControl(Bt_DN,'btDN',"",24,320,24,24)
    setButtonAs(@btOK,IDOK)
    setButtonAs(@btCan,IDCANCEL)
    @btOK.focus
  end 

  def construct
    _registerDlg_init
    if @args[:focused].substance.is_a? VRHorizTwoPaneFrame
      @tabPane.setTabTextOf(0,"left")
      @tabPane.insertTab(1,"right")
    elsif @args[:focused].substance.is_a? VRVertTwoPaneFrame
      @tabPane.setTabTextOf(0,"upper")
      @tabPane.insertTab(1,"lower")
    else
      @tabPane.setTabTextOf(0,"layout")
    end
    @ctlList=[[],[]]
    @registerd = [[],[]]
    @current_tab = 0
    @args[:c].controls.each{|k,itm|
      if itm.is_a?(FDContainer)
        sb = itm.substance
        next unless sb.is_a?(VRLayoutFrame)||
                                           itm.substance.is_a?(VRTwoPaneFrame)
        next if (@args[:c].instance_eval("@__regsterd_vr_margined_frame")==sb)
        if @args[:focused] == itm
          next
        elsif itm.registerd_to.empty?
          @ctlList[0] << ["",itm.name]
          @ctlList[1] << ["",itm.name]
        elsif itm.registerd_to[0] == @args[:focused]
          @ctlList[itm.registerd_to[1]] << ["*",itm.name]
          @registerd[itm.registerd_to[1]] << itm
        else
        end
      elsif !(itm.is_a?(FDCoverPanel))
#        p [itm.name,itm.registerd_to]
        if @args[:focused] == itm
          next
        elsif itm.registerd_to.empty?
          @ctlList[0] << ["",itm.name]
          @ctlList[1] << ["",itm.name]
        elsif itm.registerd_to[0] == @args[:focused]
          @ctlList[itm.registerd_to[1]] << ["*",itm.name]
          @registerd[itm.registerd_to[1]] << itm
        else
        end
      else
      end
    }
    @ctlList[0].each{|i|@tabPane.listView1.addItem(i)}
    @current_tab = @tabPane.selectedTab 
  end
  
  def tabPane_listView1_itemchanged(idx,state)
    return if state != 0
    if @tabPane.listView1.getItemTextOf(idx,0) == "" then
      @btRegister.caption="Register"
    else
      @btRegister.caption="UnRegister"
    end
    c0 = @args[:c].controls.select{|k,v|
      v.name == @tabPane.listView1.getItemTextOf(idx,1)}[0][1]
    @args[:frm].setFocusRgn(c0)
  end
  
  def tabPane_selchanged
    @ctlList[@current_tab].clear
    0.upto(@tabPane.listView1.countItems-1){|i|
      @ctlList[@current_tab] << [@tabPane.listView1.getItemTextOf(i,0),
                                 @tabPane.listView1.getItemTextOf(i,1)]}
    @tabPane.listView1.clearItems
    @ctlList[@tabPane.selectedTab].each{|i|@tabPane.listView1.addItem(i)}
    @current_tab = @tabPane.selectedTab 
  end
  
  def tabPane_listView1_columnclick(subitem)
    btRegister_clicked if subitem == 0
  end
  
  def btRegister_clicked
    return if @tabPane.listView1.countItems == 0
    n = @current_tab==0 ? 1 : 0
    s = @tabPane.listView1.getItemTextOf(@tabPane.listView1.focusedItem,1)
    if @tabPane.listView1.getItemTextOf(@tabPane.listView1.focusedItem,0) == ""
      @tabPane.listView1.setItemTextOf(@tabPane.listView1.focusedItem,0,"*")
      @registerd[@current_tab] << @args[:c].controls.find{|k,i| i.name == s}[1]
      @ctlList[n].reject!{|i| i[1] == s} if @tabPane.countTabs > 1
    else
      @tabPane.listView1.setItemTextOf(@tabPane.listView1.focusedItem,0,"")
      @registerd[@current_tab].reject!{|i| i.name == s}
      @ctlList[n] << ["",s] if @tabPane.countTabs > 1
    end
    @tabPane.listView1.focus
  end
  
  def btUP_clicked
    nf=@tabPane.listView1.focusedItem
    if nf > 0 then
      s=@tabPane.listView1.getItemTextOf(nf-1,0)
      @tabPane.listView1.setItemTextOf(nf-1,0,
                                        @tabPane.listView1.getItemTextOf(nf,0))
      @tabPane.listView1.setItemTextOf(nf,0,s)
      s=@tabPane.listView1.getItemTextOf(nf-1,1)
      @tabPane.listView1.setItemTextOf(nf-1,1,
                                        @tabPane.listView1.getItemTextOf(nf,1))
      @tabPane.listView1.setItemTextOf(nf,1,s)
      @tabPane.listView1.setItemStateOf(nf,0)
      @tabPane.listView1.setItemStateOf(nf-1,
                                    WConst::LVIS_SELECTED|WConst::LVIS_FOCUSED)
    end
    @tabPane.listView1.focus
  end

  def btDN_clicked
    nf=@tabPane.listView1.focusedItem
    if nf < @tabPane.listView1.countItems-1 then
      s=@tabPane.listView1.getItemTextOf(nf+1,0)
      @tabPane.listView1.setItemTextOf(nf+1,0,
                                        @tabPane.listView1.getItemTextOf(nf,0))
      @tabPane.listView1.setItemTextOf(nf,0,s)
      s=@tabPane.listView1.getItemTextOf(nf+1,1)
      @tabPane.listView1.setItemTextOf(nf+1,1,
                                        @tabPane.listView1.getItemTextOf(nf,1))
      @tabPane.listView1.setItemTextOf(nf,1,s)
      @tabPane.listView1.setItemStateOf(nf,0)
      @tabPane.listView1.setItemStateOf(nf+1,
                                    WConst::LVIS_SELECTED|WConst::LVIS_FOCUSED)
    end
    @tabPane.listView1.focus
  end

  def btOK_clicked
    r = []
    @tabPane.selectTab(0)
    tabPane_selchanged
    n = @tabPane.listView1.countItems
    0.upto(n-1) do |i|
      if @tabPane.listView1.getItemTextOf(i,0) == '*' then
        r << @args[:c].controls.find{|k,itm|
          itm.name == @tabPane.listView1.getItemTextOf(i,1)
        }[1]
      end
    end
    if @tabPane.countTabs > 1 then
      r = [r,[]]
      0.upto(@ctlList[1].size-1) do |i|
        if @ctlList[1][i][0] == '*' then
          r[1] << @args[:c].controls.find{|k,itm|
            itm.name == @ctlList[1][i][1]
          }[1]
        end
      end
    end
    close r
  end

  def btCan_clicked
    close nil
  end
end

class VersionDlg < VRModalDialog
  VersionDlg_fonts=[
      VRLocalScreen.factory.newfont('Times New Roman',-16,1,7,0,0,0,18,0),
      VRLocalScreen.factory.newfont('Times New Roman',-21,1,7,0,0,0,18,0),
      VRLocalScreen.factory.newfont('Times New Roman',-13,0,4,0,0,0,18,0),
      VRLocalScreen.factory.newfont('Times New Roman',-13,2,4,0,0,0,18,0),
      VRLocalScreen.factory.newfont('Times New Roman',-16,0,7,0,0,0,18,0)
    ]
  ShellExecute = Win32API.new('shell32','ShellExecute','LPPPPL','L')
  
  include VRCtlColor
  include VRDrawable
  include VRMouseFeasible
  include VRContainersSet
  def self.args=(arg) @@args = arg ;end
  def construct
    self.caption = 'Version information of FormDesigner'
    self.move(168,196,496,246)
    addControl(VRStatic,'static9',"000000",384,40,56,16,0x2)
    @static9.setFont(VersionDlg_fonts[0])
    addControl(VRStatic,'static1',"The FormDesigner for Project VisualuRuby",56,8,384,24)
    @static1.setFont(VersionDlg_fonts[1])
    addControl(VRStatic,'static2',"Written by:",16,80,96,16,0xb)
    @static2.setFont(VersionDlg_fonts[2])
    addControl(VRStatic,'static7',"https://sourceforge.jp/projects/fdvr",160,128,192,16)
    @static7.setFont(VersionDlg_fonts[3])
    addControl(VRStatic,'static3',"yukimi_sake@mbi.nifty.com",160,80,176,16)
    @static3.setFont(VersionDlg_fonts[2])
    addControl(VRStatic,'static8',"Version:",328,40,56,16)
    @static8.setFont(VersionDlg_fonts[0])
    addControl(VRStatic,'static5',"nyasu@osk.3web.ne.jp",160,104,176,16)
    @static5.setFont(VersionDlg_fonts[2])
    addControl(VRButton,'button1',"O       K",192,184,104,24)
    @button1.setFont(VersionDlg_fonts[4])
    addControl(VRStatic,'static10',"VisualuRuby Home Page:",16,152,136,16)
    @static10.setFont(VersionDlg_fonts[2])
    addControl(VRStatic,'static6',"Project Home Page:",16,128,112,16)
    @static6.setFont(VersionDlg_fonts[2])
    addControl(VRStatic,'static4',"Basic designed by:",16,104,112,16)
    @static4.setFont(VersionDlg_fonts[2])
    addControl(VRStatic,'static11',"",160,152,320,16)
    if $Lang == 'EN'
      @static11.caption = "http://www.osk.3web.ne.jp/~nyasu/vruby/vrproject-e.html"
    else
      @static11.caption = "http://www.osk.3web.ne.jp/~nyasu/software/vrproject.html"
    end
    @static11.setFont(VersionDlg_fonts[3])
    setButtonAs(@button1,IDOK)
    @button1.focus
  end
  
  def hittest(x,y)
    if @static7.x <= x && x <= @static7.x+@static7.w &&
      @static7.y <= y && y <= @static7.y+@static7.h
      @static7
    elsif @static11.x <= x && x <= @static11.x+@static11.w &&
      @static11.y <= y && y <= @static11.y+@static11.h
      @static11
    else
      nil
    end
  end
    
  def self_mousemove(shift,x,y)
    if ctl = hittest(x,y)
      @ctl = ctl
      ctl.setCtlTextColor(0xff0000)
      ctl.refresh
    elsif @ctl
      @ctl.setCtlTextColor(0x0)
      @ctl.refresh
    end
  end
  
  def self_lbuttonup(shift,x,y)
    if c = hittest(x,y)
      s = c.caption
      ShellExecute.call(0, nil, s, nil, nil, 0)
      close nil
    end
  end

  def self_created
    arg = @@args
    @static9.caption = arg.to_s
    centering(nil)
    setButtonAs(@button1,IDOK)
    @controls.each{|i,c| addCtlColor(c) unless c.is_a? VRButton}
    @ctl = nil
    @bmp = SWin::Bitmap.newBitmap(1,64)
    0.upto(63){|i|@bmp[0,i]=[0xff,0xff,0xff]}
  end
  
  def self_paint
    stretchBitmap 0,0,self.w,self.h,@bmp
  end
  
  def button1_clicked
    self.close nil
  end

end
