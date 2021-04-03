#COMPILE EXE
#DIM ALL

DECLARE FUNCTION funDayOfWeek IMPORT "MaainDLL.DLL" _
                 ALIAS "funDayOfWeek" () AS STRING

FUNCTION PBMAIN () AS LONG
' generic app
  LOCAL strMessage AS STRING
  '
  strMessage = "Today is " & funDayOfWeek()
  '
  MSGBOX strMessage, 0 ,"Day Information"

END FUNCTION
'
'function funDayOfWeek() as string
'  local Built as ipowertime
'  Built = class "PowerTime"
'  Built.FileTime = %pb_compiletime
'  '
'  function = Built.DayOfWeekString
'  '
'end function
