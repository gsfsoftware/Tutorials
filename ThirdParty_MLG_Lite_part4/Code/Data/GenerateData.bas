#COMPILE EXE
#DIM ALL
#IF %DEF(%PB_CC32)
  #CONSOLE OFF
#ENDIF

%TRUE = -1
%FALSE = 0
%Max_Records = 60

GLOBAL g_hWin AS DWORD   ' the handle for the graphics window
GLOBAL g_dwFont AS DWORD ' font handle
GLOBAL g_dStart AS DOUBLE ' start time

#INCLUDE "..\..\Libraries\PB_FileHandlingRoutines.inc"
#INCLUDE "..\..\Libraries\PB_RandomRoutines.inc"

$OutputFile = "DataFile.csv"


FUNCTION PBMAIN () AS LONG
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
  funSetProgressText("Exiting in 5 seconds")
  SLEEP 5000
  '
END FUNCTION
'
FUNCTION funGenerateFile(strFileName AS STRING) AS LONG
' generate the file
  LOCAL strHeader AS STRING
  LOCAL strData AS STRING
  DIM a_strFirstName() AS STRING
  DIM a_strSurnames() AS STRING
  DIM a_strDepts() AS STRING
  DIM a_strDivisions() AS STRING
  '
  LOCAL strFirstName AS STRING
  LOCAL strSurname AS STRING

  LOCAL strString AS STRING
  LOCAL lngR AS LONG
  LOCAL strActive AS STRING
  '
  g_dStart = TIMER  ' pick up the start time
  RANDOMIZE TIMER
  '
  strHeader = $DQ & "ID" & $QCQ & _
              "FirstName" & $QCQ & _
              "Surname" & $QCQ & _
              "Department" & $QCQ & _
              "Division" & $QCQ & _
              "Active" & $DQ
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
 funBuildArray("Department", a_strDepts(), _
               "Departments.csv", _
               1, ",")  ' build the Depts array
 funBuildArray("Division", a_strDivisions(), _
               "Divisions.csv", _
               1, ",")  ' build the Divisions array

 FOR lngR = 1 TO %Max_Records  ' number of records

   funSetProgressBar(lngR)
   '
   strFirstName = funGetArrayValue(a_strFirstName())
   strSurname = MCASE$(funGetArrayValue(a_strSurnames()))
   '
   IF RND(1,10) = 1 THEN
     strActive = ""
   ELSE
     strActive = "1"
   END IF
   '
   strString = $DQ & $DQ & "," & _
               $DQ & strFirstName & $QCQ & _
               strSurname & $QCQ & _
               funGetArrayValue(a_strDepts()) & $QCQ & _
               funGetArrayValue(a_strDivisions()) & $QCQ & _
               strActive & $DQ
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
