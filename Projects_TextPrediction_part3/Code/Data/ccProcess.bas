#COMPILE EXE
#DIM ALL

#INCLUDE "win32api.inc"
#INCLUDE "PB_FileHandlingRoutines.inc"
'
FUNCTION PBMAIN () AS LONG
  DIM a_strData() AS STRING
  LOCAL strFile AS STRING
  LOCAL lngCount AS LONG
  LOCAL strFileOut AS STRING
  '
  ' read the data and process it
  strFile = DIR$("Subtitle_*.txt")
  WHILE strFile <> ""
    ' open file and process
    INCR lngCount
    strFileOut = "TextData_" & RIGHT$("000" & FORMAT$(lngCount),3) & ".txt"
    '
    IF ISTRUE funReadTheFileIntoAnArray(strFile, a_strData()) THEN
    ' file loaded
      CON.PRINT "Loaded " & strFile
      CON.PRINT "Outputing To " & strFileOut
      '
      funProcess(a_strData(),strFileOut)
    '
    END IF
    '
    strFile = DIR$
  WEND
  '
  CON.PRINT "Completed"
  SLEEP 3000
  '
END FUNCTION
'
FUNCTION funProcess(a_strData() AS STRING, _
                    strFileOut AS STRING) AS LONG
' strip out unneeded data and save file
  LOCAL lngFileOut AS LONG
  LOCAL lngR AS LONG
  LOCAL strData AS STRING
  '
  lngFileOut = FREEFILE
  OPEN strFileOut FOR OUTPUT AS #lngFileOut
    FOR lngR = 1 TO UBOUND(a_strData)
      ' keep only the text data - drop chapters and blank lines
      IF LEFT$(a_strData(lngR),1) <> "0" AND _
        a_strData(lngR) <> "" AND _
        VAL(LEFT$(a_strData(lngR),1)) = 0 THEN
        ' accumulate to single line
        strData = strData & " " & a_strData(lngR)
        '
      END IF
      '
    NEXT lngR
    ' print out the data
    PRINT #lngFileOut,SHRINK$(strData)
    '
  CLOSE #lngFileOut
  '
END FUNCTION
