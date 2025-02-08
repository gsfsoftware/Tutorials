#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
TYPE udtStudentData
  Forename AS STRING * 100
  Surname AS STRING * 100
  Age AS LONG
  Balance AS CURRENCYX
END TYPE
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
'
$DataFile = "UDT_Data.txt"  ' name of the saved UDT array
'
' saved file with header
$DataFileWithHeader = "UDT_Data_WithHeader.txt"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("UDTs and file handling",0,0,80,120)
  '
  funLog("UDTs and file handling")
  '
   ' dimension our array
  DIM a_uStudentData(1 TO 10) AS udtStudentData
  '
  ' populate the array of UDTs with data
  funPopulateArray(a_uStudentData())
  '
  ' display the data in the array
  funDisplayData(a_uStudentData())
  '
  IF ISTRUE funSaveTheArrayData(a_uStudentData()) THEN
    funLog("Array saved")
    ' amend first records balance
    funLog("Amending a balance")
    a_uStudentData(1).Balance = 999.99
    ' display the data in the array
    funDisplayData(a_uStudentData())
    '
    IF ISTRUE funLoadTheArrayData(a_uStudentData()) THEN
      funLog("Array loaded" & $CRLF)
      '
      ' display the data in the array
      funDisplayData(a_uStudentData())
    ELSE
      funLog("Unable to load the Array")
    END IF
    '
  ELSE
    funLog("Unable to save the Array")
  END IF
  '
  ' make the array bigger
  funLog("Array now 20 records")
  REDIM PRESERVE a_uStudentData(1 TO 20) AS udtStudentData
  '
  ' and add another record
  funLog("Adding a new record")
  PREFIX "a_uStudentData(20)."
    Forename = "Stacey"
    Surname = "Redwood"
    Age = 29
    Balance = 10.99
  END PREFIX
  '
  IF ISTRUE funSaveTheArrayDataWithHeader(a_uStudentData()) THEN
    funLog("Array saved with header")
    ' now redim the array smaller and wipe data
    funLog("Array set to 10 records and wiped")
    REDIM a_uStudentData(1 TO 10) AS udtStudentData
    '
    ' now reload the array
    IF ISTRUE funLoadTheArrayDataWithHeader(a_uStudentData()) THEN
      funLog("Array loaded with header" & $CRLF)
      ' display the data in the array
      funDisplayData(a_uStudentData())
    ELSE
      funLog("Unable to load the Array with header")
    END IF
    '
  ELSE
    funLog("Unable to save the Array with header")
  END IF
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funLoadTheArrayDataWithHeader(BYREF a_uStudentData() _
                                       AS udtStudentData) AS LONG
' load the UDT from disk using header data
  LOCAL lngFile AS LONG     ' handle for the file
  LOCAL lngRecords AS LONG  ' number of records returned
  LOCAL strHeader AS STRING ' header block giving the number of rows
  '
  strHeader = SPACE$(5)     ' prepare the header
  '
  lngFile = FREEFILE
  TRY
    OPEN EXE.PATH$ & $DataFileWithHeader _
         FOR BINARY ACCESS READ AS #lngFile
    GET #lngFile, 1, strHeader                      ' get the header
    ' redimension the array to accomodate the data file
    REDIM a_uStudentData(1 TO VAL(strHeader)) AS udtStudentData
    ' get the data beyond the header
    GET #lngFile, LEN(strHeader)+1, a_uStudentData() _
                  TO lngRecords ' get the data
    funLog(FORMAT$(lngRecords) & " records loaded")
    FUNCTION = %TRUE
    '
  CATCH
    funLog(ERROR$)
  FINALLY
     CLOSE #lngFile
  END TRY
  '
END FUNCTION
'
FUNCTION funSaveTheArrayDataWithHeader(BYREF a_uStudentData() _
                                       AS udtStudentData) AS LONG
' save the UDT array to disk with a header
  LOCAL lngFile AS LONG      ' handle for the file
  LOCAL strHeader AS STRING  ' used for the number of rows in the array
  '
  ' create header with 5 character limit i.e. 99,999 rows max
  strHeader = RIGHT$("00000" & FORMAT$(UBOUND(a_uStudentData)),5)
  '
  ' first wipe the file
  IF ISTRUE ISFILE(EXE.PATH$ & $DataFileWithHeader) THEN
    KILL EXE.PATH$ & $DataFileWithHeader
  END IF
  '
  lngFile = FREEFILE
  TRY
    OPEN EXE.PATH$ & $DataFileWithHeader _
             FOR BINARY ACCESS WRITE AS #lngFile
    PUT #lngFile, 1, strHeader                      ' Write header.
    PUT #lngFile,LOF(#lngFile) +1 ,a_uStudentData() ' Write data
    FUNCTION = %TRUE
  CATCH
    funLog(ERROR$)
  FINALLY
    CLOSE #lngFile
  END TRY
END FUNCTION
'
FUNCTION funLoadTheArrayData(BYREF a_uStudentData() _
                             AS udtStudentData) AS LONG
' load the UDT from disk
  LOCAL lngFile AS LONG    ' handle for the file
  LOCAL lngRecords AS LONG ' number of records returned
  '
  lngFile = FREEFILE
  TRY
    OPEN EXE.PATH$ & $DataFile FOR BINARY ACCESS READ AS #lngFile
    GET #lngFile, 1, a_uStudentData() TO lngRecords
    funLog(FORMAT$(lngRecords) & " records loaded")
    FUNCTION = %TRUE
  CATCH
    funLog(ERROR$)
  FINALLY
     CLOSE #lngFile
  END TRY
  '
END FUNCTION
'
FUNCTION funSaveTheArrayData(BYREF a_uStudentData() _
                             AS udtStudentData) AS LONG
' save the UDT array to disk
  LOCAL lngFile AS LONG   ' handle for the file
  '
  ' first wipe the file
  IF ISTRUE ISFILE(EXE.PATH$ & $DataFile) THEN
    KILL EXE.PATH$ & $DataFile
  END IF
  '
  lngFile = FREEFILE
  TRY
    OPEN EXE.PATH$ & $DataFile FOR BINARY ACCESS WRITE AS #lngFile
    PUT #lngFile,1,a_uStudentData()
    FUNCTION = %TRUE
  CATCH
    funLog(ERROR$)
  FINALLY
    CLOSE #lngFile
  END TRY
  '
END FUNCTION
'
FUNCTION funPopulateArray(BYREF a_uStudentData() _
                          AS udtStudentData) AS LONG
' populate the array with data
  '
  LOCAL lngR AS LONG
  '
  PREFIX "a_uStudentData(1)."
    Forename = "John"
    Surname = "Smith"
    Age = 21
    Balance = 20.95
  END PREFIX
  '
  PREFIX "a_uStudentData(2)."
    Forename = "Sandra"
    Surname = "Jones"
    Age = 22
    Balance = 130.50
  END PREFIX
  '
  ' initialise the rest of the records
  LOCAL lngStartRecord AS LONG
  lngStartRecord = 3
  funInitialiseRecords(a_uStudentData(),lngStartRecord)
  '
END FUNCTION
'
FUNCTION funInitialiseRecords(a_uStudentData() AS udtStudentData, _
                              lngStartRecord AS LONG) AS LONG
  LOCAL lngR AS LONG
  '
  ' initialise the rest of the records
  FOR lngR = lngStartRecord TO UBOUND(a_uStudentData)
    PREFIX "a_uStudentData(lngR)."
      Forename = ""
      Surname = ""
      Age = 0
      Balance = 0.00
    END PREFIX
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funDisplayData(BYREF a_uStudentData() _
                        AS udtStudentData) AS LONG
' display the data in the array
  LOCAL lngRow AS LONG
  ' display first two entries
  FOR lngRow = 1 TO UBOUND(a_uStudentData)
    IF a_uStudentData(lngRow).Age <> 0 THEN
    ' skip blank records
      funLog("Record = " & FORMAT$(lngRow) & " " & _
             TRIM$(a_uStudentData(lngRow).Forename) & " " & _
             TRIM$(a_uStudentData(lngRow).Surname))
              '
      funLog("Age = " & FORMAT$(a_uStudentData(lngRow).Age))
      funLog("Card balance = " & _
              FORMAT$(a_uStudentData(lngRow).Balance,"0.00") & $CRLF)
    END IF
    '
  NEXT lngRow
  '
END FUNCTION
