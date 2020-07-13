#require 'vr/vrcontrol'
#require 'vr/vrcomctl'
require 'vr/vrrichedit'
require 'vr/vrmmedia'
require 'vr/vrtooltip'

module FDSDK
  DE_Prefix = 'ms-help://MS.PSDK.1033/'
  DE_Hash={
'VRButton' => 'shellcc/platform/commctls/buttons/buttons.htm',
'VRCheckbox' => 'shellcc/platform/commctls/buttons/buttontypesandstyles.htm#check_boxes',
'VRCombobox' => 'shellcc/platform/commctls/comboboxes/comboboxes.htm',
'VRCommonDialog' => 'winui/winui/windowsuserinterface/userinput/commondialogboxlibrary.htm',
'VREdit' => 'shellcc/platform/commctls/editcontrols/editcontrols.htm',
'VREditCombobox' => 'shellcc/platform/commctls/comboboxes/comboboxes.htm',
'VRGroupbox' => 'shellcc/platform/commctls/buttons/buttontypesandstyles.htm#group_boxes',
'VRListbox' => 'shellcc/platform/commctls/listboxes/listboxes.htm',
'VRListview' => 'shellcc/platform/commctls/listview/reflist.htm',
'VRMediaView' => 'multimed/vfwstart_8ld1.htm',
'VRMenu' => 'winui/winui/windowsuserinterface/resources/menus.htm',
'VRProgressbar' => 'shellcc/platform/commctls/progbar/reflist.htm',
'VRRadiobutton' => 'shellcc/platform/commctls/buttons/buttontypesandstyles.htm#radio_buttons',
'VRRebar' => 'shellcc/platform/commctls/rebar/reflist.htm',
'VRRichedit' => 'shellcc/platform/commctls/richedit/richeditcontrols.htm',
'VRScrollbar' => 'shellcc/platform/commctls/scrollbars/scrollbars.htm',
'VRStatic' => 'shellcc/platform/commctls/staticcontrols/staticcontrols.htm',
'VRStatusbar' => 'shellcc/platform/commctls/status/reflist.htm',
'VRTabbedPanel' => 'shellcc/platform/commctls/tab/reflist.htm',
'VRTabControl' => 'shellcc/platform/commctls/tab/reflist.htm',
'VRText' => 'shellcc/platform/commctls/editcontrols/editcontrols.htm',
'VRToolbar' => 'shellcc/platform/commctls/toolbar/reflist.htm',
'VRTooltip' => 'shellcc/platform/commctls/tooltip/reflist.htm',
'VRTrackbar' => 'shellcc/platform/commctls/trackbar/reflist.htm',
'VRTreeview' => 'shellcc/platform/commctls/treeview/reflist.htm',
'VRUpdown' => 'shellcc/platform/commctls/updown/reflist.htm'
  }
  
CTL_STYLE_DOC = {
'VRButton' => 'shellcc/platform/commctls/buttons/buttonreference/buttonstyles.htm',
'VRCheckbox' => 'shellcc/platform/commctls/buttons/buttonreference/buttonstyles.htm',
'VRCombobox' => 'shellcc/platform/commctls/comboboxes/comboboxreference/comboboxstyles.htm',
'VREdit' => 'shellcc/platform/commctls/editcontrols/editcontrolreference/editcontrolstyles.htm',
'VREditCombobox' => 'shellcc/platform/commctls/editcontrols/editcontrolreference/editcontrolstyles.htm',
'VRGroupbox' => 'shellcc/platform/commctls/buttons/buttonreference/buttonstyles.htm',
'VRListbox' => 'shellcc/platform/commctls/listboxes/listboxreference/listboxstyles.htm',
'VRListview' => 'shellcc/platform/commctls/listview/styles.htm',
#VRMediaView=>'',
'VRProgressbar' => 'shellcc/platform/commctls/progbar/styles.htm',
'VRRadiobutton' => 'shellcc/platform/commctls/buttons/buttonreference/buttonstyles.htm',
'VRRebar' => 'shellcc/platform/commctls/rebar/styles.htm',
'VRRichedit' => 'shellcc/platform/commctls/richedit/richeditcontrols/richeditcontrolreference/richeditconstants/richeditcontrolstyles.htm',
'VRScrollbar' => 'shellcc/platform/commctls/scrollbars/scrollbarreference/scrollbarcontrolstyles.htm',
'VRStatic' => 'ms-help://MS.PSDK.1033/shellcc/platform/commctls/staticcontrols/staticcontrolreference/staticcontrolstyles.htm',
'VRStatusbar' => 'shellcc/platform/commctls/status/styles.htm',
'VRTabbedPanel' => '',
'VRTabControl' => 'shellcc/platform/commctls/tab/styles.htm',
'VRText' => '/shellcc/platform/commctls/editcontrols/editcontrolreference/editcontrolstyles.htm',
'VRToolbar' => 'shellcc/platform/commctls/toolbar/styles.htm',
'VRTooltip' => 'shellcc/platform/commctls/tooltip/styles.htm',
'VRTrackbar' => 'shellcc/platform/commctls/trackbar/styles.htm',
'VRTreeview' => 'shellcc/platform/commctls/treeview/styles.htm',
'VRUpdown' => 'shellcc/platform/commctls/updown/styles.htm'
}
  
WND_STYLE_DOC = 'winui/winui/windowsuserinterface/windowing/windows/windowreference/WindowStyles.htm'
  WND_EXSTYLE_DOC = 'winui/winui/windowsuserinterface/windowing/windows/windowreference/windowfunctions/createwindowex.htm'
  CTL_EX_STYLE_DOC = {
'VRListview' =>  'shellcc/platform/commctls/listview/ex_styles.htm',
'VRToolbar' =>  'shellcc/platform/commctls/toolbar/ex_styles.htm',
    'VRTabControl' => 'shellcc/platform/commctls/tab/ex_styles.htm',
    'VRTabbedPanel' => 'shellcc/platform/commctls/tab/ex_styles.htm'
  }
end
