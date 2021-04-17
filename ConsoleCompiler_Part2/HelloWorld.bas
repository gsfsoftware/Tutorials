#COMPILE EXE
#DIM ALL

%TRUE = -1
%FALSE = 0

#INCLUDE "PB_FileHandlingRoutines.inc"

$MyFile = "MyFile.txt"

FUNCTION PBMAIN () AS LONG
  CON.CAPTION$= "Our Console"
  '
  IF ISTRUE funReadTheFile($MyFile) THEN
  ' the function worked
    CON.STDOUT "IT worked"
  ELSE
  ' it didn't work
    CON.STDOUT "IT didn't work"

  END IF
  '
  WAITKEY$

END FUNCTION
'
