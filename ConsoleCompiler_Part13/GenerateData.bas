#COMPILE EXE
#DIM ALL
'#CONSOLE OFF

%TRUE = -1
%FALSE = 0
%Max_Records = 1000

GLOBAL g_hWin AS DWORD   ' the handle for the graphics window
GLOBAL g_dwFont AS DWORD ' font handle
GLOBAL g_dStart AS DOUBLE ' start time

GLOBAL a_strWork() AS STRING         ' array holding the dataset

#INCLUDE "PB_FileHandlingRoutines.inc"
#INCLUDE "GenerateData_Version.inc"

#LINK "PB_RandomRoutines_SLL.sll"

#INCLUDE "UDP_routines.inc"

$OutputFile = "MyLargeFile.txt"


FUNCTION PBMAIN () AS LONG
  '
  FONT NEW "Courier New",18,0,1,0,0 TO g_dwFont
  funBuildGraphicsWindow()   ' create a graphics window
  '
  IF ISTRUE funGenerateFile($OutputFile) THEN
    funSetProgressText("File Generated successfully")
    '
    ' load the file into an array in memory
    IF ISTRUE funReadTheFileIntoAnArray($OutputFile, a_strWork()) THEN
      funSetProgressText("Array Generated")
      ' now listen for requests
      IF ISTRUE funOpenUDP() THEN
        funSetProgressText("Listening for broadcasts")
        funListenForRequests()
      END IF
      '
      funCloseUDP()
      '
    ELSE
      funSetProgressText("Array not Generated")
    END IF
    '
  ELSE
    funSetProgressText("File not Generated")
  END IF
  '
  funSetProgressText("Exiting in 10 seconds")
  SLEEP 10000
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
  g_dStart = TIMER  ' pick up the start time
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
               "firstnames.csv", _
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

 FOR lngR = 1 TO %Max_Records  ' number of records
   funSetProgressBar(lngR)
   '
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
 LOCAL TimeNow AS DOUBLE
 LOCAL Seconds AS DOUBLE
 TimeNow = TIMER
 seconds = TimeNow - g_dStart
 funSetProgressText("Duration = " & FORMAT$(Seconds,"#,") & " Seconds")
 '
 FUNCTION = %TRUE
'
END FUNCTION
'
FUNCTION funBuildGraphicsWindow() AS LONG
  LOCAL strText AS STRING
  strText = "Generating Data"
  '
  GRAPHIC WINDOW strText,10,10,530,470 TO g_hWin
  GRAPHIC ATTACH g_hWin, 0
  GRAPHIC SET FONT g_dwFont
  GRAPHIC BOX (15,440) - (518,460),20, %BLUE, RGB(191,191,191),0
  '
END FUNCTION
'
'
FUNCTION funSetProgressBar(lngR AS LONG) AS LONG
' set the progress
  LOCAL lngValue AS LONG
  LOCAL lngPercent AS LONG
  LOCAL lngStart AS LONG
  lngStart = 17
  LOCAL lngTop AS LONG
  lngTop = 500

  '
  IF lngR > %Max_Records THEN
    lngValue = %Max_Records
  ELSE
    lngValue = lngR
  END IF
  '
  lngPercent = (lngValue / %Max_Records) * 100
  lngPercent = ((lngTop * lngPercent)\100) + lngStart
  GRAPHIC BOX (lngStart,442) - (lngPercent,458),0,%BLACK,%RED,0
  GRAPHIC SET POS (15,300)
  GRAPHIC PRINT "Record " & FORMAT$(lngValue) & " of " FORMAT$(%Max_Records)
  '
END FUNCTION
