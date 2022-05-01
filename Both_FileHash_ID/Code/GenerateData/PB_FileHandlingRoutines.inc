' PB_FileHandlingRoutines.inc

' funAppendToFile - Append data to the end of an existing file
'                   or create a new file
' funArrayDump    - Save an array to a named file
' funParseFind    - Find a string in a delimited string by column name
' funReadTheFile  - Read a file and output details to the console
' funReadTheFileAndOutput   - Read a file and output to a second file
' funReadTheFileIntoAnArray - Read file into a named array
' funBinaryFileAsString - Read an entire file into a string
' funBinaryStringSaveAsFile - save a string as a binary file
' funReadTheCSVFileIntoAnArray - load a CSV file to a 2 dimensional
'                                array
' funStartRangeParse - Return the range of elements from beginning
'                      of a string
'
FUNCTION funBinaryFileAsString(strFile AS STRING) AS STRING
' return a file as a string
  LOCAL lngFile AS LONG
  LOCAL strFileString AS STRING
  LOCAL lngSize AS LONG
  '
  TRY
    lngFile = FREEFILE
    OPEN strFile FOR BINARY LOCK SHARED AS #lngFile
    lngSize = LOF(lngFile)
    GET$ lngFile, lngSize,strFileString
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
FUNCTION funBinaryStringSaveAsFile(strFile AS STRING, _
                                   strData AS STRING) AS LONG
' save a string to a binary file
  LOCAL lngFile AS LONG
  '
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
  '
END FUNCTION
'
FUNCTION funArrayDump(strFile AS STRING, _
                      BYREF a_strWork() AS STRING) AS LONG
  LOCAL lngFile AS LONG
  LOCAL lngR AS LONG
  '
  lngFile = FREEFILE
  TRY
    OPEN strFile FOR OUTPUT AS #lngFile
    FOR lngR = LBOUND(a_strWork) TO UBOUND(a_strWork)
      PRINT #lngFile, a_strWork(lngR)
    NEXT lngR
    FUNCTION = %TRUE
  CATCH
    FUNCTION = %FALSE
    #IF %DEF(%PB_CC32)
      CON.STDOUT ERROR$
    #ENDIF
  FINALLY
    CLOSE #lngFile
  END TRY
  '
END FUNCTION
'
FUNCTION funReadTheCSVFileIntoAnArray(strFilename AS STRING, _
                               BYREF a_strWork() AS STRING) AS LONG
' read a CSV file into a 2 dimensional array
  LOCAL lngFile AS LONG
  LOCAL lngRecords AS LONG
  LOCAL lngColumns AS LONG
  LOCAL strData AS STRING
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  '
  lngFile = FREEFILE
  TRY
    OPEN strFileName FOR INPUT AS #lngFile
    FILESCAN #lngFile, RECORDS TO lngRecords
    DECR lngRecords ' reduce count by 1
    ' read the header line
    LINE INPUT #lngFile,strData
    '
    lngColumns = PARSECOUNT(strData,"")
    REDIM a_strWork(lngRecords ,lngColumns) AS STRING
    '
    FOR lngR = 0 TO lngRecords
      FOR lngC = 1 TO lngColumns
        a_strWork(lngR,lngC) = PARSE$(strData,"",lngC)
      NEXT lngC
      IF NOT EOF(#lngFile) THEN
        LINE INPUT #lngFile,strData
      END IF
    NEXT lngR
    '
    FUNCTION = %TRUE
  CATCH
    ' error occurred
    FUNCTION = %FALSE
  FINALLY
    CLOSE #lngFile
  END TRY
'
END FUNCTION
'
FUNCTION funReadTheFileIntoAnArray(strFilename AS STRING, _
                                   BYREF a_strWork() AS STRING) AS LONG
' Read the file int an array
  LOCAL lngFile AS LONG
  LOCAL lngRecords AS LONG

  lngFile = FREEFILE
  TRY
    OPEN strFileName FOR INPUT AS #lngFile
    FILESCAN #lngFile, RECORDS TO lngRecords
    REDIM a_strWork(lngRecords - 1) AS STRING
    LINE INPUT #lngFile,a_strWork()
    FUNCTION = %TRUE
  CATCH
    #IF %DEF(%PB_CC32)
      CON.STDOUT ERROR$
    #ENDIF
  FINALLY
    CLOSE #lngFile
  END TRY
  '
END FUNCTION


FUNCTION funParseFind(strHeaders AS STRING ,strDelimeter AS STRING _
                     ,strColumnName AS STRING) AS LONG
' funParseFind - Find a string in a delimited string by column name
  LOCAL lngR AS LONG
  '
  TRY
    FOR lngR = 1 TO PARSECOUNT(strHeaders, strDelimeter)
      IF PARSE$(strHeaders, strDelimeter, lngR) = strColumnName THEN
        FUNCTION = lngR
        EXIT FUNCTION
      END IF
    NEXT lngR
  CATCH
    FUNCTION = 0
  FINALLY
  END TRY
  '
END FUNCTION
'
FUNCTION funReadTheFileAndOutput(strFilename AS STRING, _
                                 strColumnName AS STRING, _
                                 strValue AS STRING, _
                                 strOutputFile AS STRING) AS LONG
' read the file and output to a second file
  LOCAL lngFile AS LONG
  LOCAL lngCount AS LONG
  LOCAL strHeaders AS STRING
  LOCAL strData AS STRING
  LOCAL lngColumnNumber AS LONG
  '
  ' read the file and selectively output to a second file
  IF ISFALSE ISFILE(EXE.PATH$ & strFileName) THEN
    FUNCTION = %FALSE
  ELSE
  '
    TRY
      KILL strOutputFile
    CATCH
    FINALLY
    END TRY
  ' now open the file
    lngFile = FREEFILE
    TRY
      OPEN EXE.PATH$ & strFileName FOR INPUT AS #lngFile
      '
      FILESCAN #lngFile , RECORDS TO lngCount

      #IF %DEF(%PB_CC32)
        CON.STDOUT "Number of records = " & FORMAT$(lngCount)
      #ENDIF
      '
      LINE INPUT #lngFile, strHeaders
      '
      funAppendToFile(strOutputFile, strHeaders)
      '
      lngColumnNumber = funParseFind(strHeaders,$TAB,strColumnName)
      '
      #IF %DEF(%PB_CC32)
        CON.STDOUT "Columns = " & FORMAT$(PARSECOUNT(strHeaders,$TAB))
      #ENDIF
      '
      WHILE NOT EOF(#lngFile)
        LINE INPUT #lngFile, strData
        '
        IF PARSE$(strData,$TAB,lngColumnNumber) = strValue THEN
          IF ISFALSE funAppendToFile(strOutputFile, strData) THEN
            #IF %DEF(%PB_CC32)
              CON.STDOUT "Failed to output to file"
            #ENDIF
          ELSE
            #IF %DEF(%PB_CC32)
              CON.STDOUT "Record written"
            #ENDIF
          END IF
        END IF
        '
      WEND
      '
      FUNCTION = %TRUE
      '
    CATCH
      #IF %DEF(%PB_CC32)
        CON.STDOUT ERROR$
      #ENDIF
      FUNCTION = %FALSE
    FINALLY
      CLOSE #lngFile
    END TRY
  END IF
'
END FUNCTION

FUNCTION funReadTheFile(strFilename AS STRING) AS LONG
  '
  LOCAL lngFile AS LONG
  LOCAL strData AS STRING
  LOCAL strHeaders AS STRING
  LOCAL strSurname AS STRING
  LOCAL strForeName AS STRING
  LOCAL strAddress AS STRING
  LOCAL strTelephone AS STRING
  LOCAL lngCount AS LONG
  '
  IF ISFALSE ISFILE(EXE.PATH$ & strFileName) THEN
    FUNCTION = %FALSE
  ELSE
  ' now open the file
    lngFile = FREEFILE
    TRY
      OPEN EXE.PATH$ & strFileName FOR INPUT AS #lngFile
      '
      FILESCAN #lngFile , RECORDS TO lngCount
      '
      #IF %DEF(%PB_CC32)
        CON.STDOUT "Number of records = " & FORMAT$(lngCount)
      #ENDIF

      '
      LINE INPUT #lngFile, strHeaders
      '
      WHILE NOT EOF(#lngFile)
        LINE INPUT #lngFile, strData
        '
        strForeName = PARSE$(strData,$TAB,1)
        strSurname = PARSE$(strData,$TAB,2)
        strAddress = PARSE$(strData,$TAB,3)
        strAddress = REMOVE$(strAddress,$DQ)
        strTelephone = PARSE$(strData,$TAB,4)
        strTelephone = REMOVE$(strTelephone," ")
        '
        #IF %DEF(%PB_CC32)
          CON.STDOUT strForename & " " & strSurname
          CON.STDOUT strAddress
          CON.STDOUT strTelephone
          CON.STDOUT ""
        #ENDIF
      WEND
      '
      FUNCTION = %TRUE
    CATCH
      #IF %DEF(%PB_CC32)
        CON.STDOUT ERROR$
      #ENDIF
      FUNCTION = %FALSE
    FINALLY
      CLOSE #lngFile
    END TRY
    '
  END IF

END FUNCTION
'
FUNCTION funAppendToFile(strFilePathToAddTo AS STRING, _
                         strData AS STRING) AS LONG
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
FUNCTION funGetRowCount(strFilename AS STRING) AS LONG
' scan a file and return the number of rows it has
  LOCAL lngFile AS LONG
  LOCAL lngRows AS LONG
  '
  lngFile = FREEFILE
  IF ISTRUE ISFILE(strFilename) THEN
    OPEN strFilename FOR INPUT LOCK SHARED AS #lngFile
    FILESCAN #lngFile, RECORDS TO lngRows
    CLOSE #lngFile
    '
    FUNCTION = lngRows
  ELSE
    FUNCTION = 0
  END IF
  '
END FUNCTION
'
FUNCTION funStartRangeParse(strString AS STRING, _
                            strDelimeter AS STRING, _
                            lngEndElement AS LONG) AS STRING
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
