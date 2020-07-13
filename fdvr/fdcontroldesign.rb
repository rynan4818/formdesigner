# fdcontroldesign.rb
# The form to controls designing
#
# Programmed by yukimi_sake@mbi.nifty.com
# Copyright 2001-2004 Yukio Sakaue

require 'vr/vruby'
require 'vr/sysmod'
require 'vr/vrcontrol'
require 'vr/vrcomctl'
require 'vr/vrhandler'
require 'vr/winconst'
require 'vr/rscutil'
require 'vr/vrrichedit'
require 'vr/vrtooltip'
require 'vr/contrib/inifile'
require 'vr/vrtimer'
require 'vr/vrddrop'
require 'vr/vrclipboard'
require 'vr/vrddrop'
require 'vr/vrmmedia'
require 'vr/vrmargin'
require 'vr/vrmgdlayout'

require 'fdvr/fdwin32'
require 'fdvr/fdparser'
require 'fdvr/fdwstyle'
require 'fdvr/fdmodules'
require 'fdvr/fdresources'
require 'fdvr/fdcfg'

module FDMouseControl
    R2_COPYPEN   = 13
    R2_NOTXORPEN = 10

  def step(v)
    if @enableGrid then v-v%@span else  v  end
  end

end

class FDContainer < VRBitmapPanel
  include FDDraggable
  attr_accessor :substance, :items
  undef :addControl

  def self_destroy
    #unhookwndproc
    self.terminate if defined? self.terminate
  end
end

class ModStruct
  attr_reader :name, :oldname
  attr_accessor :childs, :parent, :tline, :sline, :eline
  def initialize(oldname,name,parent,childs=[])
    @oldname = oldname
    @name = name
    @parent = parent
    @childs = childs
    @tline = nil
    @sline = nil
    @eline = nil
  end
  
  def find(str)
    self.childs.find{|i| i.oldname == str}
  end
end

module FDControlDesign  # for DesignForm
  include VRFocusSensitive
  include VRMenuUseable
  include VRToolbarUseable
  include VRDrawable
  include VRResizeable
  include VRClosingSensitive
  include VRCommonDialog
  include VRParent
  include VRMarginedFrameUseable
  include VRDropFileTarget
  include FDMouseControl
  include VRTimerFeasible
  include CreateCtrl #from 'fdcfg'
  include FDCommonMethod
  include WConst
  include FDParent
  include FDFakeClass
  
  attr_reader :controls, :modules, :names
  attr_accessor :form, :type_of_form, :creation, :span, :enableGrid, :name
  attr_accessor :oldname, :sender, :focused, :focusExists, :buff1, :linscan2
  attr_accessor :cntnmodules, :_return_val, :tabOrders, :_default_font
  
  def vrinit
    super
    @app=@screen.application
    @curs=@app::SysCursors
  end

  def construct
    begin SWin::Application.setAccel(self,@parent) ;rescue ;end
    lpRect = ' ' * 16
    @span=$ini.read('settings','span',8).to_i
    addHandler WMsg::WM_LBUTTONDOWN,'lbuttondown',MSGTYPE::ARGLINTINT,nil
    addHandler WMsg::WM_MOUSEMOVE,  'mousemove',MSGTYPE::ARGINTINTINT,nil
    addHandler WMsg::WM_LBUTTONUP,  'lbuttonup',  MSGTYPE::ARGLINTINT,nil
    addHandler WMsg::WM_RBUTTONUP,  'rbuttonup',  MSGTYPE::ARGINTSINTSINT,nil
    addHandler WMsg::WM_RBUTTONDOWN,'rbuttondown',MSGTYPE::ARGINTSINTSINT,nil
    addHandler WMsg::WM_MOVE,  'move',  MSGTYPE::ARGLINTINT,0
    acceptEvents [WMsg::WM_LBUTTONUP,WMsg::WM_RBUTTONUP,
                  WMsg::WM_LBUTTONDOWN,WMsg::WM_RBUTTONDOWN,
                  WMsg::WM_MOUSEMOVE,WMsg::WM_MOVE]

    @dc=GetDC.Call(self.hWnd)
    x,y,w,h = self.clientrect
    @hrgn=CreateRectRgn.Call(x,y,w,h)
    SelectClipRgn.Call(@dc,@hrgn)
    @hBrush=CreateBrush.call(0)
    @oldBrush=SelectObject.Call(@dc,@hBrush)
    @hPen = CreatePen.Call(0,2,0x00404040)
    @oldhPen=SelectObject.Call(@dc,@hPen)
    @selected_point=Struct.new(:x,:y)[0,0]
    @paste_to=nil
    @copy_buff=[]
    init_designfrm
  end

  def init_designfrm
    @form=self
    @type_of_form=VRForm
    @names=[]
#    @controls={}
    @focus=[0,0,0,0]
    @moving=false; @resizing=false
    @x1=@x2=@y1=@y2=0
    @enableGrid=true
    @required=["vruby"]
    @included=[]
    @modules=[]
    @tabOrders=[]
    @_hsh_font={}
    @temp_fonts=[]
    @_font_array=[]
    @font_hash={}
    @name="form1"
    @oldname="form1"
    @buff=""
    @frm_sizebox = 'true'
    @frm_maximizebox = 'true'
#    arrydlgcreate
    moddlgcreate
    createinit
    fd_parent_init
    refreshCntName
    refreshInspect(nil)
  end
  
  def addControl(*args)
    r = super
    if @_default_font then
      r.setFont(@_default_font)
    end
    r
  end
  
=begin
  def arrydlgcreate
    tpl = VRDialogTemplate.new
    tpl.style = WS_CAPTION | WS_SYSMENU | DS_MODALFRAME | DS_SETFONT
    tpl.fontname = "MS Gothic"
    tpl.fontsize = 11
    tpl.caption="Array Editor"
    btok = tpl.addDlgControl(VRButton,"O   K",5,187,40,12,0x00010000)
    btcan = tpl.addDlgControl(VRButton,"Cancel",50,187,40,12,0x00010000)
    ed1 = tpl.addDlgControl(VREdit,"",2,2,200,180,0x00b01064)
    @arrydlg=ArrayEditDialog.new(@screen,tpl)
    @arrydlg.options ={"target"=>ed1,"okbutton"=>btok,
                      "cancelbutton"=>btcan,"default" => [["",""]]}

  end
=end
  
  def moddlgcreate
    tpl = VRDialogTemplate.new
    tpl.style = WS_CAPTION | WS_SYSMENU | DS_MODALFRAME | DS_SETFONT
    tpl.fontname = "Terminal"
    tpl.fontsize = 10
    tpl.caption="Modules"
    btok = tpl.addDlgControl(VRButton,"O   K",5,182,40,12)
    btcan = tpl.addDlgControl(VRButton,"Cancel",50,182,40,12)
    lb1 = tpl.addDlgControl(VRListbox,"",2,2,100,164,0x0060)
    @moddlg=ListBoxDlg.new(@screen,tpl)
    @moddlg.options ={"target"=>lb1,"okbutton"=>btok,
                      "cancelbutton"=>btcan,"default" => [["",0]]}
  end
  
  def setPenMode(mode)
    SetROP2.Call(@dc,mode)
  end

  def rect(x1,y1,x2,y2)
    MoveTo.Call(@dc,x1,y1,0)
    LineTo.Call(@dc,x2,y1);
    LineTo.Call(@dc,x2,y2);
    LineTo.Call(@dc,x1,y2);
    LineTo.Call(@dc,x1,y1)
  end

  def get_serial_name(s)
    s1 = s.dup
    if @names.index(s1) then
      s1.sub! /(\d+)$/ , ""
      s1 << "#{$1.to_i+1}"
      get_serial_name(s1)
    else
      @names << s1
      s1
    end
  end

  def delete_serial_name(s)
    @names.delete(s)
  end

  def self_paint
    if @enableGrid then
      a=clientrect
      SetROP2.Call(hdc,8)
      nh=(a[2]/@span).to_i;nv=(a[3]/@span).to_i
      setBrush(0)
      dc=self.hdc
      i=0
      #draw grids
      for i in 0.. nh
        grMoveTo(i*@span,0)
        grLineTo(i*@span,nv*@span)
      end
      for i in 0.. nv
        grMoveTo(0,i*@span)
        grLineTo(nh*@span,i*@span)
      end
      SetROP2.Call(hdc,13)
    end

    if @focusExists then
      addTimer(50)
    end
  end

  def self_timer
     paintFocusRect
     deleteTimer
  end

  def paintFocusRect
    dopaint do
      Rectangle.Call(@dc,@x1-5,@y1-5,@x1,@y1)
      Rectangle.Call(@dc,@x2+5,@y2+5,@x2,@y2)
      Rectangle.Call(@dc,@x1-5,@y2+5,@x1,@y2)
      Rectangle.Call(@dc,@x2+5,@y1-5,@x2,@y1)
      Rectangle.Call(@dc,@x1-5,(@y1+@y2)/2-3,@x1,(@y1+@y2)/2+2)
      Rectangle.Call(@dc,@x2+5,(@y1+@y2)/2-3,@x2,(@y1+@y2)/2+2)
      Rectangle.Call(@dc,(@x1+@x2)/2-3,@y1-5,(@x1+@x2)/2+2,@y1)
      Rectangle.Call(@dc,(@x1+@x2)/2-3,@y2+5,(@x1+@x2)/2+2,@y2)
    end if @focusExists
  end

  def setFocusRgn(c)
    unless c then
      @x1=@x2=@y1=@y2=nil
      @focusExists = false
    else
      if c.parent.is_a?(VRForm) then
        @x1=c.x;@y1=c.y;@x2=c.x+c.w;@y2=c.y+c.h
      else
        a=getFormPos(c)
        @x1=a[0];@y1=a[1];@x2=a[0]+c.w;@y2=a[1]+c.h
      end
    end
  end

  def getFormPos(c)
      r=[0,0]
    if c then
      if c.parent.is_a?VRForm then
        r[0]=c.x;r[1]=c.y
      else
        a=getFormPos(c.parent)
        r[0]=c.x+a[0];r[1]=c.y+a[1]
      end
    end
      r
  end

  def resizecursor(l,r,t,b) # from visualu.rb
    if l 
      if t 
        @curs.SizeNWSE
      elsif b 
        @curs.SizeNESW
      else
        @curs.SizeWE
      end
    elsif r 
      if t 
        @curs.SizeNESW
      elsif b 
        @curs.SizeNWSE
      else
        @curs.SizeWE
      end
    elsif t or b 
      @curs.SizeNS
    else
      @curs.Arrow
    end
  end

  def controlstate(l,r,t,b)
    @moving = @resizeALL = @resizeLR = @resizeUD = false
    if l 
      @ox1=@x2
      if t 
        @oy1=@y2;@resizeALL=true
      elsif b 
        @oy1=@y1;@resizeALL=true
      else
        @oy1=@y1;@resizeLR=true
      end
    elsif r 
      @ox1=@x1
      if t 
        @oy1=@y2;@resizeALL=true
      elsif b 
        @oy1=@y1;@resizeALL=true
      else
        @oy1=@y1;@resizeLR=true
      end
    elsif t 
      @ox1=@x1;@oy1=@y2;@resizeUD=true
    elsif b 
      @ox1=@x1;@oy1=@y1;@resizeUD=true
    else
      @ox1=@x1;@oy1=@y1;@ox2=@x2;@oy2=@y2
      @moving=true
    end
  end
  
  def set_selected_point(sx,sy)
    @selected_point.x = sx
    @selected_point.y = sy
  end
  
  def self_lbuttonup(x,y)
    num=1 ; @dragging = false
    sx=step(x < 0xefff ? x : x-0x10000)
    sy=step(y < 0xefff ? y : y-0x10000)
    ox=oy=0;a=[0,0]
    set_selected_point(sx,sy)
    if @containerCnt != self || @focused && @focused.parent != self then
      if @containerCnt != self then
        a = getFormPos(@containerCnt)
        ox = a[0]; oy = a[1]
      end
    end
    if @creation then
      nam = get_serial_name(@creation.inst + "1")
      @creating=instance_eval("#{@creation.createMethod}(@containerCnt,@creation,
        nam,nam,@ox1-ox,@oy1-oy,@creation.dflt_w, @creation.dflt_h)")
      return unless @creating
      if @creating && sx - @ox1 >0 && sy - @oy1 >0 then
        @creating.move @ox1-ox,@oy1-oy,sx-@ox1,sy-@oy1
      end
      moveC(@creating)
      @focused=@creating
      @creating.parent.child_created(@creating) if @creating.parent.respond_to? :child_created
      setFocusRgn(@focused)
      @focusExists = true if @focused
      refreshCntName
      @parent.inc_modified
    elsif @resizeALL then
      # p 'resizeALL'
      if @ox1 < sx then
        x1=@ox1 ; w=sx-@ox1
        if  @focused.respond_to?(:initMargin)
          @focused.instance_eval("@__org_w = #{w}") unless @focused.mgRight
        end
      else
        x1=sx   ; w=@ox1-sx
        if @focused.respond_to?(:initMargin)
          @focused.instance_eval("@__org_x = @__org_x + @__org_w - #{w};
                                    @__org_w = #{w}") unless @focused.mgLeft
        end
      end
      if @oy1 < sy then
        y1=@oy1 ; h=sy-@oy1
        if  @focused.respond_to?(:initMargin) 
          @focused.instance_eval("@__org_h = #{h}") unless @focused.mgBottom
        end
      else
        y1=sy   ; h=@oy1-sy
        if @focused.respond_to?(:initMargin)
          @focused.instance_eval("@__org_y = @__org_y + @__org_h - #{h};
                                      @__org_h = #{h}") unless @focused.mgTop
        end
      end
      @focused.move(x1-ox,y1-oy,w,h) unless @focused.respond_to?(:initMargin)
      moveC(@focused)
      setFocusRgn(@focused)
      @focusExists = true
      @parent.inc_modified
    elsif @resizeLR then
      # p 'resizeLR'
      if @ox1 < sx then
        # p 'right'
        x1=@ox1 ; w=sx-@ox1
        if  @focused.respond_to?(:initMargin)
          @focused.instance_eval("@__org_w = #{w}") unless @focused.mgRight
        end
      else
          # p 'left'
        x1=sx ;  w=@ox1-sx
        if @focused.respond_to?(:initMargin)
          @focused.instance_eval("@__org_x = @__org_x + @__org_w - #{w};
                                    @__org_w = #{w}") unless @focused.mgLeft
        end
      end
      @focused.move(x1-ox,@focused.y,w,@focused.h) unless
                                            @focused.respond_to?(:initMargin)
      moveC(@focused)
      setFocusRgn(@focused)
      @focusExists = true
      @parent.inc_modified
    elsif @resizeUD then
      # p 'resizeUD'
      if @oy1 < sy then
        # p 'bottom'
        y1=@oy1 ; h=sy-@oy1
        if  @focused.respond_to?(:initMargin) 
          @focused.instance_eval("@__org_h = #{h}") unless @focused.mgBottom
        end
      else
        # p 'top'
        y1=sy   ; h=@oy1-sy
        if @focused.respond_to?(:initMargin)
          @focused.instance_eval("@__org_y = @__org_y + @__org_h - #{h};
                                      @__org_h = #{h}") unless @focused.mgTop
        end
      end
      @focused.move(@focused.x,y1-oy,@focused.w,h) unless
                                            @focused.respond_to?(:initMargin)
      moveC(@focused)
      setFocusRgn(@focused)
      @focusExists = true
      @parent.inc_modified
    elsif @moving then
      if @focused.respond_to?(:_fd_dragging) && @focused._fd_dragging
        return
      end
      if @focused.respond_to? :initMargin then
        if !@focused.mgTop && !@focused.mgBottom &&
                                       !@focused.mgLeft && !@focused.mgRight
          @focused.instance_eval("@__org_y =#{sy-@yu-oy};@__org_x=#{sx-@xl-ox}")
        elsif !@focused.mgLeft && !@focused.mgRight
          @focused.instance_eval("@__org_x=#{sx-@xl-ox}")
        elsif !@focused.mgTop && !@focused.mgBottom
          @focused.instance_eval("@__org_y =#{sy-@yu-oy}")
        else
        end
        moveC(@focused)
      else
        @focused.move sx-@xl-ox,sy-@yu-oy,@xr+@xl,@yu+@yd
      end
      if @prevfocuse && @prevfocuse.parent.is_a?(VRRebar) &&
                                                            sx==@px1 && sy==@py1
        @focused = @prevfocuse
        @prevfocuse = nil
      end
      setFocusRgn(@focused)
      @focusExists = true
      @parent.inc_modified
    end
    if @focused && (@focused.visible? == false) then
      @focused.visible=true
    end
    setPenMode(R2_COPYPEN)
    self.refresh
    @moving=@resizeALL=@resizeLR=@resizeUD= false
    releaseCapture
    self.parent.tab.noselectAll
    self.focus
    refreshInspect(@focused)
    @creating = nil
    @containerCnt = self
  end

  def self_lbuttondown(x,y)
    sx=step(x);sy=step(y)
    c0 = checkfocus(x,y)
    c1 = c0 ? c0 : self
    @paste_to=c0
    xf, yf = getFormPos(@focused) if @focused
    if @focused && (@focused.parent == c1) &&
      ((xf-4 < x && x < xf + @focused.w+4) &&
         (yf-4 < y && y < yf + @focused.h+4))
      # reamin focus
    else
      setFocusRgn(@focused = c0)
    end
    
    if @creation
      if @focused && (@creation.klass <= SWin::Window) 
        if @focused.respond_to?(:addControl)
          @containerCnt = @focused
        else
          @containerCnt = @focused.parent
        end
      elsif @focused && ((@creation.createMethod == :newFD2Pane) ||
        (@creation.createMethod == :newFDLayout))
        if (@focused.is_a?(VRPanel) && !@focused.is_a?(FDContainer))
          @containerCnt = @focused
        else
          @containerCnt = @focused.parent
        end
      else
        @containerCnt = self
      end
      @ox1=sx;  @oy1=sy
      @px1 = @ox1 ; @py1 = @oy1
      setPenMode(R2_NOTXORPEN)
      setCapture
    elsif @focused
      @containerCnt=@focused.parent
      controlstate((x-@x1).abs < 4 && @y2+4 > y && y > @y1-4,
                   (x-@x2).abs < 4 && @y2+4 > y && y > @y1-4,
                   (y-@y1).abs < 4 && @x2+4 > x && x > @x1-4,
                   (y-@y2).abs < 4 && @x2+4 > x && x > @x1-4 )
      @px1 = @ox1 ; @py1 = @oy1
      if @moving 
        if @focused.parent.is_a?(VRTabbedPanel)||(@focused.parent.is_a? VRRebar)
          @prevfocuse = @focused
          @focused = @focused.parent
          setFocusRgn(@focused)
          @containerCnt=@focused.parent
          @ox1=@x1;@oy1=@y1;@ox2=@x2;@oy2=@y2
        end
        @px1 = sx ; @py1 = sy
        @xl=@px1-@x1;@yu=@py1-@y1
        @xr=@x2-@px1;@yd=@y2-@py1
        @focusExists = true
      end
      setPenMode(R2_NOTXORPEN)
      setCapture
    else
      @focused = nil
      @focusExists = false
      @containerCnt = self
    end
    refresh
    @dragging = true
  end

  def self_rbuttondown(shift,x,y)
    sx=step(x < 0xefff ? x : x-0x10000)
    sy=step(y < 0xefff ? y : y-0x10000)
    if @focused = checkfocus(x,y) then
      @paste_to=@focused
      @focused = @focused.parent if @focused.parent.class==VRTabbedPanel
      setFocusRgn(@focused)
      @focusExists = true
    else
      @paste_to=nil
      @focusExists = false
    end
    set_selected_point(sx,sy)
    refreshInspect(@focused)
    refresh
    @parent.popupMenu @parent.amenu.menu,self.x+x,self.y+y
  end

  def self_mousemove(shift,x,y)
    SWin::Application.doevents
    sx=step(x < 0xefff ? x : x-0x10000)
    sy=step(y < 0xefff ? y : y-0x10000)
    if  @creation  then
      @cur=@curs.Cross
      @app.setCursor @cur
      if (shift&1) == 1  && @dragging then   #shift1: left button down
        # erase previous lines
        rect(@ox1,@oy1,@px1,@py1)
        # draw new lines
        rect(@ox1,@oy1,sx,sy)
        @px1 = sx ; @py1 = sy
      end
    elsif @moving    then
      return if @focused.respond_to?(:_fd_dragging) && @focused._fd_dragging
      if (shift&1) == 1 && @dragging then   #shift1: left button down
        rect(@px1-@xl,@py1-@yu,@px1+@xr,@py1+@yd)
        rect(sx-@xl,sy-@yu,sx+@xr,sy+@yd)
        @px1 = sx ; @py1 = sy
      end
    elsif @resizeALL then
      if (shift&1) == 1 && @dragging then   #shift1: left button down
        rect(@ox1,@oy1,@px1,@py1)
        rect(@ox1,@oy1,sx,sy)
        @px1 = sx ; @py1 = sy
      end
    elsif  @resizeLR  then
      if (shift&1) == 1 && @dragging then   #shift1: left button down
        rect(@ox1,@oy1,@px1,@y2)
        rect(@ox1,@oy1,sx,@y2)
        @px1 = sx ; @py1 = sy
      end
    elsif @resizeUD  then
      if (shift&1) == 1 && @dragging then   #shift1: left button down
        rect(@ox1,@oy1,@x2,@py1)
        rect(@ox1,@oy1,@x2,sy)
        @px1 = sx ; @py1 = sy
      end
    elsif  @focusExists
      if @x1 && @x2 && @y1 && @y2 then
        @app.setCursor( resizecursor(
                              (x-@x1).abs < 4 && @y2+4 > y && y > @y1-4,
                              (x-@x2).abs < 4 && @y2+4 > y && y > @y1-4,
                              (y-@y1).abs < 4 && @x2+4 > x && x > @x1-4,
                              (y-@y2).abs < 4 && @x2+4 > x && x > @x1-4 ))
      end
    else
      @app.setCursor @curs.Arrow
    end
  end

  def getFontName(c)    
    if c.respond_to? :addControl
      hf = c._default_font ? c._default_font.hfont : 0
      f = @_hsh_font[hf]
    else
      hf=c.sendMessage(WMsg::WM_GETFONT,0,0)
      hf=hf+0x100000000 if hf < 0
      f = @_hsh_font[hf]
      f = nil if c.parent._default_font && c.parent._default_font == f
    end
    if  f
      f.fontname + ',' +f.params[1].abs.to_s
    else
      r = "default"
    end
  end

  def refreshInspect(c)
    return if c.class == FDCoverPanel
    c = self unless c
    r = nil
    el = []
    c.modules.each{|i|
      if j = FDModules::StdModules["#{i}".intern]
        el = el + j.events
      elsif j = FDModules::FormModules["#{i}".intern]
        el = el + j.events
      end
    } unless c.modules.empty?
    el << 'ownerdraw(iid,action,state,hwnd,hdc,left,top,right,bottom,data)' if
                                       c != self && c.owndraw && (c.owndraw > 0)
    if c != self then
      r = findPalletItem(c)
      attrs = []
      r.attrs.each{|i|
        next if i.is_a?(Array)&&c.parent.is_a?(VRTabbedPanel)&&
                                             (i[0]=="style" || i[0]=="font")
        attrs <<
        if i.is_a?(Array) then
          [i[0],i[1].call(c),i[2]]
        elsif c.is_a? FDContainer
          case i
          when 'name','caption','x','y'
            [i,c.instance_eval(i).to_s]
          else
            [i,c.substance.instance_eval(i).to_s]
          end
        else
          [i,c.instance_eval(i).to_s]
        end
      }
      if c.respond_to?(:margined) && c.margined then
        attrs = attrs + [
          ["mgLeft","#{c.mgLeft}","numnil"],
          ["mgTop","#{c.mgTop}","numnil"],
          ["mgRight","#{c.mgRight}","numnil"],
          ["mgBottom","#{c.mgBottom}","numnil"]]
      elsif c.is_a?(FDContainer) && c.substance.respond_to?(:initMargin)
        attrs = attrs + [
          ["mgLeft","#{c.substance.mgLeft}","num"],
          ["mgTop","#{c.substance.mgTop}","num"],
          ["mgRight","#{c.substance.mgRight}","num"],
          ["mgBottom","#{c.substance.mgBottom}","num"]]
      end
      if r then
        if r.events
          @parent.inspectfrm.skip_ctrl_name = false
          el = r.events + el
          @parent.inspectfrm.evtList.setListStrings(el)
       else #e.g. menu,toolbar
          @parent.inspectfrm.skip_ctrl_name = true
          @parent.inspectfrm.evtList.setListStrings(c.eventList)
        end
      end
      @parent.inspectfrm.mthdList.setListStrings(r.mthds) if r
    elsif self.type_of_form <= VRDialogComponent
      c = self
      a = c.windowrect
      attrs = [["name",c.name],["caption",c.caption],["x",a[0].to_s],
               ["y",a[1].to_s],["w",a[2].to_s],["h",a[3].to_s],
               ["FONT",eval(@prFont).call(c),:_btFont],
               ["style",'',:nil],
               ["modules",eval(@prModule).call(c),:_btModule]]
      @parent.inspectfrm.evtList.setListStrings(el)
      if !@parent.forms[0] || @parent.forms[0]==self
        @parent.inspectfrm.mthdList.setListStrings([
          "modelessform","setButtonAs(button,dlgbuttonid)","centering"])
      elsif self.type_of_form==VRModalDialog
        @parent.inspectfrm.mthdList.setListStrings([
          "openModalDialog","setButtonAs(button,dlgbuttonid)","centering"])
      else
        @parent.inspectfrm.mthdList.setListStrings([
          "openModelessDialog","setButtonAs(button,dlgbuttonid)","centering"])
      end
    else
      c = self
      a = c.windowrect
      attrs = [["name",c.name],["caption",c.caption],["x",a[0].to_s],
               ["y",a[1].to_s],["w",a[2].to_s],["h",a[3].to_s],
               ['sizebox',@frm_sizebox.to_s,:_cbTF],
               ['maximizebox',@frm_maximizebox.to_s,:_cbTF],
               ["FONT",eval(@prFont).call(c),:_btFont],
               ["style",'',:nil],
               ["modules",eval(@prModule).call(c),:_btModule]]
      @parent.inspectfrm.evtList.setListStrings(el)
      if !@parent.forms[0] || @parent.forms[0]==self
        @parent.inspectfrm.mthdList.setListStrings(["start"])
      else
        @parent.inspectfrm.mthdList.setListStrings(["showForm"])
      end
    end
    if c == self then
      s = "#{c.name}:#{c.type_of_form}"
      parent.form_edit_menu
    else
      s = "#{c.name}:#{c.class}"
      if c.is_a?(FDContainer) &&(c.substance.is_a?(VRTwoPaneFrame)||
                   c.substance.is_a?(VRLayoutFrame)||c.substance.is_a?(VRMenu))
        parent.inhibit_paste_menu
      else
        parent.enable_paste_menu
      end
    end
    
    i= @parent.inspectfrm.cbControl.findString(s)
    @parent.inspectfrm.cbControl.select(i)
    @parent.inspectfrm.setItems(attrs)
    @parent.inspectfrm.stb2.caption = ""
  end

  def setControlsList(c)
    c.each do |id,item|
      next if item.is_a? FDCoverPanel
      if item.respond_to?(:controls) then
        setControlsList(item.controls)
      end
      unless item.parent.is_a?(VRTabbedPanel) && item.is_a?(VRPanel)
        s="#{item.name}:#{item.class}"
        @parent.inspectfrm.cbControl.addString(s)
      end
    end
  end

  def refreshCntName
    @parent.inspectfrm.cbControl.clearStrings
    s="#{self.name}:#{self.type_of_form}"
    @parent.inspectfrm.cbControl.addString(s)
    setControlsList(@controls)
#    @parent.inspectfrm.cbControl.select(
#                            @parent.inspectfrm.cbControl.findString(s))
  end

  def moveC(c)
    if c.kind_of?(SWin::Window) then
      x,y,w,h=c.windowrect
      x = c.x
      y = c.y
      if c.respond_to? :initMargin then
        x = x - (c.mgLeft ? c.mgLeft : 0)
        y = y - (c.mgTop ? c.mgTop : 0)
        w = w + (c.mgLeft ? c.mgLeft : 0) + (c.mgRight ? c.mgRight : 0)
        h = h + (c.mgTop ? c.mgTop : 0) + (c.mgBottom ? c.mgBottom : 0)
      end
      c.move(x, y, w, h)
    end
  end

  def check_container(c,n = 1)
    c.name + "+" + n.to_s
    c.parent.parent.instance_eval("@#{c.name}")
    c.parent.parent.controls if c.parent.parent.kind_of? VRGroupbox
    if  c.parent.parent then
      if c.parent.parent.instance_eval("@#{c.name}") then
        r = true ; return(true)
      else
        r = check_container(c.parent,n+1)
      end
    end
    r
  end

  def update_target(name,caption,x,y,w,h,*arg)
    if @focused then
      unless @focused.name == name then
        oldname=@focused.name.dup
        @focused.name=name
        @focused.parent.instance_eval("@#{name} = @#{oldname}")
        @focused.parent.instance_eval("@#{oldname} = nil")
        @names.delete(oldname)
        @names << name
        @focused.parent.update_items(oldname,name) if
                                     @focused.parent.respond_to? :update_items
        if @focused.respond_to?(:addControl) then
          @buff.gsub!(/\_#{oldname}/,"_#{name}") if @buff
        end
      end
      if @focused.respond_to?(:initMargin)
        lf=@focused.mgLeft; tp=@focused.mgTop;
        ri=@focused.mgRight; bt=@focused.mgBottom
      end
      arg.each do |i|
        v = ((v = eval(i[1])) == "") ? nil : v
        if @focused.is_a? FDContainer
          unless @focused.substance.instance_eval("#{i[0]}")==v then
            @focused.substance.instance_eval("#{i[0]} = #{i[1]}")
            break
          end
        else
          unless @focused.instance_eval("#{i[0]}")==v then
            @focused.instance_eval("#{i[0]} = #{i[1]}")
            break
          end
        end
      end
      pr = @focused ? @focused.parent : self
      @focused.caption=caption
      @focused.move(x,y,w,h)
      if @focused.respond_to?(:initMargin)
        @focused.instance_eval("@__org_x = @__org_x + @__org_w - #{w};
                                  @__org_w = #{w}") unless lf || @focused.mgLeft
        @focused.instance_eval("@__org_y = @__org_y + @__org_h - #{h};
                                  @__org_h = #{h}") unless tp || @focused.mgTop
        @focused.instance_eval("@__org_w = #{w}") unless ri || @focused.mgRight
        @focused.instance_eval("@__org_h = #{h}") unless bt || @focused.mgBottom
        if !@focused.mgTop && !tp && !@focused.mgBottom && !bt ||
                             !@focused.mgLeft && !lf && !@focused.mgRight && !ri
          @focused.instance_eval("@__org_y=#{y};@__org_x=#{x}")
        elsif !@focused.mgLeft && !lf && !@focused.mgRight && !ri
          @focused.instance_eval("@__org_x=#{x}")
        elsif !@focused.mgTop && !tp && !@focused.mgBottom && !bt
          @focused.instance_eval("@__org_y =#{y}")
        end
      end
      pr.sendMessage(WMsg::WM_SIZE,0,MAKELPARAM(pr.w,pr.h))
      setFocusRgn(@focused)
    else #if form
      oldname=self.name
      @buff.gsub!(/\_#{oldname}/,"_#{name}") if @buff
      self.name=name
      self.caption=caption
      move(x,y,w,h)
      @parent.update_menu(self)
    end
    @parent.inc_modified
    refreshCntName
    refreshInspect(@focused)
  end
  
  def save_window(cnt)
    x0,y0,w0,h0 = cnt.windowrect
    it = nil
    if cnt.items
      if cnt.is_a?(VRRebar) && cnt.items.size==1 &&
                                           cnt.items[0][0]=="@__#{cnt.name}"
        cnt.instance_eval("deleteControl @__#{cnt.name}")
        it = nil
      else
        it = cnt.items.dup
      end
    end
    hf0 = cnt.sendMessage(WMsg::WM_GETFONT,0,0)
    hf0 = hf0 + 0x100000000 if hf0 < 0
    hf = !(_hsh_font[hf0])||(cnt.parent._prev_dflt_hfont == hf0) ? 0 : hf0
    r = {
      :type => cnt.class,
      :name => cnt.name,
      :oldname => cnt.oldname,
      :caption => cnt.caption,
      :style => cnt.style,
      :x => cnt.x,
      :y => cnt.y,
      :w => w0,
      :h => h0,
      :id => cnt.etc,
      :form => cnt.form,
      :hfont => hf,
      :items => it,
      :mods => cnt.modules && cnt.modules.dup,
      :owndraw => cnt.owndraw,
      :registerd_to => (cnt.registerd_to.empty? ? [] :
                               [cnt.registerd_to[0].name, cnt.registerd_to[1]]),
      :controls => [] }
    r[:substance] = cnt.substance if cnt.is_a? FDContainer
    unless cnt.registerd_to.empty?
      unless cnt.is_a? FDContainer
        r[:x] = cnt.__org_x
        r[:y] = cnt.__org_y
        r[:w] = cnt.__org_w
        r[:h] = cnt.__org_h
        r[:left] = cnt.mgLeft
        r[:top] = cnt.mgTop
        r[:right] = cnt.mgRight
        r[:bottom] = cnt.mgBottom
      end
      if (r0=cnt.registerd_to[0].substance).is_a? VRTwoPaneFrame
        if cnt.registerd_to[1] == 0
          if cnt.is_a? FDContainer
            r[:regist_index] = r0.pane1.index(cnt.substance)
          else
            r[:regist_index] = r0.pane1.index(cnt)
          end
        else
          if cnt.is_a? FDContainer
            r[:regist_index] = r0.pane2.index(cnt.substance)
          else
            r[:regist_index] = r0.pane2.index(cnt)
          end
        end
      elsif r0.is_a? VRGridLayoutFrame
        if cnt.is_a? FDContainer
          r[:regist_index] = r0._vr_layoutclients.each_with_index{|c,i|
            break i if c[0] == cnt.substance}
        else
          r[:regist_index] = r0._vr_layoutclients.each_with_index{|c,i|
            break i if c[0] == cnt}
        end
      else
        if cnt.is_a? FDContainer
          r[:regist_index] = r0._vr_layoutclients.index(cnt.substance)
        else
          r[:regist_index] = r0._vr_layoutclients.index(cnt)
        end
      end
    end
    if cnt.respond_to?(:addControl) then
      r[:_default_font] = cnt._default_font
      controls=cnt.controls.dup
      save_layouts = lambda do |frame|
        r[:controls] << save_window(controls.delete(frame.container.etc))
        if frame.is_a? VRTwoPaneFrame
          frame.pane1.each{|i|
            if i.is_a? SWin::Window
              r[:controls] << save_window(controls.delete(i.etc))
            else
              save_layouts.call(i) if i
            end }if frame.pane1
          frame.pane2.each{|i|
            if i.is_a? SWin::Window
              r[:controls] << save_window(controls.delete(i.etc))
            else
              save_layouts.call(i) if i
            end } if frame.pane2
        elsif frame.is_a? VRGridLayoutFrame
          frame._vr_layoutclients.each{|i|
            if i[0].is_a? SWin::Window
              r[:controls] << save_window(controls.delete(i[0].etc))
            else
              save_layouts.call(i[0]) if i[0]
            end }
        else
          frame._vr_layoutclients.each{|i|
            if i.is_a? SWin::Window
              r[:controls] << save_window(controls.delete(i.etc))
            else
              save_layouts.call(i) if i
            end }
        end
      end
      if cnt.__regsterd_vr_margined_frame
        r[:registerd_frame] = cnt.__regsterd_vr_margined_frame 
        save_layouts.call(cnt.__regsterd_vr_margined_frame)
      end
      controls.each{|i,c|
        r[:controls] << save_window(c) unless c.is_a? FDCoverPanel
      } unless controls.empty?
    end
    r
  end
  
  def saveandclosewindow(cnt)
    return unless cnt
    r = save_window(cnt)
    cnt.terminate if cnt.respond_to?(:terminate)
    cnt.parent.deleteControl(cnt)
    cnt.parent.child_deleted(cnt) if cnt.parent.respond_to? :child_deleted
    r
  end

  def recreate1(c_parent, a, offset=[0,0], paste_mode=nil, addstyle=nil)
    if a[:type] <= FDContainer
      item = findPalletItem(a[:substance].class)
    else
      item = findPalletItem(a[:type])
    end
    if paste_mode then
      newname = get_serial_name(a[:name])
    else
      newname=a[:name]
    end
    addstyle = a[:style]|a[:owndraw] unless addstyle
    x0=a[:x]+offset[0]
    y0=a[:y]+offset[1]
    c=c_parent.instance_eval("#{item.createMethod} c_parent,#{item.klass},"+
                 "'#{newname}','#{a[:caption]}',#{x0},#{y0},#{a[:w]},#{a[:h]},"+
                 "#{addstyle},a[:items]")
    c_parent.child_created(c) if c_parent.respond_to? :child_created
    c.sendMessage(WMsg::WM_SETFONT,a[:hfont],0) unless a[:hfont] == 0
    c.modules = a[:mods]
    c.form = a[:form]
    if newname == a[:name]
      c.oldname = a[:oldname]
    else
      c.oldname = a[:name]
    end
    c.registerd_to = a[:registerd_to].empty? ? [] :
          [c.parent.controls.find{|k,i|i.oldname == a[:registerd_to][0]}[1],
                                                            a[:registerd_to][1]]
    unless a[:registerd_to].empty?
      if (r0=c.registerd_to[0].substance).is_a? VRTwoPaneFrame
        if c.registerd_to[1] == 0
          if c.is_a? FDContainer
            r0.pane1[a[:regist_index],0]=c.substance
          else
            r0.pane1[a[:regist_index],0]=c
          end
        else
          if c.is_a? FDContainer
            r0.pane2[a[:regist_index],0]=c.substance
          else
            r0.pane2[a[:regist_index],0]=c
          end
        end
      elsif r0.is_a? VRGridLayoutFrame
        if c.is_a? FDContainer
          r0._vr_layoutclients[a[:regist_index],0]=c.substance
        else
          r0._vr_layoutclients[a[:regist_index],0]=[[c,c.x,c.y,c.w,c.h]]
        end
      else
        if c.is_a? FDContainer
          r0._vr_layoutclients[a[:regist_index],0]=c.substance
        else
          r0._vr_layoutclients[a[:regist_index],0]=c
        end
      end
      unless c.is_a? FDContainer
        c.extend(VRMargin).initMargin(a[:left],a[:top],a[:right],a[:bottom])
        c.margined = true
      end
    end
    if c.is_a?(FDContainer) && (cs=c.substance).is_a?(VRTwoPaneFrame)
      as = a[:substance]
      cs.ratio = as.ratio
      cs.position = as.position
      cs.gap = as.gap
      cs.bevel = as.bevel
      cs.lLimit = as.lLimit
      cs.setMargin(as.mgLeft,as.mgTop,as.mgRight,as.mgBottom)
      if cs.is_a?(VRHorizTwoPaneFrame)
        cs.rLimit = as.rLimit
      else
        cs.uLimit = as.uLimit
      end
    elsif cs && cs.is_a?(VRGridLayoutFrame)
      as = a[:substance]
      cs.instance_eval("@_vr_xsize = #{as.instance_eval("@_vr_xsize")}")
      cs.instance_eval("@_vr_ysize = #{as.instance_eval("@_vr_ysize")}")
      cs.setMargin(as.mgLeft,as.mgTop,as.mgRight,as.mgBottom)
    elsif cs && cs.is_a?(VRLayoutFrame)
      as = a[:substance]
      cs.setMargin(as.mgLeft,as.mgTop,as.mgRight,as.mgBottom)
    elsif cs
      as = a[:substance]
      if paste_mode
        cs=as.dup
      else
        cs=as
      end
    elsif c.is_a? VRTabbedPanel
      c._default_font = a[:_default_font]
      c.panels.each_index{|i|
#        c.panels[i].extend(FDCommonMethod)
#        c.panels[i].extend(FDParent).fd_parent_init
#        c.panels[i].extend CreateCtrl
        c.panels[i]._default_font = c._default_font
        a[:controls].find{|j| j[:name] == "panel#{i}"}[:controls].each{|j|
                                      recreate1(c.panels[i],j,[0,0],paste_mode)}
      }
    elsif c.is_a? VRRebar
      c.items.each{|i|
        recreate1(c,a[:controls].select{|j|
           j[:name]==i[0].sub(/^@/,'')}[0],[0,0],paste_mode)} if a[:items]
    elsif c.respond_to?(:addControl) then
      c._default_font = a[:_default_font]
      c.extend(FDCommonMethod)
      c.extend(FDParent).fd_parent_init
      c.extend CreateCtrl
      a[:controls].each{|i|recreate1(c,i,[0,0],paste_mode)}
      if paste_mode then
        c.controls.each{|k,i| i.oldname = i.name}
        c.oldname = c.name
      end
      c.sendMessage(WMsg::WM_SIZE,0,MAKELPARAM(c.w,c.h))
    end
    c
  end

  def recreateControl(cnt,parent = nil, style = nil)
    parent = cnt.parent unless parent
    idx = @tabOrders.index(cnt.etc)
    @tabOrders.delete_at(idx) if idx
    a = saveandclosewindow(cnt)
    @focused = recreate1(parent, a,[0,0], nil, style)
    @tabOrders[idx, 0] = @focused.etc if idx
    @focused.parent.sendMessage(WMsg::WM_SIZE,0,
                               MAKELPARAM(@focused.parent.w,@focused.parent.h))
    refreshInspect(@focused)
  end

  def deleteCont
    if @focused then
      if @focused.respond_to? :addControl then
        @focused.delete_child_controls
      end
      par = @focused.parent
      par.tabOrders.delete(@focused.etc)
      @focused.terminate if @focused.respond_to? :terminate
      @focused.parent.deleteControl(@focused)
      par.child_deleted(@focused) if par.respond_to? :child_deleted
      delete_serial_name(@focused.name)
      @focused = nil
      @focusExists = false
      refresh
      refreshCntName
      refreshInspect(nil)
      @parent.inc_modified
    end
  end
  
  def cutCont
    @copy_buff=[]
    @cut_mode=true
    @copy_buff << saveandclosewindow(@focused)
    @focused = nil
    @focusExists = nil
    refreshInspect(nil)
    refresh
  end
  
  def copyCont
    if @focused then
      @copy_buff=[]
      @copy_buff << save_window(@focused)
    end
  end
  
  def pasteCont
    unless @copy_buff.empty? then
      a=[]
      _ox=0; _oy=0
      _ox,_oy=getFormPos(@paste_to) if @paste_to
      @copy_buff[0][:x]=0;@copy_buff[0][:y]=0
      offset=[@selected_point.x-_ox,@selected_point.y-_oy]
      if @paste_to && @paste_to.respond_to?(:addControl) then
        @copy_buff.each{|c| a << recreate1(@paste_to,c,offset,!@cut_mode)}
      elsif @paste_to then
        @copy_buff.each{|c| a << recreate1(@paste_to.parent,c,offset,!@cut_mode)}
      else
        @copy_buff.each_with_index{|c,i| a << recreate1(self,c,offset,!@cut_mode)}
      end
      @cut_mode=nil
      @focused=a[0]
      refreshCntName
      refreshInspect(@focused)
      setFocusRgn(@focused)
      @focusExists=true
      refresh
    end
  end
  
  def backToParent
    return unless @focused
    if @focused.parent.parent.is_a? VRTabbedPanel
      @focused=@focused.parent.parent
    elsif @focused.parent != self
      @focused=@focused.parent
    else
      @focused = nil
      @focusExists=nil
    end
    c=@focused ? @focused : self
    setFocusRgn(@focused)
    refreshCntName
    refreshInspect(@focused)
    c.controls.each{|k,i|
      if i.is_a? FDContainer
        i.focus
        SetWindowPos.call(i.hWnd,1,0,0,24,24,3)
      end
    }
    c.refresh
  end
  
  def setWinStyle
    if @focused
      StyleDlg.args = [
      @focused.class,
        setWSArray(@focused.style,FDWStyle::CtlStyles),
        setWSOption(@focused.style,FDWStyle::CtlStyles),
        (FDWStyle::CtlStyles[@focused.class] ?
          FDWStyle::CtlStyles[@focused.class][:toggle] : nil)
      ]
      @parent.dialog_running = 'Window Style'
      r = @screen.openModalDialog self, nil, StyleDlg
      @parent.dialog_running = nil
      if r then
        ropt = r.shift
        rint = wsArray2int(r, FDWStyle::CtlStyles)
        st = ropt >= 0 ? rint | ropt : rint
        @focused.style = st
#        p [1235,@focused.style.to_x]
        recreateControl(@focused, nil, st)
#        p [1237,st.to_x,@focused.style.to_x]
        @parent.inc_modified
      end
    end
  end

  def _add_style(s2,style,hash)
    a=[]
     s2.each{|i| i1 = i.dup
      s = style & hash[@focused.class][:style][i1]
      a << [i1.to_s , (hash[@focused.class][:style][i1] != s ? 0 : 1)]
    }
    a
  end

  def setWSOption(style,hash)
    r = [0] ; a = [] ; n = 0
    if hash[@focused.class] && hash[@focused.class][:option] != {}
      a1 = hash[@focused.class][:option].dup.to_a.sort
      a1.each{|i|
        s = [i[0].dup,i[1]]
        ns = (s0=style & 0x3f) < 4 ? s0 : s0 & 0x3e
        r[0] = n if ns == s[1]
        a << s
        n += 1
      }
     r += a
    end
    r
  end

  def setWSArray(style,hash)
    a=[]
    if hash[@focused.class] then
      s2 = hash[@focused.class][:style].keys.dup
      a = a + _add_style(s2,style,hash)
    else
      s1 = FDWStyle::WStyles.keys.dup
      s1.each{|i| s = i.dup
        a << [s.to_s,((FDWStyle::WStyles[i] & style) == 0 ? 0 : 1)]
      }
    end
    a.sort
  end

  def wsArray2int(a,hash)
    r =0
    a.each{|i|
      if w = FDWStyle::WStyles[i[0]] then
        r |= w * i[1]
      else
        c = hash[@focused.class][:style][i[0]]
        r |=  c * i[1]
      end
    }
    r |= @focused.owndraw unless @focused.is_a? VRButton
    r
  end
  
  def setExStyle
  end
  
  def setModules
    if @focused then c=@focused else c=self end
    @moddlg.options["default"] = getModArray(c)
    @moddlg.move 0,0,104,195
    @parent.dialog_running = 'Modules'
    r = @moddlg.open(self)
    @parent.dialog_running = nil
    if r then
      c.modules.clear
      r.each{|i|
        c.set_modules(eval(i[0])) if i[1] == 1
      }
      @parent.inc_modified
    end
    refreshInspect(c)
  end

  def getModArray(c)
    r = []
    if c == self then
      FDModules::StdModules.each{|key,val|
        n = c.modules.include?(eval(key.to_s)) ? 1 : 0
        r << [key.to_s,n]
      }
      FDModules::FormModules.each{|key,val|
        n = c.modules.include?(eval(key.to_s)) ? 1 : 0
        r << [key.to_s,n]
      }
    else
      a = findPalletItem(c)
      a.mods.each{|key,val|
        n = c.modules.include?(eval(key.to_s)) ? 1 : 0
        r << [key.to_s,n]
        } if a
    end
    r
  end

  def showModDlg(a,w,h)
    @moddlg.options["default"]= a
    @moddlg.move 0,0,w,h
    @parent.dialog_running = 'Modules'
    r=@moddlg.open(self)
    @parent.dialog_running = nil
    if r then
      @parent.inc_modified
    end
    r
  end
  
  def ctrl_Tab_orders
    x0,y0,w0,h0=parent.windowrect
    TabOrderDlg.args={:x=>x0,:y=>y0,:c=>@focused.parent,:frm=>self}
    @parent.dialog_running = 'Tab order'
    @screen.modalform(self,0x02,TabOrderDlg)
    @parent.dialog_running = nil
    refreshInspect(@focused)
    @parent.inc_modified
  end
  
  def changeFocuse(s)
    c = findCtrl(s)
    if c then
      @focused = c
      setFocusRgn(c)
      @focusExists=true
    else
      @focused = nil
      @focusExists=false
    end
    refreshInspect(c)
    refresh
  end
  
  def ctrl_setFont(to_default = nil)
    def check_default(c,d)
      hf=c.sendMessage(WMsg::WM_GETFONT,0,0)
      hf=hf+0x100000000 if hf < 0
      c.is_a?(FDContainer) || !@_hsh_font[hf] || (d && hf == d.hfont)
    end

    if @focused then c = @focused else c = self end
    if c.respond_to? :addControl
      hf = c._default_font ? c._default_font.hfont : 0
    else
      hf=c.sendMessage(WMsg::WM_GETFONT,0,0)
      hf=hf+0x100000000 if hf < 0
    end
    
    if to_default
      return unless @_hsh_font[hf]
      newfont = c.parent._default_font if c.parent.respond_to? :_default_font
      dflt = nil
    else
      af = @_hsh_font[hf] ? [@_hsh_font[hf].params,0,0] :
                                      [["System",19,0,300,135,0,0,2,128],135,0]
      af[0][1]=(af[0][1]).abs.to_i if af
      @parent.dialog_running = 'Choose font'
      f = SWin::CommonDialog.chooseFont self, af
      @parent.dialog_running = nil
      if f then
        newfont=@_hsh_font[setFontHash(f)]
        dflt = newfont
        @parent.inc_modified
      else
        return
      end
    end
    
    c.setFont(newfont) unless c == self
    if c.respond_to? :addControl
      if c.is_a? VRTabbedPanel
        c.sendMessage(WMsg::WM_SIZE,0,MAKELPARAM(c.w,c.h))
        c.panels.each do |i|
          i.controls.each{|k,j| j.setFont(dflt) if
            check_default(i,c._default_font)}
          i._default_font=dflt
        end
      else
        c.controls.each do |id,j|
          j.setFont(dflt) if check_default(j,c._default_font)
        end
      end
      c._default_font=dflt
    else
      x0,y0,w0,h0=c.windowrect
      @focused.move(c.x,c.y,w0,h0)
      setFocusRgn(@focused)
    end
      
    refreshInspect(@focused)
  end
  
  def setValue(klass,val)
    klass = val
  end

  def setFontHash(f)
    unless  r=@_hsh_font.select{|k,v|
      f[0][0]==v.params[0] &&
      f[0][1]==v.params[1] &&
      f[0][2]==v.params[2] &&
      f[0][3]==v.params[3] &&
      f[0][4]==v.params[4] &&
      f[0][5]==v.params[5] &&
      f[0][6]==v.params[6] &&
      f[0][7]==v.params[7] &&
      f[0][8]==v.params[8]
    }[0] then
      f[0][3] = f[0][3]/100.to_i #weight
      ffont=@screen.factory.newfont *f[0]
      @_hsh_font[ffont.hfont]=ffont
      ffont.handle
    else
      r[0]
    end
  end
  
  def getFontHash(font_handle)
    @_hsh_font[font_handle]
  end
  
  def get_font_number(font_handle)
    return nil unless @_hsh_font[font_handle]
    unless (n=@_font_array.index(font_handle)) then
      @_font_array << font_handle
      @_font_array.size-1
    else
      n
    end
  end
  
=begin
  def showArrayEditDlg(a,w,h)
    @arrydlg.move 0,0,w,h #204,200
    @arrydlg.options["default"] = a.gsub(/\n/,"\r\n").gsub(/\t/,'\t')
    if r=@arrydlg.open(self) then
      r.gsub(/\\t/,"\t").gsub(/\r\n/,"\n").to_s
    end
  end
=end
  
  def setTrueFalse(str,svalue)
    if @focused then
      @focused.instance_eval("#{str}(#{svalue})")
    else #this form
      self.instance_eval "@frm_#{str}=svalue"
    end
  end
  
  def registerLayout
    x0,y0,w0,h0=parent.windowrect
    LayoutDlg.args={:x=>x0,:y=>y0,:c=>@focused ? @focused.parent : self,
      :frm=>self,:focused=>@focused}
    @parent.dialog_running = 'Register'
    r = @screen.openModalDialog(self,0x02,LayoutDlg)
    @parent.dialog_running = nil
    if r then
      if (s=@focused.substance).is_a? VRTwoPaneFrame
        r[0].each_with_index do |v,i|
          unless f = s.pane1.find{|j|
              if j.is_a? SWin::Window then j == v else j.container == v end }
            f =  v
            unless f.is_a? FDContainer
              f.extend(VRMargin).initMargin(0,0,0,0)
              f.margined = true
            end
          end
          unless f.is_a? SWin::Window then
            f.container.registerd_to = [@focused,0]
          else
            f.registerd_to = [@focused,0]
          end
          f = f.substance if f.is_a? FDContainer
          s.pane1.delete(f)
          s.pane1[i,0] = f
        end
        (s.pane1.size-1).downto(r[0].size){|j|
          c = s.pane1.delete_at(j)
          if c.is_a? SWin::Window
            c.registerd_to.clear
            c.setMargin(nil,nil,nil,nil)
            c.margined = nil
          else
            c.container.registerd_to.clear
          end
          } if r[0].size < s.pane1.size
        r[1].each_with_index do |v,i|
          unless f = s.pane2.find{|j|
              if j.is_a? SWin::Window then j == v else j.container == v
              end }
            f =  v
            unless f.is_a? FDContainer
              f.extend(VRMargin).initMargin(0,0,0,0)
              f.margined = true
            end
          end
          unless f.is_a? SWin::Window then
            f.container.registerd_to = [@focused,1]
          else
            f.registerd_to = [@focused,1]
          end
          f = f.substance if f.is_a? FDContainer
          s.pane2.delete(f)
          s.pane2[i,0] = f
        end
        (s.pane2.size-1).downto(r[1].size){|j|
          c = s.pane2.delete_at(j)
          if c.is_a? SWin::Window
            c.registerd_to.clear
            c.setMargin(nil,nil,nil,nil)
            c.margined = nil
          else
            c.container.registerd_to.clear
          end
        } if (r[1].size < s.pane2.size)
      elsif s.is_a? VRGridLayoutFrame
        r.each_with_index do |v,i|
          unless f = s._vr_layoutclients.find{|j|
              if j[0].is_a? SWin::Window then j[0] == v
                                                  else j[0].container == v end }
            if v.is_a? FDContainer
              f = [v.substance,0,0,v.parent.w,v.parent.h]
            else
              f =  [v,v.x,v.y,v.w,v.h]
            end
            if f[0].is_a? SWin::Window
              f[0].extend(VRMargin).initMargin(0,0,0,0)
              f[0].margined = true
            end
          end
          unless f[0].is_a? SWin::Window then
            f[0].container.registerd_to = [@focused,0]
          else
            f[0].registerd_to = [@focused,0]
          end
          f[0] = f[0].substance if f[0].is_a? FDContainer
          s._vr_layoutclients.delete(f)
          s._vr_layoutclients[i,0] = [f]
        end
        (s._vr_layoutclients.size-1).downto(r.size){|j|
          c = s._vr_layoutclients.delete_at(j)
          if c[0].is_a? SWin::Window
            c[0].registerd_to.clear
            c[0].setMargin(nil,nil,nil,nil)
            c[0].margined = nil
          else
            c[0].container.registerd_to.clear
          end
        } if r.size < s._vr_layoutclients.size
      else
        r.each_with_index do |v,i|
          unless f = s._vr_layoutclients.find{|j|
              if j.is_a? SWin::Window then j == v else j.container == v end }
            f = v
            unless f.is_a? FDContainer
              f.extend(VRMargin).initMargin(0,0,0,0)
              f.margined = true
            end
          end
          unless f.is_a? SWin::Window then
            f.container.registerd_to = [@focused,0]
          else
            f.registerd_to = [@focused,0]
          end
          f = f.substance if f.is_a? FDContainer
          s._vr_layoutclients.delete(f)
          s._vr_layoutclients[i,0] = f
        end
        (s._vr_layoutclients.size-1).downto(r.size){|j|
          c = s._vr_layoutclients.delete_at(j)
          if c.is_a? SWin::Window
            c.registerd_to.clear
            c.setMargin(nil,nil,nil,nil)
            c.margined = nil
          else
            c.container.registerd_to.clear
          end
          } if r.size < s._vr_layoutclients.size
      end
      @focused.parent.sendMessage(WMsg::WM_SIZE,0,
                               MAKELPARAM(@focused.parent.w,@focused.parent.h))
    end
    setFocusRgn(@focused)
    refreshInspect(@focused)
    refresh
  end
  
  def make_fonts_str(a)
    return  nil if a.empty?
    r = "[\n"
    a.each{|i|
      f=@_hsh_font[i].params.to_a
      f[0]="\'#{f[0]}\'"
      f[3]=f[3]/100
      r+="      VRLocalScreen.factory.newfont(#{f.join(',')}),\n"}
    r[r.size-2,1]=""
    r+="    ]\n"
    r
  end
  
  def get_require
    @modules.each{|m|
      if rq = FDModules::FormModules["#{m}".intern ] then
        (@required << rq.requires).uniq!
      elsif rq = FDModules::StdModules["#{m}".intern ] then
        (@required << rq.requires).uniq!
      end
    }
    @required.reject!{|i| !i}
    @required
  end

  def ex_include
    r = ""
    @included.uniq!
    @modules.uniq!
    @included.each{|s| r += "  include #{s} if defined? #{s}\n" if s} unless @included.empty?
    @modules.each{|s| r += "  include #{s}\n" if s} unless @modules.empty?
    r
  end
  
  def examine
    a=[]
    @cntnmodules=[]
    rf = []
    rc = []
    ctls = @controls.dup
    x0,y0,w0,h0=self.windowrect
    str = "\n  def construct\n"
    n = str.size
    str += "    self.sizebox=#{@frm_sizebox}\n" if @frm_sizebox == 'false'
    str += "    self.maximizebox=#{@frm_maximizebox}\n" if @frm_maximizebox == 'false'
    str += "    self.caption = '#{self.caption}'\n"
    str += "    self.move(#{x0},#{y0},#{w0},#{h0})\n"
    
      analize_frame = lambda do |frame|
        if frame.is_a? VRTwoPaneFrame
          frame.pane1.each do |i|
            unless i.is_a? SWin::Window
              analize_frame.call(i)
              c = ctls.delete(i.container.etc)
              rf << c.createSourceStr
            end
          end
          frame.pane2.each do |i|
            unless i.is_a? SWin::Window
              analize_frame.call(i)
              c = ctls.delete(i.container.etc)
              rf << c.createSourceStr
            end
          end
        elsif frame.is_a? VRGridLayoutFrame
          frame._vr_layoutclients.each do |i|
            unless i[0].is_a? SWin::Window
              analize_frame.call(i)
              c = ctls.delete(i[0].container.etc)
              rf << c.createSourceStr
           end
          end
        else
          frame._vr_layoutclients.each do |i|
            unless i.is_a? SWin::Window
              analize_frame.call(i)
              c = ctls.delete(i.container.etc)
              rf << c.createSourceStr
            end
          end
        end
      end
    
    if @__regsterd_vr_margined_frame
      analize_frame.call(@__regsterd_vr_margined_frame)
      c = ctls.delete(@__regsterd_vr_margined_frame.container.etc)
      rf << c.createSourceStr
    end
    
    ctls.each do |k,i|
      if i.is_a? FDContainer
        c = ctls.delete(i.etc)
        if i.substance.is_a? VRMenu
          str += c.createSourceStr
        else
          rc << c.createSourceStr
        end
      end
    end
    @tabOrders.each do |id|
      item = ctls.delete(id)
      item.style = item.style | WStyle::WS_TABSTOP
      (@required << 'vrowndraw').uniq! if item.respond_to?(:owndraw) &&
                                                          item.owndraw > 0 
      target=item
      str += target.createSourceStr
      item.style = item.style-WStyle::WS_TABSTOP
    end
    ctls.each do |id,item|
      (@required << 'vrowndraw').uniq! if item.respond_to?(:owndraw) &&
                                                          item.owndraw > 0 
      str += item.createSourceStr if item.respond_to? :createSourceStr
    end
    str += rf.to_s
    str += rc.to_s
    str += "  end \n\n"
    str
  end

  def linscan(a,ptn)
    n = 0 ; r = nil
    while a.size-1 >= n do
      if a[n] =~ ptn then
        r = n+1 ; break
      end
      n += 1
    end
    r
  end

  def linscan2(a,ptn1,ptn2 = nil, n = 0)
    r = nil
    while a.size-1 >= n do
      if a[n] =~ ptn2 then
        break
      elsif a[n] =~ ptn1 then
        r = n+1 ; break
      end
      n += 1
    end
    r
  end

  def make_executive
    @_font_array.clear
    s = examine
    s[0,0] = @cntnmodules.join("") if @cntnmodules
    s[0,0] = "  include VRContainersSet\n" if @type_of_form<=VRDialogComponent
    s[0,0] = ex_include
    s[0,0] = getDEFAULTFONT("  ") if @_default_font
    s[0,0] ="  #{self.name.capitalize1}_fonts="+
                    "#{make_fonts_str(@_font_array)}" unless @_font_array.empty?
    s[0,0] = "\nclass #{self.name.capitalize1} < #{@type_of_form}\n"
    s += "end\n"
    s
  end
  
  def check_rejectable_modules(j)
    j==VRToolbarUseable || j==VRStdControlContainer || 
    j==VRComCtlContainer || j==VRMarginedFrameUseable ||
    j==VRContainersSet || j==VROwnerDrawControlContainer
  end

  def readfile(str)
#    str = ""
    parser = FDParser.new(self,true)
#    if f then
      r = true
#      begin
#        open(f){|ff|
#          $tstamp=ff.stat.mtime.to_i
#          ff.each  do |lin|
#            str+=lin
#          end
#        }
        @buff,@nodes,@variables = parser.parse str
        @modules = @nodes["modules"].collect!{|i| eval(i)}.delete_if{|j|
          check_rejectable_modules(j)
        }
        set_controls(self,@nodes)
        set_variables(@variables)
#        refreshCntName
#      rescue
#        messageBox "\nIf you are not going to open the file of an old version\n" +
#                   "or you edited manually,then please contact me.\n\n#{$!}",
#                    "File Reading Error - #{f}",16
#        r = false
#      end
#    end
#    refreshInspect(nil)
    r
  end
  
  def parse_str(s)
    parser = FDParser.new(self)
    @buff,@nodes,@variables = parser.parse s
    @modules = @nodes["modules"].collect!{|i| eval(i)}.delete_if{|j|
      check_rejectable_modules(j)
    }
    set_controls2(self,@nodes)
#    set_variables(@variables)
  end
  
  def set_controls(c_parent,nodes)
    if c_parent.is_a? VRTabbedPanel
      c_parent.panels.each{|i|
        no=nodes["childs"].select{|j| j["name"] =~ /#{i.name}$/}[0]
        set_controls(i,no)
      }
    end
    r=nil
    nodes["addings"].each{ |i|
      mtd=findPalletItem(i[0]).createMethod
      ctrl=instance_eval("#{mtd}(c_parent,*i)")
      @names << ctrl.name
      unless (f1 = nodes["fonts"]) == {} then
        if f2 = f1["@"+i[1]] then
          if f2.is_a? Integer then
            ctrl.setFont(@_hsh_font[@temp_fonts[f2].hfont])
          else #for old form file
            f = f2
#            ffont=@screen.factory.newfont(f.fontface,f.height,f.style,
#                (f.weight / 100),f.width, f.escapement, f.orientation,
#                f.pitch_family,f.charset,f.point,f.color)
            ffont=setFontHash(f)
            ctrl.setFont(@_hsh_font[ffont])
            ctrl._default_font = @_hsh_font[ffont] if
                                                ctrl.respond_to? :_default_font
          end
        end
      end
      if ctrl.respond_to?(:addControl) && ctrl.class != FDContainer then
        ctrl.extend FDCommonMethod
        ctrl.extend(FDParent).fd_parent_init
        ctrl.extend CreateCtrl
#        r = nodes["childs"].select{|n| n["name"]=="Cntn_#{ctrl.name}"}[0]
        r = nodes["childs"].select{|n| n["name"]=~/Cntn\w*_#{ctrl.name}$/}[0]
        ctrl.modules = r["modules"].collect!{|i| eval(i)}.delete_if{|j|
          check_rejectable_modules(j)
        } if r
        set_controls(ctrl,r)
      else
        r = nodes["childs"].select{|n| n["name"]=~/Extn\w*_#{ctrl.name}/}[0]
        ctrl.modules = r["modules"].collect!{|i| eval(i)}.delete_if{|j|
          check_rejectable_modules(j)
        } if r
      end
      ctrl.parent.child_created(ctrl) if ctrl.parent.respond_to? :child_created
    }
  end
  
  def set_controls2(c_parent,nodes)
    str2inst = lambda do |_ctls|
      if _ctls.is_a?(String)
        [c_parent.instance_eval(_ctls)]
      elsif _ctls.is_a?(Array)
        _ctls.map do |i|
          if i.is_a? Array
            str2inst.call(i)
          elsif i.is_a?(String)
            c_parent.instance_eval(i)
          else
            i
          end
        end
      else
        [_ctls]
      end
    end
    if c_parent.is_a? VRTabbedPanel
      c_parent.panels.each{|i| 
        no=nodes["childs"].select{|j| j["name"] == i.name.capitalize1 }[0]
        set_controls2(i,no)
      }
    end
    c_parent.setFont(@temp_fonts[nodes["fonts"]["self"]]) if
                                                         nodes["fonts"]["self"]
    c_parent._default_font=@temp_fonts[nodes.default_font] if nodes.default_font
    r=nil
    nodes["addings"].each{|i|
      mtd=findPalletItem(i[0]).createMethod
      i[7] = 0 unless i[7]
      if (i[7] & 0x10000) == 0x10000
        i[7] &= ~0x10000
        ctrl=instance_eval("#{mtd}(c_parent,*i)");
        c_parent.tabOrders << ctrl.etc
      else
        ctrl=instance_eval("#{mtd}(c_parent,*i)");
      end
      @names << ctrl.name
      if (f1 = nodes["fonts"]) != {} && (f2 = f1["@"+i[1]])
        ctrl.setFont(@_hsh_font[@temp_fonts[f2].hfont]) if f2.is_a? Integer
      end
      if ctrl.respond_to?(:addControl) && ctrl.class != FDContainer then
        ctrl.extend FDCommonMethod
        ctrl.extend(FDParent).fd_parent_init
        ctrl.extend CreateCtrl
        r = nodes["childs"].select{|n| n["name"]=~/#{ctrl.name.capitalize1}$/}[0]
        ctrl.modules = r["modules"].collect!{|i| eval(i)}.delete_if{|j|
          check_rejectable_modules(j)
        } if r
        ctrl.modules.uniq!
        set_controls2(ctrl,r)
      else
        r = nodes["childs"].select{|n| n["name"]==ctrl.name.capitalize1}[0]
        ctrl.modules = r["modules"].collect!{|i| eval(i)}.delete_if{|j|
          check_rejectable_modules(j)
        } if r
        ctrl.modules.uniq!
      end
      ctrl.parent.child_created(ctrl) if ctrl.parent.respond_to? :child_created
    }    
    nodes.methods.each{|i|
      case i[1]
      when 'sizebox=','maximizebox='
        instance_eval "@frm_#{i[1]}'#{i[2]}'"
      when /^ctn_([a-z][a-zA-Z0-9_]*)=/
        instance_eval("@#{$1}").set_attrs(i[2])
      else
        if (c=c_parent.instance_eval(i[0])).is_a? FDContainer
          if c.substance.is_a? VRMenu
            c.send(i[1],*str2inst.call(i[2]))
          else
            c.substance.send(i[1],*str2inst.call(i[2]))
          end
        else
          c.send(i[1],*str2inst.call(i[2]))
        end
      end
    }
  end
  
  def makeModStruct(cnt,parent=nil)
    ms=ModStruct.new(cnt.oldname.capitalize1,cnt.name.capitalize1,parent)
    cnt.controls.each{|k,i|
      next if i.is_a?(FDCoverPanel)
      if i.respond_to?(:addControl)
        ms.childs << makeModStruct(i,ms)
      elsif !i.modules.empty? || (i.owndraw > 0)
        ms.childs << ModStruct.new(i.name.capitalize1,i.oldname.capitalize1,ms)
      end
    }
    ms
  end
  
  def set_variables(variables)
    variables.each{|var,val|
      case var
      when 'sizebox','maximizebox'
        instance_eval "@frm_#{var}='#{val}'"
      when /^ctn_(\w+)/
        instance_eval "@#{$1}.move #{val[0]},#{val[1]},24,24"
        instance_eval "@#{$1}.set_attrs val[2,val.size-2]"
      else
      end
    }
  end
  
  def self_dropfiles(files)
    parent.open_by_drop(files[0])
  end
  
  def self_gotfocus
    parent.designfrm=self
    parent.window_menu_set_check(self.etc)
    refreshCntName
    refreshInspect(@focused)
  end
  
  def self_resize(x,y)
    x,y,w,h = self.clientrect
    DeleteObject.Call(@hrgn)
    @hrgn=CreateRectRgn.Call(x,y,w,h)
    SelectClipRgn.Call(@dc,@hrgn)
    a=windowrect
    $ini.write "designform","top",a[0]
    $ini.write "designform","left",a[1]
    $ini.write "designform","width",a[2]
    $ini.write "designform","height",a[3]
    refreshInspect(nil)
  end
  
  def self_move(x0,y0)
    refreshInspect(self) unless @focused
    parent.inc_modified
  end
  
  def self_close
    SKIP_DEFAULTHANDLER
  end
  
end
