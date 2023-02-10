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
  funPrepOutput("Parse/Join",0,0,40,120)
  '
  funLog("Parse/Join")
  '
  ' set up a header
  LOCAL strHeader AS STRING
  'strHeader = "Name,Address,Department,Age,Division"
  ' put in an embedded double quote
  strHeader = "Name,Address,""Department,Office"",Age,Division"
  '
  DIM a_strHeader(1 TO PARSECOUNT(strHeader)) AS STRING '
  '
  ' parse the data into the array
  ' {optional parameter defaults to comma if not specified}
  'PARSE strHeader,a_strHeader(),","
  PARSE strHeader,a_strHeader()
  '
  ' list the array to the log
  funListArray(a_strHeader())
  '
  ' increase the size of the array by 1 element
  REDIM PRESERVE a_strHeader(1 TO UBOUND(a_strHeader)+1) AS STRING
  '
  ' insert a new element into the array at position 4
  ARRAY INSERT a_strHeader(2), "Payroll"
  '
  ' output a blank line to the log
  funLog("")
  ' list the array to the log
  funListArray(a_strHeader())
  '
  ' sort the array from element 3 onwards
  ARRAY SORT a_strHeader(3), COLLATE UCASE, ASCEND
  '
  ' output a blank line to the log
  funLog("")
  ' list the array to the log
  funListArray(a_strHeader())
  '
  ' join each element of the array to the Header string
  ' strHeader = JOIN$(a_strHeader(),",")
  '
  ' use double quotes
  strHeader = JOIN$(a_strHeader(),$QCQ)
  '
  ' output a blank line to the log
  funLog("")
  ' output the new header
  funLog(strHeader)
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funListArray(BYREF a_strHeader() AS STRING) AS LONG
' list the array to the log
'
  LOCAL lngH AS LONG
  FOR lngH = 1 TO UBOUND(a_strHeader)
  ' list each element of the array
    funLog(a_strHeader(lngH))
  NEXT lngH
  '
END FUNCTION
'
