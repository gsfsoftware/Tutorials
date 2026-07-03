#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
'
TYPE udtData
  strName AS STRING * 15
  strAccount AS STRING * 6
  curBalance AS CURRENCY
END TYPE
'
' set name for stored collection
$StoredCollection = "Stored_Collection.dat"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Link List Collections",0,0,40,120)
  '
  funLog("Link List Collections")
  '
  ' prepare a List collection
  GLOBAL ListCollect AS ILINKLISTCOLLECTION
  LET ListCollect = CLASS "LinkListCollection"
  '
  IF ISTRUE ISFILE(EXE.PATH$ & $StoredCollection) THEN
  ' if file exists load the collection
    IF ISTRUE funLoadTheCollection(EXE.PATH$ & $StoredCollection) THEN
    ' display what's loaded
      funDisplayCollection()
      ' add some more
      funAddExtraData()
      ' and display it too
      funDisplayCollection()
      '
    ELSE
      funLog("Unable to load collection")
    END IF
    '
  ELSE
  ' populate the initial data
    funInitialPopulate()
  END IF
  '
   ' now save the collection
  funSaveTheCollection(EXE.PATH$ & $StoredCollection)
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funAddExtraData() AS LONG
' add some extra data
  LOCAL uData AS udtData    ' udt for data
  LOCAL lngIndex AS LONG    ' index for insert
  '
  ' prepare a UDT
  PREFIX "uData."
    strName = "Second Account"
    strAccount = "100987"
    curBalance = 1500.50
  END PREFIX
  '
  ' now add to the collection
  'ListCollect.Add(uData AS STRING)
  '
  lngIndex = 1
  ListCollect.Insert(lngIndex,uData AS STRING)
'
END FUNCTION
'
FUNCTION funInitialPopulate() AS LONG
' set up the collection
  LOCAL lngIndex AS LONG
  LOCAL uData AS udtData    ' udt for data
  '
  ' display item count
  funLog("Item Count = " & FORMAT$(ListCollect.Count))
  '
  ' add some records
  funAddStringData()
  '
  ' display all items in collection
  funDisplayCollection()
  '
  ' clear out the collection and display count of items
  ListCollect.Clear
  funLog("Items Count after clear = " & FORMAT$(ListCollect.Count))
  funLog("")
  '
  ' re-add some records
  funAddStringData()
  '
  ' display all items in collection
  funDisplayCollection()
  '
  ' delete an item by index position
  lngIndex = 2
  ListCollect.Remove(lngIndex)
  '
  ' display all items in collection
  funDisplayCollection()
  '
  ' declare a variant to hold input data
  LOCAL vItemInput AS VARIANT
  ' add array
  DIM a_strDataNext(0 TO 2) AS STRING
  ARRAY ASSIGN a_strDataNext() = "A1","B1","C1"
  LET vItemInput = a_strDataNext()
  '
  ListCollect.Add(vItemInput)
  ' display the collection
  funDisplayCollection()
  '
  ' prepare a UDT
  PREFIX "uData."
    strName = "Main Account"
    strAccount = "100123"
    curBalance = 100.99
  END PREFIX
  '
  ' now add to the collection
  ListCollect.Add(uData AS STRING)
  '
  ' display the collection
  funDisplayCollection()
  '
  funLog("Item Count = " & FORMAT$(ListCollect.Count))
  '
  funLog("")
  funLog("Get first item")
  ListCollect.First                   ' set index to first item
  lngIndex = ListCollect.Index(0)     ' get current index
  '
  LOCAL vItem AS VARIANT              ' declared as variant
  vItem = ListCollect.Item(lngIndex)  ' get the current item
  funLog("Item = " & VARIANT$(vItem))
  '
  ListCollect.Replace(lngIndex,"Michael") ' replace this entry
  '
  ' display the collection
  funDisplayCollection()
  '
  funLog("")
  funLog("Test inserting")
  '
  lngIndex = 2       ' set index to 2
  ListCollect.Insert(lngIndex,"Daniel")
  ' display the collection
  funDisplayCollection()
  '
END FUNCTION
'
FUNCTION funAddStringData() AS LONG
' add some string data
  funLog("adding Strings")
  PREFIX "ListCollect.Add"
   ("Daniel")
   ("Eddie")
   ("Julie")
   ("Susan")
  END PREFIX
  '
  ' display item count
  funLog("Item Count = " & FORMAT$(ListCollect.Count))
  '
END FUNCTION
'
FUNCTION funDisplayCollection() AS LONG
' display the full collection
  LOCAL vItemOutput AS VARIANT ' declared as variant
  DIM a_strOutput(0) AS STRING ' array for data
  LOCAL lngR AS LONG           ' array row
  LOCAL uData AS udtData       ' udt
  '
  funLog("") ' output blank line
  '
  ' sweep through list collection
  FOR EACH vItemOutput IN ListCollect
    ' display item on the log
    SELECT CASE VARIANTVT(vItemOutput)
      ' dependant on the type of data stored
      CASE %VT_BSTR + %VT_ARRAY
      ' populate the string array with whats in the Variant
        TRY
          LET a_strOutput() = vItemOutput
          FOR lngR = LBOUND(a_strOutput) TO UBOUND(a_strOutput)
            funLog("Item " & FORMAT$(lngR) & " = " & a_strOutput(lngR))
          NEXT lngR
        CATCH
          funlog(ERROR$)
        FINALLY
        END TRY
        '
      CASE %VT_BSTR
      ' dynamic string
        IF LEFT$(VARIANT$(vItemOutput),1) = "?" THEN
        ' its a UDT
          TYPE SET uData = VARIANT$(BYTE,vItemOutput)
          funLog("UDT")
          funLog("Account name = " & uData.strName)
          funLog("Account number = " & uData.strAccount)
          funLog("Balance = " & FORMAT$(uData.curBalance,"#,###.00"))
        '
        ELSE
        ' just an ordinary string
          funLog("Item = " & VARIANT$(vItemOutput))
        END IF
      '
    END SELECT
    '
  NEXT
  '
END FUNCTION
'
FUNCTION funLoadTheCollection(strLoadFrom AS STRING) AS LONG
' load the collection from disk
  LOCAL lngFile AS LONG         ' file handle
  LOCAL vData AS VARIANT        ' variant for data
  LOCAL uData AS udtData        ' udt storage
  LOCAL lngRow AS LONG          ' row counter for array
  DIM a_strOutput(0) AS STRING  ' array for data
  LOCAL strType AS STRING       ' type of data
  LOCAL strData AS STRING       ' actual string data
  LOCAL strLow, strHigh AS STRING ' low and high of array range
  LOCAL lngLow, lngHigh AS LONG
  '
  ' first clean out the collection
  ListCollect.Clear
  '
  lngFile = FREEFILE
  TRY
    OPEN strLoadFrom FOR INPUT AS #lngFile
    WHILE NOT EOF(#lngFile)
    ' read the type of data
      LINE INPUT #lngFile, strType
      SELECT CASE strType
      ' determine what to do
        CASE "**ARR**"
        ' get the range
          LINE INPUT #lngFile,strLow
          LINE INPUT #lngFile,strHigh
          '
          lngLow = VAL(strLow)
          lngHigh = VAL(strHigh)
          '
          REDIM a_strOutput(lngLow TO lngHigh) AS STRING
          FOR lngRow = lngLow TO lngHigh
            LINE INPUT #lngFile,a_strOutput(lngRow)
          NEXT lngRow
          ' add array to collection
          LET vData = a_strOutput()
          ListCollect.Add(vData)
        '
        CASE "**UDT**"
        ' get the UDT
          LINE INPUT #lngFile,strData
          TYPE SET uData = strData
          ' now add to the collection
          ListCollect.Add(uData AS STRING)
        '
        CASE "**STR**"
        ' plain string
          LINE INPUT #lngFile,strData
          ListCollect.Add(strData)
      '
      END SELECT
    WEND
    '
    funLog("Items loaded = " & FORMAT$(ListCollect.Count))
    '
    FUNCTION = %TRUE
  CATCH
    FUNCTION = %FALSE
  FINALLY
    CLOSE#lngFile
  END TRY
  '
END FUNCTION
'
'
FUNCTION funSaveTheCollection(strSaveTo AS STRING) AS LONG
' save the collection to disk
  LOCAL lngFile AS LONG         ' file handle
  LOCAL vData AS VARIANT        ' variant for data
  LOCAL uData AS udtData        ' udt storage
  LOCAL lngR AS LONG            ' row counter for array
  DIM a_strOutput(0) AS STRING  ' array for data
  '
  lngFile = FREEFILE
  TRY
    OPEN strSaveTo FOR OUTPUT AS #lngFile
    FOR EACH vData IN ListCollect
      SELECT CASE VARIANTVT(vData)
      ' dependant on the type of data stored
        CASE %VT_BSTR + %VT_ARRAY
        ' array data
          LET a_strOutput() = vData
          ' print output
          PRINT #lngFile,"**ARR**"
          PRINT #lngFile,FORMAT$(LBOUND(a_strOutput))
          PRINT #lngFile,FORMAT$(UBOUND(a_strOutput))
          FOR lngR = LBOUND(a_strOutput) TO UBOUND(a_strOutput)
            PRINT #lngFile, a_strOutput(lngR)
          NEXT lngR
          '
        CASE %VT_BSTR
        ' dynamic string
          IF LEFT$(VARIANT$(vData),1) = "?" THEN
            PRINT #lngFile,"**UDT**"
            TYPE SET uData = VARIANT$(BYTE,vData)
            PRINT #lngFile,uData
          ELSE
            PRINT #lngFile,"**STR**"
            PRINT #lngFile,VARIANT$(vData)
          END IF
          '
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
