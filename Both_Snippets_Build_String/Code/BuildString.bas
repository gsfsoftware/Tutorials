#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF

' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Building Strings",0,0,40,120)
  '
  funLog("Walk through on Building Strings")
  '
  '
  DIM a_strWork() AS STRING
  DIM a_strArrayField() AS STRING
  LOCAL lngR AS LONG
  LOCAL strFilename AS STRING
  '
  ' create an output string
  LOCAL strOutput AS STRING
  LOCAL lngColumns AS LONG
  LOCAL lngC AS LONG
  LOCAL qCount AS QUAD
  LOCAL strTemp AS STRING
  '
  strFileName = EXE.PATH$ & "MyFile.csv"
  '
  IF ISTRUE funReadTheFileIntoAnArray(strFilename, _
            BYREF a_strWork()) THEN
  ' array has been loaded
    TIX qCount ' start the timer
    '
    strOutput = ""
    lngColumns = PARSECOUNT(a_strWork(0),",")
    '
    FOR lngR = 0 TO UBOUND(a_strWork())
      FOR lngC = 1 TO lngColumns
        strTemp = PARSE$(a_strWork(lngR),"",lngC)
        strOutput = strOutput & $DQ & strTemp & $DQ & ","
        'strOutput = build$(strOutput,$DQ,strTemp,$DQ,"," )
      NEXT lngC
      strOutput = RTRIM$(strOutput,",") & $CRLF
    NEXT lngR
    '
    TIX END qCount
    funLog(strOutput)
    funLog(FORMAT$(qCount,"#,") & " CPU cycles")
    '
    LOCAL sbOutput AS ISTRINGBUILDERA
    sbOutput = CLASS "StringBuilderA"
    '
    TIX qCount ' start the timer
    sbOutput.clear
    sbOutput.capacity = 5000
    '
    lngColumns = PARSECOUNT(a_strWork(0),",")
    FOR lngR = 0 TO UBOUND(a_strWork())
      FOR lngC = 1 TO lngColumns
        PREFIX "sbOutput.add "
          $DQ
          PARSE$(a_strWork(lngR),"",lngC)
          $DQ
          ","
        END PREFIX
        '
      NEXT lngC
      sbOutput.delete (sbOutput.len,1)
      sbOutput.add $CRLF
    NEXT lngR
    '
    TIX END qCount
    funLog(sbOutput.string)
    funLog(FORMAT$(qCount,"#,") & " CPU cycles")'
  ELSE
  ' cant load the array for some reason
  END IF
  '
  funWait()
  '
END FUNCTION
'
