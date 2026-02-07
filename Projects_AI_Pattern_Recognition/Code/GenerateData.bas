#COMPILE EXE
#DIM ALL

'
#IF %DEF(%PB_CC32)
' turn off the console if running console compiler
  #CONSOLE OFF
#ENDIF
'
%TRUE = -1
%FALSE = 0
%Max_Records = 1500
'
GLOBAL g_hWin AS DWORD    ' the handle for the graphics window
GLOBAL g_dwFont AS DWORD  ' font handle
GLOBAL g_dStart AS DOUBLE ' start time
'
#INCLUDE "PB_FileHandlingRoutines.inc"
#INCLUDE "PB_RandomRoutines.inc"
'  ' set name of the output file
$OutputFile = "RandomDataFile.csv"
'
FUNCTION PBMAIN () AS LONG
' build a graphics output window
  FONT NEW "Courier New",18,0,1,0,0 TO g_dwFont
  '
  funBuildGraphicsWindow()
  '
  ' generate and save the output data
  IF ISTRUE funGenerateFile($OutputFile) THEN
    funSetProgressText("File Generated successfully")
  ELSE
    funSetProgressText("File not Generated")
  END IF
  '
  funSetProgressText("Exiting in 10 seconds")
  SLEEP 10000
  '
  FONT END g_dwFont
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
FUNCTION funGenerateFile(strFileName AS STRING) AS LONG
' generate the file
  LOCAL strHeader AS STRING
  LOCAL strData AS STRING
  DIM a_strFirstName() AS STRING  ' arrays to hold
  DIM a_strSurnames() AS STRING   ' the seed data
  DIM a_strSites() AS STRING      '
  DIM a_strAssets() AS STRING     '
  '
  LOCAL strUserName AS STRING     ' users full name
  '
  LOCAL strDateOpened AS STRING   ' date of call opened
  LOCAL strTimeOpened AS STRING   ' time of call opened
  LOCAL strDayOpened AS STRING    ' day of week opened
  '
  LOCAL strDateClosed AS STRING   ' date of call closed
  LOCAL strTimeClosed AS STRING   ' time of call closed
  LOCAL strDayClosed AS STRING    ' day of week closed
  '
  LOCAL strAsset AS STRING        ' Type of asset affected
  '
  LOCAL strSeedDate AS STRING     ' date to start process at
  LOCAL strDateFormat AS STRING   ' UK/US format
  LOCAL strString AS STRING       ' string to write to CSV
  LOCAL lngDays AS LONG           ' max number of days to advance
  LOCAL lngR AS LONG
  '
  strDateFormat = "UK"       ' change to US if required
  strSeedDate = "01/01/2025" ' date to start processing at
  '
  g_dStart = TIMER  ' pick up the start time
  RANDOMIZE TIMER
  '
  strHeader = $DQ & "Date Opened" & $QCQ & _
              "Time Opened" & $QCQ & _
              "User Name" & $QCQ & _
              "User ID" & $QCQ & _
              "Site" & $QCQ & _
              "Date Closed" & $QCQ & _
              "Time Closed" & $QCQ & _
              "Asset" & $DQ
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
  funBuildArray("Sites", a_strSites(), _
                "Sites.csv", _
                1, ",")  ' build the streets array
  funBuildArray("Assets", a_strAssets(), _
                "Assets.csv", _
                1,",")  ' build the Cities array
                '
                '
  lngDays = 0   ' start with zero days advance
  '
  FOR lngR = 1 TO %Max_Records  ' number of records
    funSetProgressBar(lngR)
    '
    ' pick a day between 0 and 90 days ahead
    lngDays = RND(0,90)
    '
    ' get the start of the incident
    strDateOpened = funGetDate(strSeedDate, _
                               strDateFormat, _
                               lngDays)
    strTimeOpened = funGetTime()
    '
    ' pick a day between 0 and 5 days ahead
    lngDays = RND(0,5)
    '
    ' pick a day between 0 and 5 days ahead
    lngDays = RND(0,5)
    strDateClosed = funGetDate(strDateOpened, _
                               strDateFormat, _
                               lngDays) ' get the end date
    strTimeClosed = funGetTime(strTimeOpened)
    '
    strUserName = funGetArrayValue(a_strFirstName()) & " " & _
                  MCASE$(funGetArrayValue(a_strSurnames()))
                  '
    strString = $DQ & strDateOpened & $QCQ & strTimeOpened & $QCQ & _
                strUserName & $QCQ & _
                funGetUserID(strUserName) & $QCQ & _
                funGetArrayValue(a_strSites()) & $QCQ & _
                strDateClosed & $QCQ & _
                strTimeClosed & $QCQ & _
                funGetArrayValue(a_strAssets()) &$DQ
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
