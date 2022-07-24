#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#INCLUDE "win32api.inc"
'
#INCLUDE "PBUtils.inc"
'
' declare the external function
'DECLARE FUNCTION PBMsgbox IMPORT "PBUtils.DLL" _
'                          ALIAS "PBMsgbox" _
'                          (hApp AS DWORD,strTitle AS STRING, _
'                           strMessage AS STRING, _
'                           strButtons AS STRING, _
'                           lngIcon AS LONG, _
'                           lngDefaultButton AS LONG, _
'                           OPTIONAL strURL AS STRING) AS STRING
'
ENUM Icons SINGULAR
  PBCritical = 1
  PBInformation
  PBQuestion
  PBExclamation
END ENUM
'
FUNCTION PBMAIN () AS LONG
  LOCAL strReply AS STRING
  '
  'strReply = PBMsgbox(0,"Make a decision", _
  '                      "Are you sure you want to do this?", _
  '                      "YES|NO|Maybe|Sometimes", _
  '                      %PBInformation,1)
  '
 ' strReply = PBMsgbox(0,"Delete the Record?", _
 '                       "What do you want to do with this record?", _
 '                       "Delete|Keep|Archive", _
 '                       %PBQuestion,3)
                        '
  strReply = PBMsgbox(0,"Delete the Record?", _
                        "What do you want to do with this record?", _
                        "Delete|Keep|Archive", _
                        %PBQuestion,3,_
                        "Click link below for more info" & $CRLF & _
                        "https://gsfsoftware.co.uk/PBTutorials/Recent.htm")
  MSGBOX strReply
  '
END FUNCTION
