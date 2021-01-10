#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON


' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Array sorting",0,0,40,120)
  '
  funLog("Walk through on Array Sorting")
  '
  DIM a_strWork() AS STRING
  DIM a_strArrayField() AS STRING
  LOCAL strFilename AS STRING
  LOCAL lngR AS LONG
  '
  strFilename = EXE.PATH$ & "MyFile.csv"
  '
  IF ISTRUE funReadTheFileIntoAnArray(strFilename, _
                                   BYREF a_strWork()) THEN
  ' file loaded
    FOR lngR = 0 TO UBOUND(a_strWork)
      funLog(a_strWork(lngR))
    NEXT lngR
    '
    REDIM a_strArrayField(UBOUND(a_strWork))
    '
    FOR lngR = 0 TO UBOUND(a_strArrayField)
      a_strArrayField(lngR) = PARSE$(a_strWork(lngR),"",5)
    NEXT lngR
    '
    ' sort the array
    'array sort a_strWork(1), collate ucase, ascend
    ARRAY SORT a_strArrayField(1), COLLATE UCASE, _
          TAGARRAY a_strWork(), ASCEND
    '

    '
    funlog($CRLF & "Sorted")
    FOR lngR = 0 TO UBOUND(a_strWork)
      funLog(a_strWork(lngR))
    NEXT lngR
    '
  ELSE
  END IF
  '
  funWait()
  '
END FUNCTION
