#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE ONCE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
#INCLUDE "PipeTostring.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Using Pipes",0,0,40,120)
  '
  funLog("Using Pipes")
  '
  LOCAL strCmd AS STRING
  LOCAL wsResult AS WSTRING
  '
  ' run the Tree command
  strCmd = "tree " & EXE.PATH$ & ".."
  wsResult = funRunPipe(strCMD)
  funLog("Tree Command" & $CRLF & wsResult & $CRLF)
  '
  ' run the DIR command
  strCmd = "DIR "
  wsResult = funRunPipe(strCMD)
  funLog("DIR Command" & $CRLF & wsResult & "" & $CRLF)
  '
  ' run the Find command
  strCMD = "find /I /N " & $DQ & "wsResult" & $DQ & _
           " " & $DQ & EXE.PATH$ & "Using_Pipes.bas" & $DQ
  wsResult = funRunPipe(strCMD)
  funLog("Find Command" & $CRLF & wsResult)
  '
  CLIPBOARD RESET
  CLIPBOARD SET TEXT wsResult
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funRunPipe(strCMD AS STRING) AS STRING
' run the Pipe command
  LOCAL wsResult AS WSTRING
  wsResult = PipeToString(strCmd)
  '
  FUNCTION = wsResult
  '
END FUNCTION
