# inner.rb
# Analizing methods which parser use
#
# Programmed by yukimi_sake@mbi.nifty.com
# Copyright 2001-2003 Yukio Sakaue
require 'strscan'

module Inner

  def initialize(frm,old_data=nil)
    #    @yydebug =true
    if old_data then
      extend Inner_old
    else
      extend Inner_new
    end
    _init(frm)
  end
  
end

module Inner_old
  
  def _init(frm)
    @form=frm
    @var={}
    @x=@y=0
    @cntctrls={}
    @nodes = { "name" => "self", "childs" => [], "addings" => [],
                                  "fonts"=>{},"pendings" => [] ,"modules"=>[]}
    @item_pendings = {}
    @inFrm=@inCnt=false
  end
  
  
  def do_end
    if @inFrm then
      @inFrm , @inDef = false,false
    elsif @inCntn then
      @inCntn , @inDef =false,false
    else
      yyaccept
    end
  end

  def do_primary(val)
    if  val =~ /Cntn_\w+/ || val =~ /Extn_\w+/ || @var[val] then
      val
    else
      @form.instance_eval(val)
    end
  end
  
  def do_arr_prim(val)
    eval(val)
  end

  def do_assign(receiver,vname, val )
    if val.is_a? String then
      r = @form.instance_eval(receiver.join(".")+"."+vname+"= '"+val+"'")
    elsif val == @_newPopupMenu
      c = @form.send("newFDPopup",@form,@form.instance_eval("FDPopup"),vname.sub(/@/,''),
                            vname.sub(/@/,''),0,@y+=24,24,24,0,val)
      c.send("extend",FDCommonMethod)
      @form.instance_eval "@names << '#{vname.sub(/@/,'')}'"
    else
      @var[vname]=val
    end
  end

  def do_send(val)
    [val]
  end

  def do_send2(rcvr,val)
      rcvr.push val
  end

  def serch_ext(ext)
    r={}
    @nodes[ext].each{|i|
      if i[ext] then r = i
      else
        r = serch_ext(i)
      end
    }
    r
  end
  
  def serch_node(c,name)
    #r={}
    if c["name"] == name then
      r = c
    else
      c["childs"].each{ |i|
        if r = serch_node(i,name) then r ; break end
      }
    end
    r
  end

  def serch_nodes(a,name)
    r=nil
    a.each{|i| if r = serch_node(i,name) then
      r
      break end
    }
    r
  end

  def serch_node2(c,name)
    if r = serch_node(c,name) then
      r
    else
      r = serch_nodes(c["pendings"],name)
    end
  end

  def make_node(c,parent,child)
    r=r1=nil
      if r=serch_node(c,parent) then
        c["pendings"].reject!{|i|
          if i["name"] == child  then r1=i;true else false end
        }
        if r1 then
          r["childs"] << { "name" => child, "childs" => [*(r1["childs"])],
           "addings" => [*(r1["addings"])],"fonts"=>r1["fonts"],
                                    "modules"=>r1["modules"] }
        else
          r["childs"] << { "name" => child, "childs" => [*(r1["childs"])],
                        "addings" => [],"fonts"=>{},"modules"=>[] }
        end
      elsif r = serch_nodes(c["pendings"],parent) then
        c["pendings"].reject!{|i|
          if i["name"] == child  then r1 =i;true else false end
        }
        if r1 then
          r["childs"] << { "name" => child, "childs" => [*(r1["childs"])],
                           "addings" => [*(r1["addings"])],"fonts"=>r1["fonts"],
                                           "modules"=>r1["modules"] }
        else
          r["childs"] << { "name" => child, "childs" => [],
                   "addings" => [],"fonts"=>{},"modules"=>[]}
        end
      else
        if  child then
          c["pendings"].reject!{ |i|
            if i["name"] == child  then r1=i;true else false end
          }
          c["pendings"] << { "name" => parent, "childs" => [{ "name" => child,
                "childs" => [*(r1["childs"])],"addings" => [*(r1["addings"])],
                            "fonts"=>r1["fonts"]}], "addings" => [] ,"modules"=>[]}
        else
          c["pendings"] << {"name" => parent, "childs" => [] ,"addings" => [],
              "fonts" =>{},"modules"=>[]}
        end
      end
    c
  end
  
  def find_item(node,name)
    unless node["addings"] == []  then 
      r = node["addings"].select{|j| j[1] == name}[0]
      r
    else
      nil
    end
#    unless (pn = nodes["pendings"]) == [] then
#      pn.each{|i|r = find_item(i,name)
#      return(r) if r
#      }
#    end
    r
  end
  
  def do_call(receiver,method, args )
    receiver = @form if receiver == ["self"]
    @_newPopupMenu = nil
    a=""
    a=args.join(",")
    case method
    when 'extend'
      if @inFrm then
        @nodes = make_node(@nodes,"self",args[0])
      elsif @inCntn
        @nodes = make_node(@nodes,@cntname,args[0])
      end
    when '_cntn_init'
      if @inFrm then
        #do nothing
      elsif @inCntn
        #do nothing
      end
    when 'addControl'
      #p @cntname+"_#{args[1]}"
      if @inFrm then
        @nodes["addings"] << (args << @item_pendings[args[1]])
      elsif @inCntn then
        serch_node2(@nodes,@cntname)["addings"] <<
                         (args << @item_pendings[@cntname+"_#{args[1]}"])
      end
    when 'setMenu'
      args[0].scan(/@(.+)/)
      c = @form.send("newFDMenu",@form,@form.instance_eval("VRMenu"),$1,
                                  $1,0,@y+=24,24,24,0,@var[args[0]])
      c.send("extend",FDCommonMethod)
      @form.instance_eval "@names << '#{$1}'"
      c.send("accel",args[1])
    when 'set'
      if receiver[0]=='newPopupMenu' then
        @_newPopupMenu = args[0]
      end
      args[0]
    when 'setFont'
      if @inFrm then
        @nodes["fonts"][*receiver] = *args
      elsif @inCntn then
        (serch_node2(@nodes,@cntname)["fonts"])[*receiver] = *args
      else
      end
    when 'newfont'
      f=FontStruct.new2(args)
      f
    when 'insertband'
      p0=@cntname.sub(/_(\w+)$/,'')
      if p0 == "Cntn" then
        if itm=find_item(@nodes,$1) then
          itm.last << [args[0],args[1],args[2],args[3]]
        else
          unless @item_pendings[$1]
            @item_pendings[$1] = [[args[0],args[1],args[2],args[3]]]
          else
            @item_pendings[$1] << [args[0],args[1],args[2],args[3]]
          end
        end
      else
        if itm=find_item(serch_node2(@nodes,p0),$1) then
          itm.last << [args[0],args[1],args[2],args[3]]
        else
          unless @item_pendings[@cntname]
            @item_pendings[@cntname] = [[args[0],args[1],args[2],args[3]]]
          else
            @item_pendings[@cntname] << [args[0],args[1],args[2],args[3]]
          end
        end
      end
    when /set\w+/
      if @inFrm then
        find_item(@nodes,receiver[0].sub(/@/,''))[8] = args[0]
      elsif @inCntn
        find_item(serch_node2(@nodes,@cntname),receiver[0].sub(/@/,''))[8] = args[0]
      else
      end
    else
      receiver.send( method,*args)
    end
  end
  
  def do_array(var, args )
    if var =~/\$_.+_fonts/ then
      args[0]
    end
  end
  
  def parse( str )
    @str = str
    yyparse self, :scan
    [@st1,@nodes,@var]
  end

  def scan
    @inFrm = @inCntn = @inDef  = requires = false
    str = @str
    str.strip!
    @st1 = @modname = ""
    until str.empty? do
      case str
      when /\A\s*\$_\w+_fonts\s*=\s*/
        sfon=str[$~.end(0)..sidx=str.index("]",$~.end(0))]
        @form.instance_eval("@temp_fonts=#{sfon}")
        @form.instance_eval("@temp_fonts.each{|i|@afont[i.hfont]=i}")
        str=str[sidx+2..str.size-1]
      when /\Avr_DIR\=\"vr\/\" unless vr_DIR\W.*[\r\n]?/
        str = $' ;requires = true
      when /\Arequire vr_DIR\+('.+')\W.*[\r\n]?/
        @st1 += $& unless requires
        str = $'
      when /\Amodule (Cntn_\w+).*$/, /\Amodule (Extn_\w+).*$/
        @inCntn = includes = true ;  @cntname = $1
        make_node(@nodes,@cntname,nil)
        str = $'
        @st1 += $& +"\n"
      when /\Amodule Frm_(\w+).*$/
        @inFrm = includes = true ; @modname=$1
        @form.instance_eval("self.name='#{@modname}'")
        str = $'
        @st1 += $& +"\n"
      when /\Ainclude (\w+).*$/
        @st1 += $& unless includes
        str = $'
        s1=$1
        if @inFrm
          @nodes["modules"] << s1
        elsif @inCntn
          nod=serch_node2(@nodes,@cntname)
          nod["modules"] << s1
        else
        end
      when /\Adef +_cntn_init.*$/
        @inDef = true ; str = $' ;
      when /\Adef +_#{@modname}_init.*/
        @inDef = true ; str = $'
      when /\A#\$_/ #this is fd_prefix
        #reject fd_prefix
        str = $'
      when /\A\*/ #reject multi assign operator
        str = $'
      when /\A#.*[\r\n]?/
        if includes && @inFrm then
          includes = false
        elsif includes && @inCntn then
          includes = false
        elsif requires then
          requires = false
        else
          @st1+=$& unless @inDef
        end
        str = $'
      when /\A\s+/
        @st1 += $& unless @inDef || includes
        str = $'
      when /\Aend/
        if @inDef then
          yield 'end' ,$&
          @inDef = false
        else
          @st1+=$&
        end
        str = $'
      when /\A[+-]?\d+/
        if @inDef then
          yield :NMBR ,$&
        else
          @st1+=$&
        end
        str = $'
      when /\A"(?:[^"\\]+|\\.)*"/,/\A'(?:[^'\\]+|\\.)*'/ #"
        if @inDef
          yield :STRG, $&
        else
          @st1+=$&
        end
        str = $'
      when /\A[@$]?\w+/
        if @inDef
          yield :IDNT, $&
        else
          @st1+=$&
        end
        str = $'
      else
        c = str[0,1]
        if @inDef then
          yield c, c
        else
          @st1 += c
        end
          str = str[1..-1]
      end
    end
    yield false, '$'
  end

  def next_token
    @q.shift
  end
end #module



module Inner_new
  
  def _init(frm)
    @form=frm
#    @var={}
    @x=@y=0
    @cntctrls={}
    @nodes = Node.new(@form.name)
    @current = @nodes
    @inDef=false
  end
  
  class Node < Hash
    attr_accessor :parent, :klass, :items, :var, :methods, :default_font
    
    def initialize(name)
      self["name"]=name
      self["childs"]=[]
      self["addings"]=[]
      self["fonts"]={}
      self["modules"]=[]
      self["margins"]={}
      @klass=nil
      @items=nil
      @parent=nil
      @var={}
      @default_font=nil
      @methods=[]
    end
  
    def add(name,klass=nil)
      c=Node.new(name)
      c.parent=self
      c.klass=klass
      self["childs"] << c
      c
    end
    
    def find_class(key)
      r = self["childs"].find{|i| i["name"] == key}
      [r.klass,r.items] if r
    end
    
  end
  
  def do_end
    if @inDef then
      @inDef =false
    else
      @current=@current.parent
#      yyaccept unless @current 
    end
  end

  def do_primary(val)
    return val
    return nil unless val
    if  val =~ /\A[A-Z]\w+/ || @var[val] then
      val
    else
      @form.instance_eval(val)
    end
  end
  
  def do_arr_prim(val)
    if val.is_a?(String) && (val =~ /^['"].*['"]$/) then
      @form.instance_eval(val)
    else
      val
    end
  end
  
  def do_assign(receiver, vname, val)
    return if val == nil
    receiver = [''] unless receiver
    if val.is_a? String then
      @current.methods << [receiver.join('.'), vname+'=', val]
    elsif val && val == @__newMenu
      r = @current["addings"].find{|i| i[1] == vname.sub(/@/,'')}
      r[7] = 0; r[8] = val
    elsif val && val == @__newPopupMenu
      r = @current["addings"].find{|i| i[1] == vname.sub(/@/,'')}
      r[7] = 0; r[8] = val
    elsif val && val == @__set_mgd_frame_args
      r = @current["addings"].find{|i| i[1] == vname.sub(/@/,'')}
      r[7] = 0; r[8] = val[1..val.size-1]; r[9]= true
    elsif val && val == @__new_mgd_frame_args
      r = @current["addings"].find{|i| i[1] == vname.sub(/@/,'')}
      r[7] = 0; r[8] = val
    else
      @current.methods << [receiver.join('.'), vname+'=', val]
    end
  end

  def do_send(val)
    [val]
  end

  def do_send2(rcvr,val)
    rcvr.push val
  end
  
  def find_item(node,name)
    unless node["addings"] == []  then 
      r = node["addings"].select{|j| j[1] == name}[0]
      r
    else
      nil
    end
    r
  end
  
  def do_call(receiver,method, args )
#    receiver = @form if receiver == ["self"]
    @_newPopupMenu = nil
    a=""
    a=args.join(",")
    case method
    when 'extend'
      #do nothing
    when 'vrinit'
      #do nothing
    when 'addControl'
      cname,itm= @current.find_class(args[0])
      if cname then
        args[0]=@form.instance_eval(cname)
        args[8]=itm if itm
      else
        args[0]=@form.instance_eval(args[0])
      end
      args[1..2] = args[1..2].map{|i| eval(i)}
      @current["addings"] << args
      nil
    when 'setMenu'
#      args[0].scan(/@(.+)/)
#      c = @form.send("newFDMenu",@form,@form.instance_eval("VRMenu"),$1,
#                                  $1,0,@y+=24,24,24,0,@current.var[args[0]])
#      c.send("extend",FDCommonMethod)
#      @form.instance_eval "@names << '#{$1}'"
#      c.send("accel",args[1])
      @current.methods << [args[0],'accel', args[1]]
    when 'set'
      if receiver[0]=='newPopupMenu' then
        @__newPopupMenu = args[0]
      else
        @__newMenu = args[0]
      end
      args[0]
    when 'setFont'
      args[0].match(/[A-Z][a-zA-Z0-9_]+_fonts\[(\d)\]\Z/)
      @current["fonts"][*receiver] = $1.to_i
    when 'newfont'
      f=FontStruct.new2(args)
      f
    when 'setMarginedFrame'
      @__set_mgd_frame_args = args
      args
    when 'new'
      @__new_mgd_frame_args = args
    when 'setup'
      # thrugh receiver
      receiver
    when 'setMargin'
      @current.methods << [receiver.join('.'), method, args]
    when 'insertband'
      @current.methods << ['self', 'setbandattr', args]
      #do nothing
    when 'setupPanels'
      @current.items=args[0].map{|i| [i[0],nil,i[2]]}
    when 'autoresize_panels'
      #do nothing
    when 'register'
      @current.methods << [receiver.join('.'), method, args]
    when /set\w+/
      find_item(@current,receiver[0].sub(/@/,''))[8] = args[0]
    else
      @form.instance_eval(receiver.join('.')).send( method,*args)
    end
  end
  
  def do_array(var, args)
    if var =~/[A-Z][a-zA-Z0-9_]+_fonts\Z/ then
      args[0]
    end
  end
  
  def parse( str )
    @str = str
    yyparse self, :scan
    [@st1,@nodes,@var]
  end

  def scan
    @inDef  = requires = false
    s = StringScanner.new(@str)
    @st1 = ""; @modname = ""
    until s.eos? do
      case
      when s.scan(/\A\s*[A-Z][a-zA-Z0-9_]+?_fonts\=\s*(\[.*?\])/m)
        @form.instance_eval("@temp_fonts=#{s[1].strip}")
        @form.instance_eval("@temp_fonts.each{|i|@_hsh_font[i.hfont]=i}")
      when s.scan(/\A\s*DEFAULT_FONT\s*=[\s*A-Z][a-zA-Z0-9_]+_fonts\[(\d)\]\s*$/)
        @current.default_font = s[1].to_i
      when s.scan(/\Amodule (\w+).*$/)
        includes = true ;
        @current = @current.add(s[1])
        @st1 += s[0] +"\n"
      when s.scan(/\Aclass (\w+)\s*<\s*(\w+).*$/)
        includes = true ;
        @current = @current.add(s[1],s[2])
        @st1 += s[0] +"\n"
      when s.scan(/\Ainclude (\w+).*$/)
        @st1 += s[0] unless includes
        @current["modules"] << s[1]
      when s.scan(/\Adef +vrinit.*$/)
        @inDef = true 
      when s.scan(/\Adef construct.*$/)
        @inDef = true 
      when s.scan(/\A#\$_/) #this is fd_prefix
        #reject fd_prefix
      when s.scan(/\A\*/) #reject multi assign operator
      when s.scan(/\A#.*[\r\n]?/)
        @st1+=s[0] unless @inDef
      when s.scan(/\A\s+/)
        @st1 += s[0] unless @inDef || includes
      when s.scan(/\Aend/)
        yield 'end' ,s[0]
      when s.scan(/\Atrue/), s.scan(/\Afalse/), s.scan(/\Anil/)
        if @inDef then
          yield :CNST ,eval(s[0])
        else
          @st1+=s[0]
        end
      when s.scan(/\A0x[0-9a-fA-F]+/),s.scan(/\A\d+\.\d+/),s.scan(/\A[+-]?\d+/)
        if @inDef then
          yield :NMBR ,eval(s[0])
        else
          @st1+=s[0]
        end
      when s.scan(/\A"(?:[^"\\]+|\\.)*"/),s.scan(/\A'(?:[^'\\]+|\\.)*'/)
        if @inDef
          yield :STRG, s[0]
        else
          @st1+=s[0]
        end
      when s.scan(/\A([\@\$]?[a-z_][a-zA-Z0-9_]+)/)
        if @inDef
          yield :IDNT, s[0]
        else
          @st1+=s[0]
        end
      when s.scan(/\A[A-Z][a-zA-z0-9_]*(::[A-Z][a-zA-z0-9_]*)?/)
        if @inDef
          yield :IDNT, s[0]
        else
          p s[0]
          @st1+=s[0]
        end
      else
        c = s.getch
        if @inDef then
          yield c, c
        else
          @st1 += c
        end
      end
    end
    yield false, '$'
  end

  def next_token
    @q.shift
  end
end #module
