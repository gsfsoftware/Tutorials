' generate random name data
#COMPILE EXE
#DIM ALL
#IF %DEF(%PB_CC32)
  #CONSOLE OFF
#ENDIF


GLOBAL glngMax_Records AS LONG       ' maximum data records to produce

$OldestDOB = "01/01/1950"  ' the oldest date of birth
$NewestDOB = "01/01/2008"  ' the youngest date of birth

$OutputFile1 = "BigTest_DataFile.csv"
$OutputFile2 = "SmallTest_DataFile.csv"

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
  glngMax_Records = 100000  ' maximum records to produce
  '
  FONT NEW "Courier New",18,0,1,0,0 TO g_dwFont
  funBuildGraphicsWindow()   ' create a graphics window

  ' generate first data file
  IF ISTRUE funGenerateFiles($OutputFile1,$OutputFile2) THEN
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
FUNCTION funGenerateFiles(strFileName1 AS STRING, _
                          strFileName2 AS STRING) AS LONG
' generate the file
  LOCAL strHeader AS STRING
  LOCAL strData AS STRING
  DIM a_strMaleFirstName() AS STRING
  DIM a_strFemaleFirstName() AS STRING
  DIM a_strSurnames() AS STRING
  DIM a_strCities() AS STRING
  DIM a_strStreets() AS STRING
  LOCAL strDate AS STRING
  LOCAL strString AS STRING

  LOCAL lngR AS LONG
  '
  g_dStart = TIMER  ' pick up the start time
  RANDOMIZE TIMER   ' prepare to use random numbers
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
   KILL strFileName1
 CATCH
 FINALLY
 END TRY
 '
 TRY
   KILL strFileName2
 CATCH
 FINALLY
 END TRY

 '
 ' add headers to output files
 funAppendToFile(strFileName1, strHeader)
 funAppendToFile(strFileName2, strHeader)
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
 LOCAL lngFileHandle1 AS LONG
 lngFileHandle1 = FREEFILE
 OPEN strFileName1 FOR APPEND AS #lngFileHandle1
 '
 ' open second file
 LOCAL lngFileHandle2 AS LONG
 lngFileHandle2 = FREEFILE
 OPEN strFileName2 FOR APPEND AS #lngFileHandle2
 '
 FOR lngR = 1 TO glngMax_Records  ' number of records
   funSetProgressBar(lngR)
   '
   strString = funGetRandomData(a_strMaleFirstName(), _
                                a_strFemaleFirstName(), _
                                a_strSurnames(), _
                                a_strStreets(), _
                                a_strCities())
   '
   ' print to first file
   PRINT #lngFileHandle1,strString
   '
   ' now print 10% of records to second file
   IF RND(1,10) = 5 THEN
   ' generate random number 1-10 and if number is 5
   ' then print to second file
     PRINT #lngFileHandle2,strString
   END IF
   '
 NEXT lngR
 '
 ' create 20 more records that won't be in the large file
 '
 LOCAL lngExtraRecords AS LONG
 lngExtraRecords = 20
 '
 FOR lngR = 1 TO 20
   strString = funGetRandomData(a_strMaleFirstName(), _
                                a_strFemaleFirstName(), _
                                a_strSurnames(), _
                                a_strStreets(), _
                                a_strCities())
   '
   ' print to second file
   PRINT #lngFileHandle2,strString
 NEXT lngR
 '
 CLOSE #lngFileHandle1
 CLOSE #lngFileHandle2
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
FUNCTION funGetRandomData(a_strMaleFirstName() AS STRING, _
                          a_strFemaleFirstName() AS STRING, _
                          a_strSurnames() AS STRING, _
                          a_strStreets() AS STRING, _
                          a_strCities() AS STRING) AS STRING
' produce a random record and return as a string
'
  LOCAL strFirstName AS STRING
  LOCAL strSurname AS STRING
  LOCAL strDOB AS STRING
  '
  LOCAL strCity AS STRING
  LOCAL strGender AS STRING
  '
  LOCAL strString AS STRING
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
  FUNCTION = strString
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
  IF lngR > glngMax_Records THEN
    lngValue = glngMax_Records
  ELSE
    lngValue = lngR
  END IF
  '
  lngPercent = (lngValue / glngMax_Records) * 100
  lngPercent = ((lngTop * lngPercent)\100) + lngStart
  GRAPHIC BOX (lngStart,442) - (lngPercent,458),0,%BLACK,%RED,0
  GRAPHIC SET POS (15,400)
  GRAPHIC PRINT "Record " & FORMAT$(lngValue) & " of " FORMAT$(glngMax_Records)
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
