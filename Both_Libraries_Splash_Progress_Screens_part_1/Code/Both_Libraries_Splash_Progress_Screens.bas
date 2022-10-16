#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
#INCLUDE "GraphicSplashProgress.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Graphic splash/progress",0,0,40,120)
  '
  funLog("Graphic splash/progress")
  '
  'funOpenGraphicProgress
  LOCAL hWin AS DWORD  ' define a handle for the graphics window
  funOpenGraphicProgress(hWin,"Sample Graphics Progress",100,400)
  '
  'funUpdateGraphicProgress
  '
  LOCAL lngValue AS LONG    ' used for the % complete
  LOCAL lngR AS LONG        ' used for a progress loop
  LOCAL strMessage AS STRING ' message to display
  '
  FOR lngR = 1 TO 10
  ' for each 10% of work
    lngValue = lngValue + 10 ' set the percentage done
    '
    IF lngR < 10 THEN
      strMessage = "Still processing - " & _
                    FORMAT$(lngValue) & "%"
    ELSE
      strMessage = "Completed processing - " & _
                    FORMAT$(lngValue) & "%"
    END IF
    '
    ' update the graphics progress
    funUpdateGraphicProgress(strMessage, lngValue)
    SLEEP 500 ' wait 1/2 sec to simulate processing
    '
  NEXT lngR
  '
  SLEEP 500
  '
  funCloseGraphicProgress(hWin)
  '
  SLEEP 3000
  '
  funWait()
  '
END FUNCTION
'
