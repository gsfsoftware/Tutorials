#COMPILE EXE
#DIM ALL

DECLARE FUNCTION funDayOfWeek IMPORT "MainDLL.DLL" _
                 ALIAS "funDayOfWeek" () AS STRING

DECLARE FUNCTION funMsgBox IMPORT "PBUtils.DLL" _
                 ALIAS "PBMsgbox" (hApp AS LONG, _
                                   strTitle AS STRING, _
                                   strMessage AS STRING, _
                                   strButtons AS STRING, _
                                   lngIcon AS LONG, _
                                   lngDefaultButton AS LONG) AS STRING

ENUM msg SINGULAR
  PBExclamation = 1
  PBCritical
  PBInformation
  PBQuestion
END ENUM

FUNCTION PBMAIN () AS LONG
' generic app
  LOCAL strMessage AS STRING
  LOCAL strReturnValue AS STRING
  '
  strMessage = "Today is " & funDayOfWeek()
  '
  MSGBOX strMessage, 0 ,"Day Information"
  '
  strReturnValue = funMSGBox(%HWND_DESKTOP, _
                             "Query the Day", _
                             "What kind of day is this?" & $CRLF _
                             & "Click the button below", _
                     "&Work day|&Rest day|&Holiday|&Sick day|&TV day" , _
                             %PBQuestion, _
                             0)
  MSGBOX strReturnValue, 0, "Value returned"

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
