#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"
#INCLUDE "..\Libraries\PB_RandomRoutines.inc"

%Max_Records = 250000
%GraphicsStep = 30
GLOBAL g_hWin AS DWORD                 ' the handle for the graphics window
GLOBAL g_dwFont AS DWORD               ' font handle
GLOBAL g_dStart AS DOUBLE              ' start time
GLOBAL g_lngGraphicsPosition AS LONG   ' used to position graphics on dialog

FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Array handling",0,0,40,120)
  '
  funLog("Array handling")
  '
  FONT NEW "Courier New",18,0,1,0,0 TO g_dwFont
  funBuildGraphicsWindow()   ' create a graphics window
  '
  LOCAL lngRecordCount AS LONG
  LOCAL strFileName AS STRING
  strFileName = "Data.txt"
  funGenerateFile(strFileName)
  GRAPHIC WINDOW END g_hWin
  '
  ' now attempt to read the file into an array
  ' create a Quad variable to allow clock cycles to
  ' be counted
  LOCAL qCycleCount AS QUAD
  '
  ' load the original file and report timing
  TIX qCycleCount            ' start the clock
  funLoadFile_1(strFileName)
  TIX END qCycleCount        ' end the clock
  ' report the number of clock cycles in millions
  funlog("Method 1 - Cycles = " & _
         FORMAT$(qCycleCount\1000000) & " million")
  '
  ' load the 2nd copied file and report timing
  TIX qCycleCount
  funLoadFile_2("Data2.txt")
  TIX END qCycleCount
  funlog("Method 2 - Cycles = " & _
         FORMAT$(qCycleCount\1000000) & " million")
  '
  ' load the 3rd copied file and report timing
  TIX qCycleCount
  funLoadFile_3("Data3.txt")
  TIX END qCycleCount
  funlog("Method 3 - Cycles = " & _
         FORMAT$(qCycleCount\1000000) & " million")
  funWait()
  '
END FUNCTION
'
FUNCTION funLoadFile_1(strFileName AS STRING) AS LONG
  ' now read the file into an array
  LOCAL lngFile AS LONG
  LOCAL strRow AS STRING
  LOCAL lngRow AS LONG
  DIM a_strData() AS STRING
  '
  lngFile = FREEFILE
  '
  OPEN strFileName FOR INPUT AS #lngFile
  WHILE ISFALSE EOF(#lngFile)
    LINE INPUT #lngFile, strRow
    INCR lngRow
    REDIM PRESERVE a_strData(1 TO lngRow)
    a_strData(lngRow) = strRow
  WEND
  CLOSE #lngFile
  '
END FUNCTION
'
FUNCTION funLoadFile_2(strFileName AS STRING) AS LONG
   ' now read the file into an array
   ' by scanning the file first and dimensioning
   ' the array up front
  LOCAL lngFile AS LONG
  LOCAL lngTotalRecords AS LONG
  LOCAL strRow AS STRING
  LOCAL lngRow AS LONG
  DIM a_strData() AS STRING
  '
  lngFile = FREEFILE
  '
  OPEN strFileName FOR INPUT AS #lngFile
  FILESCAN #lngFile , RECORDS TO lngTotalRecords
  REDIM a_strData(1 TO lngTotalRecords)
  '
  WHILE ISFALSE EOF(#lngFile)
    LINE INPUT #lngFile, strRow
    INCR lngRow
    a_strData(lngRow) = strRow
  WEND
  CLOSE #lngFile
END FUNCTION
'
FUNCTION funLoadFile_3(strFileName AS STRING) AS LONG
   ' now read the file into an array
   ' by scanning the file first and dimensioning
   ' the array up front
   ' and reading the entire file in one go into
   ' the array
  LOCAL lngFile AS LONG
  LOCAL lngTotalRecords AS LONG
  LOCAL strRow AS STRING
  LOCAL lngRow AS LONG
  DIM a_strData() AS STRING
  '
  lngFile = FREEFILE
  '
  OPEN strFileName FOR INPUT AS #lngFile
  FILESCAN #lngFile , RECORDS TO lngTotalRecords
  REDIM a_strData(1 TO lngTotalRecords)
  '
  LINE INPUT #lngFile, a_strData()
  '
  CLOSE #lngFile
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
FUNCTION funSetProgressText(strData AS STRING) AS LONG
' display message
  GRAPHIC SET POS (15,g_lngGraphicsPosition)
  GRAPHIC PRINT LEFT$(strData & SPACE$(60),60)
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
  GRAPHIC SET POS (15,400)
  GRAPHIC PRINT "Record " & FORMAT$(lngValue) & " of " FORMAT$(%Max_Records)
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
  '
  LOCAL strString AS STRING
  LOCAL lngR AS LONG
  LOCAL lngFile AS LONG
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
 lngFile = FREEFILE
 OPEN strFileName FOR OUTPUT AS #lngFile
 PRINT #lngFile, strHeader
 '
 g_lngGraphicsPosition = %GraphicsStep
 funBuildArray("FirstName", a_strFirstName(), _
               "firstnames.csv", _
               3, ",")  ' build the first name array
 '
 g_lngGraphicsPosition  += %GraphicsStep
 funBuildArray("Surname", a_strSurnames(), _
               "Surnames.csv", _
               1, ",")  ' build the surname array
 g_lngGraphicsPosition  += %GraphicsStep
 funBuildArray("Streets", a_strStreets(), _
               "Streets.csv", _
               1, ",")  ' build the streets array
 g_lngGraphicsPosition  += %GraphicsStep
 funBuildArray("Cities", a_strCities(), _
               "Cities.csv", _
               1, ",")  ' build the Cities array
 g_lngGraphicsPosition  += %GraphicsStep
 funBuildArray("Eye Colours", a_strEyeColour(), _
               "EyeColour.csv", _
               1, ",")  ' build the Eye Colour array
 g_lngGraphicsPosition  += %GraphicsStep
 funBuildArray("Blood Group", a_strBloodGroup(), _
               "BloodGroups.csv", _
               1, ",")  ' build the Blood Groups array

 FOR lngR = 1 TO %Max_Records
   IF (lngR MOD 1000) = 0 THEN
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
   PRINT #lngFile, strString
 NEXT lngR
 '
 CLOSE #lngFile
 FUNCTION = %TRUE
'
END FUNCTION
