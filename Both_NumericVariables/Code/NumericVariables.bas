#COMPILE EXE
#DIM ALL

' include the common display library
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
%TestConstant = 1  ' set a constant


'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Numeric Variables",0,0,40,80)
  '
  funLog("Walk through on numeric variables ")
  '
  LOCAL intCount AS INTEGER
  '
  LOCAL quadCount AS QUAD
  '
  LOCAL Count1%   ' integer
  LOCAL Count2&   ' long
  LOCAL Count3&&  ' quad
  '
  LOCAL Amount1 AS CUR
  LOCAL BidAmount1 AS CURRENCYX
  '
  LOCAL Amount2@     ' currency
  LOCAL BidAmount2@@ ' currency X
  '
  Amount1 = 245.565@
  BidAmount2 = 245.565@@
  '
  Count1% = 1
  '
  funLog(FORMAT$(Amount1))
  funlog(FORMAT$(BidAmount2) & " plus " & _
         FORMAT$(%TestConstant))
  '
  LOCAL dwHandle AS DWORD
  '
  LOCAL lngR AS LONG
  LOCAL lngCount AS LONG
  '
  LOCAL qCount AS QUAD
  '
  TIX qCount
  FOR lngR = 1 TO 100000
    INCR lngCount
  NEXT lngR
  '
  TIX END qCount
  funLog( FORMAT$(qCount) & " cycles")
  '
  TIX qCount
  LOCAL intR AS INTEGER
  TIX qCount
  FOR intR = 1 TO 100000
    INCR lngCount
  NEXT intR
  '
  TIX END qCount
  funLog( FORMAT$(qCount) & " cycles for integer")
  '
  TIX qCount
  LOCAL bSmall AS BYTE
  LOCAL bR AS BYTE
  FOR bR = 1 TO 254
    INCR lngCount
  NEXT br
  TIX END qCount
  funLog( FORMAT$(qCount) & " cycles for byte")
  '
  TIX qCount
  FOR lngR = 1 TO 254
    INCR lngCount
  NEXT lngR
  '
  TIX END qCount
  funLog( FORMAT$(qCount) & " cycles for long")
  '
  funWait()
'
END FUNCTION
