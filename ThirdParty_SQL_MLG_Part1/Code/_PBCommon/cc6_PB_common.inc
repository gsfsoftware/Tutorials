'
' Post cc5 PB_common.inc

FUNCTION funAppendToFile(strFilePathToAddTo AS STRING, strData AS STRING) AS LONG
' append strData to the file if it exists or create a new one if it doesn't
  DIM intFile AS INTEGER
  DIM strError AS STRING
  '
  intFile = FREEFILE
  TRY
   IF ISTRUE ISFILE(strFilePathToAddTo) THEN
      OPEN strFilePathToAddTo FOR APPEND LOCK SHARED AS #intFile
    ELSE
      OPEN strFilePathToAddTo FOR OUTPUT AS #intFile
    END IF
    '
    PRINT #intFile, strData
    '
    FUNCTION = %TRUE
  CATCH
    strError = ERROR$   ' trap error for debug purposes
    FUNCTION = %FALSE
  FINALLY
    CLOSE #intfile
  END TRY
  '
END FUNCTION
'
MACRO macDialogToPixels(hDlg , x, y)
  LOCAL xx&, yy&
  DIALOG UNITS hDlg, x, y TO PIXELS yy&, xx&
END MACRO
'
FUNCTION funFileAsString(strFile AS STRING) AS STRING
' return a file as a string
  DIM intFile AS INTEGER
  DIM strWork AS STRING
  DIM strFileString AS STRING
  '
  TRY
    intFile = FREEFILE
    OPEN strFile FOR INPUT LOCK SHARED AS #intFile
    WHILE NOT EOF(intFile)
      LINE INPUT #intFile, strWork
      strFileString = strFileString & strWork & $CRLF
    WEND
    strFileString = RTRIM$(strFileString,$CRLF) ' trim the last $CRLF
    FUNCTION = strFileString
  CATCH
    FUNCTION = ""
  FINALLY
    CLOSE #intFile
  END TRY
  '
END FUNCTION

FUNCTION funRemoveNull(strString AS STRING) AS STRING
' this function looks at a string and removes any nulls in it
  FUNCTION = REMOVE$(strString,CHR$(0))
END FUNCTION
'
FUNCTION SendStringToDiskAtLocation(strString AS STRING, strLocation AS STRING)AS LONG
  ' send the specified string to disk to the specified location
  DIM lngFile AS LONG
  '
  TRY
    KILL strLocation
  CATCH
  FINALLY
  END TRY
  '
  TRY
    lngFile = FREEFILE
    OPEN strLocation FOR OUTPUT AS #lngFile
    PRINT#lngFile, strString
    FUNCTION = %TRUE
  CATCH
    FUNCTION = %FALSE
  FINALLY
    CLOSE #lngFile
  END TRY
  '
END FUNCTION
'
FUNCTION funBinaryStringSaveAsFile(strFile AS STRING, strData AS STRING) AS LONG
  DIM lngFile AS LONG
  lngFile = FREEFILE
  TRY
    OPEN strFile FOR BINARY LOCK SHARED AS #lngFile
    PUT$ #lngFile, strData
    FUNCTION = %TRUE
  CATCH
    FUNCTION = %FALSE
  FINALLY
    CLOSE #lngFile
  END TRY
END FUNCTION
'
FUNCTION funBinaryFileAsString(strFile AS STRING) AS STRING
' return a file as a string
  DIM lngFile AS LONG
  DIM strFileString AS STRING
  DIM lngSize AS LONG
  '
  TRY
    lngFile = FREEFILE
    OPEN strFile FOR BINARY LOCK SHARED AS #lngFile
    lngSize = LOF(lngFile)
    GET$ lngFile, lngSize, strFileString
    '
    FUNCTION = strFileString
  CATCH
    FUNCTION = ""
  FINALLY
    CLOSE #lngFile
  END TRY
  '
END FUNCTION
'
FUNCTION funUser() AS STRING
' return the NT user
  LOCAL zName     AS ASCIIZ * %UNLEN + 1
  GetUserName zName, SIZEOF(zName)
  FUNCTION = zName
END FUNCTION
'
FUNCTION funUnReverseDate(strDate AS STRING) AS STRING
  ' return the date as dd/mm/yyyy where input is in form YYYYMMDD
  FUNCTION = RIGHT$(strDate,2) & "/" & MID$(strDate,5,2) & "/" & LEFT$(strDate,4)
END FUNCTION
'
FUNCTION funReverseDate(strDate AS STRING) AS STRING
' return the date as YYYYMMDD where input is in form DD/MM/YYYY
  FUNCTION = RIGHT$(strDate,4) & MID$(strDate, 4,2) & LEFT$(strDate,2)
'
END FUNCTION
'
FUNCTION funUKTime AS STRING
' return the time as hhmmss
  DIM strTime AS STRING
  '
  strTime = TIME$
  '
  FUNCTION = LEFT$(strTime,2) & MID$(strTime,4,2) & RIGHT$(strTime,2)
'
END FUNCTION
'
FUNCTION funUKDate AS STRING
' return the current date in dd/mm/yyyy format
  DIM strDate AS STRING
  '
  strDate= DATE$
  '
  FUNCTION = MID$(strDate,4,2) & "/" & LEFT$(strDate,2) & "/" & RIGHT$(strDate,4)
END FUNCTION
'
FUNCTION funLongMonthName(strMonthNumber AS STRING) AS STRING
' return month name
  '
  DIM intMonthNumber AS INTEGER
  '
  intMonthNumber = VAL(strMonthNumber)
  '
  SELECT CASE intMonthNumber
    CASE 1
      FUNCTION = "January"
    CASE 2
      FUNCTION = "February"
    CASE 3
      FUNCTION = "March"
    CASE 4
      FUNCTION = "April"
    CASE 5
      FUNCTION = "May"
    CASE 6
      FUNCTION = "June"
    CASE 7
      FUNCTION = "July"
    CASE 8
      FUNCTION = "August"
    CASE 9
      FUNCTION = "September"
    CASE 10
      FUNCTION = "October"
    CASE 11
      FUNCTION = "November"
    CASE 12
      FUNCTION = "December"
    CASE ELSE
      FUNCTION = ""
    END SELECT
    '
END FUNCTION
'
FUNCTION funLongMonthNumber(strMonthName AS STRING) AS STRING
' return the long month number given the month name
  SELECT CASE strMonthName
    CASE "January"
      FUNCTION = "01"
    CASE "February"
      FUNCTION = "02"
    CASE "March"
      FUNCTION = "03"
    CASE "April"
      FUNCTION = "04"
    CASE "May"
      FUNCTION = "05"
    CASE "June"
      FUNCTION = "06"
    CASE "July"
      FUNCTION = "07"
    CASE "August"
      FUNCTION = "08"
    CASE "September"
      FUNCTION = "09"
    CASE "October"
      FUNCTION = "10"
    CASE "November"
      FUNCTION = "11"
    CASE "December"
      FUNCTION = "12"
    CASE ELSE
      FUNCTION = "0"
  END SELECT
'
END FUNCTION
'
FUNCTION funShortMonthNumber(strMonthName AS STRING) AS STRING
' return the short month number given the month name
  SELECT CASE strMonthName
    CASE "Jan"
      FUNCTION = "01"
    CASE "Feb"
      FUNCTION = "02"
    CASE "Mar"
      FUNCTION = "03"
    CASE "Apr"
      FUNCTION = "04"
    CASE "May"
      FUNCTION = "05"
    CASE "Jun"
      FUNCTION = "06"
    CASE "Jul"
      FUNCTION = "07"
    CASE "Aug"
      FUNCTION = "08"
    CASE "Sep"
      FUNCTION = "09"
    CASE "Oct"
      FUNCTION = "10"
    CASE "Nov"
      FUNCTION = "11"
    CASE "Dec"
      FUNCTION = "12"
    CASE ELSE
      FUNCTION = "0"
  END SELECT
'
END FUNCTION
'
FUNCTION funMonthNumber() AS STRING
' return the month number of current date
  FUNCTION = MID$(funUKDate(),4,2)
END FUNCTION
'
FUNCTION funShortMonthName(strMonthNumber AS STRING) AS STRING
' return the short month name for the month number given
  DIM intMonthNumber AS INTEGER
  '
  intMonthNumber = VAL(strMonthNumber)
  '
  SELECT CASE intMonthNumber
    CASE 1
      FUNCTION = "Jan"
    CASE 2
      FUNCTION = "Feb"
    CASE 3
      FUNCTION = "Mar"
    CASE 4
      FUNCTION = "Apr"
    CASE 5
      FUNCTION = "May"
    CASE 6
      FUNCTION = "Jun"
    CASE 7
      FUNCTION = "Jul"
    CASE 8
      FUNCTION = "Aug"
    CASE 9
      FUNCTION = "Sep"
    CASE 10
      FUNCTION = "Oct"
    CASE 11
      FUNCTION = "Nov"
    CASE 12
      FUNCTION = "Dec"
    CASE ELSE
      FUNCTION = ""
    END SELECT
    '
END FUNCTION
'
FUNCTION funLongUKDate() AS STRING
' return the date as 2003Jul10
  DIM strDate AS STRING
  '
  strDate = DATE$
  FUNCTION = MID$(strDate,4,2) & " " & funShortMonthName(MID$(strDate,1,2)) & " " & RIGHT$(strDate,4)
'
END FUNCTION
'
FUNCTION funStandardDate(strDate AS STRING) AS STRING
' return 01 Jun 2007 where strDate = 01/06/2007
  FUNCTION = LEFT$(strDate,3) & funShortMonthName(MID$(strDate,4,2)) & RIGHT$(strDate,5)
'
END FUNCTION
'
'
FUNCTION funReverseLongUKDate AS STRING
' return the date as 2003Jul10
  DIM strDate AS STRING
  '
  strDate = DATE$
  FUNCTION = RIGHT$(strDate,4) & funShortMonthName(MID$(strDate,1,2)) & MID$(strDate,4,2)
'
END FUNCTION
'
FUNCTION funReverseDateAsNumber(strDate AS STRING) AS STRING
' given the date as dd/mm/yyyy return yyyymmdd
  FUNCTION = RIGHT$(strDate,4) & MID$(strDate,4,2) & LEFT$(strDate,2)
'
END FUNCTION
'
FUNCTION funReverseGivenUKDate(strDate AS STRING) AS STRING
' return the given date in yyyy/mm/dd format
  '
  FUNCTION =   RIGHT$(strDate,4) & "/" & MID$(strDate,4,2) & "/" & LEFT$(strDate,2)
'
END FUNCTION
'
FUNCTION funReverseUKDate AS STRING
' return the current date in yyyy/mm/dd format
  DIM strDate AS STRING
  '
  strDate= DATE$
  '
  FUNCTION = funReverseGivenUKDate(strDate)

END FUNCTION

'
FUNCTION FileNam (BYVAL Src AS STRING) AS STRING
  LOCAL x AS LONG

  x = INSTR(-1, Src, ANY ":/\")
  IF x THEN
      FUNCTION = MID$(Src, x + 1)
  ELSE
      FUNCTION = Src
  END IF

END FUNCTION
'
#IF %DEF(%PB_CC32)
FUNCTION funExitApp() AS LONG
' exit the application
'
  DIM strText AS STRING
  DIM strI AS STRING
  DIM lngExit AS LONG
  DIM lngWait AS LONG
  '
    strText = "All Operations completed " & funUKDate & " " & TIME$
    STDOUT strText
    STDOUT "Press any key to exit"
    '
    WHILE ISFALSE lngExit
      strI = INKEY$
      IF LEN(strI) <> 0 THEN
        lngExit = %TRUE
      ELSE
        SLEEP 500
        INCR lngWait
        '
        IF lngWait > 20 THEN
        ' been waiting more that 10 seconds
        ' so exit
          lngExit = %TRUE
        ELSE
          STDOUT ".";
        END IF
        '
      END IF
    WEND
END FUNCTION
#ENDIF
'
FUNCTION funFileAsStringArray(BYVAL strFile AS STRING, BYREF o_aWork() AS STRING) AS LONG
' read a file and return as a string array
  '
  DIM lngFile AS LONG
  DIM lngCount AS LONG
  '
  lngFile = FREEFILE
  '
  IF ISTRUE ISFILE(strFile) THEN
    TRY
      OPEN strFile FOR INPUT LOCK SHARED AS #lngFile
      FILESCAN #lngFile, RECORDS TO lngCount
      REDIM o_aWork(1 TO lngCount) AS STRING
      LINE INPUT #lngFile, o_aWork() TO lngCount
      FUNCTION = %TRUE
    CATCH
      FUNCTION = %FALSE
    FINALLY
      CLOSE #lngFile
    END TRY
    '
  ELSE
    FUNCTION = %FALSE
  END IF
'
END FUNCTION
'
FUNCTION ArrayDump(strFile AS STRING, a_work() AS STRING) AS LONG
' dump the array to disk - as long as its single dimension and a string
  DIM intFile AS INTEGER
  DIM lngR AS LONG
  '
  TRY
    '
    ' ensure that the folder structure already exists
    IF ISFALSE funCreateFolders(FilePath(strFile)) THEN
      FUNCTION = %FALSE
      EXIT FUNCTION
    END IF
    '
    intFile = FREEFILE
    OPEN strFile FOR OUTPUT AS #intFile
    FOR lngR = LBOUND(a_work) TO UBOUND(a_work)
      PRINT #intFile, a_work(lngR)
    NEXT lngR
    '
    FUNCTION = %TRUE

  CATCH
    FUNCTION = %FALSE

  FINALLY
    CLOSE #intFile
  END TRY
    '
END FUNCTION
'
FUNCTION funCreateFolders (strFile AS STRING) AS INTEGER
  DIM strFilePart AS STRING
  DIM intPartCount AS INTEGER
  DIM strPath AS STRING
  DIM lngStartColumn AS LONG
  '
  IF LEFT$(strFile,2)="\\" THEN
  ' Handle the UNC paths
  '"\\pvcs\PVCSDATA$\ABC"
    lngStartColumn = 5
  ELSE
  '"C:\TEST\ABC"
    lngStartColumn = 2
  END IF
  '
  TRY
  '
    FOR intPartCount = lngStartColumn TO PARSECOUNT(strfile,ANY "\/")
    ' get each folder by name
      strFilePart = PARSE$(strFile,ANY "\/",intPartCount)
      '
      strPath = funAddPaths(strFile,intPartCount)
      IF ISFALSE ISFOLDER(strPath) THEN
      ' folder structure needs to be created
        MKDIR strPath
      END IF
      '
    NEXT intPartCount
    '
    FUNCTION = %TRUE
  CATCH
    FUNCTION = %FALSE
  FINALLY
  END TRY
  '
END FUNCTION
'
FUNCTION funAddPaths(strFile AS STRING,intCount AS INTEGER) AS STRING
' add the paths together
  DIM intR AS INTEGER
  DIM strPath AS STRING
  '
  strPath = PARSE$(strfile,ANY "\/",1)
  FOR intR = 2 TO intCount
    strPath = strPath & "\" & PARSE$(strFile,ANY "\/",intR)
  NEXT intR
  '
  FUNCTION = strPath
'
END FUNCTION
'
FUNCTION FilePath (BYVAL Src AS STRING) AS STRING
  LOCAL x AS LONG

  x = INSTR(-1, Src, ANY ":\/")
  IF x THEN FUNCTION = LEFT$(Src, x)

END FUNCTION
'
FUNCTION funPath2UNC (BYVAL InputPath AS STRING) AS STRING
' take an input path and return the UNC version of this
  DIM uni AS UNIVERSAL_NAME_INFO PTR
  DIM az AS ASCIIZ * 1024
  DIM r&
  uni = VARPTR(az)
  '
  WNetGetUniversalName BYVAL STRPTR(InputPath), %UNIVERSAL_NAME_INFO_LEVEL, BYVAL uni, 1024 TO r&
  FUNCTION = @uni.@lpUniversalName
END FUNCTION
'
FUNCTION funTempDirectory() AS STRING
  LOCAL zText AS ASCIIZ * 256
  GetTempPath 256, zText
  FUNCTION = zText
END FUNCTION
'
FUNCTION SystemDirectory () AS STRING
  LOCAL zText AS ASCIIZ * 256
  GetSystemDirectory zText, 256
  FUNCTION = zText
END FUNCTION
'
FUNCTION WindowsDirectory () AS STRING
  LOCAL zText AS ASCIIZ * 256
  GetWindowsDirectory zText, 256
  FUNCTION = zText
END FUNCTION
'
FUNCTION funStartRangeParse(strString AS STRING, strDelimeter AS STRING,lngEndElement AS LONG) AS STRING
' return the range of elements
  DIM strData AS STRING
  DIM lngR AS LONG
  '
  strData = ""
  FOR lngR = 1 TO lngEndElement
    strData = strData & PARSE$(strString,strDelimeter,lngR) & strDelimeter
  NEXT lngR
  '
  FUNCTION = strData
END FUNCTION
'
FUNCTION funMidRangeParse(strString AS STRING, strDelimeter AS STRING,lngStartElement AS LONG,lngEndElement AS LONG) AS STRING
' return the range of elements
  DIM strData AS STRING
  DIM lngR AS LONG
  '
  strData = strDelimeter
  FOR lngR = lngStartElement TO lngEndElement
    strData = strData & PARSE$(strString,strDelimeter,lngR) & strDelimeter
  NEXT lngR
  '
  strData = RTRIM$(strData,strDelimeter)
  FUNCTION = strData
END FUNCTION
'
FUNCTION funEndRangeParse(strString AS STRING, strDelimeter AS STRING,lngStartElement AS LONG) AS STRING
' return the range of elements
  DIM strData AS STRING
  DIM lngR AS LONG
  '
  strData = strDelimeter
  FOR lngR = lngStartElement TO PARSECOUNT(strString, strDelimeter)
    strData = strData & PARSE$(strString,strDelimeter,lngR) & strDelimeter
  NEXT lngR
  '
  strData = RTRIM$(strData,strDelimeter)
  FUNCTION = strData
END FUNCTION
'
FUNCTION funParseFind(strString AS STRING, strDelimeter AS STRING, strSearchCriteria AS STRING) AS LONG
' return the position in a delimeted string that a target exists in - returning 0 in not in the string
  DIM lngR AS LONG
  '
  TRY
    FOR lngR = 1 TO PARSECOUNT(strString, strDelimeter)
      IF PARSE$(strString,strDelimeter,lngR) = strSearchCriteria THEN
        FUNCTION = lngR
        EXIT FUNCTION
      END IF
    NEXT lngR
    '
    FUNCTION = 0
  CATCH
    FUNCTION = 0
  FINALLY
  END TRY
'
END FUNCTION
'
FUNCTION funParsePut(strString AS STRING, strDelimeter AS STRING, lngElement AS LONG, strValue AS STRING) AS STRING
' attempt to slot strValue into strString as the element location
' returning updated value of strString
'
  DIM strBefore AS STRING
  DIM strAfter AS STRING
  '
  IF PARSECOUNT(strString,strDelimeter)< lngElement THEN
    FUNCTION = strString
    EXIT FUNCTION
  END IF
  '
  strBefore = funStartRangeParse(strString,strDelimeter,lngElement - 1)
  strAfter = funEndRangeParse(strString,strDelimeter,lngElement + 1)
  '
  FUNCTION = strBefore & strValue & strAfter
  '
END FUNCTION
'
'#IF NOT %DEF(%PB_CC32)
'MACRO macDialogToPixels(hDlg , x, y)
'  LOCAL xx&, yy&
'  DIALOG UNITS hDlg, x, y TO PIXELS yy&, xx&
'END MACRO
'#ENDIF
