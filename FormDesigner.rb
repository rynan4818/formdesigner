#! ruby -Ks
#
# FormDesigner.rb
# Programmed by yukimi_sake@mbi.nifty.com
# Copyright 2001-2004 Yukio Sakaue

$KCODE = 's'

$program_dir = File.dirname(File.expand_path($0))
$:.unshift($program_dir)

require 'fdvr/fdmain'
require 'fdvr/fdcontroldesign'
require 'fdvr/fdinspect'
require 'fdvr/fddialogs'

VRLocalScreen.start FDControlSelection

