# parse.y
# Parser for sources of forms
#
# Programmed by yukimi_sake@mbi.nifty.com
# Copyright 2001-2003 Yukio Sakaue

class FDParser

  options no_result_var

rule
  accmtd : block
         | accmtd block

  block  : 'end'                        { do_end }
         | stlist 'end'                 { do_end }

  stlist  : stmt
          | stlist stmt

  stmt    : primary
          | assign
          | call

  rcvr    : IDNT '.'                    { do_send(val[0]) }
          | rcvr IDNT '.'               { do_send2(val[0],val[1]) }
          | rcvr IDNT '(' args ')' '.'  {	do_call(val[0],val[1],val[3])}

  call    : IDNT '(' args ')'           { do_call(nil,val[0],val[2]) }
          | IDNT '(' ')'                { do_call(nil,val[0],[]) }
          | rcvr IDNT '(' args ')'      { do_call(val[0],val[1],val[3])}
          | rcvr IDNT                   { do_call(val[0],val[1],[]) }
  
  assign  : IDNT '=' arg                { do_assign(nil,val[0],val[2]) }
          | rcvr IDNT '=' arg           { do_assign(val[0],val[1],val[3]) }

  args    : arg                         { val }
          | args ',' arg                { val[0].push val[2] }

  arg     : primary                     { do_primary(val[0]) }
          | array
          | call
          | evalary
 
  evalary : IDNT array                  { do_array(val[0],val[1]) }

  array   : '[' contents ']'            { val[1] }
          | '[' ']'                     { [] }

  contents: field                       { val }
          | contents ',' field          { val[0].push val[2] }

  field   : primary                     { do_arr_prim(val[0])}
          | array

  primary : IDNT
          | NMBR
          | STRG
          | CNST
end

---- header
require 'fdvr/inner'

---- inner

include Inner
