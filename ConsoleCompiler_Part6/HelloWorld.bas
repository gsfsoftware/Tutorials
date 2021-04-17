#COMPILE EXE
#DIM ALL

%TRUE = -1
%FALSE = 0

#INCLUDE "PB_FileHandlingRoutines.inc"

$MyFile     = "MyFile.txt"
$OutputFile = "OutputFile.txt"

TYPE udtUsers
  strForeName  AS STRING * 50
  strSurname AS STRING   * 100
  strAddress AS STRING   * 200
  strTelephone AS STRING * 20
  strEyeColour AS STRING * 10
  strBloodGroup AS STRING * 50
  strBloodGroupShort AS STRING * 3
END TYPE


FUNCTION PBMAIN () AS LONG
  DIM a_strWork() AS STRING
  LOCAL uUser AS udtUsers
  LOCAL lngR AS LONG
  LOCAL strData AS STRING
  LOCAL strHeaders AS STRING
    '
  CON.CAPTION$= "Our Console"
  '
  IF ISTRUE funReadTheFileIntoAnArray($MyFile, a_strWork()) THEN
  ' the function worked
    CON.STDOUT FORMAT$(UBOUND(a_strWork))
    '
    ARRAY SORT a_strWork(1), COLLATE UCASE, ASCEND
    '
    FOR lngR = 0 TO  UBOUND(a_strWork)
      strData = a_strWork(lngR)
      '
      IF lngR = 0 THEN
      ' read the headers
        strHeaders = strData
        ITERATE FOR
      END IF
      '
      PREFIX "uUser."
        strForeName = PARSE$(strData,$TAB,1)
        strSurname = PARSE$(strData,$TAB,2)
        strAddress = PARSE$(strData,$TAB,3)
        strAddress = REMOVE$(uUser.strAddress,$DQ)
        strTelephone = PARSE$(strData,$TAB,4)
        strTelephone = REMOVE$(uUser.strTelephone," ")
        strEyeColour = PARSE$(strData,$TAB,5)
        strBloodGroup = PARSE$(strData,$TAB,6)
        strBloodGroupShort = PARSE$(uUser.strBloodGroup,ANY "()",2)
      END PREFIX
      '
      IF TRIM$(uUser.strBloodGroupShort) = "A-" THEN
        ITERATE FOR
      END IF
      '
      CON.STDOUT TRIM$(uUser.strForeName)
      CON.STDOUT TRIM$(uUser.strSurname)
      CON.STDOUT TRIM$(uUser.strAddress)
      CON.STDOUT TRIM$(uUser.strTelephone)
      CON.STDOUT TRIM$(uUser.strBloodGroup)
      CON.STDOUT TRIM$(uUser.strBloodGroupShort)
      SLEEP 500
      '
    NEXT lngR


'    IF ISTRUE funArrayDump($OutputFile, a_strWork()) THEN
'      CON.STDOUT "Array saved"
'    ELSE
'      CON.STDOUT "Array not saved"
'    END IF

    '
    CON.STDOUT "IT worked"
  ELSE
  ' it didn't work
    CON.STDOUT "IT didn't work"

  END IF
  '
  WAITKEY$

END FUNCTION
'
