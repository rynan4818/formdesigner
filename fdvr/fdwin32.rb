#Win32API

require 'Win32API'

module User32
  GetDC = Win32API.new('User32', 'GetDC', 'L', 'L')
  IsWindow = Win32API.new('user32','IsWindow','L','L')
  GetForegroundWindow = Win32API.new('user32','GetForegroundWindow','V','L')
  SetForegroundWindow = Win32API.new('user32','SetForegroundWindow','L','L')
  SetActiveWindow = Win32API.new('user32','SetActiveWindow','L','L')
  DestroyWindow = Win32API.new('user32','DestroyWindow','L','L')
  SendDlgItemMessage=Win32API.new('user32','SendDlgItemMessage','LLLLL','L')
  SendDlgItemMessage2=Win32API.new('user32','SendDlgItemMessage','LLLLP','L')
  DrawFrameControl=Win32API.new('user32','DrawFrameControl','LPII','I')
  SetWindowPos = Win32API.new('user32','SetWindowPos','LLLLLLL','L')
end

module GDI32
  GetTextFace=Win32API.new('GDI32','GetTextFace','LLP','L')
  CreateRectRgn = Win32API.new('GDI32','CreateRectRgn','LLLL','L')
  SelectClipRgn = Win32API.new('GDI32','SelectClipRgn','LL','L')
  CreatePen = Win32API.new('GDI32', 'CreatePen', 'LLL', 'L')
  CreateBrush = Win32API.new('GDI32', 'CreateSolidBrush', 'L', 'L')
  SelectObject = Win32API.new('GDI32', 'SelectObject', 'LL', 'L')
  DeleteObject = Win32API.new('GDI32', 'DeleteObject', 'L', 'L')
  SetROP2 = Win32API.new('GDI32','SetROP2','LL','L')
  MoveTo = Win32API.new('GDI32', 'MoveToEx', 'LLLP', 'V')
  LineTo = Win32API.new('GDI32', 'LineTo', 'LLL', 'V')
  Rectangle = Win32API.new('GDI32', 'Rectangle', 'LLLLL', 'V')
  SetBkMode = Win32API.new("GDI32", "SetBkMode", ['L']*2, 'L')
  TextOut = Win32API.new("GDI32","TextOut",['L','L','L','P','L'],'L')
end

module Kernel32
end

module Shell32
  ShellExecute = Win32API.new('shell32','ShellExecute','LPPPPI','L')
end


module Hhctrl
  HtmlHelp=Win32API.new('hhctrl.ocx',"HtmlHelpA","LPLP","L")
end
