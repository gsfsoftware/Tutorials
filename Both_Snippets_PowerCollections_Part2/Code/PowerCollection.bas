#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF

' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc
'
TYPE uCustomers
  AccountNumber AS STRING * 4
  FirstName AS STRING * 50
  Surname AS STRING   * 50
  Address AS STRING   * 100
  Telephone AS STRING * 14
END TYPE
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Building Power Collections",0,0,40,120)
  '
  funLog("Walk through on Power Colletions")
  '
  DIM a_strWork() AS STRING
  LOCAL strFilename AS STRING
  '
  ' define the customers collection
  GLOBAL Customers AS IPOWERCOLLECTION
  Customers = CLASS "PowerCollection"
  ' define the UDTs used for each record
  LOCAL udtCustomers AS uCustomers
  LOCAL udtCustomerOut AS uCustomers
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
  'if isfalse funLoadRawFile(EXE.PATH$ & "MyFile.csv") then
  '  funLog "Unable to load for CSV"
  '  funWait()
  '  exit function
  'end if
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
    AccountNumber = "1300"
    FirstName     = "Fred"
    Surname       = "Smith"
    Address       = "12 Any Place,Any City"
    Telephone     = "0555 0123 6000"
  END PREFIX
  '
  wKey = udtCustomers.AccountNumber
  Customers.add(wKey,udtCustomers AS STRING)
  '
  IF OBJRESULT = %S_OK THEN
    funLog (wKey & " stored")
  ELSE
    funLog (wKey & " already stored or errored")
  END IF
  '
  funLog( FORMAT$(Customers.Count) & " records found")
  '
  ' remove a customer
  wKey = "1200"
  Customers.Remove(wKey)
  IF OBJRESULT = %S_OK THEN
    funLog("Account " & wKey & " removed")
    funLog( FORMAT$(Customers.Count) & " records found")
  ELSE
    funLog("Account " & wKey & " not removed")
  END IF
  '
  ' update a record
  wKey = "0600"
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
    Customers.Replace(wKey,udtCustomerOut AS STRING)
    IF OBJRESULT = %S_OK THEN
      funLog(wKey & " account updated")
    END IF
  ELSE
  END IF
  '
  Customers.Sort(0) ' sort the collection
  '
  ' read the stored data
  FOR EACH vData IN Customers
  ' populate vData with the next record stored in the collection
  ' and populate the UDT from vData
    TYPE SET udtCustomerOut = VARIANT$(BYTE,vData)
    funLog("Got " & TRIM$(udtCustomerOut.AccountNumber) & " " & _
           TRIM$(udtCustomerOut.FirstName) & " " & _
           TRIM$(udtCustomerOut.Surname) & " " & _
           TRIM$(udtCustomerOut.Address) & " " & _
           TRIM$(udtCustomerOut.Telephone))
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
        AccountNumber = PARSE$(a_strWork(lngR),"",5)
        FirstName     = PARSE$(a_strWork(lngR),"",1)
        Surname       = PARSE$(a_strWork(lngR),"",2)
        Address       = PARSE$(a_strWork(lngR),"",3)
        Telephone     = PARSE$(a_strWork(lngR),"",4)
      END PREFIX
      '
      ' add the customer record
      wKey = udtCustomers.AccountNumber
      Customers.add(wKey,udtCustomers AS STRING)
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
  '
  lngFile = FREEFILE
  TRY
    OPEN strSaveTo FOR OUTPUT AS #lngFile
    FOR EACH vData IN Customers
      TYPE SET udtCustomerOut = VARIANT$(BYTE,vData)
      PRINT #lngFile,udtCustomerOut
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
  ' set up the wide unicode string for the unique key
  LOCAL wKey AS WSTRING
  '
  lngFile = FREEFILE
  TRY
    OPEN strFileFrom FOR INPUT AS #lngFile
    WHILE NOT EOF(#lngFile)
      LINE INPUT #lngFile,strCustomers
      TYPE SET udtCustomers = strCustomers
      '
      ' add record to the collection
      wKey = udtCustomers.AccountNumber
      Customers.Add(wKey, udtCustomers AS STRING)
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
