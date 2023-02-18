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
  funPrepOutput("Conditional Code",0,0,40,120)
  '
  funLog("Conditional Code")
  '
  ' build an array to hold some data
  DIM a_strData(1 TO 9) AS STRING
  ARRAY ASSIGN a_strData() = "apple","orange","grapefruit", _
                             "pear","apricot","banana", _
                             "peach","plum","watermelon"
  '
  ' display the data on the log
  LOCAL lngF AS LONG
  FOR lngF = 1 TO UBOUND(a_strData)

  ' filter out all but one
    'IF a_strData(lngF) = "apple" THEN
    '  funLog(a_strData(lngF))
    'end if
    '
    ' filter out all but two items
    'if a_strData(lngF) = "apple" then
    '  funLog(a_strData(lngF))
    'elseif a_strData(lngF) = "pear" then
    '  funLog(a_strData(lngF))
    'else
    ' for all other records
    'end if
    '
    ' filter out all but two items, with less typing
    'IF a_strData(lngF) = "apple" OR _
    '   a_strData(lngF) = "pear" THEN
    '  funLog(a_strData(lngF))
    'END IF
    '
    ' filter out just one item
    'IF a_strData(lngF) <> "apple" then
    '  funLog(a_strData(lngF))
    'end if
    '
    ' try to exclude two item types
    'IF a_strData(lngF) <> "apple" or _
    '   a_strData(lngF) <> "pear" THEN
    '  funLog(a_strData(lngF))
    'END IF
    '
    ' exclude two item types
    'select case a_strData(lngF)
    '  case "apple","pear"
    '  ' do nothing
    '  case else
    '    funLog(a_strData(lngF))
    'end select
    '
    ' exclude everything alpabetically >= "pear"
    SELECT CASE a_strData(lngF)
      CASE IS >= "pear"
      CASE ELSE
        funLog(a_strData(lngF))
    END SELECT
    '
  NEXT lngF
  '
  funWait()
  '
END FUNCTION
'
