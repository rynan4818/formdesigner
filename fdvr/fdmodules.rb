# fdmodules.rb
# Modules for which add to controls
#
# Programmed by yukimi_sake@mbi.nifty.com
# Copyright 2001-2003 Yukio Sakaue

module FDModules
  FDMod = Struct.new(:events,:methods,:requires)
  
  FormModules = {
    :VRDestroySensitive => FDMod[['self_destroy'],[],'vrhandler'],
    :VRClosingSensitive => FDMod[['self_close'],[],'vrhandler'],
    :VRClipboardObserver => FDMod[['self_drawclipboard'],[],'vrclipboard']
  }
  
  ParentModules = {
    :VRMessageParentRelayer => FDMod[[],[],'']
  }
  
  StdModules = {
    :VRDrawable => FDMod[['self_paint'],[]],
   # :VRMessageHandler => FDMod[[],['acceptEvents(ev_array)',
   #                      'addHandler(msg,handlername,argtype,argparsestr)']],
    :VRResizeSensitive => FDMod[['self_resize(w,h)'],[]],
    :VRMouseFeasible => FDMod[[
      'self_lbuttonup(shift,x,y)',
      'self_lbuttondown(shift,x,y)',
      'self_rbuttonup(shift,x,y)',
      'self_rbuttondown(shift,x,y)',
      'self_mousemove(shift,x,y)',
    ],[],'vrhandler'],
    :VRFocusSensitive => FDMod[[
      'self_gotfocus()',
      'self_lostfocus()'
      ],[],'vrhandler'],
    :VRKeyFeasible  => FDMod[[
      'self_char(keycode,keydata)',
      'self_deadchar(keycode,keydata)',
      'self_syschar(keycode,keydata)',
      'self_sysdeadchar(keycode,keydata)'
    ],[],'vrhandler'],
    :VROwnerDrawControlContainer => FDMod[[],[],'vrowndraw'],
    :VRDropFileTarget => FDMod[['self_dropfiles(files)'],[],'vrddrop'],
    :VRDragFileSource => FDMod[['dragStart(files)'],[],'vrddrop']
  }
  MMModules = {
    :VRMediaViewModeNotifier => FDMod[[],[],'']
  }
  
end
