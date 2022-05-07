' generate random name data
#COMPILE EXE
#DIM ALL
#IF %DEF(%PB_CC32)
  #CONSOLE OFF
#ENDIF


%Max_Records = 1000       ' maximum data records to produce

$OldestDOB = "01/01/1950"  ' the oldest date of birth
$NewestDOB = "01/01/2008"  ' the youngest date of birth

$OutputFile = "Test_DataFile.csv"

GLOBAL g_hWin AS DWORD   ' the handle for the graphics window
GLOBAL g_dwFont AS DWORD ' font handle
GLOBAL g_dStart AS DOUBLE ' start time

#INCLUDE "Win32api.inc"

#INCLUDE "PB_FileHandlingRoutines.inc"
#INCLUDE "PB_RandomRoutines.inc"
#INCLUDE "DateFunctions.inc"
#INCLUDE "PB_DatesExt.inc"
'
FUNCTION PBMAIN () AS LONG
  '
  RANDOMIZE TIMER
  '
  FONT NEW "Courier New",18,0,1,0,0 TO g_dwFont
  funBuildGraphicsWindow()   ' create a graphics window
  '
  IF ISTRUE funGenerateFile($OutputFile) THEN
    funSetProgressText("File Generated successfully")
  ELSE
    funSetProgressText("File not Generated")
  END IF
  '
  funSetProgressText("Exiting in 3 seconds")
  SLEEP 3000
  '
END FUNCTION
'
FUNCTION funSetProgressText(strData AS STRING) AS LONG
 STATIC lngYStart AS LONG
 '
 IF lngYStart = 0 THEN
   lngYStart = 10
 ELSE
   lngYStart = lngYStart + 30
 END IF
 '
 GRAPHIC SET POS (15,lngYStart)
 GRAPHIC PRINT LEFT$(strData & SPACE$(100),100)
END FUNCTION
'
FUNCTION funGenerateFile(strFileName AS STRING) AS LONG
' generate the file
  LOCAL strHeader AS STRING
  LOCAL strData AS STRING
  DIM a_strMaleFirstName() AS STRING
  DIM a_strFemaleFirstName() AS STRING
  DIM a_strSurnames() AS STRING
  DIM a_strCities() AS STRING
  DIM a_strStreets() AS STRING
  LOCAL strDate AS STRING
  '
  LOCAL strFirstName AS STRING
  LOCAL strSurname AS STRING
  LOCAL strDOB AS STRING
  '
  LOCAL strCity AS STRING
  LOCAL strGender AS STRING
  '
  LOCAL strString AS STRING
  LOCAL lngR AS LONG
  '
  g_dStart = TIMER  ' pick up the start time
  RANDOMIZE TIMER
  '
  strHeader = $DQ & "FirstName" & $QCQ & _
                    "Surname" & $QCQ & _
                    "Gender" & $QCQ & _
                    "DOB" & $QCQ & _
                    "Address" & $QCQ & _
                    "City" & $QCQ & _
                    "Region" & $QCQ & _
                    "Postcode" & $QCQ & _
                    "Home Telephone" & $QCQ & _
                    "Email" & $QCQ & _
                    "Age" & $DQ
              '
 TRY
   KILL strFileName
 CATCH
 FINALLY
 END TRY
 '
 funAppendToFile(strFileName, strHeader)
 '
 funBuildArray("Male FirstName", a_strMaleFirstName(), _
               "Male.csv", _
               3, ",")  ' build the first name array
               '
 funBuildArray("Female FirstName", a_strFemaleFirstName(), _
               "Female.csv", _
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
               1, "|")  ' build the Cities array


 '
 LOCAL lngFileHandle AS LONG
 lngFileHandle = FREEFILE
 OPEN strFileName FOR APPEND AS #lngFileHandle
 '
 FOR lngR = 1 TO %Max_Records  ' number of records
   funSetProgressBar(lngR)
   '
   strSurname = MCASE$(funGetArrayValue(a_strSurnames()))
   '
   strCity = funGetArrayValue(a_strCities())
   IF RND(1,2) = 1 THEN
     strGender ="Male"
     strFirstName = MCASE$(funGetArrayValue(a_strMaleFirstName()))
   ELSE
     strGender ="Female"
     strFirstName = MCASE$(funGetArrayValue(a_strFemaleFirstName()))
   END IF
   ' get the DOB & CHI
   strDOB = funGetDOB()
   '
   strString = $DQ & strFirstName & $QCQ & _
                     strSurname & $QCQ & _
                     strGender & $QCQ & _
                     strDOB & $QCQ & _
                     funStreetNumber() & " " & funGetArrayValue(a_strStreets()) & $QCQ & _
                     funCity(strCity) & $QCQ & _
                     funRegion(strCity) & $QCQ & _
                     funGeneratePostCode(strCity) & $QCQ & _
                     funGetTelephone & $QCQ & _
                     funGetEmail(strFirstName & " " & strSurname) & $QCQ & _
                     funGetAge(strDOB) & $DQ

   '
   PRINT #lngFileHandle,strString
 NEXT lngR
 '
 CLOSE #lngFileHandle
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
FUNCTION funCity(strCity AS STRING) AS STRING
  FUNCTION = PARSE$(strCity,"",1)
END FUNCTION
'
FUNCTION funRegion(strCity AS STRING) AS STRING
  FUNCTION = PARSE$(strCity,"",2)
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
FUNCTION funGetDOB() AS STRING
' get the date of birth
  STATIC lngStart AS LONG
  STATIC lngEnd AS LONG
  LOCAL lngDOB AS LONG
  LOCAL strDOB AS STRING
  LOCAL lngGenderMarker AS LONG
  '
  IF lngStart = 0 THEN
  ' determine for first iteration
    lngStart = funGregorianToJdn($OldestDOB)
    lngEnd = funGregorianToJdn($NewestDOB)
  END IF
  '
  lngDOB = RND(lngStart,lngEnd)
  '
  strDOB = funJdnToGregorian(lngDOB)
  '
  FUNCTION = strDOB
'
END FUNCTION
'
