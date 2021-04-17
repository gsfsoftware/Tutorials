' PB_FileHandlingRoutines.inc

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
