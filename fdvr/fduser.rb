# fduser.rb
# user defined pallets and controls
#
# This prototype was programmed by yukimi_sake@mbi.nifty.com
# Copyright 2001-2003 Yukio Sakaue

require 'fdvr/fdcontrols'

module CreateCtrl
  include FDControls

  def user_createinit #add user pallet
    $conf <<  FDPallet["User",[

    ]]
  end

end
