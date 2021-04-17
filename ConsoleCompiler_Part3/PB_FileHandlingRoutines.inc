' PB_FileHandlingRoutines.inc

FUNCTION funParseFind(strHeaders AS STRING ,strDelimeter AS STRING _
                     ,strColumnName AS STRING) AS LONG
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
      CON.STDOUT "Number of records = " & FORMAT$(lngCount)
      '
      LINE INPUT #lngFile, strHeaders
      '
      funAppendToFile(strOutputFile, strHeaders)
      '
      lngColumnNumber = funParseFind(strHeaders,$TAB,strColumnName)
      '
      CON.STDOUT "Columns = " & FORMAT$(PARSECOUNT(strHeaders,$TAB))
      '
      WHILE NOT EOF(#lngFile)
        LINE INPUT #lngFile, strData
        '
        IF PARSE$(strData,$TAB,lngColumnNumber) = strValue THEN
          IF ISFALSE funAppendToFile(strOutputFile, strData) THEN
            CON.STDOUT "Failed to output to file"
          ELSE
            CON.STDOUT "Record written"
          END IF
        END IF
        '
      WEND
      '
      FUNCTION = %TRUE
      '
    CATCH
      CON.STDOUT ERROR$
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
      CON.STDOUT "Number of records = " & FORMAT$(lngCount)

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
        CON.STDOUT strForename & " " & strSurname
        CON.STDOUT strAddress
        CON.STDOUT strTelephone
        CON.STDOUT ""
      WEND
      '
      FUNCTION = %TRUE
    CATCH
      CON.STDOUT ERROR$
      FUNCTION = %FALSE
    FINALLY
      CLOSE #lngFile
    END TRY
    '
  END IF

END FUNCTION
'
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
