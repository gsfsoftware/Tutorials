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
'
TYPE uCustomers
  AccountNumber AS STRING * 8
  FirstName AS STRING * 50
  Surname AS STRING   * 50
  Address AS STRING   * 100
  Telephone AS STRING * 14
END TYPE
'
TYPE uAccounts
  AccountNumber AS STRING * 8
  Balance AS CURRENCY
  Transaction1 AS CURRENCY
  Transaction2 AS CURRENCY
  Transaction3 AS CURRENCY
END TYPE
'
' set up prefix values
$UserPrefix = "USER"
$AccountPrefix = "ACCT"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Associative Arrays - Power Collections",0,0,40,120)
  '
  funLog("Associative Arrays - Power Collections")
  '
  ' define the customers collection
  GLOBAL Customers AS IPOWERCOLLECTION
  Customers = CLASS "PowerCollection"
  '
  ' define the UDTs used for each record
  LOCAL udtCustomers AS uCustomers
  LOCAL udtCustomerOut AS uCustomers
  LOCAL udtAccounts AS uAccounts
  '
  ' define variable to determine record type
  LOCAL strRecordType AS STRING
  '
    ' set up a wide unicode string for the unique key
  ' in the collection
  LOCAL wKey AS WSTRING
  ' long variable to be used to read through the array
  LOCAL lngR AS LONG
  ' variant to hold data coming out of the collection
  LOCAL vData AS VARIANT
  ' long variable to hold the record number in the collection
  ' of the data retrieved
  LOCAL lngItem AS LONG
  '
'  if isfalse funLoadRawFile(EXE.PATH$ & "MyUserData.csv") then
'    funLog "Unable to load for CSV"
'    funWait()
'    exit function
'  else
'    funLog "CSV loaded into Collection"
'  end if
'  '
'  IF ISTRUE funSaveCollection(EXE.PATH$ & "Customers.txt") THEN
'    funLog("Successfully saved the collection to disk")
'  ELSE
'    funLog("Unable to save the collection to disk")
'  END IF
'
  IF ISFALSE funLoadCollection(EXE.PATH$ & "Customers.txt") THEN
    funLog "Unable to load for TXT"
    funWait()
    EXIT FUNCTION
  END IF
  '
  ' display how many records are in the collection
  funLog( FORMAT$(Customers.Count) & " records found")
  '
  ' add another record
  PREFIX "udtCustomers."
    AccountNumber = $UserPrefix & "1300"
    FirstName     = "Fred"
    Surname       = "Smith"
    Address       = "12 Any Place,Any City"
    Telephone     = "0555 0123 6000"
  END PREFIX
  '
  wKey = udtCustomers.AccountNumber
  Customers.ADD(wKey,udtCustomers AS STRING)
  '
  ' display how many records are in the collection
  funLog( FORMAT$(Customers.Count) & " records found")
  '
  ' adding different data - Accounts
  PREFIX "udtAccounts."
    AccountNumber = $AccountPrefix & "1300"
    Balance = 100.00
    Transaction1 = +2.50
    Transaction2 = -13.20
    Transaction3 = +40.75
  END PREFIX
  '
  wKey = udtAccounts.AccountNumber
  Customers.ADD(wKey,udtAccounts AS STRING)
  '
  ' test is record added successfully
  IF OBJRESULT = %S_OK THEN
    funLog (wKey & " stored")
    funLog( FORMAT$(Customers.Count) & " records found")
  ELSE
    funLog (wKey & " already stored or errored")
  END IF
  '
  ' remove a customer
  wKey = $UserPrefix & "1200"
  Customers.Remove(wKey)
  IF OBJRESULT = %S_OK THEN
    funLog("Account " & wKey & " removed")
    funLog( FORMAT$(Customers.Count) & " records found")
  ELSE
    funLog("Account " & wKey & " not removed")
  END IF
  '
  ' update a record
  wKey = $UserPrefix & "0600"
  ' does the record exist?
  lngItem = Customers.Contains(wKey)
  IF lngItem = 0 THEN
  ' no record found
    funLog("Data not found")
  ELSE
    funLog("Data found at record = " & FORMAT$(lngItem))
    ' pull back the record into vData using the lngItem record number
    Customers.Entry(lngItem,wKey,vData)
  END IF
  '
   ' alternatively pull back the record into vData
  ' in one line of code
  ' using the wKey which we already set to be "0600"
  vData = Customers.Item(wKey)
  IF OBJRESULT = %S_OK THEN
  ' populate the UDT with the data from vData variant variable
    TYPE SET udtCustomerOut = VARIANT$(BYTE,vData)
    ' now update the UDT
    PREFIX "udtCustomerOut."
      Address = "126 Main Crescent, Hopetown"
      Telephone = "0570 0946 7020"
    END PREFIX
    '
    ' now update the collection using the UDT
    ' replacing the record which has wKey = "0600"
    Customers.REPLACE(wKey,udtCustomerOut AS STRING)
    IF OBJRESULT = %S_OK THEN
      funLog(wKey & " account updated")
    END IF
  ELSE
    funLog(wKey & " account not found")
  END IF
  '
  Customers.SORT(0) ' sort the collection
  '
  ' read the stored data
  FOR EACH vData IN Customers
  ' populate vData with the next record stored in the collection
  ' and populate the UDT from vData
    strRecordType = VARIANT$(BYTE,vData)
    '
    SELECT CASE LEFT$(strRecordType,4)
      CASE "USER"
      '
        TYPE SET udtCustomerOut = VARIANT$(BYTE,vData)
        funLog("Got " & TRIM$(udtCustomerOut.AccountNumber) & " " & _
           TRIM$(udtCustomerOut.FirstName) & " " & _
           TRIM$(udtCustomerOut.Surname) & " " & _
           TRIM$(udtCustomerOut.Address) & " " & _
           TRIM$(udtCustomerOut.Telephone))
      CASE "ACCT"
        TYPE SET udtAccounts = VARIANT$(BYTE,vData)
        funLog("Got " & TRIM$(udtAccounts.AccountNumber ) & " " & _
           "Balance = " & FORMAT$(udtAccounts.Balance,"+#,##0.00") & $CRLF & _
           "Item 1  = " & FORMAT$(udtAccounts.Transaction1,"#,##0.00") & $CRLF & _
           "Item 2  = " & FORMAT$(udtAccounts.Transaction2,"#,##0.00") & $CRLF & _
           "Item 3  = " & FORMAT$(udtAccounts.Transaction3,"#,##0.00") & $CRLF)
    END SELECT
  ' then get the next record
  NEXT
  '
  IF ISTRUE funSaveCollection(EXE.PATH$ & "Customers.txt") THEN
    funLog("Successfully saved the collection to disk")
  ELSE
    funLog("Unable to save the collection to disk")
  END IF
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funLoadRawFile(strFileFrom AS STRING) AS LONG
' load the collection from a CSV
  DIM a_strWork() AS STRING
  LOCAL lngR AS LONG
  LOCAL udtCustomers AS uCustomers
  ' set up a wide unicode string for the unique key
  ' in the collection
  LOCAL wKey AS WSTRING
  '
  IF ISTRUE funReadTheFileIntoAnArray(strFileFrom, _
                                      BYREF a_strWork()) THEN
    ' array has been loaded
    FOR lngR = 1 TO UBOUND(a_strWork)
      ' prepare the UDT with the data
      PREFIX "udtCustomers."
        AccountNumber = $UserPrefix & PARSE$(a_strWork(lngR),"",5)
        FirstName     = PARSE$(a_strWork(lngR),"",1)
        Surname       = PARSE$(a_strWork(lngR),"",2)
        Address       = PARSE$(a_strWork(lngR),"",3)
        Telephone     = PARSE$(a_strWork(lngR),"",4)
      END PREFIX
      '
      ' add the customer record
      wKey = udtCustomers.AccountNumber
      Customers.ADD(wKey,udtCustomers AS STRING)
      IF OBJRESULT = %S_OK THEN
      ' operation has been successful
        funLog(wKey & " stored")
      ELSE
      ' possible duplicate key?
        funLog(wKey & " already stored or errored")
      END IF
      '
    NEXT lngR
    '
    FUNCTION = %TRUE
    '
  ELSE
    FUNCTION = %FALSE
  END IF
'
END FUNCTION
'
FUNCTION funSaveCollection(strSaveTo AS STRING) AS LONG
' save the collection to disk
  LOCAL lngFile AS LONG
  LOCAL vData AS VARIANT
  LOCAL udtCustomerOut AS uCustomers
  LOCAL udtAccounts AS uAccounts
  LOCAL strRecordType AS STRING
  '
  lngFile = FREEFILE
  TRY
    OPEN strSaveTo FOR OUTPUT AS #lngFile
    FOR EACH vData IN Customers
      strRecordType = VARIANT$(BYTE,vData)
      '
      SELECT CASE LEFT$(strRecordType,4)
        CASE "USER"
          TYPE SET udtCustomerOut = VARIANT$(BYTE,vData)
          PRINT #lngFile,udtCustomerOut
        CASE "ACCT"
          TYPE SET udtAccounts = VARIANT$(BYTE,vData)
          PRINT #lngFile,udtAccounts
      END SELECT
    NEXT
    FUNCTION = %TRUE
  CATCH
    FUNCTION = %FALSE
  FINALLY
    CLOSE#lngFile
  END TRY
  '
END FUNCTION
'
FUNCTION funLoadCollection(strFileFrom AS STRING) AS LONG
' load the collection from disk
  LOCAL lngFile AS LONG
  LOCAL strCustomers AS STRING
  LOCAL udtCustomers AS uCustomers
  LOCAL udtAccounts AS uAccounts
  ' set up the wide unicode string for the unique key
  LOCAL wKey AS WSTRING
  '
  lngFile = FREEFILE
  TRY
    OPEN strFileFrom FOR INPUT AS #lngFile
    WHILE NOT EOF(#lngFile)
      LINE INPUT #lngFile,strCustomers
      SELECT CASE LEFT$(strCustomers,4)
        CASE "USER"
          TYPE SET udtCustomers = strCustomers
          '
          ' add record to the collection
          wKey = udtCustomers.AccountNumber
          Customers.ADD(wKey, udtCustomers AS STRING)
        CASE "ACCT"
          TYPE SET udtAccounts = strCustomers
          wKey = udtAccounts.AccountNumber
          ' add record to the collection
          Customers.ADD(wKey, udtAccounts AS STRING)
      END SELECT
      '
      IF OBJRESULT = %S_OK THEN
      ' operation worked
        funlog(wKey & " stored")
      ELSE
      ' possible duplicate key?
        funlog(wKey & " already stored or errored")
      END IF
      '
    WEND
    '
    FUNCTION = %TRUE
    '
  CATCH
    FUNCTION = %FALSE
  FINALLY
    CLOSE #lngFile
  END TRY
  '
END FUNCTION
