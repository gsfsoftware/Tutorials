#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\PB_Common_Strings.inc"
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"
#INCLUDE "..\Libraries\PB_Sorting.inc"
'

FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("String functions library",0,0,40,120)
  '
  funLog("String functions library")
  '
  LOCAL strFilename AS STRING
  DIM a_strWork() AS STRING
  LOCAL strHeaders AS STRING
  LOCAL lngR AS LONG
  LOCAL strError AS STRING
  '
  strFilename = EXE.PATH$ & "MyFile.csv"
  '
  ' read the file into an array
  IF ISTRUE funReadTheFileIntoAnArray(strFilename, _
                                      BYREF a_strWork()) THEN
     ' pick up the headers
    strHeaders = a_strWork(0)
    funLog strHeaders
    '
    ' determine the column positions
    LOCAL lngFirstName AS LONG
    LOCAL lngSurname AS LONG
    LOCAL lngAddress AS LONG
    LOCAL lngTelephone AS LONG
    LOCAL lngAccount AS LONG
    LOCAL lngBalance AS LONG
    '
    ' store the column positions
    lngFirstName = funParseFind(strHeaders,",","FirstName")
    lngSurname   = funParseFind(strHeaders,",","Surname")
    lngAddress   = funParseFind(strHeaders,",","Address")
    lngTelephone = funParseFind(strHeaders,",","Telephone")
    lngAccount   = funParseFind(strHeaders,",","Account Number")
    lngBalance   = funParseFind(strHeaders,",","Balance")
    '
    funDisplayArray(BYREF a_strWork())
    '
    'array sort a_strWork(1) ,COLLATE UCASE, ascend
    'funDisplayArray(BYREF a_strWork())
    '
    ' sort by surname descending
'    IF ISTRUE funArraySort(BYREF a_strWork(), _
'                           "STRING", lngSurname ,_
'                           ",", "ASCEND", _
'                           strError,%TRUE) THEN
'                           '
'      funDisplayArray(BYREF a_strWork())
'    END IF
'
' sort by Balance ascending
    IF ISTRUE funArraySort(BYREF a_strWork(), _
                           "CURRENCY", lngBalance ,_
                           ",", "DESCEND", _
                           strError,%TRUE) THEN
                           '
      funDisplayArray(BYREF a_strWork())
    END IF
    '
  END IF
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funDisplayArray(BYREF a_strWork() AS STRING) AS LONG
  LOCAL lngR AS LONG
  '
  funLog ""
  FOR lngR = LBOUND(a_strWork) TO UBOUND(a_strWork)
    funlog "Record " & FORMAT$(lngR) & "  " & _
                       a_strWork(lngR)
  NEXT lngR
  '
END FUNCTION
