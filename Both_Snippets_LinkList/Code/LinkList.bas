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
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Link List",0,0,40,120)
  '
  funLog("Link List")
  '
  ' prepare a List collection
  LOCAL ListCollect AS ILINKLISTCOLLECTION
  LET ListCollect = CLASS "LinkListCollection"
  '
  ' declare a variant to hold input data
  LOCAL vItemInput AS VARIANT
  LET vItemInput = "Test"
  '
  ' clear out the collection and display count of items
  ListCollect.Clear
  funLog("Items = " & FORMAT$(ListCollect.Count))
  '
  ' add items to the end of the list
  ListCollect.Add(vItemInput)
  funLog("Items = " & FORMAT$(ListCollect.Count))
  '
  ListCollect.Add("Test2_data")
  '
  ' display each item in the list
  LOCAL vItemOutput AS VARIANT
  FOR EACH vItemOutput IN ListCollect
    funLog("Item = " & VARIANT$(vItemOutput))
  NEXT
  '
  funLog("")
  '
  ' insert a new item at an index position
  LOCAL lngIndex AS LONG
  lngIndex = 2
  ListCollect.Insert(lngIndex,"New Data")
  '
  mDisplayList(ListCollect)
  '
  funLog("")
  '
  ' delete an item by index position
  lngIndex = 1
  ListCollect.Remove(lngIndex)
  '
  mDisplayList(ListCollect)
  '
  funLog("")
  ' replace an item
  lngIndex = 1
  ListCollect.Replace(lngIndex,"Newer Data")
  '
  mDisplayList(ListCollect)
  '
  ' what is the current index?
  lngIndex = ListCollect.Index(0)
  funLog("Current Index = " & FORMAT$(lngIndex))
  ' and how many items are there
  funLog("Items = " & FORMAT$(ListCollect.Count))
  '
  funLog("")
  LOCAL lngR AS LONG
  FOR lngR = 1 TO 5
    vItemInput = "Item " & FORMAT$(lngR)
    ListCollect.Add(vItemInput)
  NEXT lngR
  '
  mDisplayList(ListCollect)
  '
  ' set index to the last item
  lngIndex = ListCollect.Last
  ' get the previous item
  funLog("Last = " & VARIANT$(ListCollect.Previous))
  funLog("Next Last = " & VARIANT$(ListCollect.Previous))
  '
  lngIndex = ListCollect.First
  funLog("First = " & VARIANT$(ListCollect.Next))
  funLog("Next = " & VARIANT$(ListCollect.Next))
  '
  ' get 4th in list
  funLog("4th = " & VARIANT$(ListCollect.Item(4)))
  '
  ' add array
  DIM a_strDataNext(0 TO 2) AS STRING
  ARRAY ASSIGN a_strDataNext() = "A1","B1","C1"
  LET vItemInput = a_strDataNext()
  '
  ListCollect.Add(vItemInput)
  '
  mDisplayList_ex(ListCollect)
  '
  funWait()
  '
END FUNCTION
'
MACRO mDisplayList_ex(ListCollect)
' display the list of items in the List collection
  ' macro temp variables
  MACROTEMP vItemOutput,a_strOutput, lngR
  LOCAL vItemOutput AS VARIANT ' declared as variant
  DIM a_strOutput(0) AS STRING
  LOCAL lngR AS LONG
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
        funLog("Item = " & VARIANT$(vItemOutput))
    END SELECT
   '
  NEXT
END MACRO
'
MACRO mDisplayList(ListCollect)
' display the list of items in the List collection
  ' macro temp variables
  MACROTEMP vItemOutput
  LOCAL vItemOutput AS VARIANT ' declared as variant
  '
  ' sweep through list collection
  FOR EACH vItemOutput IN ListCollect
  ' display item on the log
    funLog("Item = " & VARIANT$(vItemOutput))
   '
  NEXT
END MACRO
