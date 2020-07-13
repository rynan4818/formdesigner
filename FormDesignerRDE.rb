#! ruby -Ks
#
# FormDesigner.rb
# Programmed by yukimi_sake@mbi.nifty.com
# Copyright 2001-2007 Yukio Sakaue

$KCODE = 's'
require 'win32ole'
$RDE = WIN32OLE.new 'RDE.Main'
require 'fdvr/fdmain'
require 'fdvr/fdcontroldesign'
require 'fdvr/fdinspect'
require 'fdvr/fddialogs'

VRLocalScreen.start FDControlSelection

