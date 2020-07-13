# fdcontrols.rb
# Controls on pallets
#
# Programmed by yukimi_sake@mbi.nifty.com
# Copyright 2001-2003 Yukio Sakaue

require 'vr/vrmgdlayout'
require 'fdvr/m17n'
require 'fdvr/fdmodules'
require 'fdvr/fdresources'
require 'yaml'

class Hash
  def << (h) self.update h end
  def + (h) r = self.clone; r.update h end
end


module FDControls
  include FDBmps
  include FDItems
  include FDFakeClass
  include FDModules
  include VRMarginedFrameUseable
  attr_reader(:prBevel)

  FDStruct=Struct.new :klass,:inst,:dflt_w,:dflt_h,:style,:required,:included,
          :createMethod,:info,:attrs,:events,:mthds,:mods,:popups,:items,:bmp,
          :default_style
  FDPallet = Struct.new(:title,:items)
      # Description of attribute metohd definition
  def controls_init
#    @prStyle = lambda{|c|"0x"+sprintf("%8X",c.style)}
    @prStyle = 'lambda{|c| st = (c.style|c.owndraw)-c._default_style
      st == 0 ? "default" : sprintf("%#x",st)}'
    @prExStyle = 'lambda{|c| c.exstyle.to_x}'
    @prFont = 'lambda{|c| getFontName(c)}'
    @prTab = 'lambda{|c| c.tab_order}'
    @prArray = 'lambda{|c| "click ->"}'
    @prMenuItem = 'lambda{|c| "click ->"}'
    @prModule = 'lambda{|c| "click ->"}'
    @prAccel = 'lambda{|c| if c.getaccel then "true" else "false" end}'
    @prCCS = 'lambda{|c| FDWStyle::CCSStr[c.style & 0x2f]}'
    @prOwnerDraw = 'lambda{|c| c.owndraw_used?}'
    @prLayout =  'lambda{|c| "click ->"}'
    @prBevel = 'lambda{|c|
      { VRMgdTwoPaneFrame::BevelNone=>"None",
        VRMgdTwoPaneFrame::BevelGroove1=>"Groove1",
        VRMgdTwoPaneFrame::BevelGroove2=>"Groove2",
        VRMgdTwoPaneFrame::BevelRaise1=>"Raise1",
        VRMgdTwoPaneFrame::BevelRaise2=>"Raise2",
        VRMgdTwoPaneFrame::BevelSunken1=>"Sunken1",
        VRMgdTwoPaneFrame::BevelSunken2=>"Sunken2"}[c.substance.bevel]}'
    std_attr = ["name","caption","x","y","w","h",["font",@prFont,:_btFont],
               ["style",@prStyle,:_btStyle],["exstyle",@prExStyle,:_btExStyle],
               ["modules",@prModule,:_btModule], ["tabOrder", @prTab,:_btTab],
               ["owndraw",@prOwnerDraw,:_cbOwnDraw]]
    
=begin
a = [
  FDPallet["Standard",[
  #klass,inst,dflt_w,dflt_h,style,required,included,createMethod,info,container
    FDStruct["VRButton","button",80,24,0,"vrcontrol",nil,:newFDCtrl,"Button",
     std_attr, #attrs
      ["clicked","dblclicked"], #events
      [

      ],#mthds
      StdModules,#mods
      [["font","setfont"],["color","setcolor"]],#popups
      nil,#items
      BmpButton,0x50000000
    ],
    FDStruct["VREdit","edit",120,20,0,"vrcontrol",nil,:newFDCtrl,"Edit",
      std_attr, #attrs
      ["changed"], #events
      [
        "text", "text=(str)","getSel","setSel(st,en,noscroll=0)","setCaret(r)",
        "replaceSel(newstr)","readonly=(b)","limit","modified","modified=(f)",
        "cut","copy","paste","clear","undo"
      ],#mthds
      StdModules,#mods
      [["font","setfont"],["color","setcolor"]],#popups
      nil,#items
      BmpEdit,0x50000080
    ],
    FDStruct["VRText","text",120,100,0,"vrcontrol",nil,:newFDCtrl,"Text",
      std_attr, #attrs
      ["changed"], #events
      [
        "text", "text=(str)","getSel","setSel(st,en,noscroll=0)","setCaret(r)",
        "replaceSel(newstr)","readonly=(b)","limit","modified","modified=(f)",
        "cut","copy","paste","clear","undo"
      ],#mthds
      StdModules,#mods
      [["font","setfont"],["color","setcolor"]],#popups
      nil,#items
      BmpText,0x50000044
    ],
    FDStruct["VRCheckbox","checkBox",96,24,0,"vrcontrol",nil,:newFDCtrl,"CheckBox",
      std_attr, #attrs
      ["clicked","dblclicked"], #events
      ["checked?", "check(v)"],#mthds
      StdModules,#mods
      [["font","setfont"],["color","setcolor"]],#popups
      nil,#items
      BmpCheckbox,0x50000003
    ],
    FDStruct["VRRadiobutton","radioBtn",96,24,0,"vrcontrol",nil,:newFDCtrl,"RadioButton",
      std_attr, #attrs
      ["clicked","dblclicked"], #events
      ["checked?", "check(v)"],#mthds
      StdModules,#mods
      [["font","setfont"],["color","setcolor"]],#popups
      nil,#items
      BmpRadiobutton,0x50000009
    ],
FDStruct["VRStatic","static",96,24,0,"vrcontrol",nil,:newFDCtrl,"StaticText",
      std_attr, #attrs
      [], #events
      [],#mthds
      StdModules,#mods
      [["font","setfont"],["color","setcolor"]],#popups
      nil,#items
      BmpStatic,0x50000000
    ],
    FDStruct["VRListbox","listBox",120,120,0,"vrcontrol",nil,:newFDCtrl,"ListBox",
      std_attr, #attrs
      ["selchanged"], #events
      ["addString(idx,str)","deleteString(idx)","countStrings","clearStrings",
        "eachString{|i|}","setListStrings(strarray)","selectedString","select(idx)",
        "getTextOf(idx)","setDir(fname,opt=0)","findString(findstr,start=0)","getDataOf(idx)",
        "setDataOf(idx,data)"],#mthds
      StdModules,#mods
      [["font","setfont"],["color","setcolor"]],#popups
      nil,#items
      BmpListbox,0x50800001
    ],
    FDStruct["VRCombobox","comboBox",120,80,0,"vrcontrol",nil,:newFDCombo,"ComboBox",
      std_attr[0..5]+["drop_h"]+std_attr[6..-1], #attrs
      ["selchanged"], #events
      ["addString(idx,str)","deleteString(idx)","countStrings","clearStrings",
        "eachString{|i|}","setListStrings(strarray)","selectedString","select(idx)",
        "getTextOf(idx)","setDir(fname,opt=0)","findString(findstr,start=0)","getDataOf(idx)",
        "setDataOf(idx,data)"],#mthds
      StdModules,#mods
      [["font","setfont"],["color","setcolor"]],#popups
      nil,#items
      BmpCombobox,0x50000203
    ],
    FDStruct["VREditCombobox","edCmbBox",120,80,0,"vrcontrol",nil,:newFDCombo,
    "EditComboBox",
      std_attr[0..5]+["drop_h"]+std_attr[6..-1], #attrs
      ["selchanged"], #events
      ["addString(idx,str)","deleteString(idx)","countStrings","clearStrings",
        "eachString{|i|}","setListStrings(strarray)","selectedString","select(idx)",
        "getTextOf(idx)","setDir(fname,opt=0)","findString(findstr,start=0)","getDataOf(idx)",
        "setDataOf(idx,data)"],#mthds
      StdModules,#mods
      [["font","setfont"],["color","setcolor"]],#popups
      nil,#items
      BmpEdCombo,0x50000243
    ],
    FDStruct["VRGroupbox","groupBox",120,120,0,"vrcontrol",nil,:newFDCtrl,"GroupBox",
      std_attr, #attrs
      [], #events
      [],#mthds
       StdModules.merge(ParentModules),#mods
      [["font","setfont"],["color","setcolor"]],#popups
      nil,#items
      BmpGroupbox,0x50000007
    ],
    FDStruct["VRPanel","panel",120,120,0,"vrcontrol",nil,:newFDCtrl,"Panel",
      std_attr[0..-3], #attrs
      [], #events
      [],#mthds
      StdModules.merge(ParentModules),#mods
      [["font","setfont"],["color","setcolor"]],#popups
      nil,#items
      BmpPanel,0x50000000
    ],
    FDStruct["VRCanvasPanel","canvaspanel",120,120,0,"vrcontrol",nil,:newFDCtrl,"CanvasPanel",
      std_attr[0..-3], #attrs
      [], #events
      ["createCanvas(w,h,color=0xffffff)","canvas"],#mthds
      StdModules.merge(ParentModules),#mods
      [["font","setfont"],["color","setcolor"]],#popups
      nil,#items
      BmpCanvasPanel,0x50000000
    ],
    FDStruct["VRBitmapPanel","bmppanel",120,120,0,"vrcontrol",nil,:newFDCtrl,"BmpPanel",
      std_attr[0..-3], #attrs
      [], #events
      ["loadFile(filename)", "createBitmap(info,bmp)" ,"bmp"],#mthds
      StdModules.merge(ParentModules),#mods
      [["font","setfont"],["color","setcolor"]],#popups
      nil,#items
      BmpBitmapPanel,0x50000000
    ]
  ]],
  FDPallet["Additonal",[
    FDStruct["VRRichedit","richEdit",150,150,0,"vrrichedit",nil,
    :newFDCtrl,"RichEdit",
      std_attr[0..-2],#attrs
      ["changed"],
      [
        "text",
        "text=(str)",
        "getSel",
        "setSel(st,en,noscroll=0)",
        "setCaret(r)",
        "replaceSel(newstr)",
        "readonly=(b)",
        "limit",
        "modified",
        "modified=(f)",
        "cut",
        "copy",
        "paste",
        "clear",
        "undo",
        "char2line(ptr)",
        "setTextFont(fontface,height=280,area=SCF_SELECTION)",
        "getTextFont(selarea=true)",
        "setTextColor(col,area=SCF_SELECTION)",
        "getTextColor(selarea=true)",
        "setBold(flag=true,area=SCF_SELECTION)",
        "setItalic(flag=true,area=SCF_SELECTION)",
        "setUnderlined(flag=true,area=SCF_SELECTION)",
        "setStriked(flag=true,area=SCF_SELECTION)",
        "bold?(selarea=true)",
        "italic?(selarea=true)",
        "underlined?(selarea=true)",
        "striked?(selarea=true)",
        "setAlignment(align)",
        "bkcolor=(color)",
        "selformat(area=SCF_SELECTION)",
        "selformat=(format)"
      ],#mthds
      StdModules,#mods
      [["font","setfont"]],#popups
      nil,#items
      BmpRichedit,0x50000004
    ],
    FDStruct["VRToolbar","toolBar",150,26,0,"vrcomctl","VRToolbarUseable",:newFDToolbar,"Toolbar",
      std_attr[0..-3]+[["ccstyles",@prCCS,nil],["buttons",@prArray,:_btArray]], #attrs
      nil, #events
      [
        "insertButton(i,name,style=TBSTYLE_BUTTON)",
        "addButton(style)",
        "deleteButton(i)",
        "clearButtons",
        "countButtons",
        "setImagelist(imglist)",
        "setParent(hwnd)",
        "autoSize",
        "indeterminateOf(i,bool=true)",
        "commandToIndex(id)",
        "enableButton(i,bool=true)",
        "getButtonStateOf(id)",
        "setButtonStateOf(i,state)",
        "setButtons(buttons)",
        "enumButtons"
      ],#mthds
      StdModules,#mods
      [["font","setfont"]],#popups
      FDItems::FDToolbarTemplate,#items
      BmpToolbar,0x50000001
    ],
    FDStruct["VRRebar","rebar",150,32,0,"vrcomctl",nil,:newFDRebar,"Rebar",
      std_attr[0..-3]+[["buttons",@prArray,:_btArray]], #attrs
      ["layoutchanged"], #events
      [
        "insertband(cntl,txt,minx=30,miny=cnt.h+2,band=-1)",
        "bkColor=(c)",
        "bkColor",
        "textColor=(c)",
        "textColor",
        "relayout(x=self.x, y=self.y, w=self.w, h=self.h)"
      ],#mthds
      StdModules,#mods
      [["font","setfont"],["color","setcolor"]],#popups
      nil,#items
      BmpRebar,0x50000001
    ],
    FDStruct["VRListview","listView",120,120,0,"vrcomctl",nil,:newFDCtrl,"Listview",
     std_attr+[["lvexstyle",'lambda{|c|c.lvexstyle.to_x}',:_btStyle]],#attrs
   ["itemchanged(idx,state)","itemchanging(idx,state)","columnclick(subitem)",
        "begindrag","beginrdrag"], #events
      [
        "setViewMode(mode)",
        "getViewMode",
        "iconview",
        "reportview",
        "smalliconview",
        "listview",
        "setBkColor(color)",
        "bkcolor=(color)",
        "lvexstyle",
        "lvexstyle=(style)",
        "setListviewExStyle(style,mask=0xffffffff)",
        "insertColumn(column,text,width=50,format=0,textsize=title.size)",
        "deleteColumn(column)",
        "clearColumns",
        "countColumns",
        "addColumn(text,width=50,format=0,textsize=title.size)",
        "setImagelist(imagelist,itype=0)",
        "setItemIconOf(hitem,img)",
        "getItemIconOf(hitem)",
        "getColumnWidthOf(column)",
        "setColumnWidthOf(column,width)",
        "getColumnTextOf(column)",
        "setColumnTextOf(column,text)",
        "getColumnFormatOf(column)",
        "setColumnFormatOf(column,format)",
        "insertItem(index,texts,lparam=0,textsize=128)",
        "addItem(texts,lparam=0,textsize=128)",
        "insertMultiItems(index,multitexts)",
        "deleteItem(idx)",
        "clearItems" ,
        "countItems",
        "hittest(x,y)",
        "hittest2(x,y)",
        "getItemRect(idx)",
        "getItemStateOf(idx)",
        "setItemStateOf(idx,state)",
        "selectItem(idx,flag) ",
        "getNextItem(start,flags)",
        "focusedItem",
        "getItemTextOf(idx,subitem=0,textsize=128)",
        "setItemTextOf(idx,subitem,text,textsize=text.size)",
        "getItemLParamOf(idx)",
        "setItemLParamOf(idx,lparam)",
        "selected?(idx)",
        "focused?(idx)",
        "eachSelectedItems",
        "countSelectedItems()",
        "ensureVisible(i,partial=true)",
      ],#mthds
      StdModules,#mods
      [["font","setfont"]],#popups
      nil,#items
      BmpListview,0x50000001
    ],
    FDStruct["VRTreeview","treeView",120,120,0,"vrcomctl",nil,:newFDCtrl,"Treeview",
      std_attr[0..-2],#attrs
      [
        "selchanged(hitem,lparam)",
        "itemexpanded(hitem,state,lparam)",
        "deleteitem(hitem,lparam)",
        "begindrag(hitem,state,lparam)",
        "beginrdrag(hitem,state,lparam)"
      ],#events
      [
        "insertItem(hparent,hafter,text,lparam=0,textsize=text.size)",
        "insertMultiItems(hparent,hafter,items)",
        "addItem(hparent,text,lparam=0,textsize=text.size)",
        "addMultiItems(hparent,items)",
        "deleteItem(hitem)",
        "clearItems",
        "countItems",
        "selectItem(hitem)",
        "indent",
        "indent=",
        "hittest(x,y)",
        "hittest2(x,y)",
        "getNextItem(hitem,code)",
        "topItem",
        "root",
        "last",
        "selectedItem()",
        "getParentOf(hitem)",
        "getChildOf(hitem)",
        "getNextSiblingOf(hitem)",
        "setImagelist(imagelist)",
        "setItemIconOf(hitem,img,simg)",
        "getItemIconOf(hitem)",
        "setItemLParamOf(hitem,lparam)",
        "getItemLParamOf(hitem)",
        "setItemTextOf(hitem,text)",
        "getItemTextOf(hitem,textsize=128)",
        "setItemStateOf(hitem,state)",
        "getItemStateOf(hitem)"
      ],#mthds
      StdModules,#mods
      [["font","setfont"]],#popups
      nil,#items
      BmpTreeview,0x5000000f
    ],
    FDStruct["VRProgressbar","prgrssBar",120,20,0,"vrcomctl",nil,:newFDCtrl,"Progressbar",
      std_attr[0..-3], #attrs
      [], #events
      [
      "setRange(minr,maxr)","position","position=(pos)","stepwidth=(st)","step","advance(n=1)"
      ],#mthds
      StdModules,#mods
      [["font","setfont"],["color","setcolor"]],#popups
      nil,#items
      BmpProgressbar,0x50000000
    ],
    FDStruct["VRTrackbar","trackBar",120,25,0,"vrcomctl",nil,:newFDCtrl,"Trackbar",
      std_attr[0..-2], #attrs
      [], #events
      [
        "position",
        "position=(pos)",
        "linesize",
        "linesize=(s)",
        "pagesize",
        "pagesize=(p)",
        "rangeMin",
        "rangeMin=(m)",
        "rangeMax",
        "rangeMax=(m)",
        "selStart",
        "selStart=(m)",
        "selEnd",
        "selEnd=(m)",
        "clearSel",
      ],#mthds
      StdModules,#mods
      [["font","setfont"],["color","setcolor"]],#popups
      nil,#items
      BmpTrackbar,0x50000000
    ],
    FDStruct["VRUpdown","updown",25,16,0,"vrcomctl",nil,:newFDCtrl,"Updown",
      std_attr[0..-3], #attrs
      ["changed(pos)"], #events
      [
        "setRange(minr,maxr)",
        "getRange",
        "position",
        "position=",
        "base",
        "base=(b)",
      ],#mthds
      StdModules,#mods
      [["font","setfont"],["color","setcolor"]],#popups
      nil,#items
      BmpUpdown,0x50000000
    ],
    FDStruct["VRStatusbar","statusbar",120,25,0,"vrcomctl",nil,:newFDCtrl,"Statusbar",
      std_attr[0..-3], #attrs
      [], #events
      [
        "setparts(p,width=[-1])",
        "parts",
        "getTextOf(idx)",
        "setTextOf(idx,text,style=0)",
        "getRectOf(idx)",
        "minheight=(minh)"
      ],#mthds
      StdModules,#mods
      [["font","setfont"],["color","setcolor"]],#popups
      nil,#items
      BmpStatusbar,0x50000000
    ],
    FDStruct["VRTabControl","tabControl",140,45,0,"vrcomctl",nil,:newFDCtrl,"TabControl",
    std_attr[0..-3]+[["owndraw",@prOwnerDraw,:_cbOwnDraw]], #attrs
      ["selchanged"], #events
      [
        "insertTab(index,text,textmax=text.size,lparam=0)",
        "clearTabs",
        "deleteTab(idx)",
        "countTabs",
        "selectedTab",
        "selectTab(idx)",
        "setImagelist(imagelist)",
        "setTabSize(width,height)",
        "getTabRect(i)",
        "adjustRect(x,y,w,h,flag=false)",
        "getTabTextOf(idx)",
        "setTabTextOf(idx,text)",
        "getTabImageOf(idx)",
        "setTabImageOf(idx,image)",
        "getTabLParamOf(idx)",
        "setTabLParamOf(idx,lparam)"
      ],#mthds
      StdModules.merge(ParentModules),#mods
      [["font","setfont"],["color","setcolor"]],#popups
      nil,#items
      BmpTabControl,0x54000000
    ],
    FDStruct["VRTabbedPanel","tabPanel",140,140,0,"vrcomctl",nil,:newFDTabbedPanel,"TabbedPanel",
    std_attr[0..-3] + [["pages",@prArray,:_btArray],
    ["owndraw",@prOwnerDraw,:_cbOwnDraw]], #attrs
      ["selchanged"], #events
      [
        "setupPanels(title-1,title-2,title-3,....)",
        "send_parent2(idx,controlname,eventname)",
        "panels",
        "insertTab(index,text,textmax=text.size,lparam=0)",
        "clearTabs",
        "deleteTab(idx)",
        "countTabs",
        "selectedTab",
        "selectTab(idx)",
        "setImagelist(imagelist)",
        "setTabSize(width,height)",
        "getTabRect(i)",
        "adjustRect(x,y,w,h,flag=false)",
        "getTabTextOf(idx)",
        "setTabTextOf(idx,text)",
        "getTabImageOf(idx)",
        "setTabImageOf(idx,image)",
        "getTabLParamOf(idx)",
        "setTabLParamOf(idx,lparam)"
      ],#mthds
      StdModules.merge(ParentModules),#mods
      [["font","setfont"],["color","setcolor"]],#popups
      ['tab1','tab2'],#items
      BmpTabbedPanel,0x54000000
    ],
    FDStruct["VRMediaView","mmedia",200,26,0,"vrmmedia","VRMediaViewModeNotifier",
                                                    :newFDCoverd,"MediaView,",
      std_attr[0..-3], #attrs
      [
        "onerror()",
        "modechanged(newmode)",
        "sizechanged()",
        "mediachanged(str)",
      ], #events
      [
        "mediaopen(filename,flag=0)",
        "mediaclose",
        "mode",
        "modestring(n)",
        "errorstring",
        "play",
        "pause",
        "stop",
        "eject",
        "step(n=1)",
        "seek(pos)",
        "seekHome",
        "seekEnd",
        "playable?",
        "ejectable?",
        "window?",
        "length",
        "position",
        "volume",
        "volume=(vl)",
        "speed",
        "speed=",
        "zoom",
        "zoom="
      ],#mthds
       StdModules,#mods
      [],#popups
      nil,#items
      BmpMmedia,0x50005d80
    ]
  ]],

  FDPallet["System" ,[
    FDStruct["VRMenu","mainmenu",24,24,0,"vrcontrol","VRMenuUseable",:newFDMenu,"Menu",
      ["name","caption","x","y",["accel",@prAccel,:_cbTF],["menus",@prMenuItem,:_btArray]],
      nil,
      ["append(caption,state)",
       "insert(ptr,caption,state)",
       "delete(id)",
       "count",
       "set(sarr)"
      ],#mthds
      nil,#mods
      [["addItem","addItem"]],
      FDItems::FDMenuTemplate,#items
      BmpMenu
    ],
    FDStruct["FDPopup","popupmenu",24,24,0,"vrcontrol","VRMenuUseable",:newFDPopup,"PopupMenu",
      ["name","caption","x","y",["menus",@prMenuItem,:_btArray]],
      nil,
      ["showPopup(menu)",
       "append(caption,state)",
       "insert(ptr,caption,state)",
       "delete(id)",
       "count",
       "set(sarr)"
      ],#mthds
      nil,#mods
      [["addItem","addItem"]],
      FDItems::FDPopupMenuTemplate,#items
      #FDItems::FDMenuTemplate,#items
      BmpPopupMenu
    ],
    FDStruct["FDOpenDlg","openDlg",24,24,0,nil,nil,:newFDOpenSaveDlg,"OpenDlg",
      ["name","caption","x","y",
    ["filters",@prArray,:_btArray],["flags",@prArray,:_btArray],
    "title","defaultExt"], #attrs
      [], #events
      ["openFilenameDialog(*arg)"],#mthds
      nil,#mods
      [],#popups
      nil,#items
      BmpOpenDlg
    ],
    FDStruct["FDSaveDlg","saveDlg",24,24,0,nil,nil,:newFDOpenSaveDlg,"SaveDlg",
      ["name","caption","x","y",
        ["filters",@prArray,:_btArray],["flags",@prArray,:_btArray],"title","defaultExt"], #attrs
      [], #events
      ["saveFilenameDialog(*arg)"],#mthds
      nil,#mods
      [],#popups
      nil,#items
      BmpSaveDlg
    ],
    FDStruct["FDSelectDir","selectDirectory",24,24,0,nil,nil,:newFDSelectDir,"SelectDirectory",
      ["name","caption","x","y","title","initialdir",["flags",@prArray,:_btArray]], #attrs
      [], #events
      ["selectDirectory(*arg)"],#mthds
      nil,#mods
      [],#popups
      nil,#items
      BmpFolder
    ],
    FDStruct["FDFontDlg","fontDlg",24,24,0,nil,nil,:newFDModule,"FontDlg",
      ["name","caption","x","y"], #attrs
      [], #events
      ["chooseFontDialog(*arg)"],#mthds
      nil,#mods
      [],#popups
      nil,#items
      BmpFontDlg
    ],
    FDStruct["FDColorDlg","colorDlg",24,24,0,nil,nil,:newFDModule,"ColorDlg",
      ["name","caption","x","y"], #attrs
      [], #events
      ["chooseColorDialog(*arg)"],#mthds
      nil,#mods
      [],#popups
      nil,#items
      BmpColorDlg
    ]
 ]],
FDPallet["Layout",[
    FDStruct["VRMgdHorizTwoPaneFrame","horiz2Pane",24,24,0,'vrmgdlayout',
    "VRMarginedFrameUseable",:newFD2Pane,
    "Horiz2Pane",["name","caption","x","y",["register",@prLayout,:_btLayout],
      ["ratio",'lambda{|c|c.substance.ratio}',"self.ratio"],
      ["position",'lambda{|c|c.substance.position}',"self.position"],
      ["gap",'lambda{|c|c.substance.gap}',"num"],
      ["bevel",@prBevel,:_cbBevel],
      ["lLimit",'lambda{|c|c.substance.lLimit}',"num"],
      ["rLimit",'lambda{|c|c.substance.rLimit}',"num"]
      ], #attrs
      [], #events
      [],#mthds
      nil,#mods
      [],#popups
      nil,#items
      BmpHoriz2Pane
    ],
    FDStruct["VRMgdVertTwoPaneFrame","vert2Pane",24,24,0,'vrmgdlayout',
    "VRMarginedFrameUseable",:newFD2Pane,
      "Vert2Pane",["name","caption","x","y",["register",@prLayout,:_btLayout],
      ["ratio",'lambda{|c|c.substance.ratio}',"self.ratio"],
      ["position",'lambda{|c|c.substance.position}',"self.position"],
      ["gap",'lambda{|c|c.substance.gap}',"num"],
      ["bevel",@prBevel,:_cbBevel],
      ["uLimit",'lambda{|c|c.substance.uLimit}',"num"],
      ["lLimit",'lambda{|c|c.substance.lLimit}',"num"]
      ], #attrs
      [], #events
      [],#mthds
      nil,#mods
      [],#popups
      nil,#items
      BmpVert2Pane
    ],
    FDStruct["VRMgdFullsizeLayoutFrame","fullsize",24,24,0,'vrmgdlayout',
    "VRMarginedFrameUseable",:newFDLayout,
      "FullsizeFrame",["name","caption","x","y",["register",@prLayout,:_btLayout],
      ], #attrs
      [], #events
      [],#mthds
      nil,#mods
      [],#popups
      nil,#items
      BmpFullsize
    ],
    FDStruct["VRMgdHorizLayoutFrame","horizFrame",24,24,0,'vrmgdlayout',
    "VRMarginedFrameUseable",:newFDLayout,
      "HorizFrame",["name","caption","x","y",["register",@prLayout,:_btLayout],
      ], #attrs
      [], #events
      [],#mthds
      nil,#mods
      [],#popups
      nil,#items
      BmpHorizFrame
    ],
    FDStruct["VRMgdVertLayoutFrame","vertFrame",24,24,0,'vrmgdlayout',
    "VRMarginedFrameUseable",:newFDLayout,
      "VertFrame",
      ["name","caption","x","y",["register",@prLayout,:_btLayout],
      ], #attrs
      [], #events
      [],#mthds
      nil,#mods
      [],#popups
      nil,#items
      BmpVertFrame
    ],
    FDStruct["VRMgdGridLayoutFrame","gridFrame",24,24,0,'vrmgdlayout',
    "VRMarginedFrameUseable",:newFDLayout,
    "GridFrame",["name","caption","x","y",["register",@prLayout,:_btLayout],
      ["xsize",'lambda{|c|c.substance.instance_eval "@_vr_xsize"}',"@_vr_xsize"],
      ["ysize",'lambda{|c|c.substance.instance_eval "@_vr_ysize"}',"@_vr_ysize"]
      ], #attrs
      [], #events
      [],#mthds
      nil,#mods
      [],#popups
      nil,#items
      BmpGridFrame
    ],
]]]
=end
    
    if defined? ExerbRuntime
      a = YAML.load(ExerbRuntime.open('fddefault.yml'))
    else
      a = YAML.load_file($program_dir + '/fddefault.yml')
    end
    
    a.each{|i|
      i.items.each{|j|
        j.klass = eval(j.klass)
        j.attrs = j.attrs.map{|i|
          if i.is_a? Array;
            [i[0], i[1].is_a?(Proc) ? i[1] : eval(i[1]) ,i[2]]
          else
            i
          end
        }
        j.bmp = Zlib::Inflate.inflate(j.bmp.unpack('m')[0])
      }
    }
    a
  end
end
