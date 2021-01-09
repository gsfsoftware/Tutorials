#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
#IF %DEF(%PB_CC32)
' if we are in the console compiler
' turn the console off
  #CONSOLE OFF
#ENDIF
'
' include the libraries
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"
#INCLUDE "..\Libraries\PB_Shell.inc"
#INCLUDE "..\Libraries\Datefunctions.inc"
'
GLOBAL g_strLogFile AS STRING
GLOBAL g_strHTMLlogFile AS STRING
'
' this will be X drive
$WinAPI_PBCC  = "E:\PowerBasic\PBCC60\WinAPI"

' this will be y drive
$AutoBuilder  = "D:\Youtube\PowerBasic\Both_AutoBuilder_Part2\Code"

' this will be Z drive
$WinAPI_PBWin = "E:\PowerBasic\PBWin10\WinAPI"
'
$PBCC = "E:\PowerBasic\PBCC60\BIN\PBCC.exe"
$PBWIN = "E:\PowerBasic\PBWin10\BIN\PBWin.exe"

'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  '
  LOCAL dwFont AS DWORD
  DIM a_strBuildList() AS STRING
  LOCAL strBuildFile AS STRING
  LOCAL lngBuildFailures AS LONG
  LOCAL lngBuildSuccess AS LONG
  LOCAL strHTML AS STRING
  '
  ' create the graphics window
  LOCAL hWin AS DWORD
  GRAPHIC WINDOW "Auto builder", 300, 300, 530, 270 TO hWin
  GRAPHIC ATTACH hWin, 0, REDRAW
  GRAPHIC BOX (15,140) - (518,160),20, %BLUE, RGB(191,191,191),0
  FONT NEW "Courier New",18,0,1,0,0 TO dwFont
  GRAPHIC SET FONT dwFont
  '
  g_strLogFile = EXE.PATH$ & "Log_of_Builds.log"
  '
  TRY
    KILL g_strLogFile
  CATCH
  FINALLY
  END TRY
  '
  g_strHTMLlogFile = EXE.PATH$ & "Log_of_Builds.html"
  TRY
    KILL g_strHTMLlogFile
  CATCH
  FINALLY
  END TRY
  '
  ' prepare the html log
  strHTML = "<html><body><p><h2>Auto Build log</h2></p>" & _
            "<table><th>Project</th><th>Type</th><th>Build state</th>" & _
            "<th>Log</th>"
  funAppendToFile(g_strHTMLlogFile , strHTML)
            '
  strBuildFile = EXE.PATH$ & "BuildList.txt"
  '
  IF ISTRUE funReadTheFileIntoAnArray(strBuildFile, _
                                      a_strBuildList()) THEN
  ' build file loaded
    lngBuildFailures = 0
    lngBuildSuccess  = 0
    '
    ' build the code for each project
    IF ISTRUE funBuildCode(lngBuildFailures, _
                           lngBuildSuccess, _
                           a_strBuildList()) THEN
      funLog("Completed build " & $CRLF & _
             "Build Successes = " & FORMAT$(lngBuildSuccess) & $CRLF & _
             "Build Failures  = " & FORMAT$(lngBuildFailures))
    ELSE
      funLog("Unable to complete build " & $CRLF & _
             "Build Successes = " & FORMAT$(lngBuildSuccess) & $CRLF & _
             "Build Failures  = " & FORMAT$(lngBuildFailures))
    END IF
  '
  ELSE
    funLog("Unable to read " & strBuildFile)
  END IF
  '
  strHTML = "</table></body></html>"
  funAppendToFile(g_strHTMLlogFile , strHTML)
  '
  FONT END dwFont
END FUNCTION
'
FUNCTION funBuildCode(lngBuildFailures AS LONG, _
                      lngBuildSuccess AS LONG, _
                      BYREF a_strBuildList() AS STRING) AS LONG
' build the applications
'
  LOCAL lngR AS LONG
  LOCAL strType AS STRING
  LOCAL strProject AS STRING
  LOCAL strData AS STRING
  LOCAL strFileName AS STRING
  LOCAL strDelivers AS STRING
  LOCAL lngMax AS LONG
  '
  ' check virtual drives are set up
  IF ISFALSE funCheckVirtualDrives() THEN
  ' unable to set up virtual drives
    funLog("Unable to set up the virtual drives")
    EXIT FUNCTION
  END IF
  '
  lngMax = UBOUND(a_strBuildList)
  '
  ' for each application
  FOR lngR = 0 TO lngMax
    strData = a_strBuildList(lngR)
    '
    ' skip over comment lines
    IF LEFT$(strData,1) = "'" THEN ITERATE
    '
    strProject  = TRIM$(PARSE$(strData,"|",1))
    strType     = UCASE$(TRIM$(PARSE$(strData,"|",2)))
    strFileName = TRIM$(PARSE$(strData,"|",3))
    strDelivers = TRIM$(PARSE$(strData,"|",4))
    '
    ' update the progress bar on the graphics window
    funSetProgressBar(lngR , _
                      lngMax, _
                      strProject)
    GRAPHIC REDRAW    ' redraw the graphics windo
    '
    ' build this project
    IF ISTRUE funBuildProject(strProject,strType, _
                              strFileName, strDelivers) THEN
      INCR lngBuildSuccess
    ELSE
      INCR lngBuildFailures
    END IF
    '
  NEXT lngR
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funBuildProject(strProject AS STRING, _
                         strType AS STRING , _
                         strFileName AS STRING, _
                         strDelivers AS STRING) AS LONG
                         '
  ' build an individual project
  LOCAL strCMD AS STRING
  LOCAL strBuildLogFile AS STRING
  LOCAL strBuildDetails AS STRING
  LOCAL strLog AS STRING
  LOCAL strBuildState AS STRING
  ' set the log name
  strLog = LEFT$(strFileName,LEN(strFileName)-4)
  '
  ' purge files from previous builds
  TRY
    KILL EXE.PATH$ & "Script.bat"
  CATCH
  FINALLY
  END TRY
  '
  ' first remove any previous builds & log files
  TRY
    KILL $DQ & "Y:\Source\" & strProject & "\" & _
                  strDelivers & $DQ
  CATCH
  FINALLY
  END TRY
  '
  TRY
    KILL $DQ & "Y:\Source\" & strProject & "\" & _
                  strProject & ".log" & $DQ
  CATCH
  FINALLY
  END TRY
  '
  ' prepare the Script batch file
  funAppendToFile(EXE.PATH$ & "Script.bat", _
                      "Y:" & $CRLF & _
                      "CD " & $DQ & "Y:\Source\" & _
                      strProject & $DQ)'
                      '
  SELECT CASE strType
    CASE "PBCC"
    ' Powerbasic console app
      funAppendToFile(EXE.PATH$ & "Script.bat", _
        $DQ & $PBCC & $DQ & _
        " /L" & $DQ & strLog & $DQ & _
        " /Q " & _
        "/I" & $DQ & "X:\" & $DQ & _
        ";" & $DQ & "Y:\Source\" & strProject & "\" & _
                  strFileName & $DQ)
    CASE "PBWIN"
    ' Powerbasic windows app
      funAppendToFile(EXE.PATH$ & "Script.bat", _
      $DQ & $PBWin & $DQ & _
      " /L" & $DQ & strLog & $DQ & _
      " /Q " & _
      "/I" & $DQ & "Z:\" & $DQ & _
      ";" & $DQ & "Y:\Source\" & strProject & "\" & _
                  strFileName & $DQ)
  END SELECT
  '
  ERRCLEAR
  ' run the batch file
  funExecCmd(EXE.PATH$ & "Script.bat")
  '
  ' prep the build state html
  strBuildState = "<tr><td>" & strProject & "</td>" & _
                  "<td>" & strType & "</td>
  '
  IF ERR <> 0 THEN
  ' error running script batch file
    FUNCTION = %FALSE
    strBuildState = strBuildState & _
    "<td style=""background-color:LIGHTCORAL"">Failed</td></tr>"
  ELSE
  ' check for build success
    strBuildLogFile = "Y:\Source\" & strProject & "\" & _
                       strLog & ".log"
    strBuildDetails = funBinaryFileAsString(strBuildLogFile)
    IF strBuildDetails = "" THEN
      FUNCTION = %FALSE
      strBuildState = strBuildState & _
         "<td style=""background-color:LIGHTCORAL"">Failed</td>"
    ELSE
    ' log has appeared - so what's in it?
      IF INSTR(strBuildDetails,"Disk image:") > 0 THEN
      ' success
        FUNCTION = %TRUE
        strBuildState = strBuildState & _
           "<td style=""background-color:LIGHTGREEN"">Success</td>"
      ELSE
      ' some kind of error
        FUNCTION = %FALSE
        strBuildState = strBuildState & _
               "<td style=""background-color:LIGHTCORAL"">Failed</td>"
      END IF
      '
    END IF
  '
  END IF
  '
  ' update the html log
  strBuildState = strBuildState & _
     "<td><a href=""file:///" & strBuildLogFile & $DQ & _
     ">Log file</a></td></tr>"
  funAppendToFile(g_strHTMLlogFile , strBuildState)

END FUNCTION
'
FUNCTION funSetProgressBar(lngR AS LONG, _
                           lngMax AS LONG, _
                           strProject AS STRING) AS LONG
  ' set the progress bar in the graphics window
  LOCAL lngValue AS LONG
  LOCAL lngPercent AS LONG
  LOCAL lngStart AS LONG
  lngStart = 17
  LOCAL lngTop AS LONG
  lngTop = 500
  '
  IF lngR > lngMax THEN
    lngValue = lngMax
  ELSE
    lngValue = lngR
  END IF
  '
  lngPercent = (lngValue / lngMax) * 100
  lngPercent = ((lngTop * lngPercent)\100) + lngStart
  GRAPHIC BOX (lngStart,142) - (lngPercent,158),0,%BLACK,%RED,0
  GRAPHIC SET POS (15,100)
  GRAPHIC PRINT LEFT$("Building " & strProject & SPACE$(200),200)
  '
END FUNCTION
'
FUNCTION funLog(strData AS STRING ) AS LONG
' log to file
  FUNCTION = funAppendToFile(g_strLogFile, funUKDate & _
  " " & TIME$ & " " & strData)
'
END FUNCTION
'
FUNCTION funCheckVirtualDrives() AS LONG
' check the virtual drives are set up
  LOCAL strCmd AS STRING
  '
  IF ISFALSE ISFOLDER("Y:\Source") THEN
    strCmd = "subst Y: " & $AutoBuilder
    funExecCmd(strCmd & "")
    '
    IF ISFALSE ISFOLDER("Y:\Source") THEN
      EXIT FUNCTION
    END IF
  END IF
  '
  IF ISFALSE ISFILE("X:\Win32Api.inc") THEN
    strCmd = "subst X: " & $WinAPI_PBCC
    funExecCmd(strCmd & "")
    '
    IF ISFALSE ISFILE("X:\Win32Api.inc") THEN
      EXIT FUNCTION
    END IF
  END IF '
  '
  IF ISFALSE ISFILE("Z:\Win32Api.inc") THEN
    strCmd = "subst Z: " & $WinAPI_PBWin
    funExecCmd(strCmd & "")
    '
    IF ISFALSE ISFILE("Z:\Win32Api.inc") THEN
      EXIT FUNCTION
    END IF
  END IF
  '
  FUNCTION = %TRUE
  '
END FUNCTION
