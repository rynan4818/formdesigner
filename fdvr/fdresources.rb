# fdresources.rb
# Bitmaps of pallets
#
# Programmed by yukimi_sake@mbi.nifty.com
# Copyright 2001-2003 Yukio Sakaue

require 'vr/vrcontrol'
require 'vr/vrcomctl'

module FDBmps
  
BmpNoselect="
BAV1OhFTV2luOjpCaXRtYXACigFCTYoBAAAAAAAAdgAAACgAAAAXAAAAFwAA
AAEABAAAAAAAFAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAACAAAAAgIAA
gAAAAIAAgACAgAAAgICAAMDAwAAAAP8AAP8AAAD//wD/AAAA/wD/AP//AAD/
//8AZmZmZmZmZmZmZmZgZmZmZmZmZmZmZmZgZmZmZmZmZmZmZmZgZmZmZmZm
ZmZgZmZgZmZmZmZmZmYPBmZgZmZmZmZmZmD/8GZgZmZmZmZmZg//BmZgZmZm
ZmZmYP/wZmZgZmZmZgZmD/8GZmZgZmZmZgBg//BmZmZgZmZmYP8P/wZmZmZg
ZmZmYP//8GZmZmZgZmZmD///BmZmZmZgZmZmD///8GZmZmZgZmZg////8AZm
ZmZgZmZg///wBmZmZmZgZmYP//AGZmZmZmZgZmYP8AZmZmZmZmZgZmDwBmZm
ZmZmZmZgZmAGZmZmZmZmZmZgZmZmZmZmZmZmZmZgZmZmZmZmZmZmZmZgZmZm
ZmZmZmZmZmZg
"
=begin
BmpBitmapPanel = "
eJx9kEtPwzAQhO/+KxwGsCrFx62TyD2gNlZVpUckyymPCg6g8PPZ9SMpF9ay
4288GT/Ulk4P+0t/PD2+f+9fP+3z6L/OI9mXqbfH88eWSoWJBysDjTL0M5Ei
6qg6ep7/X7Z0omnHP6csnkwsTknkxaeWZtEPTe7UAnMLkdL3AIimgIa0cVGH
2roBQVphzxy1qXzvXV2PKtmDHrTREiAm74QjDHMUuxZewl2orHK6DquBz7Jy
BFcXU4ywIBwg2wxKzFw/SUgGps2bB1ACgLvYSIgpgczYCKvVkAWdj8wB1/iH
c4Vb5gfTyw7LslmPKIxYroTiNrd3zm1Qvwh7lAc=
"
BmpButton = "
eJyVj8EKwjAMhu95meBOu/7rLOwgGzLG5k0Q4kTRg7rXN61Vp6B2CUnzf0lK
SxmaWbm1dZPsL+XuZNbt8ty1ML1YU3fHDME2osm4hNYlOwAEzPGYsFr/NhMC
kEKX/V1aiELxUJuLHIPjVXoP5MxDzg75s2J2jJhTrA5vLrGavg+Mn6v62hdP
D5o+wRRNUxfGmuIW+GVJ1J//axoDugFHdbiD
"
BmpCanvasPanel = "
eJx9kEtrwzAMx+/+KjmI7eSrajewltJ0lJLmVhi4j+Wh0mKWT19JcfrYYAqW
9ftHkm2ZCW7elvt8vXn/vi6PnduVn5dtie4QcrfethNM9hXYOXFYissjokGc
4piRc/y/ubQQwwcXay8OAotBRf658BhFL+yw0ANEDyLpXgCIZgAswqvFYesX
6VO22GsD1oU56sdiESz367XMK2uisi3+craqK0P009VVw71UIGaixHZGA3eN
nmjniWlg81t48PmJH0/IAiU787UjvAjK5O7Mj4nZbuQmcastjQgyy6yioCnd
SQbIXFOLzCsPiSsiHvesuQ/VPE/Z3AD5Carq
"
BmpCheckbox = "
eJyVUMEKwjAMvedngp7m8a2zsINsyBibN0GIE0UPyn7fZN1gPUxmQtO8lzRp
QinqTXH1Vb29f4rby52b47tt4DrxrmqfKUa5iBpnBo0Z3wME7DFlePV/ixsP
ILk+HmqpI0rKQGrwkKE3vkzCQcbcZ2zUcJfMxhFzgtMjUlmLaU7wKLuApcuD
LmFSgDhBB4iwDjXHGhUEbJ1FrJ6ScQdZ7DhhWvvFad+LM/+7NJoT9AUyh7hV
"
BmpColorDlg = "
eJyVUMEKwjAMvedniu4wr892BQ9jm4yxeROEOFF04Cj49bbbRLspakrSvNeX
piktUcySvc6L+bFNDhe5LdfXqoSsWcu8Oi8x2I5tkC6gdEEbgIAID4W2OeIs
AVSkGG9MDg7wyhZ3GpuwJbkj7WGsYByfLnqHEsIo4ahuT4VwHAmxwObkLZ5g
7xUO16sawhYbn/gHk0+MO4RtyLf4hmAXZFNM3wRT/Lye+g52tKwNW9M0Df+O
6bNgNMKbT6VXgu7TsbIO
"
BmpCombobox = "
eJx9UcsKgzAQvO/PLO0p1zUa8FAsIqK9FQpbS0t7aMnvd/MCTa0bsmZmdiao
UFC/a66m6/f3T3N76fPQvseB9MRGd+OzoFgXlqZdo8E1Y4mAqKI0YeS8XTpu
Iq7F7LPkwEKyJ0U8lGQdf1RhU4loS3SUfx4RHQeIik6PxeJfPM5u91js6MxS
NhAqygljqoCrNq0QUEEX9URkA3nA4gJYG9gyzHXwBNPynTjJqp4yrD0OcfKr
1B9DFrjyUWFOwBfQtaGd
"
BmpEdCombo = "
eJyFUE0LwjAMvefPBD31mnUb8yCOMWTzJgwyRdGD0r9v+iXdnJrQNO+9vJQN
MhpXu7Fs9+vLc3e+62PXPPqO9IlL3fa3jEIMLEXbQp0tpSECooLeE39Dh0PE
GzG7XdKwkLY321yw76lW/lCOaHK0lLtrRMsBoqLDdZL8ifvkdYfFjtYsYTyh
ghwxxvC4aGL6BQW0QY/EbGC+YPIALA38MqQ6OIJp+k0cZVUNTkfjU1VZgsWs
vhhmCxd+KqQEvACsY6Pz
"
BmpEdit = "
eJyNT8sKwjAQvO/PBD3lOk0MeJAWKaXxJghRUfSg9Pfdra1JCmo3zGZnkn1R
gWZRHl3dLC/P8nw3+3b78C3MKThT+1uBwQ6BnRGHVpzrAAJWGH84jn+bGQCE
NSf3tTgILIZe5MeNRSd6pd+AVaqzSqT+rpQSjZTS2F2zE+Zy+vbBZ+MWwXO3
aMI171zJAJohAkcf5HxMQMJJKuYJUigtKJ1s0jFymgqRJyNOVvi78xxOqUAv
0kCk6Q==
"
BmpFolder = "
eJyFUcEKgzAMvednwnbRa1qn7DCUIcN6GwwqQ2Gwib+/pHWuim4pSZPXJK9p
QVGzy5u0vOzbPr8/9LU6v0xFurWpLmujaJSbZaPFkBGTsQLRgaaMv6JHJbJH
Lna92LEMij+cEo69T0XslRLEIUGB3F4gCgaIMdXd1nIk2TfWUR89pxgCwJpM
sc4TwvNlA1gwTAlhed0ZUt6zIQorl7UrWNBGRDlCEEbDD4CopitxPPyO5TGV
hc+M2wV+pJBARjL+n1U402zBG8k2t2U=
"
BmpFontDlg = "
eJytT00LwjAMvffPFD3t+tJZ8SAbMsbqTRCq4nAHZX/fJNu0ehAFU/LxXpLX
1hDqWXHwVT0/34pT53bN5hoauGP0rgoXwmj7yMFJQCPB94ABFpgmPNefzY0O
xBUvqxYXkcmoJDfXOXrhy2xw5Nb2uRVKc2mtcMbaDNv25cRvsfl1YcJhycsB
FLkEjQS1gnX4gSnBAZoVGyESdZaBCD3xez/BJiUGRVIB6C1i9P8/p8vDM+5Q
P7y5
"
BmpFullsize = "
eJyVUMEKwjAMvednip52fevc8CAbMmTdTRA6xaEHZb9v09Q6pzhsaZL3mrR5
oRTdouzyerc838vTVe+b7c000Eeb69pcUoR1sM5oNmjY5ANAwAoxY3bpcAC7
dsX+LRdYR1pPustNhoH5KpGDTKkhU0x5XynFHCmVoO3ftjWcVXDMQfoNe0RC
ScKzWLBB6rHzlrHjwwOt4J4CUTAx7WAO078FY0Si0f8dO/hscSpBJNJLo6SP
Z/BraHFgUcMDBla0hQ==
"
BmpGridFrame = "
eJydUE0PgjAMvffPNLILO5ZNEg8GYogBbxJi0fh10PD3bREUvYh0eW/t67aX
FSKqZ0kdZ+vgeE8OV7fNV7ciJ7fn2GXFJaIuKhZySpQrxQ0REM3pdeJnuA5E
vJDL7VuSsIjcitJcempUT8MnyCM2HlVq9xRRNUAMaXP6WFyaylQoMFYzLgNR
UXC20n/X8C2MrhHF2QjjTmBHO/Y1THHsDWGK4/9/xmFY1tHCcMrwAKz/rbQ=
"
BmpGroupbox = "
eJydUMEKgzAMvedXPIS5izvGquBhKE5EvQ0K1bG5HTb8/SVVodtgbCbkNe+1
aeBBSNUm65Ky8s+P7HRTx7q4NzWp3iSqbK4hzaENgxKgWiAZiYAopuVFwv33
UHMRmZSH7V/cGBaNFflyH9Eoeh5MRRHiGKFI9swRRQPEgNrLS5pPjk4wH7qt
5gQBbQUv7efsfuTw74DLYc3GhcOaje2wiwtOOLwJJVvi5cK15YV44lsTJ+6Y
Cq6r8ARMuK44
"
BmpHoriz2Pane = "
eJylUE0LwjAMvefPBD3t+to58SAOGbLuJgiZouhB2d837T7o6mEHU5rkvab5
IoN2dWiL6rS+fw63lz3Xx7erYa9S2Mo9DQa5iCrrFWqvig4gYIMpYlHscAHZ
6eeQSx1RUgKpj/scnefLrL/ImbucPRVsyew5Ys7QPGZHeutgFjAtBURYBjz5
NBI9CYwYW8USYTTiZvMboXQlaUCaIC5AoYKCeQdpi//P/IMp3jJ9Adl3tEM=
"
BmpHorizFrame = "
eJydUMsOgkAMvPdnGuECx2GRxIOBGGLAm4SkaEQ9aPh9W0RFLwa6mW5n2u6j
FKFZpE2Sb73TPT1e3b7Y3MoC7iCJy8tLhMFqUefMoTCXdAABS7wr/pobAMhK
m/uzNBAVpRc1uY7RmZ4FTyBm7mI2qd8zZtOIOcCu/VpS+bVfs8IPLZLKU5UV
51DzH06/whROUxvGnObc+OI098nT/sxjC8VGS+Mp0wMfdbOq
"
BmpListbox = "
eJx9UMEOgjAMvfdnqp64lsESDkYghIA3E5OJ0ehBw+/bbswMmHZZt/f6urcN
Umq3h4tu2t3tfbg+1amrX31HajBaNf0jpSnOhpOSRJ0kPRIBUU5eoXn/P9Q0
iUzBzfYs3hgmjSW5uM9oFL5M3KQMccxQKLuWiMIBYkLH+2yYFTahu2C0Ic3F
EBCClcPW3DnP614PE+EFvmF1oMN17kZlMTBR2vqmigoijl8DWAh+XTH6BAje
uGhYfFLkUyEk4APesqAd
"
BmpListview = "
eJyVUcEKwjAMvedngp52jZ2FHcaKjLHtJgixouhBLezrTboJFYqwlL7kveT1
kMKOuk1ztm23vb6ay8Mc+8Nz6Ml4tqYd7jta4sQCRoF6BRuIgGhP3wkr9f8w
yyXiSszxLSlYRI6iNOuSguqumC+ViKFElWJ2iKoBYkHj7efw+MYksryeakSY
JE35gawhnYe1hrQPaw0ph7WGyOOWycH8BTrgK1+xU/RZrsbCRX8QLquFdMvw
AXQBnGE=
"
BmpMenu = "
eJyNTssOgkAMvPdnGoUDHLuLKAcCMcQAN5AEMJh40Gzi19sFRB4h2EmnnWn3
AYKqXVC50WXfvILbQ2bx+ZnEJJvSlVGaCOqjKJmkJko0HTmB6EDDxmbIPolK
jw+3d3FTsql75Tusu55Cq0tyEJWD2mpriKg9QLQovW8j8+oWVa9zozCgYBob
U00njbU55Nbb1xgWLPI1fno2H10A/7yw0NgF2CxqbwpeNG1jYGOuryRMWwkF
XRGLhbnGWaTfb68BPuZ3svI=
"
BmpMmedia = "
eJyFkE0PgjAMhu/9M42MgxzLEMLBYAwxwM1kwDAYPfjx9+0AkXrQLi193pVu
K4RkV5mN84PX37PTVR+L/a0sSPdtrPOqDGky03LQLlDpQsIORBuaK/6anpyo
TfnnoRcnLYsuf24j5jGn3Xp0ihCfETpp+O4QnQaIa6rOv1eXdqm92JkDZZR9
1AlIwfhWsqpTyRxnhlEYSz4FRnWJZNdWsOKTpWD8L0bJjbdk4G3RET1xIsob
ud0PQ4PiTdxqyY33ngmyBY9ADBLkXOWCF/o5tMA=
"
BmpOpenDlg = "
eJyVkFELwiAQgN/vz0i9tNdTc/QwNmKMubcguIpGQQ1hvz51bnNEUR7e/D5P
nQLHapWfVFmtr11+uYtDvX/qGsWZlCj1jWNoR7JJuIS1S8ogAuIWxwplx9+b
CB2Rdnax38sOyEry0k5mEo3zRTJ0lIwZyZzy34Ix54CxBJt2EfQrw8cCmn92
4KwPYcJ8D6PiQSz5Iacl6TtDQ52J9iTH0ZmONyHCiTPDKEJ1qpF75tMFLLc4
vYtO+eLOxP94pJghFvACWyK7dw==
"
BmpPanel = "
eJydUMEKgkAQvc+veBiyi9fn2oKHUEJEvQXCamR1KPz9ZldFo4hyHvN23tud
HRgKkW+SRme5f34kp5s6Fod7WUC1RqusvIYYozZCyhIKS7oHCNhheqGl/h5q
TMDE0uz+ksKIaZwpl/sIvfXTYEhEzH3E1nJnymw9Yg5QdS8w75oXIfrSbGsB
Waqd4cXtiOZHTf82LDWtmThpWjNx0jQb80q81Gq3jQH+pyVWHS0NegJFCq5T
"
BmpPopupMenu = "
eJyNUN8LgkAMft8/MzqD8nGeJT6IEhLqm2RYYRShHfXXd9PzR0HUxnb7vn3b
6YFDh1l4WMdbUTXh6SrzZFOnCcmqXMs4Sx0yVpQ6SU6UcvJ0ANGKBsVPkyaI
Sl8Pt7t0UWqSaxW4Gnc1RcsuyEVULjLVnhEic4C4pOz8p1+Ovnavx5DdC6uw
9gMx4lboH6Md7YixbXGnwL5vW9ARz+AZPJhQDjsqUvSYDAz9twUwDny/QVdq
go0e+Z9RDIJ5//FmwYi7gY8+9IJm8TmAxgy+5WL6eLnIBUyJ+vwugBfPFbWd
"
BmpPrinter = "
eJyVkMEKwjAMhu95maIenMfY6agwHCLieptMtooTkenQpzdp17FdHCYkzfc3
KW1hieVkW673h+n1ub3cZXbc1ekR5bVYy71Ol9haXlCSnDDlFFEA4gq7jlGT
bSAWiobtWVQUJHLdxCGxqzEJXGAoRBMKluyaCMEaCBGgrv7zNP6QN3xta1EW
G2XUWxnnQ95UxDzQY1rBqM4jPct7fh5lIEF4sw23PudT5sBeLuzYG1ih0i8v
tO96+QH/Tr+/oDqb15bBC67BTiSO68fJT/DxDz1kUuDXr8IX7TGsxg==
"
BmpProgressbar = "
eJzFUE0LwjAMvefPBD3t+tZa2GFsyBidN0GoK4oeJv37pnVCVfDjZEJe816S
0oZK9Itmb7p+ebg0/qy2dj0NFmp0RnXDqcRsOyegIsBGMAEgYIV7h5H8vak5
AFfJcLpLEieiS6IUa40Q9ba4BTRz0ByldLbMUSPmApvjg7tvOf06kHPKBXlc
bkHXPvlYRfcvnD41PPN8fbJtHf7/Z7oCLXS6gw==
"
BmpRadiobutton = "
eJytT8EKwjAMvedngjttx7Sz0INsyBjrbooQNxQ9KPt9025iN0QUTEia99qk
L6CoXhVHU9XJ6V70V71rtjfXkO7Y6MpdFE12YEnaJ2p8MgMREK3p+cJI/dn0
FERspTnMkoKF5EDK5SanwfNlOgbliEOOngpnieg5QEypPc+cv8XwW8MeswhD
y9r2+CKc7cSzCMtCEdbWr9knHsOSeIfHAWrxgQqyR0migCmW6Ej9d+c5hpiA
B0Fku7k=
"
BmpRebar = "
eJydUMEKwjAMvedngu6yHrPOOQ+yIUO23cRJh0zwoOz3TdZWxhC0JiR57yUp
bSGhflX0WXVcD8/ieten+vBoatKDyXTVNgk56wwnLYkaSVsOINrQe+KraRdE
ZsfL01kMDIuCx33K3GIqYxuUIo4pijTVElE0QIypvf3n4MHygirqo27mCi+5
VNfOhQMLaNvn3A38zCF0Yc4hZMGaivyTwL8JFxb0YR+bLwcGq/4=
"
BmpRichedit = "
eJx9kMEOgjAMhu99FQ9/NDHhWoYkHghoCAFvJsapEfWgWcLT28GUAcaSdf2/
tSsdhVzM01OcF4vrK7081L7cPquS1VnHKq/uITs7aHHKOi6tiw0zMa/4kxFL
/N+UW8x6LcXtXRJogbqFcphEbCzPgm5xBJgIFrV7BlhGQMAYmplo43e3ujuQ
YixvpgfAbFdvfF0fxxoun34nDC+Q3/QbdLt4GgOYRoJmou2crmPSJF0VOZAh
cLN/dT+xfAGyqSYPoIGfMHqkH49KPqA372WRQg==
"
BmpSaveDlg = "
eJyVkE0PgjAMhu/9M4ueuL5sjnAgEEMI82ZiMjESPWhI/PV2HyBeBNus2/ts
bbdRimZTnnXdbK/P8nKXx3b/MC1kZ7WszS1FtJPlIF1A64IeAAJ2GE9oXv82
GQdgc072tXhhGVoPebNQGByvkjCghBiUcMjPlRCOkRAJDv2X2xXa9yR/h8wB
oxC6qcJrvJY0xcdMoBh9haap4qyAzDt2u6jpz4T4xKCJQZUE8LFs1af1NAf0
Bu4Vskg=
"
BmpStatic = "
eJylj80KwjAQhO/7MkFPvU5SUzxIi5TSeBOEqFjsQenru5tEiCKlYEI2+83O
5oc0ulV9tm23vj3r62iO/f7hepiLt6Z1d400Tp6DkYBegp0AAjZ4Oyzn88Ok
BfgtN4ezOPEs+iBycVdiEr0p4kKp1FQqkcLeKCUaKVXgMHxMv5RpcQMregA0
56gik2bJVS5iMOQs5sTDV52Zb9YsiSkZAmcNM0zxPClkNwbOnvj3n38w5QK9
AOuPuzk=
"
BmpStatusbar = "
eJyFUE0PgjAMvfeveGhUDngsQyIHAzGEgDcT4mDR6EHD37cdDEZitC/r+t76
9gURleusTYpyc3tn5qku1elVV6Q6naiifkQ0RqM5KUlUSUp6IiDak+tIuP4d
ahxEOmWz3YsLzaK2Ii8eY+pFz8NhUIzYxyiSnXNE0QAxpPN9Af2Pu3uAK7rU
hyZEgxKtINDU5W0gK6uDYOAgggmujLmBZ7Z4PJ0NAze2H2ZBLH6DWJbcBEvO
5qXwjTfYbhsHOWAyT2/0Y/f30ySDL8AH2DytwQ==
"
BmpTabControl = "
eJydUD0PgkAM3ftXHBqJA46PQxIGAzGEAJvEpGIkOqj8fe8OTnFQ0Tb32vfa
3hcFyOfJPspy73hNDme1LTaXsoBqJFJZeQow2E40KAMoDEQdQMAKriPS+WdT
wwIk1sN2L52IFsWKurgO0Rk99fuFkLkL2Ug2psxGI2YfVfvi8o2Xwz2oD4HU
iyZ++jROvw6MOf1zonN618APsxyzWFJds292nJxQ3diredkyT/s0gzQW6A7j
qLFv
"
BmpTabbedPanel = "
eJyVUMEOgjAMvfdXODQiBziWIckOBmIIAW4SzIRI9KDy+25jAzVGsc3avtd2
eRuElK+SY5zl7umWdBe2L3bXsiDWiphl5TkkY42QgalAhQrxQAREG7ITsay/
GzOHSHC5rO+ShZCk0KRsbiMaFJ/646EIcYhQUTqniIoDRJ+q/sXFL1waHTCm
UNRey2dX+LhujB80xskCT+HAAztuiX8wLFh4U9BNCsDhnyS3fBapMTlcpLKn
32wxWKK6o1tj0CMu+zQV4ZmABzxQqWY=
"
BmpText = "
eJx9UMEKwjAMvedngp52zVoLHmRDxli9CUJVFD0o+32bZq7NEFuS5b3uvaSF
mvpVc3Zdv769m+vTHIf9yw9kLsGZzj9qmtYpxGQ40cDJjURAtKHvHy7W/5eZ
gihsozh5xSJEMiQyHu4sjcy3lQRZxNEiU+nbIjIHiBUd7mqHJfaqex38ZAoW
q+jDBFccGqM6T9PMGLRAHHlAwSLNBhqDCPgGLCon4NA4NxAM2bEUSPdsyN1Y
jIgFhiUx48Uj/XpUKAn4AKt4mWE=
"
BmpToolbar = "
eJyNkE0PgjAMhu/9M4te4Fo6l3AgEEMIeDMxqTMaPUiW8OvtBiiQqHRpt/fZ
17tBgtUmP5uy2l7b/PKgY71/NjWSZUNlc09wiBNLIV+w9sU4REDc4bjCyPh3
0JCInMrmcJYMWCAHKJOZRud5EfeJWimnlUehL5TyDJSK8XCbNV6r4duCpWGb
+sZF39vgEjCA/j0UtVHrRIuK9Uez9s6nOuuyjhCWgKLwHZMNFG5kTamk3Gjf
GjwYLfHwo0uLah7u75vXaJgCeAGRwbDN
"
BmpTooltip = "
eJyNkE0LwjAMhu/5M0FzmNesc+BBJiKyeROqVfHrsDLw15t0TjtRMaVpnzdp
mwZSXg6KXb5YDo++OFzNupzXVclm73KzqC4pP8w6cUYdl+ryhhmYx9xl5LL/
beYxmd1EDoe7ZONEdEGU4DTjRvXZqJ2cITYZqhTWGaJqgDji1ak33L8M3xKq
Xrmpq+Q1JE8YrGV4E6ZIW7pJObcn+68MHxPQJtseI9UvDrYhfTkW9Ihy19uk
LVm+cfa0Om0S231R2BJEggR9oknPHgjXw4jPlmzUI4ibBHdrBqjD
"
BmpTrackbar = "
eJyFkEsPgjAMx+/7Kh4ajQevZTjCwUAMIbCbxGRiXDTxMT++Kw9xE7HL2v7+
W7sHCzCfJweR5YvTPTle+K7Y3soCea0Ez8pzgJ3tlXWcHBbkhEFkiGvsdwib
TxvvJqKKbXHTyybKiqoR7eImREN6umonhgAmBJKamAKQxgBWKLUzlM9VJK9S
P3UX38x84RePHKCYK1TLwOFZrKIPftRxPdzTFnuCzwDE0JvBlLg1Ru5fg2+m
PlKz4YrTnzbGzpvZCzvtu4s=
"
BmpTreeview = "
eJyFUGELwiAQ/e6fOeqL+3q6hKDYiDFc34LgKoqCEv9+6nQtq6V4d+/d+Z7I
BLaz6qCadn421ekmd3rz6DTKIynZdFeBce3JBekDah+URWSIC0wTytXTS8aD
SEt3OWi5ghxJgXTNdYnW83XRHywBbAmeCrkG8BwDKHB7SbsLqiO8MvyesNd+
wywfyAToM7/6LBKTDr8M2FcHGrwjNtzYhH2vx9FZZAMiExDDLyRpEZ8dCMkN
H438xeHZY4I9AVq4t9A=
"
BmpUpdown = "
eJyFUMEOgjAMvfdXODR6wuNjiNnBQAwh4M3EZGIketDw+64DDCMCXdr1vXXd
6yhCsUlvSV5sH5/0/lKX8vSuSqjaJCqvnhF6uxoblASUEpIWIGCPoSKx+bKp
3gGj7WXXyybGksaR9vAYoxU+CztHzNzGLJTbM2bhiDnEufGW+Yf7pw8DDnSt
qdbGIyYYPrb6RpgCLbIXG8xiEoKdhQdfYtSsNaD5gqkiX7KMtDazhzuFu58i
Gv8qfQEte7KW
"
BmpVert2Pane = "
eJyNUE0PgjAMvffPNHri+jaEeDAQQwzjZmJSNBo9aPj7bpMAA0G7tN17Wz9J
oV5ldVIc1tdXdnnoY7l/mhL6LIkuzF2hlZNYo51B6UzSAARs0P34KbpVQLY2
2OeyF7GkeNI+7mI0js+jjyJmbmJ2lPc5s+OIOUJ180dCb6ACbCPTARbfdk8Y
35DqcNtrOpeQphXmsQnmV0JjYoyXEtI/Fb+N4IrQcMbKr35hSdOZ+y3TG2ju
s6o=
"
BmpVertFrame = "
eJydUMEOgjAMvfdnGvGCx8cmiQcDMcQMbxKSopHoQcPvuwHT6UXkNX1bX9e9
bJSgWWRNWuyjyyM739TR7O6lgTpJqorymmBELZaUIxhHaQcQsMbrxE+oMQHZ
2OH+LrsRK0ov2uZWo3N6Hg8JzdxpdlK/5sxOI+YYh/YjpFrWYUgVhf13Td/C
5JrZOXvUkx19TXMcPWiO4/9v5hArCYaHX6YnKduzow==
"
=end
end

module FDFakeClass
  class FDPopup
  end
  
  class FDOpenDlg
    attr :filters,1
    attr :flags,1
    attr :title,1
    attr :defaultExt,1
  end
  
  class FDSaveDlg
    attr :filters,1
    attr :flags,1
    attr :title,1
    attr :defaultExt,1
  end
  
  class FDFontDlg
  end
  
  class FDColorDlg
  end
  
  class FDSelectDir
    attr :flags,1
    attr :title,1
    attr :initialdir,1
  end
  
  class FDLayout
    attr :register,1
    attr :position,1
  end
end

module FDComDlgItems

  OpenFileFlag = {
    "OFN_ALLOWMULTISELECT" => 512,
    "OFN_CREATEPROMPT" => 0x2000,
#    "OFN_ENABLEHOOK" => 32,
#    "OFN_ENABLETEMPLATE" => 64,
#    "OFN_ENABLETEMPLATEHANDLE" => 128,
    "OFN_EXPLORER" => 0x80000,
    "OFN_EXTENSIONDIFFERENT" => 0x400,
    "OFN_FILEMUSTEXIST" => 0x1000,
    "OFN_HIDEREADONLY" => 4,
    "OFN_LONGNAMES" => 0x200000,
    "OFN_NOCHANGEDIR" => 8,
    "OFN_NODEREFERENCELINKS" => 0x100000,
    "OFN_NOLONGNAMES" => 0x40000,
    "OFN_NONETWORKBUTTON" => 0x20000,
#    "OFN_NOREADONLYRETURN" => 0x8000,
#    "OFN_NOTESTFILECREATE" => 0x10000,
#    "OFN_NOVALIDATE" => 256,
#    "OFN_OVERWRITEPROMPT" => 2,
    "OFN_PATHMUSTEXIST" => 0x800,
    "OFN_READONLY" => 1,
 #   "OFN_SHAREAWARE" => 0x4000,
    "OFN_SHOWHELP" => 16,
 #   "OFN_SHAREFALLTHROUGH" => 2,
 #   "OFN_SHARENOWARN" => 1,
 #   "OFN_SHAREWARN" => 0,
 #   "OFN_NODEREFERENCELINKS" => 0x100000
  }
  
  SaveFileFlag = {
#    "OFN_ALLOWMULTISELECT" => 512,
    "OFN_CREATEPROMPT" => 0x2000,
#    "OFN_ENABLEHOOK" => 32,
#    "OFN_ENABLETEMPLATE" => 64,
#    "OFN_ENABLETEMPLATEHANDLE" => 128,
    "OFN_EXPLORER" => 0x80000,
    "OFN_EXTENSIONDIFFERENT" => 0x400,
#    "OFN_FILEMUSTEXIST" => 0x1000,
    "OFN_HIDEREADONLY" => 4,
    "OFN_LONGNAMES" => 0x200000,
    "OFN_NOCHANGEDIR" => 8,
    "OFN_NODEREFERENCELINKS" => 0x100000,
    "OFN_NOLONGNAMES" => 0x40000,
    "OFN_NONETWORKBUTTON" => 0x20000,
    "OFN_NOREADONLYRETURN" => 0x8000,
    "OFN_NOTESTFILECREATE" => 0x10000,
    "OFN_NOVALIDATE" => 256,
    "OFN_OVERWRITEPROMPT" => 2,
    "OFN_PATHMUSTEXIST" => 0x800,
    "OFN_READONLY" => 1,
#    "OFN_SHAREAWARE" => 0x4000,
    "OFN_SHOWHELP" => 16,
#    "OFN_SHAREFALLTHROUGH" => 2,
#    "OFN_SHARENOWARN" => 1,
#    "OFN_SHAREWARN" => 0,
#    "OFN_NODEREFERENCELINKS" => 0x100000
  }
  BrowseFolderFlag = {
    "BIF_RETURNONLYFSDIRS"=>1,
    "BIF_DONTGOBELOWDOMAIN"=>2,
    "BIF_STATUSTEXT"=>4,
    "BIF_RETURNFSANCESTORS"=>8,
    "BIF_EDITBOX"=>16,
    "BIF_VALIDATE"=>32,
    "BIF_NEWDIALOGSTYLE"=>64,
    "BIF_BROWSEINCLUDEURLS"=>128,
    "BIF_USENEWUI"=>80,
    "BIF_BROWSEFORCOMPUTER"=>0x1000,
    "BIF_BROWSEFORPRINTER"=>0x2000,
    "BIF_BROWSEINCLUDEFILES"=>0x4000,
    "BIF_SHAREABLE"=>0x8000
  }

end

module OwnerDrawBtnBmp

BmpDN = SWin::Bitmap.loadString(
'
BAh1OhFTV2luOjpCaXRtYXAB7kJN7gAAAAAAAAB2AAAAKAAAAA8AAAAPAAAA
AQAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAIAAAACAgACA
AAAAgACAAICAAADOzs4AgICAAAAA/wAA/wAAAP//AP8AAAD/AP8A//8AAP//
/wB3d3d3d3d3cHd3d3d3d3dwd3d3d3d3d3B3d3dwd3d3cHd3dwAHd3dwd3dw
AAB3d3B3dwAAAAd3cHdwAAAAAHdwdwAAAAAAB3BwAAAAAAAAcAAAAAAAAAAA
d3d3d3d3d3B3d3d3d3d3cHd3d3d3d3dwd3d3d3d3d3A=
')

BmpUP = SWin::Bitmap.loadString(
'
BAh1OhFTV2luOjpCaXRtYXAB7kJN7gAAAAAAAAB2AAAAKAAAAA8AAAAPAAAA
AQAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAIAAAACAgACA
AAAAgACAAICAAADOzs4AgICAAAAA/wAA/wAAAP//AP8AAAD/AP8A//8AAP//
/wB3d3d3d3d3cHd3d3d3d3dwd3d3d3d3d3B3d3d3d3d3cAAAAAAAAAAAcAAA
AAAAAHB3AAAAAAAHcHdwAAAAAHdwd3cAAAAHd3B3d3AAAHd3cHd3dwAHd3dw
d3d3cHd3d3B3d3d3d3d3cHd3d3d3d3dwd3d3d3d3d3A=
')

end

module FDHelp
  HH_hash={"VRForm"=>0x1000,
"VRLayoutManager"=>0x1001,
"VRVertLayoutManager"=>0x1002,
"VRHorizLayoutManager"=>0x1003,
"VRGridLayoutManager"=>0x1004,
"VRDropFileTarget"=>0x1005,
"VRVertTwoPane"=>0x1006,
"VRHorizTwoPane"=>0x1007,
"VRDrawable"=>0x1008,
"VRMenuUseable"=>0x1009,
"VRCommonDialog"=>0x100a,
"VRMediaViewModeNotifier"=>0x100b,
"VRButton"=>0x100c,
"VRCheckbox"=>0x100d,
"VRRadiobutton"=>0x100e,
"VRGroupbox"=>0x100f,
"VRStatic"=>0x1010,
"VREdit"=>0x1011,
"VRText"=>0x1012,
"VRListbox"=>0x1013,
"VRCombobox"=>0x1014,
"VREditCombobox"=>0x1015,
"VRRichedit"=>0x1016,
"VRListview"=>0x1017,
"VRTreeview"=>0x1018,
"VRProgressbar"=>0x1019,
"VRTrackbar"=>0x101a,
"VRUpdown"=>0x101b,
"VRStatusbar"=>0x101c,
"VRTabControl"=>0x101d,
"VRTabbedPanel"=>0x101e,
"VRRebar"=>0x101f,
"VRToolbar"=>0x1020,
"VRPanel"=>0x1021,
"VRBitmapPanel"=>0x1022,
"VRCanvasPanel"=>0x1023,
"VRMediaView"=>0x1024,
"VRMenu"=>0x1025,
"VRMenuItem"=>0x1026,
"VRWinComponent"=>0x1027,
"VRMessageHandler"=>0x1028,
"VRParent"=>0x1029,
"VRStdControlContainer"=>0x102a,
"VRComCtlContainer"=>0x102b,
"VRScreen"=>0x102c}
end

module FDSources
  BeginOfFD="##__BEGIN_OF_FORMDESIGNER__\n"
  Caution="## CAUTION!! ## This code was automagically ;-) created by "<<
  "FormDesigner.\n## NEVER modify manualy -- otherwise, you'll have a "<<
  "terrible experience.\n\n"
  EndOfFD="##__END_OF_FORMDESIGNER__\n"
  TagOfFD="##__BY_FDVR"
  Follows=<<EEOOSS
## Now,you can describe freely in subsequent lines.
## But be carefully to change the line tagged  "#{TagOfFD}".

EEOOSS

  StartOfForm="VRLocalScreen.start "
  StartOfModeless="VRLocalScreen.modelessform(nil,WStyle::WS_OVERLAPPEDWINDOW,"
  StartOfMdlsDlg="VRLocalScreen.modelessform(nil,nil,"
  StartOfModeless2=").show\nVRLocalScreen.messageloop"
end

module FDMsg
end
