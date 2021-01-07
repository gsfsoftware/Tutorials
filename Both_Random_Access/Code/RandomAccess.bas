#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"

'
TYPE udtCustomers
  FirstName AS STRING * 50
  Surname AS STRING * 50
  Street AS STRING * 100
  City AS STRING * 50
  EyeColour AS STRING * 10
  BloodGroup AS STRING * 25
  Email AS STRING * 150
END TYPE


FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Random Access",0,0,40,120)
  '
  funLog("Random Access")
  '
  LOCAL strDBName AS STRING
  LOCAL lngDBHandle AS LONG
  LOCAL strInputFile AS STRING
  '
  LOCAL qRecord AS QUAD
  LOCAL qTotalRecords AS QUAD
  LOCAL uCustomer AS udtCustomers
  LOCAL strOutput AS STRING
  '
  strDBName = EXE.PATH$ & "dbCustomers.dat"
  '
  TRY
    KILL strDBName
  CATCH
  FINALLY
  END TRY
  '
  lngDBHandle = funOpenRandomDB(strDBName)
  '
  IF lngDBHandle > 0 THEN
  ' now write to the file
    strInputFile = EXE.PATH$ & "Data\MyLargeFile.txt"
    IF ISTRUE funPopulateDB(lngDBHandle,strInputFile) THEN
    ' populated ok
      qTotalRecords = funGetDBRecordCount(lngDBHandle)
      funLog(FORMAT$(qTotalRecords) & " Records in the DB")
      '
      ' read the whole db
      FOR qRecord = 1 TO qTotalRecords
      ' for each record
        IF ISTRUE funGetDBRecord(lngDBHandle, _
                                 qRecord, _
                                 uCustomer) THEN
          ' print the names
          strOutput = SHRINK$(uCustomer.FirstName & " " & _
                              uCustomer.Surname)
          funLog("Rec " & FORMAT$(qRecord) & " = " & strOutput)
        END IF
        '
      NEXT qRecord
      '
      qRecord = 9
      IF ISTRUE funGetDBRecord(lngDBHandle, _
                           qRecord, _
                           uCustomer) THEN
        strOutput = SHRINK$(uCustomer.FirstName & " " & _
                            uCustomer.Surname)
        funLog("Rec " & FORMAT$(qRecord) & " = " & strOutput)
        '
        ' update a record
        uCustomer.FirstName = "Samantha"
        IF ISTRUE funSaveDBRecord(lngDBHandle, _
                                  qRecord, _
                                  uCustomer) THEN
        ' get the record again
          IF ISTRUE funGetDBRecord(lngDBHandle, _
                                   qRecord, _
                                   uCustomer) THEN
            ' print the names
            strOutput = SHRINK$(uCustomer.FirstName & " " & _
                                uCustomer.Surname)
            funLog("Rec " & FORMAT$(qRecord) & " = " & strOutput)
          END IF
        ELSE
          funlog("Could not update")
        END IF
        '
      END IF
    '
    ELSE
      funLog("DB failed populate db")
      '
    END IF
  '
  ' now add a brand new record
    qRecord = 11
    PREFIX "uCustomer."
      FirstName  = "James"
      Surname    = "Smith"
      Street     = "10 Any Old Street"
      City       = "Moon city"
      EyeColour  = "Green"
      BloodGroup = ""
      Email      = ""
    END PREFIX
    '
    IF ISTRUE funSaveDBRecord(lngDBHandle, _
                              qRecord, _
                              uCustomer) THEN
      IF ISTRUE funGetDBRecord(lngDBHandle, _
                               qRecord, _
                               uCustomer) THEN
      ' print the names
        strOutput = SHRINK$(uCustomer.FirstName & " " & _
                            uCustomer.Surname)
        funLog("Rec " & FORMAT$(qRecord) & " = " & strOutput)
      END IF
    END IF
    '
    qTotalRecords = funGetDBRecordCount(lngDBHandle)
    funLog(FORMAT$(qTotalRecords) & " Records in the DB")
    '
    qRecord = 12
    IF ISTRUE funGetDBRecord(lngDBHandle, _
                             qRecord, _
                             uCustomer) THEN
      funLog("Got record")
    ELSE
      funLog("Can't get record " & FORMAT$(qRecord))
    END IF
    '
    ' now close the DB
    funCloseRandomDB(lngDBHandle)
    '
  ELSE
    funLog("DB failed to open")
  END IF
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funCloseRandomDB(lngDBHandle AS LONG) AS LONG
' close down the file
  CLOSE #lngDBHandle
END FUNCTION
'
FUNCTION funSaveDBRecord(lngDBHandle AS LONG, _
                         qRecord AS QUAD, _
                         uCustomer AS udtCustomers) AS LONG
' save a customer record
  TRY
    SEEK #lngDBHandle,qRecord
    PUT #lngDBHandle,qRecord,uCustomer
    '
    FUNCTION = %TRUE
  CATCH
    FUNCTION = %FALSE
  FINALLY
  END TRY
'
END FUNCTION
'
FUNCTION funGetDBRecord(lngDBHandle AS LONG, _
                        qRecord AS QUAD, _
                        uCustomer AS udtCustomers) AS LONG
  LOCAL uTestEmpty AS udtCustomers
' get a customer record
  TRY
    GET #lngDBHandle,qRecord,uCustomer
    ' test to see if we have got back a totally NULL record
    IF uTestEmpty = uCustomer THEN
      FUNCTION = %FALSE
    ELSE
      FUNCTION = %TRUE
    END IF
    '
  CATCH
    FUNCTION = %FALSE
  FINALLY
  END TRY
  '
END FUNCTION
'
FUNCTION funGetDBRecordCount(lngDBHandle AS LONG) AS QUAD
' determine the size of the DB
  LOCAL uCustomer AS udtCustomers
  LOCAL qSize AS QUAD
  '
  qSize = LOF(lngDBHandle)
  FUNCTION = qSize \ LEN(uCustomer)
  '
END FUNCTION
'
FUNCTION funPopulateDB(lngDBHandle AS LONG, _
                       strInputFile AS STRING) AS LONG
' read the input file and put records into the DB file
'
  LOCAL uCustomer AS udtCustomers
  LOCAL lngFile AS LONG
  LOCAL lngTotalRecords AS LONG
  LOCAL lngCount AS LONG
  LOCAL strData AS STRING
  LOCAL strHeaders AS STRING
  LOCAL qRecord AS QUAD
  '
  LOCAL lngFirstName AS LONG
  LOCAL lngSurname AS LONG
  LOCAL lngAddress AS LONG
  LOCAL lngEyeColour AS LONG
  LOCAL lngBloodGroup AS LONG
  LOCAL lngEmail AS LONG
  '
  LOCAL strCity AS STRING
  LOCAL strStreet AS STRING
  '
  lngFile = FREEFILE
  TRY
    OPEN strInputFile FOR INPUT AS #lngFile
    FILESCAN #lngFile, RECORDS TO lngTotalRecords
    '
    FOR lngCount = 1 TO lngTotalRecords
      LINE INPUT #lngFile, strData
      '
      IF lngCount = 1 THEN
        strHeaders = strData
        '
        lngFirstName = funParseFind(strData ,$TAB _
                                 ,"FirstName")
        lngSurname = funParseFind(strData ,$TAB _
                                 ,"Surname")
        lngAddress = funParseFind(strData ,$TAB _
                                 ,"Address")
        lngEyeColour = funParseFind(strData ,$TAB _
                                 ,"Eye Colour")
        lngBloodGroup = funParseFind(strData ,$TAB _
                                 ,"Blood Group")
        lngEmail = funParseFind(strData ,$TAB _
                                 ,"Email")
                                 '
      ELSE
      ' data lines
        strStreet = PARSE$(strData,$TAB,lngAddress)
        strCity   = strStreet
        '
        PREFIX "uCustomer."
          FirstName = PARSE$(strData,$TAB,lngFirstName)
          Surname   = PARSE$(strData,$TAB,lngSurname)
          Street    = funStartRangeParse(strStreet,",",PARSECOUNT(strStreet,",")-1)
          City       = PARSE$(strCity,",",-1)
          EyeColour  = PARSE$(strData,$TAB,lngEyeColour)
          BloodGroup = PARSE$(strData,$TAB,lngBloodGroup)
          Email      = PARSE$(strData,$TAB,lngEmail)
        END PREFIX
        '
        INCR qRecord
        PUT #lngDBHandle,qRecord, uCustomer
      '
      END IF
      '
    NEXT lngCount
    '
    FUNCTION = %TRUE
  CATCH
    FUNCTION = %FALSE
  FINALLY
    CLOSE #lngFile
  END TRY
  '
END FUNCTION
'
FUNCTION funOpenRandomDB(strDBName AS STRING) AS LONG
' opens db and returns file handle
  LOCAL lngFile AS LONG
  LOCAL uCustomer AS udtCustomers
  '
  lngFile = FREEFILE
  '
  TRY
    OPEN strDBName FOR RANDOM AS #lngFile LEN = LEN(uCustomer)
    FUNCTION = lngFile
  CATCH
    FUNCTION = 0
  FINALLY
  END TRY
  '
END FUNCTION
'
