# fdwstyle.rb
# The wondow styles of controls
#
# Programmed by yukimi_sake@mbi.nifty.com
# Copyright 2001-2003 Yukio Sakaue

module FDWStyle
  WStyles ={
    "WS_BORDER" =>           0x800000,
    #  "WS_CAPTION" =>          0xc00000,
    #  "WS_CHILD" =>          0x40000000,
    #  "WS_CHILDWINDOW" =>    0x40000000,
    #  "WS_CLIPCHILDREN" =>    0x2000000,
    #  "WS_CLIPSIBLINGS" =>    0x4000000,
    "WS_DISABLED" =>        0x8000000,
    #  "WS_DLGFRAME" =>         0x400000,
    "WS_GROUP" =>             0x20000,
    "WS_HSCROLL" =>          0x100000,
    #  "WS_ICONIC" =>         0x20000000,
    #  "WS_MAXIMIZE" =>        0x1000000,
    #  "WS_MAXIMIZEBOX" =>       0x10000,
    #  "WS_MINIMIZE" =>       0x20000000,
    #  "WS_MINIMIZEBOX" =>       0x20000,
    #  "WS_OVERLAPPED" =>              0,
    #  "WS_OVERLAPPEDWINDOW" => 0xcf0000,
    #  "WS_POPUP" =>          0x80000000,
    #  "WS_POPUPWINDOW" =>    0x80880000,
    #  "WS_SIZEBOX" =>           0x40000,
    #  "WS_SYSMENU" =>           0x80000,
    #  "WS_TABSTOP" =>           0x10000,
    "WS_THICKFRAME" =>        0x40000,
    #  "WS_TILED" =>                   0,
    #  "WS_TILEDWINDOW" =>      0xcf0000,
    #  "WS_VISIBLE" =>        0x10000000,
    "WS_VSCROLL" =>          0x200000}
  
  
  CtlStyles = {
    VRButton => {
      :style=>{
        "BS_DEFPUSHBUTTON"  => 0x01,
        #  "BS_OWNERDRAW" => 0x0b,
        "BS_BITMAP" => 128,
        "BS_BOTTOM" => 0x800,
        "BS_CENTER" => 0x300,
        "BS_LEFT" => 256,
        "BS_RIGHT" => 512,
        "BS_TOP" => 0x400,
        "BS_VCENTER" => 0xc00,
        "BS_FLAT" => 0x8000,
        "BS_MULTILINE" => 0x2000,
        
        "WS_DISABLED" =>        0x8000000,
        "WS_THICKFRAME" =>        0x40000
      },
      :option =>{}
    },
    VREdit => {
      :style=>{
        "ES_AUTOHSCROLL" => 128,
        "ES_AUTOVSCROLL" => 64,
        "ES_CENTER" => 1,
        "ES_LOWERCASE" => 16,
        # "ES_MULTILINE" => 4,
        "ES_NOHIDESEL" => 256,
        "ES_NUMBER" => 0x2000,
        "ES_OEMCONVERT" => 0x400,
        "ES_PASSWORD" => 32,
        "ES_READONLY" => 0x800,
        "ES_RIGHT" => 2,
        "ES_UPPERCASE" => 8,
        "ES_WANTRETURN" => 4096,
        
        "WS_DISABLED" =>        0x8000000,
        "WS_THICKFRAME" =>        0x40000
      },
      :option =>{}
    },
    VRText => {
      :style=>{
        "ES_AUTOHSCROLL" => 128,
        "ES_AUTOVSCROLL" => 64,
        # "ES_CENTER" => 1,
        "ES_LOWERCASE" => 16,
        # "ES_MULTILINE" => 4,
        "ES_NOHIDESEL" => 256,
        "ES_NUMBER" => 0x2000,
        "ES_OEMCONVERT" => 0x400,
        "ES_PASSWORD" => 32,
        "ES_READONLY" => 0x800,
        # "ES_RIGHT" => 2,
        "ES_UPPERCASE" => 8,
        "ES_WANTRETURN" => 4096,
        
        "WS_DISABLED" =>        0x8000000,
        "WS_THICKFRAME" =>        0x40000
      },
      :option =>{}
    },
    VRCheckbox => {
      :style=>{
        "BS_RIGHTBUTTON" => 32,
        
        "WS_BORDER" =>           0x800000,
        "WS_DISABLED" =>        0x8000000,
        "WS_GROUP" =>             0x20000,
        "WS_THICKFRAME" =>        0x40000,
      },
      :option =>{}
    },
    VRRadiobutton => {
      :style=>{
        "BS_RIGHTBUTTON" => 32,
        
        "WS_BORDER" =>           0x800000,
        "WS_DISABLED" =>        0x8000000,
        "WS_GROUP" =>             0x20000,
        "WS_THICKFRAME" =>        0x40000,
      },
      :option =>{}
    },
    VRStatic => {
      :style=>{
        "SS_NOPREFIX" => 128,
        "SS_NOTIFY" => 256,
        "SS_CENTERIMAGE" => 512,
        "SS_RIGHTJUST" => 0x400,
        "SS_REALSIZEIMAGE" => 0x800,
        "SS_SUNKEN" => 4096,
        
        "WS_BORDER" =>           0x800000,
        "WS_THICKFRAME" =>        0x40000,
      },
      :option =>{
        "SS_LEFT" => 0,
        "SS_CENTER" => 1,
        "SS_RIGHT" => 2,
        "SS_ICON" => 3,
        "SS_BLACKRECT" => 4,
        "SS_GRAYRECT" => 5,
        "SS_WHITERECT" => 6,
        "SS_BLACKFRAME" => 7,
        "SS_GRAYFRAME" => 8,
        "SS_WHITEFRAME" => 9,
        "SS_USERITEM" => 10,
        "SS_SIMPLE" => 11,
        "SS_LEFTNOWORDWRAP" => 12,
        "SS_OWNERDRAW" => 13,
        "SS_BITMAP" => 14,
        "SS_ENHMETAFILE" => 15,
        "SS_ETCHEDHORZ" => 16,
        "SS_ETCHEDVERT" => 17,
        "SS_ETCHEDFRAME" => 18,
      }
    },
    VRListbox => {
      :style=>{
        #  "LBS_NOTIFY" => 1,
        "LBS_SORT" => 2,
        "LBS_NOREDRAW" => 4,
        "LBS_MULTIPLESEL" => 8,
        #  "LBS_OWNERDRAWFIXED" => 0x10,
        #  "LBS_OWNERDRAWVARIABLE" => 0x20,
        "LBS_HASSTRINGS" => 0x40,
        "LBS_USETABSTOPS" => 0x80,
        "LBS_NOINTEGRALHEIGHT" => 0x100,
        "LBS_MULTICOLUMN" => 0x200,
        "LBS_WANTKEYBOARDINPUT" => 0x400,
        "LBS_EXTENDEDSEL" => 0x800,
        "LBS_DISABLENOSCROLL" => 0x1000,
        "LBS_NODATA" => 0x2000,
        "LBS_NOSEL" => 0x4000,
        #  "LBS_STANDARD" => 0xa00003,
        
        "WS_DISABLED" =>        0x8000000,
        "WS_THICKFRAME" =>        0x40000,
      },
      :option =>{}
    },
    VRCombobox => {
      :style=>{
        #  "CBS_SIMPLE" => 1,
        #  "CBS_DROPDOWN" => 2,
        #  "CBS_DROPDOWNLIST" => 3,
        #  "CBS_OWNERDRAWFIXED" => 0x10,
        #  "CBS_OWNERDRAWVARIABLE" => 0x20,
        "CBS_AUTOHSCROLL" => 0x40,
        "CBS_OEMCONVERT" => 0x80,
        "CBS_SORT" => 0x100,
        "CBS_HASSTRINGS" => 0x200,
        "CBS_NOINTEGRALHEIGHT" => 0x400,
        "CBS_DISABLENOSCROLL" => 0x800,
        "CBS_UPPERCASE" => 0x2000,
        "CBS_LOWERCASE" => 0x4000,
        
        "WS_DISABLED" =>        0x8000000,
        "WS_THICKFRAME" =>        0x40000,
      },
      :option =>{}
    },
    
    VREditCombobox => {
      :style=>{
        #  "CBS_SIMPLE" => 1,
        #  "CBS_DROPDOWN" => 2,
        #  "CBS_DROPDOWNLIST" => 3,
        #  "CBS_OWNERDRAWFIXED" => 0x10,
        #  "CBS_OWNERDRAWVARIABLE" => 0x20,
        "CBS_AUTOHSCROLL" => 0x40,
        "CBS_OEMCONVERT" => 0x80,
        "CBS_SORT" => 0x100,
        "CBS_HASSTRINGS" => 0x200,
        "CBS_NOINTEGRALHEIGHT" => 0x400,
        "CBS_DISABLENOSCROLL" => 0x800,
        "CBS_UPPERCASE" => 0x2000,
        "CBS_LOWERCASE" => 0x4000,
        
        "WS_DISABLED" =>        0x8000000,
        "WS_THICKFRAME" =>        0x40000,
       },
      :option =>{}
    },
    
    VRGroupbox => {
      :style=>{
        "WS_DISABLED" =>        0x8000000,
        "WS_THICKFRAME" =>        0x40000,
      },
      :option =>{}
    },
    
    VRRichedit => {
      :style => {
        "ES_DISABLENOSCROLL" => 8192,
        "ES_EX_NOCALLOLEINIT" =>16777216,
        "ES_NOIME" =>524288,
        "ES_SAVESEL" =>32768,
        "ES_SELFIME" =>262144,
        "ES_SUNKEN" =>16384,
        "ES_VERTICAL" =>4194304,
        "ES_SELECTIONBAR" =>16777216,
        "ES_AUTOHSCROLL" => 128,
        "ES_AUTOVSCROLL" => 64,
        "ES_CENTER" => 1,
        "ES_MULTILINE" => 4,
        "ES_NOHIDESEL" => 256,
        "ES_READONLY" => 0x800,
        "ES_RIGHT" => 2,
        "ES_WANTRETURN" => 4096,
        
        "WS_DISABLED" =>        0x8000000,
        "WS_THICKFRAME" =>        0x40000
      },
      :option => {}
    },
    
    VRToolbar => {
      :style=>{
        "TBSTYLE_TOOLTIPS" => 256,
        "TBSTYLE_WRAPABLE" => 512,
        "TBSTYLE_ALTDRAG" => 1024,
        "TBSTYLE_FLAT" => 2048,    
      },
      :option =>{
        "CCS_TOP" => 1,
        "CCS_NOMOVEY" => 2,
        "CCS_BOTTOM" => 3,
        "CCS_NORESIZE" => 4,
        "CCS_NOPARENTALIGN" => 8,
        "CCS_ADJUSTABLE" => 32,
        "CCS_NODIVIDER" => 64
      }
    },
VRRebar => {
      :style=>{
        "RBS_TOOLTIPS" => 256,
        "RBS_VARHEIGHT" => 512,
        "RBS_BANDBORDERS" => 1024,
        "RBS_FIXEDORDER" => 2048,
      },
      :option =>{
        "CCS_TOP" => 1,
        "CCS_NOMOVEY" => 2,
        "CCS_BOTTOM" => 3,
        "CCS_NORESIZE" => 4,
        "CCS_NOPARENTALIGN" => 8,
        "CCS_ADJUSTABLE" => 32,
        "CCS_NODIVIDER" => 64
      }
    },
    VRListview => {
      :style=>{
        #"LVS_TYPEMASK" => 3,
        "LVS_SINGLESEL" => 4,
        "LVS_SHOWSELALWAYS" => 8,
        "LVS_SORTASCENDING" => 0x10,
        "LVS_SORTDESCENDING" => 0x20,
        "LVS_SHAREIMAGELISTS" => 0x40,
        "LVS_NOLABELWRAP" => 0x80,
        "LVS_AUTOARRANGE" => 0x100,
        "LVS_EDITLABELS" => 0x200,
        "LVS_NOSCROLL" => 0x2000,
        "LVS_TYPESTYLEMASK" => 0xfc00,
        #"LVS_ALIGNTOP" => 0,
        "LVS_ALIGNLEFT" => 0x800,
        "LVS_ALIGNMASK" => 0xc00,
        #"LVS_OWNERDRAWFIXED" => 0x400,
        "LVS_NOCOLUMNHEADER" => 0x4000,
        "LVS_NOSORTHEADER" => 0x8000,
        
        "WS_DISABLED" =>        0x8000000,
        "WS_THICKFRAME" =>        0x40000
      },
      :option =>{
        "LVS_ICON" => 0,
        "LVS_REPORT" => 1,
        "LVS_SMALLICON" => 2,
        "LVS_LIST" => 3
      }
    },
    
    VRTreeview => {
      :style => {
        "TVS_HASLINES" => 2,
        "TVS_LINESATROOT" => 4,
        "TVS_EDITLABELS" => 8,
        "TVS_DISABLEDRAGDROP" => 16,
        "TVS_SHOWSELALWAYS" => 32,
        
        "WS_DISABLED" =>        0x8000000,
        "WS_THICKFRAME" =>        0x40000
      },
      :option =>{}
    },
    
    VRProgressbar => {
      :style=>{
        "WS_BORDER" =>           0x800000,
        "WS_DISABLED" =>        0x8000000,
        "WS_THICKFRAME" =>        0x40000
      },
      :option =>{}
    },
    
    VRTrackbar => {
      :style=>{
        "TBS_VERT" => 2,
#        "TBS_HORZ" => 0,
        "TBS_TOP" => 4,
#        "TBS_BOTTOM" => 0,
        "TBS_LEFT" => 4,
#        "TBS_RIGHT" => 0,
        "TBS_BOTH" => 8,
        "TBS_NOTICKS" => 16,
        "TBS_ENABLESELRANGE" => 32,
        "TBS_FIXEDLENGTH" => 64,
        "TBS_NOTHUMB" => 128,
        
        "WS_BORDER" =>           0x800000,
        "WS_DISABLED" =>        0x8000000,
        "WS_THICKFRAME" =>        0x40000
      },
      :toggle => ["TBS_VERT", "TBS_TOP", "TBS_LEFT"],
      :option =>{}
    },
    
    VRUpdown => {
      :style=>{
        "UDS_WRAP" => 1,
        "UDS_SETBUDDYINT" => 2,
        "UDS_ALIGNRIGHT" => 4,
        "UDS_ALIGNLEFT" => 8,
        "UDS_AUTOBUDDY" => 16,
        "UDS_ARROWKEYS" => 32,
        "UDS_HORZ" => 64,
        "UDS_NOTHOUSANDS" => 128,
        
        "WS_DISABLED" =>        0x8000000,
        "WS_THICKFRAME" =>        0x40000
      },
      :option =>{}
    },
    
    VRStatusbar => {
      :style=>{
        "SBARS_SIZEGRIP" => 256
      },
      :option =>{    
        "CCS_TOP" => 1,
        "CCS_NOMOVEY" => 2,
        "CCS_BOTTOM" => 3,
        "CCS_NORESIZE" => 4,
        "CCS_NOPARENTALIGN" => 8,
        "CCS_ADJUSTABLE" => 32,
        "CCS_NODIVIDER" => 64,
        
        "WS_DISABLED" =>        0x8000000,
      }
    },
    
    VRTabControl => {
      :style=>{
        "TCS_FORCEICONLEFT" => 16,
        "TCS_FORCELABELLEFT" => 32,
#        "TCS_TABS" => 0,
        "TCS_BUTTONS" => 256,
#        "TCS_SINGLELINE" => 0,
        "TCS_MULTILINE" => 512,
#        "TCS_RIGHTJUSTIFY" => 0,
        "TCS_FIXEDWIDTH" => 1024,
        "TCS_RAGGEDRIGHT" => 2048,
        "TCS_FOCUSONBUTTONDOWN" => 0x1000,
        #"TCS_OWNERDRAWFIXED" => 0x2000,
        "TCS_TOOLTIPS" => 0x4000,
        "TCS_FOCUSNEVER" => 0x8000,
        "TCS_BOTTOM" => 2,
        "TCS_RIGHT" => 2,
        "TCS_VERTICAL" => 128,
        "TCS_HOTTRACK" => 0x0040,
        
        "WS_DISABLED" =>        0x8000000,
      },
      :toggle => ["TCS_VERTICAL", "TCS_BOTTOM", "TCS_RIGHT"],
      :option =>{}
      
    },
    
    VRTabbedPanel => {
      :style=>{
        "TCS_FORCEICONLEFT" => 16,
        "TCS_FORCELABELLEFT" => 32,
#        "TCS_TABS" => 0,
        #"TCS_BUTTONS" => 256,
#        "TCS_SINGLELINE" => 0,
        "TCS_MULTILINE" => 512,
#        "TCS_RIGHTJUSTIFY" => 0,
        "TCS_FIXEDWIDTH" => 1024,
        "TCS_RAGGEDRIGHT" => 2048,
        "TCS_FOCUSONBUTTONDOWN" => 0x1000,
        #"TCS_OWNERDRAWFIXED" => 0x2000,
        "TCS_TOOLTIPS" => 0x4000,
        "TCS_FOCUSNEVER" => 0x8000,
        "TCS_BOTTOM" => 2,
        "TCS_RIGHT" => 2,
        "TCS_VERTICAL" => 128,
        "TCS_HOTTRACK" => 0x0040,
        
        "WS_DISABLED" =>        0x8000000,
      },
      :toggle => ["TCS_VERTICAL", "TCS_BOTTOM", "TCS_RIGHT"],
      :option =>{}
    }
  }
  
  LVMStr = {
    0 => "LVS_ICON",
    1 => "LVS_REPORT",
    2 => "LVS_SMALLICON",
    3 => "LVS_LIST"
  }
  
  LVMConst = {
    "LVS_ICON" => 0,
    "LVS_REPORT" => 1,
    "LVS_SMALLICON" => 2,
    "LVS_LIST" => 3
  }
  
  CCSStr = {
    1 => "CCS_TOP",
    2 => "CCS_NOMOVEY",
    3 => "CCS_BOTTOM",
    4 => "CCS_NORESIZE",
    8 => "CCS_NOPARENTALIGN",
    0x20 => "CCS_ADJUSTABLE",
    0x40 => "CCS_NODIVIDER"
  }
  
  CCSConst= {    
    "CCS_TOP" => 1,
    "CCS_NOMOVEY" => 2,
    "CCS_BOTTOM" => 3,
    "CCS_NORESIZE" => 4,
    "CCS_NOPARENTALIGN" => 8,
    "CCS_ADJUSTABLE" => 0x20,
    "CCS_NODIVIDER" => 0x40
  }
end

module FDExStyle
  ExStyles = {
    'WS_EX_ACCEPTFILES' => 16,
    'WS_EX_APPWINDOW' => 0x40000,
    'WS_EX_CLIENTEDGE' => 512,
    'WS_EX_COMPOSITED' => 0x2000000, # XP
    'WS_EX_CONTEXTHELP' => 0x400,
    'WS_EX_CONTROLPARENT' => 0x10000,
    'WS_EX_DLGMODALFRAME' => 1,
    'WS_EX_LAYERED' => 0x80000, # w2k
    'WS_EX_LAYOUTRTL' => 0x400000, # w98, w2k
    'WS_EX_LEFT' => 0,
    'WS_EX_LEFTSCROLLBAR' => 0x4000,
    'WS_EX_LTRREADING' => 0,
    'WS_EX_MDICHILD' => 64,
    'WS_EX_NOACTIVATE' => 0x8000000, # w2k
    'WS_EX_NOINHERITLAYOUT' => 0x100000, # w2k
    'WS_EX_NOPARENTNOTIFY' => 4,
    'WS_EX_OVERLAPPEDWINDOW' => 0x300,
    'WS_EX_PALETTEWINDOW' => 0x188,
    'WS_EX_RIGHT' => 0x1000,
    'WS_EX_RIGHTSCROLLBAR' => 0,
    'WS_EX_RTLREADING' => 0x2000,
    'WS_EX_STATICEDGE' => 0x20000,
    'WS_EX_TOOLWINDOW' => 128,
    'WS_EX_TOPMOST' => 8,
    'WS_EX_TRANSPARENT' => 32,
    'WS_EX_WINDOWEDGE' => 256
  }
  
  CtlExStyles = {
    VRListview => {
      'LVS_EX_CHECKBOXES' => 4,
      'LVS_EX_FULLROWSELECT' => 32,
      'LVS_EX_GRIDLINES' => 1,
      'LVS_EX_HEADERDRAGDROP' => 16,
      'LVS_EX_ONECLICKACTIVATE' => 64,
      'LVS_EX_SUBITEMIMAGES' => 2,
      'LVS_EX_TRACKSELECT' => 8,
      'LVS_EX_TWOCLICKACTIVATE' => 128,
#      'LVSICF_NOINVALIDATEALL' =>   0x00000001,
#      'LVSICF_NOSCROLL' =>  0x00000002,
      #if( _WIN32_IE >= 0x0400 )
      'LVS_EX_FLATSB' =>    0x00000100,
      'LVS_EX_REGIONAL' =>  0x00000200,
      'LVS_EX_INFOTIP' =>   0x00000400,
      'LVS_EX_UNDERLINEHOT' =>      0x00000800,
      'LVS_EX_UNDERLINECOLD' =>     0x00001000,
      'LVS_EX_MULTIWORKAREAS' =>    0x00002000,
      #endif /* _WIN32_IE >=0x0400 */
      #if( _WIN32_IE >= 0x0500 )
      'LVS_EX_LABELTIP' =>     0x00004000,
      'LVS_EX_BORDERSELECT' => 0x00008000,
    },
    VRToolbar => {
    },
    VRTabControl => {
    }
  }
end

module FDOwnerDraw
  ODConst={
    VRButton=>{'use'=>0x0b},
    VRListbox=>{'fixed'=>0x10,'variable'=>0x20},
    VRCombobox=>{'fixed'=>0x10,'variable'=>0x20},
    VREditCombobox=>{'fixed'=>0x10,'variable'=>0x20},
    VRListview=>{'fixed'=>0x400},
    VRTabControl=>{'fixed'=>0x2000},
    VRTabbedPanel=>{'fixed'=>0x2000}
  }
end


