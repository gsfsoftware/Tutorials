#COMPILE EXE
#DIM ALL

%TRUE = -1
%FALSE = 0

#INCLUDE "PB_FileHandlingRoutines.inc"

$MyFile = "MyFile.txt"
$OutputFile = "OutputFile.txt"


FUNCTION PBMAIN () AS LONG
  CON.CAPTION$= "Our Console"
  '
  IF ISTRUE funReadTheFileAndOutput($MyFile, _
                                    "Eye Colour", _
                                    "Brown", _
                                    EXE.PATH$ & $OutputFile) THEN
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
