# fdcfg.rb
# Configuration File of FormDesigner for Visualu Ruby
#
# Programmed by yukimi_sake@mbi.nifty.com
# Copyright 2001-2003 Yukio Sakaue

require 'fdvr/fdcontrols'
require 'fdvr/fddialogs'

class VRControl
  def setFont(font,redraw=true)
    if self.dopaint then
      super font
    end
    if font.is_a?(SWin::Font) then
      self.properties["font"]=font
      sendMessage WMsg::WM_SETFONT,font.hfont, ( (redraw)? 1 : 0 )
    elsif !font
      sendMessage WMsg::WM_SETFONT,0,1
      self.properties["font"]=nil
    else
      raise "#{font} is not a font."
    end
  end
end

class VRLayoutFrame  
  def reset_registerd
    @_vr_layoutclients.each do|i|
      if i.is_a? SWin::Window
        i.setMargin(nil,nil,nil,nil)
      elsif i
        i.reset_registerd
      end
      i.registerd_to.clear
    end
  end
end

class VRTwoPaneFrame
  module VRTwoPaneFrameUsable
    def self_vrsepl2buttondown(s,x,y)
      @_vr_twopaneframes.each do |f|
        if f.hittest(x,y)
          f.setDragCur
          f.dragstart 
          @_vr_current_tpframe=f
          @_fd_dragging=true
        end
      end
    end

    def self_vrsepl2buttonup(s,x,y)
      @_vr_current_tpframe=nil
      @_vr_twopaneframes.each do |f|
        f.dragend
        @_fd_dragging=false
      end
      refresh
    end
  end
  
  def reset_registerd
    if @pane1.is_a? Array
      @pane1.each do|i|
        if i.is_a? SWin::Window
          i.setMargin(nil,nil,nil,nil)
          i.registerd_to.clear
        else
          i.reset_registerd
          i.container.registerd_to.clear
        end
      end
    elsif @pane1
      if @pane1.is_a? SWin::Window
        @pane1.setMargin(nilnilnilnil)
        @pane1.registerd_to.clear
      else
        @pane1.reset_registerd
        @pane1.container.registerd_to.clear
      end
    end
    if @pane2.is_a? Array
      @pane2.each do|i|
        if i.is_a? SWin::Window
          i.setMargin(nil,nil,nil,nil)
          i.registerd_to.clear
        else
          i.reset_registerd
          i.container.registerd_to.clear
        end
      end
    elsif @pane2
      if @pane2.is_a? SWin::Window
        @pane2.setMargin(nilnilnilnil)
        @pane2.registerd_to.clear
      else
        @pane2.reset_registerd
        @pane2.container.registerd_to.clear
      end
    end
  end
end

module VRMarginedFrameUseable
  module VRMgdLayoutFrame
    def register(*ctls)
      @_vr_layoutclients.concat(ctls.flatten.map{|i|
        unless  $subwnd
          i.registerd_to = [self.container,0]
          unless i.is_a?(FDContainer)
            i.margined = true
            i.extend(VRMargin).initMargin(0,0,0,0)
            i
          else
            i.substance
          end
        else
          i.extend(VRMargin).initMargin(0,0,0,0) unless i.is_a?(FDContainer)
        end
      })
      _vr_relayout
    end
  end

  class VRMgdGridLayoutFrame
    def register(*ctls)
      if ctls[0].is_a? Array
        ctls.each do|i|
          unless $subwnd
            i[0].margined = true
            i[0].registerd_to = [self.container,0]
          end
          i[0].extend(VRMargin).initMargin(0,0,0,0) unless
                                                         i[0].is_a?(FDContainer)
          super(*i)
        end
      else
        unless $subwnd
          ctls[0].margined = true
          ctls[0].registerd_to = [self.container,0]
        end
        ctls[0].extend(VRMargin).initMargin(0,0,0,0) unless
                                                      ctls[0].is_a?(FDContainer)
        super
      end
    end
  end
  
  class VRMgdVertTwoPaneFrame
    alias :_vr_draw_bevel_org :_vr_draw_bevel
    
    def _vr_draw_bevel(win)
      _vr_draw_bevel_org(win) if $subwnd || !@container.registerd_to.empty? ||
          (window_parent.__regsterd_vr_margined_frame == self)
    end
  end
  
  class VRMgdHorizTwoPaneFrame
    alias :_vr_draw_bevel_org :_vr_draw_bevel
    
    def _vr_draw_bevel(win)
      _vr_draw_bevel_org(win) if  $subwnd ||  !@container.registerd_to.empty? ||
          (window_parent.__regsterd_vr_margined_frame == self)
    end
  end
end

module ExecuteDesignfrm
  include VRDestroySensitive
#  include VRMouseFeasible
  
  def vrinit
    super
    $subwnd = self
  end
  def self_destroy
    $main.exitExec if $main.alive?
    $subwnd = nil
  end
end

class Array
  def format
    r = "[\n"
    self.each{|i|
      if i == self.last
        r += "  " + i.inspect + "\n"
      else
        r += "  " + i.inspect + ",\n"
      end
    }
    r += "]\n"
  end
end

class Integer
  def to_x
    sprintf "%#x" ,self
  end
end

class String
  def esc
    self.gsub /\"/,'\"'
  end
  
end

class MenuStrMaker
  def _analize(ar,mn=nil)
    @ar += "  "*@n + "[\"#{mn}\",[\n" if mn
    ar.each{|i|
      if i[1].is_a? Array then
        @n += 1
        _analize(i[1],i[0])
        @ar[@ar.size-1,0]=','
      else
        @ar += "  "*(@n+1) + i.inspect + ",\n"
      end
    }
    @ar[@ar.size-2,1]="]"
    @ar += "  "*@n + "]\n"
    @n -= 1
  end
  
  def makeStr(ar)
    @ar="[\n"
    @n = 0
    _analize(ar)
    @ar[@ar.size-4,1]=''
    @ar
  end
end

module FDCommonMethod
  attr :controls

  def vrinit
    super
    @controls={}
  end

  def setcontrols(contorls)
    @controls = contorls
  end

  def checkfocus(x,y)
    p=[0,0,0x100000000,0x100000000]
    r = nil
    @controls.each { |i,c|
      unless c.is_a?(VRToolbar::VRToolbarButton) || c.is_a?(FDCoverPanel) ||
             !c.visible?
        if (c.x < x) && (c.x+c.w > x) &&
                (c.y < y ) && (c.y+c.h > y) then
          if p[0]<c.x || p[1]<c.y || p[2] >c.w || p[3]>c.h then
            p=[c.x,c.y,c.w,c.h]
            r=c
            if c && c.respond_to?(:addControl) && c.visible? then
              r1 = c.checkfocus(x-c.x,y-c.y)
              r=r1 if r1
            end
          end
        end
      end
    }
    r
  end

  def findCtrl(s)
    c=nil
    @controls.each { |id,item|
      if item.respond_to?(:addControl) then
       return c if c = item.findCtrl( s )
      end
      return item if item.name == s
    }
    c
  end

end


module WMsg
  RB_IDTOINDEX = WM_USER + 16
end

module FDDraggable
  include VRMessageHandler
  def draggable_init
    if self.is_a? VRPanel
      addHandler WMsg::WM_PAINT,  "vrsepl2paint",  MSGTYPE::ARGNONE,nil
      acceptEvents [WMsg::WM_PAINT]
    else
      hookwndproc unless hookedwndproc?
    end
    addHandler WMsg::WM_LBUTTONDOWN,"lbuttondown",MSGTYPE::ARGLINTINT,nil
    addHandler WMsg::WM_MOUSEMOVE,  "mousemove",MSGTYPE::ARGINTINTINT,nil
    addHandler WMsg::WM_LBUTTONUP,  "lbuttonup",  MSGTYPE::ARGLINTINT,nil
    addHandler WMsg::WM_RBUTTONUP,  "rbuttonup",  MSGTYPE::ARGINTSINTSINT,nil
    addHandler WMsg::WM_RBUTTONDOWN,"rbuttondown",MSGTYPE::ARGINTSINTSINT,nil
    addHandler WMsg::WM_SIZE, "resize",MSGTYPE::ARGLINTINT,nil
    acceptEvents [WMsg::WM_LBUTTONUP,WMsg::WM_RBUTTONUP,
                  WMsg::WM_LBUTTONDOWN,WMsg::WM_RBUTTONDOWN,
                  WMsg::WM_MOUSEMOVE,WMsg::WM_SIZE]

  end

  def self_lbuttondown(x,y)
    self.substance.move(self.x,self.y,w,h) if self.is_a? FDCoverPanel
    @parent.send "self_lbuttondown",
               (x < 0xefff ? x+self.x : x+self.x-0x10000),
    (y < 0xefff ? y+self.y : y+self.y-0x10000)
    SKIP_DEFAULTHANDLER unless self.is_a? VRTabControl
  end
  
  def self_mousemove(shift,x,y)
    @parent.send :self_mousemove,shift,
               (x < 0xefff ? x+self.x : x+self.x-0x10000),
               (y < 0xefff ? y+self.y : y+self.y-0x10000)
  end

  def self_lbuttonup(x,y)
    x0,y0,w0,h0=self.windowrect
    x0=self.x
    y0=self.y
    if respond_to? :initMargin then
      x0 = x0 - (mgLeft ? mgLeft : 0)
      y0 = y0 - (mgTop ? mgTop : 0)
      w0 = w0 + (mgLeft ? mgLeft : 0) + (mgRight ? mgRight : 0)
      h0 = h0 + (mgTop ? mgTop : 0) + (mgBottom ? mgBottom : 0)
    end
    self.move(x0,y0,w0,h0)
    @parent.send "self_lbuttonup",
               (x < 0xefff ? x+self.x : x+self.x-0x10000),
               (y < 0xefff ? y+self.y : y+self.y-0x10000)
    SKIP_DEFAULTHANDLER unless self.is_a? VRTabControl
  end

  def self_rbuttondown(shift,x,y)
    @parent.send "self_rbuttondown",shift,
               (x < 0xefff ? x+self.x : x+self.x-0x10000),
               (y < 0xefff ? y+self.y : y+self.y-0x10000)
    SKIP_DEFAULTHANDLER
  end

  def self_resize(w,h)
    if self.is_a? VRTabbedPanel
      x,y,w,h = adjustRect(0,0,self.w,self.h,false)
      @panels.each{|i| i.move x,y,w-x,h-y }
    else
    end
  end
  
  def self_vrsepl2paint
    nil
  end
end

module CreateCtrl
  require 'fdvr/fduser' #user defined configuration
  include FDControls

  attr_reader :cmodules, :cinfo, :_vr_menu, :_hsh_font, :required, :modules

  Stylehash = {
      "TBSTYLE_BUTTON"        => 0,
      "TBSTYLE_SEP"           => 1,
      "TBSTYLE_CHECK"         => 2,
      "TBSTYLE_GROUP"         => 4,
      "TBSTYLE_CHECKGROUP"    => 6
    }
  Indent_Str = '  '
  
  module FDControlExt
    attr_reader :__org_x,:__org_y,:__org_w,:__org_h
    attr_accessor :form , :oldname, :items , :modules, :owndraw,
                  :registerd_to, :margined, :_default_style
    def _ext_init()
      @modules = []; @owndraw = 0; @taborder = -1; @form = @parent.form;
      @oldname = @name ;@registerd_to = [] ;@margined = nil
      @_default_style = 0
    end
    def set_modules(m); (@modules << m).uniq!; end
    def get_parents_str(c)
      return "" if c.is_a? VRForm
      s = "_#{c.name}"
      s[0,0] = get_parents_str(c.parent) unless c.parent.is_a? VRForm
      s
    end
    
    def getLevel(c)
      if c.is_a?(VRForm) || c.is_a?(VRDialogComponent) then
        ""
      else
        getLevel(c.parent) + Indent_Str
      end
    end
    
    def owndraw_used?
      FDOwnerDraw::ODConst[self.class].each{|key,value|
        return key if value == @owndraw } if @owndraw != 0
      'not used'
    end
    
    def tab_order
      if (self.style & WStyle::WS_TABSTOP) == 0 then
        ""
      else
        @taborder.to_s
      end
    end
    
    def set_owndraw(state)
      unless @owndraw=FDOwnerDraw::ODConst[self.class][state]
        @owndraw=0
      end
    end
    
    def mk_addstr(cnt,name,caption,x,y,w,h,sty)
      st = ','+sprintf("%#x",sty) unless sty == 0
      "addControl(#{cnt},'#{name}',\"#{caption}\",#{x},#{y},#{w},#{h}#{st})\n"
    end
  end

  module FDParent
    include FDCommonMethod, CreateCtrl, VRContainersSet
    
    attr_reader :included, :names, :cntnmodules,
                :_fd_dragging, :_vr_twopaneframes
    attr_accessor :tabOrders, :__regsterd_vr_margined_frame,
                  :_default_font, :_prev_dflt_hfont
    
    def fd_parent_init()
      vrinit; @included = []; @tabOrders=[]; @cntnmodules=[]
    end
    
    def addControl(*args)
      r = super
      if @_default_font then
        r.setFont(@_default_font)
      end
      r
    end

    def delete_child_controls
      @controls.each{|k,v|
        deleteControl(v)
        @form.delete_serial_name(v.name)
        delete_child_controls if v.respond_to? :addControl
      }
    end
    
    def getDEFAULTFONT(lv)
      return "" unless @_default_font
      hf=@_default_font.hfont
      n = @form.get_font_number(hf)
      "#{lv}  DEFAULT_FONT=#{@form.name.capitalize1}_fonts[#{n}]\n"
    end

    def getFontStrParent(lv)
      return "" if !@_default_font || self.parent.is_a?(VRTabbedPanel)
      hf = @_default_font.hfont
      if (n = @form.get_font_number(hf))
        lv + "    self.setFont(#{@form.name.capitalize1}_fonts[#{n}])\n"
      else  "" end
    end
    
    def get_childs_source(novrinit=nil)
      ctls = @controls.dup
      @cntnmodules=[]
      r=[]
      rf=[]
      lv=getLevel(self)
      s="\n"+lv+"class #{self.name.capitalize1} < #{self.class}\n"; sattr=""
      incld1 = []
      @modules.uniq!
      analize_frame = lambda do |frame|
        if frame.is_a? VRTwoPaneFrame
          frame.pane1.each do |i|
            unless i.is_a? SWin::Window
              analize_frame.call(i)
              c = ctls.delete(i.container.etc)
              rf << yield(c)
            end
          end
          frame.pane2.each do |i|
            unless i.is_a? SWin::Window
              analize_frame.call(i)
              c = ctls.delete(i.container.etc)
              rf << yield(c)
            end
          end
        elsif frame.is_a? VRGridLayoutFrame
          frame._vr_layoutclients.each do |i|
            unless i[0].is_a? SWin::Window
              analize_frame.call(i)
              c = ctls.delete(i[0].container.etc)
              rf << yield(c)
           end
          end
        else
          frame._vr_layoutclients.each do |i|
            unless i.is_a? SWin::Window
              analize_frame.call(i)
              c = ctls.delete(i.container.etc)
              rf << yield(c)
            end
          end
        end
      end
      
      if @__regsterd_vr_margined_frame
        analize_frame.call(@__regsterd_vr_margined_frame)
        c = ctls.delete( @__regsterd_vr_margined_frame.container.etc)
        rf << yield(c)
      end
      @tabOrders.each{|id| item = ctls.delete(id)
        next if item.class == FDCoverPanel
        if item.is_a? VRNotifyControl then
          (incld1 << "VRComCtlContainer").uniq!
        else
          (incld1 << "VRStdControlContainer").uniq!
        end
        (@modules << "VROwnerDrawControlContainer").uniq! if item.owndraw > 0
        sattr += lv+"  attr_reader :#{item.name}\n"
        item.style = item.style+WStyle::WS_TABSTOP
        r << yield(item)
      }
      
      ctls.each{|id,item|
        next if @tabOrders.index(id)
        next if item.class == FDCoverPanel
        if item.is_a? VRNotifyControl then
          (incld1 << "VRComCtlContainer").uniq!
        else
          (incld1 << "VRStdControlContainer").uniq!
        end
        (@modules << "VROwnerDrawControlContainer").uniq! if item.owndraw > 0
        sattr += lv+"  attr_reader :#{item.name}\n"
        r << yield(item)
      }
      unless @modules.empty? then
        incld1 = incld1 + @modules
        @modules.each{|m|
          if rq = FDModules::StdModules["#{m}".intern ] then
            (@form.required << rq.requires).uniq!
            @form.required.reject!{|i| !i} #delete nil
          end
        }
      end
      s1 = []
      incld1.each{|i| s1 << lv+"  include #{i}"}
      @included.each{|m| s1 << lv+"  include #{m} if defined? #{m}" if m}
      s += s1.join("\n") + "\n"
      s += getDEFAULTFONT(lv) if @_default_font
      s += sattr
      s += @cntnmodules.join("") if @cntnmodules
      s += "\n#{lv}  def construct\n"
#      s += getFontStrParent(lv)
      s += r.to_s
      s += rf.to_s
      s += lv+"  end\n"
      s += lv+"end\n"
      s
    end

    def set_include(i)
      @included << i
      @included.uniq!
    end

  end

  module STDSourceMaker

    def getFontStr(lv)
      hf=sendMessage(WMsg::WM_GETFONT,0,0)
      hf=hf+0x100000000 if hf < 0
      if  (n = @form.get_font_number(hf)) &&
             (!@parent._default_font || @parent._default_font.hfont != hf)
        lv + "  @#{name}.setFont(#{@form.name.capitalize1}_fonts[#{n}])\n"
      else  "" end
    end
        
    def addRequire
      unless @modules.empty? then
        @modules.each{|m|
          if rq = FDModules::StdModules["#{m}".intern ] then
            (@form.required << rq.requires).uniq!
            @form.required.reject!{|i| !i}
          end
        }
      end
    end

    def addModules
      sp=get_parents_str(self.parent)
      lv=getLevel(self)
      ms = lv+"class #{name.capitalize1} < #{self.class}\n"
      @modules.each{|m|
        ms += lv+"  include #{m}\n";
        (@form.required << FDModules::StdModules["#{m}".intern ].requires).uniq!
        @form.required.reject!{|i| !i}
      }
      ms += lv+"end\n\n"
      @parent.cntnmodules << ms
    end

    def createStdSourceStr
      if respond_to? :initMargin
        x0=@__org_x; y0=@__org_y; w0=@__org_w; h0=@__org_h
      else
        x0,y0,w0,h0 = self.windowrect; x0=self.x; y0=self.y
      end
      str = ""
      sty = (self.style|@owndraw)-@_default_style
      sp = get_parents_str(self.parent)
      lv = getLevel(self)
      cnt = self.class.to_s
      if respond_to?(:addControl) then
        str += lv + "  " +
                mk_addstr(name.capitalize1,name,caption.esc,x0,y0,w0,h0,sty)
        @parent.cntnmodules << get_childs_source{|i| i.createSourceStr}
        addRequire
      elsif !@modules.empty? || @owndraw > 0 then
        str += lv + "  " +
                mk_addstr(name.capitalize1,name,caption.esc,x0,y0,w0,h0,sty)
        addModules
      else
        str += lv+"  "+ mk_addstr(cnt,name,caption.esc,x0,y0,w0,h0,sty)
      end
      str+= getFontStr(lv)
      str
    end

    def createSourceStr
      createStdSourceStr
    end

  end
  
  def set_modules(m) (@modules << m) ; @modules.uniq! end

  def findPalletItem(cnt)
    r = nil
    if cnt.is_a? FDStruct then
        return cnt
    else
      if cnt.respond_to?(:substance) then
        c = cnt.substance
      else
        c = cnt
      end
      
      $conf.each{|pallet|
        r = pallet.items.find{|i| (c == i.klass) || (c.class == i.klass)}
        return(r) if r
      }
    end
    r
  end

  def set_cnt_attr(a,cnt)
    @required = [] unless @required
    @required << cnt.required
    @required.uniq!
    @cmodules={} unless @cmodules
    @cinfo={} unless @cinfo
    @cmodules[a.etc]=a.inspect.sub(/#<(.+):.*>/,'\1')
    @cinfo[a.etc]=cnt.klass
    a.extend(FDDraggable).draggable_init
    a.extend(FDControlExt)._ext_init
    a._default_style = cnt.default_style
  end
  
  def check_owndraw(c,addstyle)
    if ods = FDOwnerDraw::ODConst[c.klass] then
      ods.each{|key,value|
        return value if addstyle & value != 0 
      }
    end
    0
  end
  
  #definiton of creating methods on FormDesigner

  def newFDCtrl(prnt,cnt,name,caption,x,y,w,h,addstyle=0,c_items=nil)
    c = findPalletItem(cnt)
    od = check_owndraw(c,addstyle)
    addstyle -= od if c.klass <= VRButton
    a = prnt.addControl(c.klass,name,caption,x,y,w,h,addstyle )
    prnt.set_include(c.included)
    a.extend STDSourceMaker
    set_cnt_attr(a,c)
    a.owndraw = od
    a.extend(FDParent).fd_parent_init if a.respond_to?(:addControl)
    a
  end

  module FDComboExt
    attr :drop_h,1
    include STDSourceMaker
  end

  def newFDCombo(prnt,cnt,name,caption,x,y,w,h,addstyle=0,c_items=nil)
    c = findPalletItem(cnt)
    addstyle |= 1 if c.klass == VREditCombobox
    od = check_owndraw(c,addstyle)
    addstyle -= od
    a=prnt.addControl(c.klass,name,caption,x,y,w,h,addstyle )
    a.extend FDComboExt
    prnt.set_include(c.included)
    
    def a.createSourceStr
      if respond_to? :initMargin
        x0=@__org_x; y0=@__org_y; w0=@__org_w; h0=@__org_h
      else
        x0,y0,w0,h0 = self.windowrect; x0=self.x; y0=self.y
      end
      str = ""
      sty = style+@owndraw-@_default_style
      sty &= 0xfffffffe if self.class == VREditCombobox
      sp = get_parents_str(self.parent)
      lv = getLevel(self)
      cnt=self.to_s.sub(/\#\<([A-Za-z]+).*/,'\1')
      if !@modules.empty? || @owndraw > 0 then
        cnt = name.capitalize1
        addModules
      end
      str += lv+"  "+ mk_addstr(cnt,name,caption.esc,x0,y0,w0,@_drop_h,sty)
      str += getFontStr(lv)
      str
    end
    
    def a.drop_h; @_drop_h=h unless @_drop_h; @_drop_h end
    
    def a.set_drop_h(h0) @_drop_h=h0 ;end
    
#    def a.terminate
#      @parent.deleteControl @_coverPanel
#    end

    set_cnt_attr(a,c)
    a.owndraw = od
    a.set_drop_h(h)
    x0,y0,w0,h0=a.windowrect
    a.move(a.x,a.y,a.w,h0)
    a
  end
  
  module FDCoverExt
    attr :_coverPanel,1
    include STDSourceMaker
    def move(x,y,w,h)
      super
      @_coverPanel.move(x,y,w,h) if @_coverPanel
    end
  end

  def newFDCoverd(prnt,cnt,name,caption,x,y,w,h,addstyle=0,c_items=nil)
    c = findPalletItem(cnt)
    od = check_owndraw(c,addstyle)
    addstyle -= od
    cv=prnt.addControl(FDCoverPanel,'_'+name,'',x,y,w,h)
    a=prnt.addControl(c.klass,name,caption,x,y,w,h,addstyle )
    a.extend FDCoverExt
    prnt.set_include(c.included)
    def a.createSourceStr
      if respond_to? :initMargin
        x0=@__org_x; y0=@__org_y; w0=@__org_w; h0=@__org_h
      else
        x0,y0,w0,h0 = self.windowrect; x0=self.x; y0=self.y
      end
      str = ""
      sty = self.style+@owndraw-@_default_style
      sp=get_parents_str(self.parent)
      lv=getLevel(self)
      cnt=self.to_s.sub(/\#\<([A-Za-z]+).*/,'\1')
      str += lv+"  "+ mk_addstr(cnt,name,caption.esc,x0,y0,w0,h0,sty)
      hf=sendMessage(WMsg::WM_GETFONT,0,0)
      hf=hf+0x100000000 if hf < 0
      if n = @form.get_font_number(hf) then
        str += lv+"  @#{name}.setFont($_#{@form.name}_fonts[#{n}])\n"
      else  nil end
      if @owndraw > 0 then
        str += lv+"  @#{name}.extend(#{name.capitalize1}).vrinit\n"
        addModules
      end
      str
    end
    
    def a.terminate
      @parent.deleteControl @_coverPanel
    end

    set_cnt_attr(a,c)
    a.owndraw = od
    a._coverPanel = cv
    cv.substance = a
    a
  end

  def newFDToolbar(prnt,cnt,name,caption,x,y,w,h,addstyle=0,c_items=nil)
    addstyle |= 4 if prnt.is_a? VRRebar
    c = findPalletItem(cnt)
    a=prnt.addControl(c.klass,name,caption,x,y,w,h,addstyle )
    a.class.module_eval "attr :_vr_toolbar_buttons,1"
    prnt.extend VRToolbarUseable
    prnt.set_include(c.included)
    
    def a.getItemsStr(option=nil)
      lv=getLevel(self)
      s = lv+"  ["
      0.upto(countButtons-1){|i|
        b = getButton(i)
        st = option ? b[3].to_s : Stylehash.invert[b[3]].to_s
        s << "\n#{lv}    [\"#{@parent._vr_toolbar_buttons[b[1]].name}\",#{st}],"
      }
      if s[s.size-1] == ','[0] then s[s.size-1,1] = "\n#{lv}  ]" else  s << "]" end
      s
    end
    
    def a.getItems2
      s = []
      0.upto(countButtons-1){|i|
        b = getButton(i)
        st = Stylehash.invert[b[3]].to_s
        s << [st,@parent._vr_toolbar_buttons[b[1]].name]
      }
      s
    end

    def a.refreshItems(ar)
      begin
      ar.collect!{|i| [i[1],Stylehash[i[0]]]}
      self.terminate
      setButtons(ar)
      self.items = ar
      rescue Exception
        messageBox $!,'Illegal setting of items',16
      end
    end

    def a.terminate
      (countButtons-1).downto(0){|i|
        b = getButton(i)
        @parent._vr_toolbar_buttons.delete(b[1])
        deleteButton(i)
      }
    end

    def a.createSourceStr
      if respond_to? :initMargin
        x0=@__org_x; y0=@__org_y; w0=@__org_w; h0=@__org_h
      else
        x0,y0,w0,h0 = self.windowrect; x0=self.x; y0=self.y
      end
      str = ""
      sty = self.style-@_default_style
      cnt=self.class.to_s
      lv=getLevel(self)
      str += lv+"  "+ mk_addstr(cnt,name,caption.esc,x0,y0,w0,h0,sty)
      if countButtons > 0 then
        str += lv+"  "+"@#{name}.setButtons(\n#{getItemsStr(true)})\n"
      else
        str += "\n"
      end
    end

    def a.eventList
      as = []
      0.upto(countButtons-1){|i|
        b = getButton(i)
        as << @parent._vr_toolbar_buttons[b[1]].name + "_clicked" unless b[3] == 1
      }
      as
    end

    def a.buttons
      @form._return_val=nil
      ItemEditDlg::POS[0] = [100,100,400,300]
      ItemEditDlg::LISTWIDTH[0] = 254
      ItemEditDlg::ADDINGNAME[0] = 'toolButton'
      ItemEditDlg::ADDREMOVE[0] = true
      ItemEditDlg::TITLES[0]=[['button style',140],['button name',110]]
      ItemEditDlg::ITEMS[0] = getItems2
      ItemEditDlg::FIXCOLUMN[0] = true
      ItemEditDlg::UPDOWN[0] = true
      ItemEditDlg::STYLES[0]=['TBSTYLE_BUTTON','TBSTYLE_SEP','TBSTYLE_CHECK',
      'TBSTYLE_GROUP','TBSTYLE_CHECKGROUP']
      ItemEditDlg::DEFAULTSTR[0]='TBSTYLE_BUTTON'
      VRLocalScreen.modalform @form ,nil,ItemEditDlg
      r = @form._return_val
      refreshItems(r) if r
      @form.refreshInspect(self)
    end

    set_cnt_attr(a,c)
    if c_items then
      a.setButtons(c_items)
      a.items = c_items
    elsif a.items
      a.setButtons(a.items)
    else
      items2=c.items.dup.collect!{|i|
        [get_serial_name(i[0]),i[1]]
      }
      a.setButtons(items2)
      a.items = items2
    end
    a
  end

  def newFDRebar(prnt,cnt,name,caption,x,y,w,h,addstyle=0, c_items=nil)
    if prnt.is_a? VRRebar then
      messageBox 'cannot arrange VRRebar on VRRebar','Illegal arrangement',16
      return
    end
    c = findPalletItem(cnt)
    a=prnt.addControl(c.klass,name,caption,x,y,w,h,addstyle)
    prnt.set_include(c.included)
    a.extend STDSourceMaker
    def a.get_childs_source(novrinit=nil)
      @cntnmodules = []
      lv=getLevel(self)
      r=[]
      s=""
      incld1 = []
      @modules.uniq!
      @items.each{|i|
        ct = instance_eval("#{i[0]}")
        break if ct.is_a?(VRStatic) && i[0] == "@__"+ct.parent.name
        break if ct.class == FDCoverPanel
        if ct.kind_of? VRNotifyControl then
          (incld1 << "VRComCtlContainer").uniq!
        else
          (incld1 << "VRStdControlContainer").uniq!
        end
        r << yield(ct,i[1],i[2],i[3])
      }
      unless @modules.empty? then
        incld1 = incld1 + @modules
        @modules.each{|m|
          if rq = FDModules::StdModules["#{m}".intern ] then
            (@form.required << rq.requires).uniq!
            @form.required.reject!{|i| !i} #delete nil
          end
        }
      end
      s += "\n#{lv}  def construct\n"
#      s += getFontStrParent(lv)
      s += r.to_s
      s1 = []
      incld1.each{|i| s1 << "#{lv}  include #{i}"}
      @included.each{|m| s1<<"#{lv}  include #{m} if defined? #{m}" if m} unless
                                                                @included.empty?
      sp=get_parents_str(self.parent)
      s = s1.join("\n")+ "\n" + s
      s[0,0] = getDEFAULTFONT(lv) if @_default_font
      s[0,0] = "\n#{lv}class #{name.capitalize1} < #{self.class}\n"
      s += "#{lv}  end\n"
      s += "#{lv}end\n"
      s
    end

    def  a.createSourceStr
      if respond_to? :initMargin
        x0=@__org_x; y0=@__org_y; w0=@__org_w; h0=@__org_h
      else
        x0,y0,w0,h0 = self.windowrect; x0=self.x; y0=self.y
      end
      str = ""
      sty = self.style-@_default_style
      sp=get_parents_str(self.parent)
      lv=getLevel(self)
      cnt=self.class.to_s
      if respond_to?(:addControl) then
        str += lv+"  "+ mk_addstr(name.capitalize1,name,caption.esc,
                                                               x0,y0,w0,h0,sty)
        @parent.cntnmodules << get_childs_source{|c,t,w,h|
          s=c.createSourceStr
          s.sub! /^ +/,lv+"    @#{c.name}="
          s << lv+"    insertband(@#{c.name},'#{t}',#{w},#{h})\n"
          s
        }
        addRequire
      elsif !@modules.empty? then
        str += lv+"  "+ mk_addstr(name.capitalize1,name,caption.esc,x,y,w,h,sty)
        addModules
      else
        str += lv+"  "+ mk_addstr(cnt,name,caption.esc,x,y,w,h,sty)
      end
      str+= getFontStr(lv)
      str
    end

    def a.refreshItems(ar)
      @items.each_index{|i|
        i0 =ar.select{|j| @items[i][0] == j[0]}[0]
        @items[i][1] = i0[1]
        @items[i][2] = i0[2].to_i
        @items[i][3] = i0[3].to_i
        setbandattr(i,i0[1],i0[2].to_i,i0[3].to_i)
      }
    end

    def a.bands
      @form._return_val=nil
      ItemEditDlg::LISTWIDTH[0] = 392
      ItemEditDlg::STYLES[0]=nil
      ItemEditDlg::POS[0] = [100,100,400,300]
      ItemEditDlg::ADDREMOVE[0] = false
      ItemEditDlg::UPDOWN[0] = false
      ItemEditDlg::TITLES[0]=[['control',100],['text',100],
                                                      ['min w',92],['min h',92]]
      ItemEditDlg::ITEMS[0] = @items
      ItemEditDlg::FIXCOLUMN[0] = true
      VRLocalScreen.modalform @form ,nil,ItemEditDlg
      r = @form._return_val
      refreshItems(r) if r
    end

    def a.setbandattr(idx,txt="",minx=30,miny=30)
      unless idx.is_a? Integer
        n = @items.index(items.find{|i| i[0] == "@#{idx.name}" })
        idx = n
      end
      mask= WConst::RBBIM_TEXT | WConst::RBBIM_STYLE | WConst::RBBIM_CHILD |
                                 WConst::RBBIM_CHILDSIZE | WConst::RBBIM_SIZE
      t= ""
      tis = [56,mask,0,0,0,t,0,0,0,0,0,0,0,0,0].pack("LLLLLP#{t.length}LLLLLLLL")
      sendMessage WMsg::RB_GETBANDINFO,idx,tis
      a = tis.unpack("LLLLLPLLLLLLLL")
      a[5]= txt; a[9]=minx; a[10]=miny
      rbbi=a.pack("LLLLLP#{txt.length}LLLLLLLL")
      sendMessage(WMsg::RB_INSERTBAND+5,idx,rbbi)
    end

    def a.deleteband(idx)
      sendMessage WMsg::RB_DELETEBAND,idx,0
    end
    
    def a.update_items(oldname,newname)
      @items.find{|i|i[0]=='@'+oldname}[0] = '@' + newname
    end
    
=begin    
    def a.terminate
      @items.reject!{|i|
        unless i[0] == "@__#{self.name}"
          deleteControl(instance_eval("#{i[0]}"))
          child_deleted(instance_eval("#{i[0]}"))
        end
        true
      }
    end
=end
    
    def a.child_created(c)
      if c0=@items.find{|i| i[0] == "@__#{self.name}"} then
        deleteControl(instance_eval("#{c0[0]}"))
        @items.delete_at(0)
        deleteband(0)
      end
      @parent.instance_eval("@#{c.name}=nil")
      @parent.instance_eval "@controls.delete(c.etc)"
      @controls[c.etc] = c
      unless itm=@items.find{|i| i[0] == '@'+c.name} then
        @items << itm=['@'+c.name,c.name,30,c.h+2]
      end
      instance_eval "@#{c.name}=c"
      insertband(c,itm[1],itm[2],itm[3])
      relayout
    end

    def a.child_deleted(c)
      idx = @items.index(@items.find{|i| i[0] == '@'+c.name })
      @items.delete_at(idx)
      deleteband(idx)
      if @items.empty? then
        cv=addControl(VRStatic,"__#{name}",'',0,0,25,25)
        @parent.instance_eval("@#{cv.name}=nil")
        @parent.instance_eval "@controls.delete(cv.etc)"
        @controls[cv.etc] = cv
        instance_eval("@#{cv.name}=cv")
        insertband(cv,"",0,30)
        @items = [['@'+cv.name,""]]
        c1 = findPalletItem(cv)
        @form.set_cnt_attr(cv,c1)
     end
    end

    set_cnt_attr(a,c)
    a.extend(FDParent).fd_parent_init
    unless c_items then
      cv=a.addControl(VRStatic,"__#{name}",'',0,0,25,25)
      a.parent.instance_eval("@#{cv.name}=nil")
      a.parent.instance_eval "@controls.delete(cv.etc)"
      a.controls[cv.etc] = cv
      a.instance_eval("@#{cv.name}=cv")
      a.insertband(cv,"",0,30)
      a.items = [['@'+cv.name,""]]
      c1 = findPalletItem(cv)
      set_cnt_attr(cv,c1)
    else
     a.items = c_items 
    end
    a
  end

  def newFDTabbedPanel(prnt,cnt,name,caption,x,y,w,h,addstyle=0,c_items=nil)
    if prnt.is_a? VRTabControl then
      messageBox 'cannot arrange VRTabbedPanel on VRTabControl','Illegal arrangement',16
      return
    end
    c = findPalletItem(cnt)
#    addstyle = 0 unless addstyle
    od = check_owndraw(c,addstyle)
    addstyle -= od
    a=prnt.addControl(c.klass,name,caption,x,y,w,h,addstyle )
    a.extend STDSourceMaker
    prnt.set_include(c.included)

    def a.getItemsStr(option=nil)
      lv=getLevel(self)
      s = "[\n"
      0.upto(countTabs-1){ |i|
        s += "#{lv}      ['#{getTabTextOf(i)}'," +
             "#{@panels[i].name.capitalize1},'#{@panels[i].name}'],\n"}
      s[s.size-2,2] = "\n#{lv}    ]"
      s
    end

    def a.getItems2
      s = []
      0.upto(countTabs-1){ |i| s << [@panels[i].name,getTabTextOf(i)]}
      s
    end

    def a.refreshItems(a0)
      @items = a0.collect{|i| i[1]}
      a1 = a0.select{|i| i[0]!=""}.collect{|i| instance_eval('@'+i[0])}
      @panels.each_with_index{|itm,idx|
        unless a1.find{|j| j == itm } then
          @panels[idx].delete_child_controls
          deleteControl(@panels[idx])
          @panels.delete_at(idx)
        end
      }
      @panels.each{|i| 
        instance_eval "@#{i.name}=nil"
        i.name = "___"+i.name
      }
      clearTabs
      0.upto(a0.size-1){|i|
        insertTab(i,a0[i][1])
        if (n=a0[i][0]) != ''  then
          m = 0.upto(@panels.size-1){|j| break j if @panels[j].name == "___#{n}" }
          @panels[i,0] = @panels.delete_at(m)
          instance_eval "@#{@panels[i].name.sub(/^___/,'')}=nil"
          @panels[i].name = "panel#{i}"
          instance_eval "@#{@panels[i].name}=@panels[i]"
        else
          @panels[i,0] = nil
          x,y,w,h = adjustRect(0,0,self.w,self.h,false)
          @panels[i] = addControl(VRPanel,"panel#{i}","panel#{i}",x,y,w-x,h-y)
          @panels[i].extend VRContainersSet
          @panels[i].containers_init
          @panels[i].show 0
          c1 = @form.findPalletItem(@panels[i])
          @form.set_cnt_attr(@panels[i],c1)
          @panels[i].extend STDSourceMaker
          @panels[i].extend(FDParent).fd_parent_init
          @panels[i].extend CreateCtrl
        end
        @panels[i]._default_font = self._default_font
      }
      #selectTab 0
    end

    def a.terminate
    end

    def a.createSourceStr
      lv = getLevel(self)
      if respond_to? :initMargin
        x0=@__org_x; y0=@__org_y; w0=@__org_w; h0=@__org_h
        sr = lv + "  auto_panelresize(true)\n"
      else
        x0,y0,w0,h0 = self.windowrect; x0=self.x; y0=self.y
        sr = ""
      end
      str = ""
      sty = self.style+@owndraw-@_default_style
      cnt=self.class.to_s
      str += lv+"  "+mk_addstr(name.capitalize1,name,caption.esc,x0,y0,w0,h0,sty)
      s2 = ""
      sattr=""
      @panels.each{|i|
        i.modules = self.modules
        sattr += lv+"  attr_reader :#{i.name}\n"
        s2 << i.get_childs_source(true){|j| j.createSourceStr}
      }
      s2 += "\n" + lv + "  def construct\n"
      s2 += getFontStrParent(lv)
      s2 += lv + "    setupPanels(*#{getItemsStr(true)})\n" if @panels.size > 0 
      s2 += lv + "  end\n"
      @parent.cntnmodules<<"\n#{lv}class #{name.capitalize1} < #{self.class}\n"
      @modules.each{|m|
        @parent.cntnmodules << lv+"  include #{m}\n";
        (@form.required << FDModules::StdModules["#{m}".intern ].requires).uniq!
        @form.required.reject!{|i| !i}
      }
      @parent.cntnmodules << "#{sattr}"
      @parent.cntnmodules << getDEFAULTFONT(lv) if @_default_font
      @parent.cntnmodules << sr
      @parent.cntnmodules << s2 + "#{lv}end\n"
      str += getFontStr(lv)
      str
    end

    def a.pages
      @form._return_val=nil
      ItemEditDlg::LISTWIDTH[0] = 392
      ItemEditDlg::STYLES[0]=nil
      ItemEditDlg::POS[0] = [100,100,400,300]
      ItemEditDlg::ADDINGNAME[0] = 'tab'
      ItemEditDlg::ADDREMOVE[0] = true
      ItemEditDlg::UPDOWN[0] = false
      ItemEditDlg::TITLES[0]=[['panel',120],['title',100]]
      ItemEditDlg::ITEMS[0] = getItems2
      ItemEditDlg::FIXCOLUMN[0] = true
      VRLocalScreen.modalform @form ,nil,ItemEditDlg
      r = @form._return_val
      refreshItems(r) if r
      @form.refreshCntName
      @form.refreshInspect(self)
    end

    set_cnt_attr(a,c)
    a.owndraw = od
    a.extend(FDParent).fd_parent_init
    if c_items then
      a.setupPanels(*c_items)
      a.items = c_items
    elsif a.items
      a.setupPanels(*a.items)
    else
      a.setupPanels(*c.items)
      a.items = c.items
    end
    a.panels.each{|i|
      c1 = findPalletItem(i)
      set_cnt_attr(i,c1)
      i.extend STDSourceMaker
      i.extend(FDParent).fd_parent_init
    }
    a
  end

  def newFDMenu(prnt,cnt,name,caption,x,y,w,h,addstyle=0,c_items=nil)
    c = findPalletItem(cnt)
    prnt.class.module_eval "attr :_vr_menus,1 "
    a=addControl(FDContainer,name,caption,x,y,w,h,addstyle )
    prnt.set_include(c.included)
    
    def a.createMthodStr(t)
      s= "@#{self.name}.#{t}"
      s
    end
    
    def a.getItemsStr
      mn=MenuStrMaker.new
      mn.makeStr(@items)
    end

    def a.refreshItems(a)
      begin
      self.items = a
      @parent._vr_menus.clear
      self.terminate
      self.substance = @parent.newMenu.set(self.items)
      @parent.setMenu self.substance,false
      rescue Exception
        messageBox $!,'Illegal setting of items',16
      end
    end

    def a.terminate
      @parent.setMenu @parent.newMenu,false if parent.visible?
    end

    def a.set_attrs(a)
      #do nothing
    end

    def a.createSourceStr
      r =  "    \#$_addControl(VRMenu,'#{name}',\"\",#{x},#{y},24,24)\n"
      r += "    @#{self.name} = newMenu.set(\n"
      r += self.getItemsStr.gsub(/^/," "*6)
      r += "    )\n"
      @_kb_accel=false unless @_kb_accel
      r += "    setMenu(@#{self.name},#{@_kb_accel})\n"
#      r += "    \#$_ctn_#{self.name}=[#{self.x},#{self.y}]\n"
      r
    end

    def a.eventList
      s_ary = []
      @parent._vr_menus.each{|i,c|
        s_ary << c.name + "_clicked" unless c.name == '_vrmenusep'
      }
      s_ary
    end
    
    def a.menus
      a = []
      @form._return_val=nil
      analizer = MenuAnalizer.new
      MenuEditDlg::ITEMS[0] = analizer.analize(@items)
      MenuEditDlg::POS[0] = [@form.x+50,@form.y+50,468,300]
      0.upto(analizer.colCount-1){|i| a << ["#{i+1}",112]}
      MenuEditDlg::TITLES[0]=a
      VRLocalScreen.modalform @form ,nil,MenuEditDlg
      r = analizer.unanalize(@form._return_val) if @form._return_val
      refreshItems(r) if r
      @form.refreshInspect(self)
    end
    
    def a.accel(a = true) @_kb_accel = a end
      
    def a.getaccel() @_kb_accel end
    
    set_cnt_attr(a,c)
    a.bmp=SWin::Bitmap.loadString(c.bmp)
    if c_items then
      a.items=c_items
    elsif c.items
      a.items=c.items
    else
      a.items=FDMenuTemplate
    end
    a.accel(true)
    a.substance = newMenu.set a.items
    self.setMenu a.substance,false
    a
  end
  
  def newFDPopup(prnt,cnt,name,caption,x,y,w,h,addstyle=0,c_items=nil)
    c = findPalletItem(cnt)
    a=addControl(FDContainer,name,caption,x,y,w,h,addstyle )
    prnt.set_include(c.included)
    
    def a.createMthodStr(t)
      case t
      when /^showPopup/
        s=t.sub /(\(.+\))/,"(@#{self.name})"
      else
        s= "@#{self.name}.#{t}"
      end
      s
    end
    
    def a.getItemsStr
      mn=MenuStrMaker.new
      mn.makeStr(@items)
    end
    
    def a.set_attrs(a)
      #do nothing
    end

    def a.createSourceStr
      r =  "    \#$_addControl(FDPopup,'#{name}',\"\",#{x},#{y},24,24)\n"
      r += "    @#{self.name} = newPopupMenu.set(\n"
      r += self.getItemsStr.gsub(/^/," "*6)
      r += "    )\n"
      r
    end

    def a.menus
      a = []
      @form._return_val=nil
      analizer = MenuAnalizer.new
      MenuEditDlg::ITEMS[0] = analizer.analize(@items)
      MenuEditDlg::POS[0] = [@form.x+50,@form.y+50,468,300]
      0.upto(analizer.colCount-1){|i| a << ["#{i+1}",112]}
      MenuEditDlg::TITLES[0]=a
      VRLocalScreen.modalform @form ,nil,MenuEditDlg
      @items = analizer.unanalize(@form._return_val) if @form._return_val
      @form.refreshInspect(self)
    end

    def a.eventList
      ar = []
      an = MenuAnalizer.new
      ana = an.analize(@items)
      ana.each{|i|
        level = 0
        flag0 = nil
        a = []
        i.each{|j|
          if j == "" then
            break if flag0
            level += 1
          else
            a << j
            flag0 = true
          end
        }
        ar << a[1]+'_clicked' if a.size > 1 && a[1] != "_vrmenusep"
      }
      ar
    end
    
    set_cnt_attr(a,c)
    if c_items then
      a.items=c_items
    elsif c.items
      a.items=c.items
    else
      a.items=FDItems::FDPopupMenuTemplate
    end
    a.bmp=SWin::Bitmap.loadString(c.bmp)
    a.substance = c.klass.new 
    a
  end

  def newFDOpenSaveDlg(prnt,cnt,name,caption,x,y,w,h,addstyle=0,info=nil,ext=nil)
    c = findPalletItem(cnt)
    a=addControl(FDContainer,name,caption,x,y,w,h,addstyle )
    def a.init
      @substance.filters = FDItems::FDDlgFilterTemplate
      if @substance.class == FDOpenDlg
        aryFlags = FDComDlgItems::OpenFileFlag
        @substance.flags = aryFlags['OFN_FILEMUSTEXIST']
      else
        aryFlags = FDComDlgItems::SaveFileFlag
        @substance.flags = aryFlags['OFN_OVERWRITEPROMPT']
      end
      @substance.title = nil
      @substance.defaultExt = nil
    end

    def a.createSourceStr
      cnt=self.substance.class.name.sub /^.*::/,''
      sb = self.substance
      sty = sprintf("%#x",style)
      r =  "    \#$_addControl(#{cnt},'#{name}',\"\",#{x},#{y},24,24)\n"
      r += "    \#$_ctn_#{self.name}=[#{sb.filters.inspect},#{sb.flags.to_x},"+
                "#{sb.title.inspect},#{sb.defaultExt.inspect}]\n"
      r
    end

    def a.createMthodStr(s)
      sb = self.substance
      str = s.sub /\(.*$/ , ''
      fs = sb.flags ? sb.flags.to_x : 'nil'
      "#{str}(#{sb.filters.inspect},#{fs},#{sb.title.inspect},"+
      "#{sb.defaultExt.inspect})"
    end

    def a.set_attrs(a)
      @substance.filters = a[0]
      @substance.flags = a[1]
      @substance.title = a[2]
      @substance.defaultExt = a[3]
    end

    def a.filters
      @substance.filters = [["all(*.*)","*.*"]] unless @substance.filters
      @form._return_val=nil
      ItemEditDlg::LISTWIDTH[0] = 392
      ItemEditDlg::STYLES[0]=nil
      ItemEditDlg::POS[0] = [100,100,400,300]
      ItemEditDlg::ADDINGNAME[0] = '*.*'
      ItemEditDlg::ADDREMOVE[0] = true
      ItemEditDlg::UPDOWN[0] = true
      ItemEditDlg::TITLES[0]=[['title',200],['filter',100]]
      ItemEditDlg::ITEMS[0] = @substance.filters
      ItemEditDlg::FIXCOLUMN[0] = false
      VRLocalScreen.modalform @form ,nil,ItemEditDlg
      r = @form._return_val
      @substance.filters=r if r
      @form.refreshInspect(self)
    end

    def a.flags
      if @substance.class == FDOpenDlg
        aryFlags = FDComDlgItems::OpenFileFlag
        @substance.flags = aryFlags['OFN_FILEMUSTEXIST'] unless @substance.flags
      else
        aryFlags = FDComDlgItems::SaveFileFlag
        @substance.flags = aryFlags['OFN_OVERWRITEPROMPT'] unless @substance.flags
      end
      a = []
      aryFlags.each{|k,v|
        n = ((@substance.flags & v) == 0 ) ? 0 : 1
        a << [k.dup,n]
      }
      if s = @form.showModDlg(a,104,195) then
        n = 0
        s.each{|i| n |=  aryFlags[i[0]] if i[1] !=0}
        @substance.flags=n
      end
      @form.refreshInspect(self)
    end

    def a.title() @substance.title end

    def a.defaultExt() @substance.defaultExt end
    
    a.substance = c.klass.new 
    set_cnt_attr(a,c)
    a.bmp=SWin::Bitmap.loadString(c.bmp)
    a.init
    a
  end

  def newFDSelectDir(prnt,cnt,name,caption,x,y,w,h,addstyle=0,info=nil,ext=nil)
    c = findPalletItem(cnt)
    a=addControl(FDContainer,name,caption,x,y,w,h,addstyle )
    def a.init
      @substance.flags=FDComDlgItems::BrowseFolderFlag["BIF_RETURNONLYFSDIRS"]
    end
    def a.flags
      a = []
      FDComDlgItems::BrowseFolderFlag.each{|k,v|
        n = ((@substance.flags & v) == 0 ) ? 0 : 1
        a << [k.dup,n]
      }
      if s = @form.showModDlg(a,104,195) then
        n = 0
        s.each{|i| n |=  FDComDlgItems::BrowseFolderFlag[i[0]] if i[1] !=0}
        @substance.flags = n
      end
    end
    
    def a.set_attrs(a) #do nothing
    end

    def a.title() @substance.title end

    def a.initialdir() @substance.initialdir end

    def a.terminate
    end
    def a.createSourceStr
      cnt=self.substance.class.name.sub /^.*::/,''
      sty = sprintf("%#x",style)
      r =  "    \#$_addControl(#{cnt},'#{name}',\"\",#{x},#{y},24,24)\n"
      r += "    \#$_ctn_#{self.name}=[#{self.x},#{self.y},"+
                "#{@substance.title.inspect},#{@substance.initialdir.inspect},"+
                "#{@substance.flags.to_x}]\n"
      r
    end
    def a.createMthodStr(s)
      sb = self.substance
      str = s.sub /\(.*$/ , ''
      fs = sb.flags ? sb.flags.to_x : 'nil'
      "#{str}(#{sb.title.inspect},#{sb.initialdir.inspect},#{fs})"
    end
    a.substance = c.klass.new 
    set_cnt_attr(a,c)
    a.bmp=SWin::Bitmap.loadString(c.bmp)
    a.init
    a
  end

  def newFD2Pane(prnt,cnt,name,caption,x,y,w,h,addstyle=0,items=nil,first=nil)
    c = findPalletItem(cnt)
    a=prnt.addControl(FDContainer,name,"",x,y,w,h,addstyle )
    prnt.set_include(c.included)
    def a.getItemsStr(option=nil)
      ""
    end
    
    def a.set_attrs(a)
      #do nothing
    end
    
    def a.refreshItems(ar)
    end
    
    def a.terminate
      if parent.__regsterd_vr_margined_frame == self.substance
        parent.__regsterd_vr_margined_frame=nil;GC.start
      end
        @substance.bevel=VRMgdTwoPaneFrame::BevelNone
        @substance.gap=0
        @substance.pane1.each{|i|
        if i.is_a? SWin::Window then
          i.setMargin(nil,nil,nil,nil)
          i.registerd_to = []
          i.margined = nil
        end
      } if @substance.pane1
      @substance.pane2.each{|i|
        if i.is_a? SWin::Window then
          i.setMargin(nil,nil,nil,nil)
          i.registerd_to = []
          i.margined = nil
        end
      } if @substance.pane2
    end
    
    def a.createSourceStr
      def self.create_setmargin(lv,name,o)
        "#{lv}  @#{name}.setMargin("+o.mgLeft.inspect+','+o.mgTop.inspect+
                              ','+o.mgRight.inspect+','+o.mgBottom.inspect+")\n"
      end
      make_panes = lambda do |p|
        s=p.map{|i|
          '@'+(i.is_a?(SWin::Window) ? i.name : i.container.name)+','}.to_s
        s[0,s.size-1]
      end
      lv = getLevel(self)
      sb = self.substance
      cnt=sb.class.name.sub /^.*::/,''
      sty = sprintf("%#x",style)
      r = "#{lv}  \#$_addControl(#{cnt},'#{name}',\"\",#{x},#{y},24,24)\n"
      if parent.__regsterd_vr_margined_frame == self.substance
        r += "#{lv}  @#{self.name}=setMarginedFrame(#{cnt}," +
             "[#{make_panes.call(sb.pane1)}],[#{make_panes.call(sb.pane2)}])\n"
        r += create_setmargin(lv,self.name,sb)
      else
        r += "#{lv}  @#{self.name}=#{cnt}.new([#{make_panes.call(sb.pane1)}]," +
                                 "[#{make_panes.call(sb.pane2)}]).setup(self)\n"
      end

      r += "#{lv}  @#{self.name}.ratio=#{sb.ratio}\n" if sb.ratio
      r += "#{lv}  @#{self.name}.position=#{sb.position}\n" if sb.position
      r += "#{lv}  @#{self.name}.gap=#{sb.gap}\n"
      r += "#{lv}  @#{self.name}.bevel=" +
                         "VRMgdTwoPaneFrame::Bevel#{eval(@form.prBevel).call(self)}\n"
      r += "#{lv}  @#{self.name}.lLimit=#{sb.lLimit}\n" if sb.lLimit > 0
      if sb.is_a? VRHorizTwoPaneFrame
        r += "#{lv}  @#{self.name}.rLimit=#{sb.rLimit}\n" if sb.rLimit > 0
      else
        r += "#{lv}  @#{self.name}.uLimit=#{sb.uLimit}\n" if sb.uLimit > 0
      end
      sb.pane1.each do |i|
        if i.is_a? SWin::Window
          r += create_setmargin(lv,i.name,i)
        else
          r += create_setmargin(lv,i.container.name,i)
        end
      end
      sb.pane2.each do |i|
        if i.is_a? SWin::Window
          r += create_setmargin(lv,i.name,i)
        else
          r += create_setmargin(lv,i.container.name,i)
        end
      end
      r
    end
    
    def a.createMthodStr(s)
      str = s.sub /\(.*$/ , ''
      "#{str}"
    end
    
    c.klass.module_eval("attr :pane1,1;attr :pane2,1")
    c.klass.module_eval("attr :container,1")
    if first or (!items && !prnt.__regsterd_vr_margined_frame)
      if items
        a.substance = prnt.setMarginedFrame(c.klass,
        items[0].map{|i|
          (j= prnt.instance_eval(i)).is_a?(FDContainer)? j.substance : j},
        items[1].map{|i|
          (j= prnt.instance_eval(i)).is_a?(FDContainer)? j.substance : j})
        a.substance.pane1.each do |i|
          if i.is_a?(SWin::Window)
            i.registerd_to=[a,0]
            i.margined = true
          else
            i.container.registerd_to=[a,0]
          end
        end
        a.substance.pane2.each do |i|
          if i.is_a?(SWin::Window)
            i.registerd_to=[a,1]
            i.margined = true
          else
            i.container.registerd_to=[a,1]
          end
        end
      else
        a.substance = prnt.setMarginedFrame(c.klass,[],[])
      end
      a.bmp=SWin::Bitmap.loadString(c.bmp)
    else
      if items
        a.substance = c.klass.new(
        items[0].map{|i|
          (j= prnt.instance_eval(i)).is_a?(FDContainer)? j.substance : j},
        items[1].map{|i|
           (j= prnt.instance_eval(i)).is_a?(FDContainer)? j.substance : j})
        a.substance.pane1.each do |i|
          if i.is_a?(SWin::Window)
            i.registerd_to=[a,0]
          else
            i.container.registerd_to=[a,0]
          end
        end
        a.substance.pane2.each do |i|
          if i.is_a?(SWin::Window)
            i.registerd_to=[a,1]
          else
            i.container.registerd_to=[a,1]
          end
        end
      else
        a.substance = c.klass.new([],[]).initMargin(0,0,0,0)
      end
      a.substance.setup(prnt)
      bm=SWin::Bitmap.loadString(c.bmp)
      bm1 = SWin::Bitmap.newBitmap(23,23)
      0.upto(bm.width-1) do |i|
        0.upto(bm.height-1) do |j|
          clr = bm[i,j]
          bm1[i,j] = [clr[1],clr[2],clr[0]]
        end
      end
      a.bmp=bm1
    end
    a.substance.container = a
    
    a.substance.bevel = VRMgdTwoPaneFrame::BevelGroove1
    _x,_y,_w,_h= prnt.clientrect
    prnt.sendMessage(WMsg::WM_SIZE,0,MAKELPARAM(_w,_h))
    set_cnt_attr(a,c)
    a
  end
  
  def newFDLayout(prnt,cnt,name,caption,x,y,w,h,addstyle=0,items=nil,first=nil)
    c = findPalletItem(cnt)
    a=prnt.addControl(FDContainer,name,"",x,y,w,h,addstyle )
    prnt.set_include(c.included)
    def a.getItemsStr(option=nil)
      ""
    end
    
    def a.set_attrs(a)
      #do nothing
    end
    
    def a.refreshItems(ar)
    end
    
    def a.terminate
      if parent.__regsterd_vr_margined_frame == self.substance
        parent.__regsterd_vr_margined_frame=nil
      end
      @substance._vr_layoutclients.each{|i|
        if i.is_a? SWin::Window then
          i.setMargin(nil,nil,nil,nil)
          i.registerd_to = nil
          i.margined = nil
        end
      }
    end
    
    def a.createSourceStr
      def self.create_setmargin(lv,name,o)
        "#{lv}  @#{name}.setMargin("+o.mgLeft.inspect+','+o.mgTop.inspect+
                              ','+o.mgRight.inspect+','+o.mgBottom.inspect+")\n"
      end
      make_panes=lambda do |p|
        unless self.substance.is_a? VRGridLayoutFrame
          s=p.map{|i|
            '@'+
            if i.is_a?(SWin::Window)
              i.name
            elsif i.is_a? Array
              if i[0].is_a? SWin::Window
                i[0].name
              else
                i[0].container.name
              end
            else
              i.container.name
            end +','
          }.to_s
        else
          s=p.map{|i|
            '[@'+
            if i.is_a?(SWin::Window)
              i.name+",#{i.x},#{i.y},#{i.w},#{i.h}"
            elsif i.is_a? Array
              if i[0].is_a? SWin::Window
                i[0].name+",#{i[0].x},#{i[0].y},#{i[0].w},#{i[0].h}"
              else
                i[0].container.name + ",#{i[0].parent.x},#{i[0].parent.y}"+
                ",#{i[0].parent.w},#{i[0].parent.h}"
              end
            else
              i.container.name+",#{i.parent.x},#{i.parent.y}"+
              ",#{i.parent.w},#{i.parent.h}"
            end +'],'
          }.to_s
        end
        s[0,s.size-1]
      end
      lv = getLevel(self)
      sb = self.substance
      cnt=sb.class.name.sub /^.*::/,''
      sty = sprintf("%#x",style)
      r =  "#{lv}  \#$_addControl(#{cnt},'#{name}',\"\",#{x},#{y},24,24)\n"
      if parent.__regsterd_vr_margined_frame == sb
        unless sb.is_a? VRGridLayoutFrame
          r += "#{lv}  @#{self.name}=setMarginedFrame(#{cnt})\n"
        else
          r += "#{lv}  @#{self.name}=setMarginedFrame(#{cnt},"+
          "#{sb.instance_eval('@_vr_xsize')},"+
          "#{sb.instance_eval('@_vr_ysize')})\n"
        end
        unless sb._vr_layoutclients.empty?
          r += "#{lv}  @#{self.name}.register(" +
                                  "#{make_panes.call(sb._vr_layoutclients)})\n" 
          r += create_setmargin(lv,self.name,sb)
        end
      else
        r += "#{lv}  @#{self.name}=#{cnt}.new\n"
      end
      sb._vr_layoutclients.each do |i|
        if i.is_a? SWin::Window
          r += create_setmargin(lv,i.name,i)
        elsif i.is_a? Array
          if i[0].is_a? SWin::Window
            r += create_setmargin(lv,i[0].name,i[0])
          else
            r += create_setmargin(lv,i[0].container.name,i[0])
          end
        else
          r += create_setmargin(lv,i.container.name,i)
        end
      end
      r
    end
    
    def a.createMthodStr(s)
      str = s.sub /\(.*$/ , ''
      "#{str}"
    end
    
    c.klass.module_eval("attr :_vr_layoutclients,1")
    c.klass.module_eval("attr :container,1")
    if first or (!items && !prnt.__regsterd_vr_margined_frame)
      if items
        if c.klass == VRMgdGridLayoutFrame
          a.substance = prnt.setMarginedFrame(c.klass,prnt.w,prnt.h)
        else
          a.substance = prnt.setMarginedFrame(c.klass,
          items.map{|i|
            (j= prnt.instance_eval(i)).is_a?(FDContainer)? j.substance : j})
        end
      else
        if c.klass == VRMgdGridLayoutFrame
          a.substance = prnt.setMarginedFrame(c.klass,prnt.w,prnt.h)
        else
          a.substance = prnt.setMarginedFrame(c.klass)
        end
      end
      a.bmp=SWin::Bitmap.loadString(c.bmp)
    else
      if items
        if c.klass <= VRGridLayoutFrame
          a.substance = c.klass.new(prnt.w,prnt.h).initMargin(0,0,0,0)
        else
          a.substance = c.klass.new.initMargin(0,0,0,0)
        end
      else
        if c.klass <= VRGridLayoutFrame
          a.substance = c.klass.new(prnt.w,prnt.h).initMargin(0,0,0,0)
        else
          a.substance = c.klass.new.initMargin(0,0,0,0)
        end
      end
      bm=SWin::Bitmap.loadString(c.bmp)
      bm1 = SWin::Bitmap.newBitmap(23,23)
      0.upto(bm.width-1) do |i|
        0.upto(bm.height-1) do |j|
          clr = bm[i,j]
          bm1[i,j] = [clr[1],clr[2],clr[0]]
        end
      end
      a.bmp=bm1
    end
    a.substance.container = a
    _x,_y,_w,_h= prnt.clientrect
    prnt.sendMessage(WMsg::WM_SIZE,0,MAKELPARAM(_w,_h))
    set_cnt_attr(a,c)
    a
  end
  
  def newFDModule(prnt,cnt,name,caption,x,y,w,h,addstyle=0,info=nil,ext=nil)
    c = findPalletItem(cnt)
    a=addControl(FDContainer,name,caption,x,y,w,h,addstyle )
    def a.getItemsStr(option=nil)
      ""
    end
    
    def a.set_attrs(a)
      #do nothing
    end
    
    def a.refreshItems(ar)
    end
    
    def a.terminate
    end
    
    def a.createSourceStr
      cnt=self.substance.class.name.sub /^.*::/,''
      sty = sprintf("%#x",style)
      r =  "    \#$_addControl(#{cnt},'#{name}',\"\",#{x},#{y},24,24)\n"
      r
    end
    
    def a.createMthodStr(s)
      str = s.sub /\(.*$/ , ''
      "#{str}"
    end
    a.substance = c.klass.new 
    set_cnt_attr(a,c)
    a.bmp=SWin::Bitmap.loadString(c.bmp)
    a
  end
  
  def createinit()
    $conf = controls_init
    user_createinit
  end
end

class FDCoverPanel < VRPanel
  include FDDraggable
  undef :addControl
  attr :substance,1
  def vrinit
    super
    draggable_init
  end
end

class FDDummyPanel < VRPanel
  undef :addControl
  def vrinit
    super
    draggable_init
  end
end
