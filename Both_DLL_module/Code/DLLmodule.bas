#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON

' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc
'#INCLUDE "..\Libraries\PB_Sorting.inc"

' define the DLL function and its parameters
DECLARE FUNCTION funArraySort IMPORT "PB_Sort.DLL" _
                         ALIAS "funDLLArraysort" _
                        (BYREF a_strWork() AS STRING, _
                         strSortType AS STRING, _
                         lngField AS LONG, _
                         strDelimiter AS STRING, _
                         strSortOrder AS STRING, _
                         strError AS STRING) AS LONG
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("DLL Module",0,0,40,120)
  '
  funLog("Walk through on DLL Modules")
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
    LOCAL strError AS STRING     ' string to hold error description
    LOCAL lngField AS LONG       ' field number to sort on
    LOCAL strDelimiter AS STRING ' the column separator i.e. delimiter
    LOCAL strSortType AS STRING  ' the variable type of the tagged sort array
    LOCAL strSortOrder AS STRING ' the type of sort Ascend or Descend
    '
    lngField = 5
    strDelimiter = ","
    strSortType = "LONG"
    strSortOrder = "ASCEND"
    'strSortOrder = "DESCEND"
    '
    IF ISTRUE funArraySort(BYREF a_strWork(), _
                           strSortType, _
                           lngField, _
                           strDelimiter, _
                           strSortOrder, _
                           strError) THEN

    'sorted ok
      funlog($CRLF & "Sorted")
      FOR lngR = 0 TO UBOUND(a_strWork)
        funLog(a_strWork(lngR))
      NEXT lngR
    '
    ELSE
    ' unable to sort
      funLog("Unable to sort " & strError)
    END IF
  '
  END IF
  '
  funWait()
  '
END FUNCTION
