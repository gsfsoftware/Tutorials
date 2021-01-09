' Common display library

#IF %DEF(%PB_CC32)
' we are in the console compiler version
  FUNCTION funPrepOutput(strConsoleName AS STRING, _
                         lngXStart AS LONG, _
                         lngYStart AS LONG, _
                         OPTIONAL lngRows AS LONG, _
                         lngColumns AS LONG) AS LONG
                         '
    LOCAL lngNumRows AS LONG
    LOCAL lngNumCols AS LONG
    '
    IF ISTRUE ISMISSING(lngRows) THEN
      lngNumRows = 25
      lngNumcols = 80
    ELSE
      lngNumRows = lngRows
      lngNumcols = lngColumns
    END IF
    '
    CON.VIRTUAL = lngNumRows, lngNumcols
    '
    CON.CAPTION$= strConsoleName
    CON.COLOR 10,-1                 ' make the text green and default background
    CON.LOC = lngXStart,lngYStart   ' set the screen location of the console
  END FUNCTION
  '
  FUNCTION funLog(strData AS STRING) AS LONG
    CON.STDOUT strData
  END FUNCTION
  '
  FUNCTION funWait() AS LONG
    CON.STDOUT "Press any key to exit"
    WAITKEY$
  END FUNCTION
#ELSE
' we are not in the Console compiler so it
' must be the Windows compiler version
  GLOBAL g_hTxtWin AS DWORD
  FUNCTION funPrepOutput(strConsoleName AS STRING, _
                         lngXStart AS LONG, _
                         lngYStart AS LONG, _
                         OPTIONAL lngRows AS LONG, _
                         lngColumns AS LONG) AS LONG
    LOCAL lngNumRows AS LONG
    LOCAL lngNumCols AS LONG
    '
    IF ISTRUE ISMISSING(lngRows) THEN
      lngNumRows = 25
      lngNumcols = 80
    ELSE
      lngNumRows = lngRows
      lngNumcols = lngColumns
    END IF

    TXT.WINDOW(strConsoleName,lngXStart,lngYStart,lngNumRows,lngNumcols) TO g_hTxtWin
    '
  END FUNCTION
  '
  FUNCTION funLog(strData AS STRING) AS LONG
    LOCAL lngR AS LONG
    FOR lngR = 1 TO PARSECOUNT(strData,$CRLF)
      TXT.PRINT strData
    NEXT lngR
  END FUNCTION
  '
  FUNCTION funWait() AS LONG
    TXT.PRINT "Click the message box to exit the application"
    MSGBOX "Click OK to exit",%MB_ICONINFORMATION OR %MB_TASKMODAL,"Completed"
  END FUNCTION
#ENDIF
