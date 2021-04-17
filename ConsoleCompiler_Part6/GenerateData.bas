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
  LOCAL strData AS STRING
  DIM a_strFirstName() AS STRING
  DIM a_strSurnames() AS STRING
  DIM a_strCities() AS STRING
  DIM a_strStreets() AS STRING
  DIM a_strEyeColour() AS STRING
  DIM a_strBloodGroup() AS STRING

  LOCAL strString AS STRING
  LOCAL lngR AS LONG
  '
  RANDOMIZE TIMER
  '
  strHeader = "FirstName" & $TAB & _
              "Surname" & $TAB & _
              "Address" & $TAB & _
              "Telephone" & $TAB & _
              "Eye Colour" & $TAB & _
              "Blood Group"
              '
 TRY
   KILL strFileName
 CATCH
 FINALLY
 END TRY
 '
 funAppendToFile(strFileName, strHeader)
 '
 funBuildArray("FirstName", a_strFirstName(), _
               "babies-first-names-top-100-boys.csv", _
               3, ",")  ' build the first name array
 '
 funBuildArray("Surname", a_strSurnames(), _
               "Surnames.csv", _
               1, ",")  ' build the surname array
 funBuildArray("Streets", a_strStreets(), _
               "Streets.csv", _
               1, ",")  ' build the streets array
 funBuildArray("Cities", a_strCities(), _
               "Cities.csv", _
               1, ",")  ' build the Cities array
 funBuildArray("Eye Colours", a_strEyeColour(), _
               "EyeColour.csv", _
               1, ",")  ' build the Eye Colour array
 funBuildArray("Blood Group", a_strBloodGroup(), _
               "BloodGroups.csv", _
               1, ",")  ' build the Blood Groups array

 FOR lngR = 1 TO 2000  ' 100 records
   IF (lngR MOD 200) = 0 THEN
     CON.STDOUT FORMAT$(lngR)
   END IF
   strString = funGetArrayValue(a_strFirstName()) & $TAB & _
               MCASE$(funGetArrayValue(a_strSurnames())) & $TAB & _
               funStreetNumber() & " " & funGetArrayValue(a_strStreets()) & _
               "," & funGetArrayValue(a_strCities()) & $TAB & _
               funGetTelephone() & $TAB & _
               funGetArrayValue(a_strEyeColour()) & $TAB & _
               funGetArrayValue(a_strBloodGroup())
   '
   funAppendToFile(strFileName, strString)
 NEXT lngR
 '
 FUNCTION = %TRUE
'
END FUNCTION
