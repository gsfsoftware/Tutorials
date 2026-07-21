' PB_RandomAccess_lib.inc
'
' funOpenRandomDB(strDBName AS STRING,lngLength as long)
' - open a random access file
' funCloseRandomDB(lngDBHandle AS LONG)
' - close a random access file
' funGetDBRecordCount(lngDBHandle AS LONG,lngLength AS LONG)
' - determine the number of records in the random access file
' funGetDBRecord(lngDBHandle AS LONG,qRecord AS QUAD,strData AS STRING)
' - return strData as populated UDT
' funSaveDBRecord(lngDBHandle AS LONG,qRecord AS QUAD,strData AS STRING)
' - save a record
'
'
FUNCTION funOpenRandomDB(strDBName AS STRING, _
                         lngLength AS LONG) AS LONG
' opens db and returns file handle
  LOCAL lngFile AS LONG
  '
  lngFile = FREEFILE
  '
  TRY
    OPEN strDBName FOR RANDOM AS #lngFile LEN = lngLength
    FUNCTION = lngFile
  CATCH
    FUNCTION = 0
  FINALLY
  END TRY
  '
END FUNCTION
'
FUNCTION funCloseRandomDB(lngDBHandle AS LONG) AS LONG
' close down the file
  CLOSE #lngDBHandle
END FUNCTION
'
FUNCTION funGetDBRecordCount(lngDBHandle AS LONG, _
                             lngLength AS LONG) AS QUAD
' determine the number of records in the random access file
  LOCAL qSize AS QUAD
  '
  qSize = LOF(lngDBHandle)
  FUNCTION = qSize \ lngLength
  '
END FUNCTION
'
FUNCTION funGetDBRecord(lngDBHandle AS LONG, _
                        qRecord AS QUAD, _
                        strData AS STRING) AS LONG
  ' return strData as populated UDT
  TRY
    GET #lngDBHandle,qRecord,strData
    FUNCTION = %TRUE
    '
  CATCH


  FINALLY
  END TRY
  '
END FUNCTION
'
FUNCTION funSaveDBRecord(lngDBHandle AS LONG, _
                         qRecord AS QUAD, _
                         strData AS STRING) AS LONG
' save a record
  '
  TRY
    PUT #lngDBHandle,qRecord,strData
    '
    FUNCTION = %TRUE
  CATCH
    FUNCTION = %FALSE
  FINALLY
  END TRY
'
END FUNCTION
