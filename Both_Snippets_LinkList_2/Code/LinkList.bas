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
MACRO mDisplayList(ListCollect)
' display the list of items in the List collection
  ' macro temp variables
  MACROTEMP vItemOutput
  LOCAL vItemOutput AS VARIANT ' declared as variant
  '
  funLog("") ' output blank line
  ' sweep through list collection
  FOR EACH vItemOutput IN ListCollect
  ' display item on the log
    funLog("Item = " & VARIANT$(vItemOutput))
   '
  NEXT
END MACRO
'
MACRO mDisplayList_ex(ListCollect)
' display the list of items in the List collection
  ' macro temp variables
  MACROTEMP vItemOutput,a_strOutput, lngR , uData
  LOCAL vItemOutput AS VARIANT ' declared as variant
  DIM a_strOutput(0) AS STRING
  LOCAL lngR AS LONG
  LOCAL uData AS udtData
  '
  funLog("") ' output blank line
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
          funLog("Balance = " & FORMAT$(uData.curBalance,"#.##"))
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
END MACRO
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Link List Collections",0,0,40,120)
  '
  funLog("Link List Collections")
  '
  LOCAL lngIndex AS LONG    ' index for collection
  LOCAL uData AS udtData    ' udt for data
  '
  ' prepare a List collection
  LOCAL ListCollect AS ILINKLISTCOLLECTION
  LET ListCollect = CLASS "LinkListCollection"
  '
  ' display item count
  funLog("Item Count = " & FORMAT$(ListCollect.Count))
  '
  ' add some records
  funAddStringData(ListCollect)
  '
  ' display all items in collection
  mDisplayList(ListCollect)
  '
  ' clear out the collection and display count of items
  ListCollect.Clear
  funLog("Items Count after clear = " & FORMAT$(ListCollect.Count))
  funLog("")
  '
  ' re-add some records
  funAddStringData(ListCollect)
  '
  ' display all items in collection
  mDisplayList(ListCollect)
  '
  ' delete an item by index position
  lngIndex = 2
  ListCollect.Remove(lngIndex)
  '
  ' display all items in collection
  mDisplayList(ListCollect)
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
  mDisplayList_ex(ListCollect)
  '
  'prepare a UDT
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
  mDisplayList_ex(ListCollect)
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
  mDisplayList_ex(ListCollect)
  '
  funLog("")
  funLog("Test inserting")
  '
  lngIndex = 2       ' set index to 2
  ListCollect.Insert(lngIndex,"Daniel")
  ' display the collection
  mDisplayList_ex(ListCollect)
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funAddStringData(ListCollect AS ILINKLISTCOLLECTION) AS LONG
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
