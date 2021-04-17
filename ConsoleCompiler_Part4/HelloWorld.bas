#COMPILE EXE
#DIM ALL

%TRUE = -1
%FALSE = 0

#INCLUDE "PB_FileHandlingRoutines.inc"

$MyFile     = "MyFile.txt"
$OutputFile = "OutputFile.txt"


FUNCTION PBMAIN () AS LONG
  DIM a_strWork() AS STRING
  CON.CAPTION$= "Our Console"
  '
  IF ISTRUE funReadTheFileIntoAnArray($MyFile, a_strWork()) THEN
  ' the function worked
    CON.STDOUT FORMAT$(UBOUND(a_strWork))
    '
    ARRAY SORT a_strWork(1), COLLATE UCASE, ASCEND
    '
    IF ISTRUE funArrayDump($OutputFile, a_strWork()) THEN
      CON.STDOUT "Array saved"
    ELSE
      CON.STDOUT "Array not saved"
    END IF

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
