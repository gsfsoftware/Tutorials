#COMPILE EXE
#DIM ALL
#IF %DEF(%PB_CC32)
  #CONSOLE OFF
#ENDIF

%TRUE = -1
%FALSE = 0
%Max_Records = 2000    ' number of record to create
%GraphicsStep = 30     ' gap between text lines on graphics window
'
GLOBAL g_hWin AS DWORD                 ' the handle for the graphics window
GLOBAL g_dwFont AS DWORD               ' font handle
GLOBAL g_dStart AS DOUBLE              ' start time
GLOBAL g_lngGraphicsPosition AS LONG   ' used to position graphics on dialog

#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"
#INCLUDE "..\Libraries\PB_RandomRoutines.inc"

$OutputFile = "UserFile.sql"


FUNCTION PBMAIN () AS LONG
  '
  RANDOMIZE TIMER
  '
  FONT NEW "Courier New",18,0,1,0,0 TO g_dwFont
  funBuildGraphicsWindow()   ' create a graphics window
  '
  IF ISTRUE funGenerateFile($OutputFile) THEN
    g_lngGraphicsPosition  += %GraphicsStep
    funSetProgressText("File Generated successfully")
  ELSE
    g_lngGraphicsPosition  += %GraphicsStep
    funSetProgressText("File not Generated")
  END IF
  '
  SLEEP 1000
  g_lngGraphicsPosition  += %GraphicsStep
  funSetProgressText("Exiting in 2 seconds")
  SLEEP 2000
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
FUNCTION funGenerateFile(strFileName AS STRING) AS LONG
' generate the file
  LOCAL strHeader AS STRING
  LOCAL strData AS STRING
  DIM a_strFirstName() AS STRING
  DIM a_strSurnames() AS STRING
  DIM a_strCities() AS STRING
  DIM a_strStreets() AS STRING
  DIM a_strJobTitles() AS STRING
  DIM a_strDepartments() AS STRING
  '
  LOCAL strFirstName AS STRING
  LOCAL strSurname AS STRING
  LOCAL strDOB AS STRING
  '
  LOCAL strDepartment AS STRING
  LOCAL strJobTitle AS STRING
  LOCAL strCity AS STRING
  '
  LOCAL strString AS STRING
  LOCAL lngR AS LONG
  '
  g_dStart = TIMER  ' pick up the start time
  RANDOMIZE TIMER
  '
  strHeader = "Active,FirstName,Surname,DOB,JobTitle,Department," & _
              "street,city,postcode," & _
              "Telephone,Email,Age"
              '
 TRY
   KILL strFileName
 CATCH
 FINALLY
 END TRY
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
               '
 g_lngGraphicsPosition  += %GraphicsStep
 funBuildArray("Streets", a_strStreets(), _
               "Streets.csv", _
               1, ",")  ' build the streets array
               '
 g_lngGraphicsPosition  += %GraphicsStep
 funBuildArray("Cities", a_strCities(), _
               "Cities.csv", _
               1, ",")  ' build the Cities array
               '
 g_lngGraphicsPosition  += %GraphicsStep
 funBuildArray("Departments", a_strDepartments(), _
               "Departments.csv", _
               1, ",")
               '
 g_lngGraphicsPosition  += %GraphicsStep
 funBuildArray("Job titles", a_strJobTitles(), _
               "JobTitle.csv", _
               1, ",")'
 '
 ' direct write
 '----------------------
 LOCAL lngFile AS LONG
 lngFile = FREEFILE
 OPEN strFileName FOR OUTPUT AS #lngFile
 '----------------------
 '
 FOR lngR = 1 TO %Max_Records  ' number of records
   funSetProgressBar(lngR)
   '
   strFirstName = MCASE$(funGetArrayValue(a_strFirstName()))
   strSurname = MCASE$(funGetArrayValue(a_strSurnames()))
   strDOB = funGenerateDOB()
   strDepartment = funGetArrayValue(a_strDepartments())
   strJobtitle =  funGetArrayValue(a_strJobTitles())
   strCity = funGetArrayValue(a_strCities())

   '
   strString = "Insert into dbo.tbl_UserList" & $CRLF & _
               "(" & strHeader & ")" & $CRLF & _
               "Values(" & _
               "1," & _
               $SQ & strFirstName & $SQ & "," & _
               $SQ & funEscapeApostrophe(strSurname) & $SQ & "," & _
               $SQ & strDOB & $SQ & "," & _
               $SQ & strJobtitle & $SQ & "," & _
               $SQ & strDepartment & $SQ & "," & _
               $SQ & funStreetNumber() & " " & funGetArrayValue(a_strStreets()) & $SQ & "," & _
               $SQ & strCity & $SQ & "," & _
               $SQ & funGeneratePostCode(strCity) & $SQ & "," & _
               $SQ & funGetTelephone & $SQ & "," & _
               $SQ & funEscapeApostrophe(funGetEmail(strFirstName & " " & strSurname)) & $SQ & "," & _
               funGetAge(strDOB) & ")" & $CRLF & "GO" & $CRLF
   '
   '
   ' direct write
   '-------------
   PRINT #lngFile, strString
   '-------------
 NEXT lngR
 '
 ' direct write
 '-------------
 CLOSE #lngFile
 '-------------
 '
 LOCAL TimeNow AS DOUBLE
 LOCAL Seconds AS DOUBLE
 TimeNow = TIMER
 seconds = TimeNow - g_dStart
 g_lngGraphicsPosition += %GraphicsStep
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
  GRAPHIC SET POS (15,400)
  GRAPHIC PRINT "Record " & FORMAT$(lngValue) & " of " FORMAT$(%Max_Records)
  '
END FUNCTION
'
FUNCTION funEscapeApostrophe(BYVAL strData AS STRING) AS STRING
  ' Handle single ' in sql strings
  REPLACE "'" WITH "''" IN strData
  FUNCTION = strData
END FUNCTION
'
