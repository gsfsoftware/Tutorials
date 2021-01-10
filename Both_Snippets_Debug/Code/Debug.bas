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
  funPrepOutput("Array sorting",0,0,40,120)
  '
  funLog("Walk through on Array Sorting")
  '
  'profile "ProfileLog.txt"
  '
  TRACE NEW "Tracelog.txt"
  TRACE ON
  '
  DIM a_strWork() AS STRING
  DIM a_strArrayField() AS STRING
  LOCAL lngR AS LONG
  LOCAL strFilename AS STRING
  '
  strFileName = EXE.PATH$ & "MyFile.csv"
  '
  TRACE PRINT "Reading the file into the array"
  IF ISTRUE funReadTheFileIntoAnArray(strFilename, _
            BYREF a_strWork()) THEN
  ' array has been loaded
    FOR lngR = 0 TO UBOUND(a_strWork())
      funLog(a_strWork(lngR))
    NEXT lngR
    '
    ' redim the Sorting array to be the same size
    REDIM a_strArrayField(UBOUND(a_strWork)) AS STRING
    FOR lngR = 0 TO UBOUND(a_strArrayField)
    ' store telephone number in tag array
      a_strArrayField(lngR) = PARSE$(a_strWork(lngR),"",2)
    NEXT lngR
    '
    TRACE PRINT "now Sorting"
    TRACE OFF
    'ARRAY SORT a_strWork(1), COLLATE UCASE, ascend
    ARRAY SORT a_strArrayField(1) , _
          COLLATE UCASE, _
          TAGARRAY a_strWork() ,ASCEND
          '
    funLog($CRLF & "Sorted")
    FOR lngR = 0 TO UBOUND(a_strWork())
      funLog(a_strWork(lngR))
    NEXT lngR

  '
  ELSE
  ' cant load the array for some reason
  END IF
  '
  funWait()
  '
  TRACE OFF
  TRACE CLOSE
  '
END FUNCTION
'
FUNCTION funDummyRoutine() AS LONG
  SLEEP 100
  funLog(FUNCNAME$)
END FUNCTION
