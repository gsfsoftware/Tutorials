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
  funPrepOutput("Queue Handling",0,0,40,120)
  '
  funLog("Queue Handling")
  '
  ' declare the Collection Queue
  LOCAL Collection AS IQUEUECOLLECTION
  LET Collection = CLASS "QueueCollection"
  '
  ' create variable to hold number of items in the queue
  LOCAL lngCountItems AS LONG
  ' count how many items exist in the queue
  mCountItems(lngCountItems)
  '
  LOCAL vItemInput AS VARIANT
  ' add an array item to the queue
  DIM a_strData(0 TO 4) AS STRING
  ARRAY ASSIGN a_strData() = "A","B","C","D","E"
  '
  LET vItemInput = a_strData()
  '
  ' add the variant to the collection queue
  Collection.enqueue(vItemInput)
  '
  ' add an array item to the queue
  DIM a_strDataNext(0 TO 2) AS STRING
  ARRAY ASSIGN a_strDataNext() = "A1","B1","C1"
  LET vItemInput = a_strDataNext()
  '
  ' add the variant to the collection queue
  Collection.enqueue(vItemInput)
  '
   ' repopulate the array with different data
  ARRAY ASSIGN a_strDataNext() = "A10","B10","C10"
  LET vItemInput = a_strDataNext()
  '
  ' add the variant to the collection queue
  Collection.enqueue(vItemInput)
  '
  ' add a dynamic string item to the queue
  LET vItemInput = "Apple Pie"
  Collection.enqueue(vItemInput)
  '
  ' count how many items exist in the queue
  mCountItems(lngCountItems)
  '

  ' now extract the items from the queue
  LOCAL vItem AS VARIANT         ' variant to hold data coming back from the queue
  DIM a_strOutput(0) AS STRING   ' array to put that data into
  LOCAL lngR AS LONG             ' counter for each row in the array
  '
  LOCAL lngItem AS LONG
  ' using the count of items
  ' extract each item from the queue
  FOR lngItem = 1 TO lngCountItems
    ' pull oldest item from the queue
    vItem = Collection.dequeue
    ' test to ensure the variant extracted
    ' is not empty
    IF VARIANTVT(vItem) = %VT_EMPTY THEN
      funLog("No items left in queue")
    ELSE
      ' display the item extracted
      funLog "Variant type = " & FORMAT$(VARIANTVT(vItem))
      '
      SELECT CASE VARIANTVT(vItem)
        ' dependant on the type of data stored
        CASE %VT_BSTR + %VT_ARRAY
          ' populate the string array with whats in the Variant
          TRY
            LET a_strOutput() = vItem
            '
            FOR lngR = LBOUND(a_strOutput) TO UBOUND(a_strOutput)
              funLog("Item " & FORMAT$(lngR) & " = " & a_strOutput(lngR))
            NEXT lngR
            funLog("")
          CATCH
            funLog ERROR$
          FINALLY
          END TRY
          '
        CASE %VT_BSTR
        ' dynamic string
          funLog("Data = " & VARIANT$(vItem))
          funLog("")
        '
        CASE ELSE
          funLog("Some other type")
          funLog("")
          '
      END SELECT
      '
    END IF
    '
  NEXT lngItem
  '
  funWait()
  '
END FUNCTION
'
MACRO mCountItems(lngCountItems)
  lngCountItems = Collection.Count
  funLog("There are " & FORMAT$(lngCountItems) & _
         " items in the queue")
END MACRO
