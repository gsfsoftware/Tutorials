#COMPILE EXE
#DIM ALL

%TRUE = -1
%FALSE = 0

#INCLUDE "PB_FileHandlingRoutines.inc"
#INCLUDE "PB_RandomRoutines.inc"

$OutputFile = "MyLargeFile.txt"


FUNCTION PBMAIN () AS LONG
  '
  CON.CAPTION$= "Our Console" ' Title the console window
  CON.COLOR 10,-1             ' make the text green and default background
  CON.LOC = 20,20             ' set the screen location of the console
  '
  IF ISTRUE funGenerateFile($OutputFile) THEN
    CON.STDOUT "File Generated successfully"
  ELSE
    CON.STDOUT "File not Generated"
  END IF
  '
  CON.STDOUT "Press any key to exit"
  WAITKEY$
  '
END FUNCTION
'
FUNCTION funGenerateFile(strFileName AS STRING) AS LONG
' generate the file
  LOCAL strHeader AS STRING
  '
  strHeader = "FirstName" & $TAB & _
              "Surname" & $TAB & _
              "Address" & $TAB & _
              "Telephone" & $TAB & _
              "Eye Colour" & $TAB & _
              "Blood Group"
              '
 funAppendToFile(strFileName, strHeader)

 FUNCTION = %TRUE
'
END FUNCTION
