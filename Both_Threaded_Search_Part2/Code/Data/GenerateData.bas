#COMPILE EXE
#DIM ALL
#CONSOLE OFF

%TRUE = -1
%FALSE = 0
%Max_Records = 100000

GLOBAL g_hWin AS DWORD   ' the handle for the graphics window
GLOBAL g_dwFont AS DWORD ' font handle
GLOBAL g_dStart AS DOUBLE ' start time

#INCLUDE "PB_FileHandlingRoutines.inc"
#INCLUDE "PB_RandomRoutines.inc"

$OutputFile = "MyLargeFile.txt"


FUNCTION PBMAIN () AS LONG
  '
  'CON.CAPTION$= "Our Console" ' Title the console window
  'CON.COLOR 10,-1             ' make the text green and default background
  'CON.LOC = 20,20             ' set the screen location of the console
  '
  FONT NEW "Courier New",18,0,1,0,0 TO g_dwFont
  funBuildGraphicsWindow()
  '
  IF ISTRUE funGenerateFile($OutputFile) THEN
    funSetProgressText("File Generated successfully")
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
  DIM a_strDomains() AS STRING
  '
  LOCAL strFirstName AS STRING
  LOCAL strSurname AS STRING
  LOCAL strEmail AS STRING

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
              "Blood Group" & $TAB & _
              "Email"
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
 funBuildArray("Domains", a_strDomains(), _
               "Domains.csv", _
               1, ",")  ' build the domains array

 FOR lngR = 1 TO %Max_Records  ' number of records

   funSetProgressBar(lngR)
   '
   strFirstName = funGetArrayValue(a_strFirstName())
   strSurname = MCASE$(funGetArrayValue(a_strSurnames()))
   strEmail =  strFirstName & "." & strSurname & FORMAT$(RND(1,9)) & "@" & _
               funGetArrayValue(a_strDomains())
               '
   strString = strFirstName & $TAB & _
               strSurname & $TAB & _
               funStreetNumber() & " " & funGetArrayValue(a_strStreets()) & _
               "," & funGetArrayValue(a_strCities()) & $TAB & _
               funGetTelephone() & $TAB & _
               funGetArrayValue(a_strEyeColour()) & $TAB & _
               funGetArrayValue(a_strBloodGroup()) & $TAB & _
               strEmail
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
FUNCTION funSetProgressText(strText AS STRING) AS LONG
' set the progress text
  STATIC lngPos AS LONG
  '
  lngPos = lngPos + 30
  GRAPHIC SET POS (15, lngPos)
  GRAPHIC PRINT strText & SPACE$(50)
  '
END FUNCTION
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
