#COMPILE EXE
#DIM ALL

#INCLUDE "Win32Api.inc"

GLOBAL a_strWork() AS STRING

#INCLUDE "PB_FileHandlingRoutines.inc"

$DataFile = "MyLargeFile.txt"

FUNCTION PBMAIN () AS LONG
  '
  LOCAL lngR AS LONG
  LOCAL lngStart AS LONG
  LOCAL lngEnd AS LONG
  LOCAL qCount AS QUAD
  '
  CON.CAPTION$= "Data analysis"
  CON.COLOR 10,0
  CON.LOC = 20, 20
  '
  lngStart = TIMER
  TIX qCount
  '
  IF ISTRUE funReadTheFileIntoAnArray($DataFile, a_strWork()) THEN
  ' the function worked
    CON.STDOUT "File read into array of " & _
               FORMAT$(UBOUND(a_strWork)) & " records"


  '
  ELSE
    CON.STDOUT "Unable to read the input file"
  END IF
  '
  lngEnd = TIMER
  TIX END qCount
  '
  CON.STDOUT FORMAT$(lngEnd - lngStart) & " seconds"
  CON.STDOUT FORMAT$(qCount,"#,") & " CPU cycles"
  '
  CON.STDOUT "Press any key to exit"
  WAITKEY$
END FUNCTION
'
