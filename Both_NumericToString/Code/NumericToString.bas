#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON


' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"

'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Numeric to String",0,0,40,120)
  '
  funLog("Walk through on Numeric to String formatting")
  '
  LOCAL lngR AS LONG
  '
  LOCAL lngStart, lngEnd AS LONG
  '
  lngStart = 10: lngEnd = 20
  '
  'FOR lngR = lngStart TO lngEnd
  '  funLog( "|" & trim$(str$(lngR)) & "|")
  'NEXT lngR
  '
'  FOR lngR = lngStart TO lngEnd
'    funLog( "|" & rset$(format$(lngR,"#,##0"),6) & "|")
'  NEXT lngR
'  '
'  lngR = 2000
'  funLog( "|" & FORMAT$(lngR,"#,##0") & "|")
'  lngR = -2000
'  funLog( "|" & FORMAT$(lngR,"#,##0") & "|")
  '
  LOCAL lngCount AS LONG
  lngCount = 0
  FOR lngR = lngStart TO lngEnd
    INCR lngCount
    funLog( "|" & USING$("Value on entry # is #",lngCount, lngR) & "|")
  NEXT lngR
  '
  funWait()
  '
END FUNCTION
