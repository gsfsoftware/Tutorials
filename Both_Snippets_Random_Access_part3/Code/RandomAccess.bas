#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
#INCLUDE "PB_FileHandlingRoutines.inc"
#INCLUDE "PB_RandomAccess_lib.inc"
'
' UDT to hold record information
TYPE udtCustomers
  Active AS LONG
  FirstName AS STRING * 50
  Surname AS STRING * 50
  Street AS STRING * 100
  City AS STRING * 50
  EyeColour AS STRING * 10
  BloodGroup AS STRING * 25
  Email AS STRING * 40
  Balance AS CURRENCYX
END TYPE
'
GLOBAL uEmptyCustomer AS udtCustomers
'
' set the file names
$InputFile = "Data\MyLargeFile.txt"
$DBFile    = "dbCustomers.dat"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Random Access",0,0,120,150)
  '
  funLog("Random Access")
  '
  LOCAL strDBName AS STRING     ' name of random access file
  LOCAL lngDBHandle AS LONG     ' handle of random access file
  LOCAL strInputFile AS STRING  ' data input file name/path
  '
  LOCAL qRecord AS QUAD           ' record number
  LOCAL qTotalRecords AS QUAD     ' total number of records
  LOCAL uCustomer AS udtCustomers ' udt for data record
  '
  LOCAL strData AS STRING         ' user record data
  '
  strDBName = EXE.PATH$ & $DBFile
  '
  TRY
  ' delete random access file if it exists
    KILL strDBName
  CATCH
  FINALLY
  END TRY
  '
  funPrepEmptyRecord()
  '
  lngDBHandle = funOpenRandomDB(strDBName, LEN(uCustomer))
  '
  IF lngDBHandle > 0 THEN
  ' file has been opened
    strInputFile = EXE.PATH$ & $InputFile
    IF ISTRUE funPopulateDB(lngDBHandle,strInputFile) THEN
    ' populated ok
      qTotalRecords = funGetDBRecordCount(lngDBHandle,LEN(uCustomer))
      funLog(FORMAT$(qTotalRecords) & " Records in the DB")
    END IF
    '
    ' read the whole db
    FOR qRecord = 1 TO qTotalRecords
    ' for each record
      IF ISTRUE funGetDBRecord(lngDBHandle, _
                               qRecord, _
                               strData) THEN
      TYPE SET uCustomer = strData
      ' print the names
        funDisplayRecord(qRecord, uCustomer)
      END IF
      '
    NEXT qRecord
    '
    funLog($CRLF & "Amendments")
    qRecord = 9
    IF ISTRUE funGetDBRecord(lngDBHandle, _
                             qRecord, _
                             strData) THEN
      TYPE SET uCustomer = strData
      funDisplayRecord(qRecord, uCustomer)
      '
      ' update a record
      funLog("Updating record")
      uCustomer.FirstName = "Samantha"
      '
      strData = uCustomer
      IF ISTRUE funSaveDBRecord(lngDBHandle, _
                                qRecord, _
                                strData) THEN
      ' print the details
        funDisplayRecord(qRecord, uCustomer)
      ELSE
        funlog("Could not update")
      END IF
      '
    END IF
    '
    ' now add a brand new record
    funLog($CRLF & "Adding new record")
    qRecord = 11
    '
    PREFIX "uCustomer."
      Active     = %TRUE
      FirstName  = "James"
      Surname    = "Smith"
      Street     = "10 Any Old Street"
      City       = "Moon city"
      EyeColour  = "Green"
      BloodGroup = "O RhD negative (O-)"
      Email      = "James.Smith@anywhere.com"
      Balance    = 99.00
    END PREFIX
    '
    strData = uCustomer
    IF ISTRUE funSaveDBRecord(lngDBHandle, _
                              qRecord, _
                              strData) THEN
      IF ISTRUE funGetDBRecord(lngDBHandle, _
                               qRecord, _
                               strData) THEN
        TYPE SET uCustomer = strData
      ' print the names
        funDisplayRecord(qRecord, uCustomer)
      END IF
      '
    ELSE
    ' failure to save
      funLog("Unable to save record -> " & FORMAT$(qRecord))
    END IF
    '
    qTotalRecords = funGetDBRecordCount(lngDBHandle, LEN(uCustomer))
    funLog(FORMAT$(qTotalRecords) & " Records in the DB")
    '
    qRecord = 12
    IF ISTRUE funGetDBRecord(lngDBHandle, _
                             qRecord, _
                             strData) THEN
      TYPE SET uCustomer = strData
      funLog("Got record")
    ELSE
      funLog("Can't get record " & FORMAT$(qRecord))
    END IF
    '
    ' display all records
    funLog($CRLF & "All records")
    funDisplayAllRecords(lngDBHandle)
    '
     ' now mark a record as inactive
    funLog($CRLF & "Deactivating a record")
    qRecord = 6
    IF ISTRUE funGetDBRecord(lngDBHandle, _
                             qRecord, _
                             strData) THEN
      TYPE SET uCustomer = strData
      ' mark record as inactive
      strData = uEmptyCustomer
      IF ISTRUE funSaveDBRecord(lngDBHandle, _
                                qRecord, _
                                strData) THEN
        funLog("Rec " & FORMAT$(qRecord) & " now inactive")
      END IF
      '
    END IF
    '
    ' display all Active records
    funLog($CRLF & "All Active records")
    funDisplayAllRecords(lngDBHandle,%TRUE)
    '
    ' now close the DB
    funCloseRandomDB(lngDBHandle)
  ELSE
    funLog("DB failed to open")
  END IF
  '

  '
  funWait()
  '
END FUNCTION
'
FUNCTION funPrepEmptyRecord() AS LONG
' prepare an empty record
  PREFIX "uEmptyCustomer."
    Active = %FALSE
    FirstName  = ""
    Surname    = ""
    Street     = ""
    City       = ""
    EyeColour  = ""
    BloodGroup = ""
    Email      = ""
    Balance    = 0.00
  END PREFIX
  '
END FUNCTION
'
FUNCTION funDisplayAllRecords(lngDBHandle AS LONG, _
                              OPTIONAL lngActiveOnly AS LONG) AS LONG
' display all the records in the Random access file
' optional parameter allows only active records to be shown
  LOCAL qRecord AS QUAD
  LOCAL qTotalRecords AS QUAD
  LOCAL uCustomer AS udtCustomers
  LOCAL strData AS STRING
  '
  qRecord = 1 ' start at record 1
  '
  qTotalRecords = funGetDBRecordCount(lngDBHandle, LEN(uCustomer))
  '
  SEEK lngDBHandle, qRecord ' move to record
  '
  WHILE (ISFALSE EOF(lngDBHandle) AND qRecord <= qTotalRecords)
    IF ISTRUE funGetDBRecord(lngDBHandle , _
                             qRecord , _
                             strData) THEN
      TYPE SET uCustomer = strData
      ' so display the customer
      IF lngActiveOnly = %TRUE THEN
      ' only active records wanted
        IF uCustomer.Active = %TRUE THEN
          funDisplayRecord(qRecord,uCustomer)
        END IF
      ELSE
      ' otherwise display all records
        funDisplayRecord(qRecord,uCustomer)
      END IF
      INCR qRecord
    ELSE
      EXIT LOOP
    END IF
    '
  WEND
  '
END FUNCTION
'
FUNCTION funDisplayRecord(qRecord AS QUAD, _
                          uCustomer AS udtCustomers) AS LONG
' display the loaded record
  LOCAL strOutput AS STRING
  LOCAL strBalance AS STRING
  '
  strBalance = SPACE$(10)
  RSET strBalance = FORMAT$(uCustomer.Balance,"#,###.00")
  '
  strOutput = "Rec " & FORMAT$(qRecord) & " = " & _
               SHRINK$(uCustomer.FirstName & " " & _
                       uCustomer.Surname) & $TAB & _
               uCustomer.email & _
               strBalance
               '
  funLog(strOutput)
  '
END FUNCTION
'
FUNCTION funPopulateDB(lngDBHandle AS LONG, _
                       strInputFile AS STRING) AS LONG
' read the input file and put records into the DB file
'
  LOCAL uCustomer AS udtCustomers
  LOCAL lngFile AS LONG
  LOCAL lngTotalRecords AS LONG  ' total record count
  LOCAL lngCount AS LONG         ' record number
  LOCAL strData AS STRING        ' actual data
  LOCAL strHeaders AS STRING     ' headers
  LOCAL qRecord AS QUAD          ' record number in random access file
  '
  LOCAL lngFirstName AS LONG   ' starting positions
  LOCAL lngSurname AS LONG     ' for each named column
  LOCAL lngAddress AS LONG
  LOCAL lngEyeColour AS LONG
  LOCAL lngBloodGroup AS LONG
  LOCAL lngEmail AS LONG
  LOCAL lngBalance AS LONG
  '
  LOCAL strCity AS STRING
  LOCAL strStreet AS STRING
  '
  LOCAL strDataOut AS STRING
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
        ' find the starting position of each column
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
        lngBalance = funParseFind(strData ,$TAB _
                                 ,"Balance")
      ELSE
      ' data lines
        strStreet = PARSE$(strData,$TAB,lngAddress)
        strCity   = strStreet
        '
        PREFIX "uCustomer."
          Active    = %TRUE
          FirstName = PARSE$(strData,$TAB,lngFirstName)
          Surname   = PARSE$(strData,$TAB,lngSurname)
          Street    = funStartRangeParse(strStreet,",",PARSECOUNT(strStreet,",")-1)
          City       = PARSE$(strCity,",",-1)
          EyeColour  = PARSE$(strData,$TAB,lngEyeColour)
          BloodGroup = PARSE$(strData,$TAB,lngBloodGroup)
          Email      = PARSE$(strData,$TAB,lngEmail)
          Balance    = VAL(PARSE$(strData,$TAB,lngBalance))
        END PREFIX
        ' save the udt to file
        INCR qRecord
        strDataOut = uCustomer
        PUT #lngDBHandle,qRecord, strDataOut
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
