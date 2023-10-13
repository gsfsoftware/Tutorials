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
  lngCountItems = Collection.Count
  '
  funLog("There are " & FORMAT$(lngCountItems) & _
         " items in the queue")
         '
  LOCAL vItemInput AS VARIANT
  ' add an item to the queue
  vItemInput = "First Test"
  Collection.enqueue(vItemInput)
  '
  mCountItems(lngCountItems)
  '
  ' add multiple items to the queue
  LOCAL lngR AS LONG
  FOR lngR = 1 TO 5
  ' add an item to the queue
    Collection.enqueue("Test " & FORMAT$(lngR))
  NEXT lngR
  '
  mCountItems(lngCountItems)
  '
  ' extract the items from the queue
  LOCAL vItem AS VARIANT
  '
  LOCAL lngItem AS LONG
  ' using the count of items
  ' extract each item from the queue
  FOR lngItem = 1 TO lngCountItems
    ' pull oldest item from the queue
    vItem = Collection.dequeue
    '
    ' test to ensure the variant extracted
    ' is not empty
    IF VARIANTVT(vItem) = %VT_EMPTY THEN
      funLog("No items left in queue")
    ELSE
    ' display the item extracted
      funLog("Item = " & VARIANT$(vItem))
    END IF
    '
  NEXT lngItem
  '
  mCountItems(lngCountItems)
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
