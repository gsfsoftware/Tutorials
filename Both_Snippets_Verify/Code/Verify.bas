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
  funPrepOutput("Verify command",0,0,40,120)
  '
  funLog("Verify command")
  '
  ' Determine whether each character of a string is
  ' present in another string.
  LOCAL strData AS STRING          ' variable to hold data string
  strData = "ATCGTAGCATTAU"
  '
  LOCAL lngResult AS LONG          ' position of first character
                                   ' that does not match
  LOCAL strResult AS STRING        ' Result of verification
  '
  ' verify the DNA bases in the string
  IF ISTRUE funVerifyDNAbases(strData,lngResult) THEN
    strResult = " Verifies"
  ELSE
    strResult = " fails to verify at position " & FORMAT$(lngResult)
  END IF
  '
  funLog(strData & strResult & $CRLF)
  '
  ' verify numbers
  LOCAL lngStart AS LONG  ' variable to hold start position
  lngStart = 9            ' verify from 9th character onwards
  '
  strData = "Value = 123.99"
  lngResult = VERIFY(lngStart,strData,"0123456789.")
  '
  IF lngResult = 0 THEN
    strResult = " Number Verifies"
  ELSE
    strResult = " Number does not Verify"
  END IF
  '
  funLog(strData & strResult & $CRLF)
  '
  ' verify a case dependant string
  strData = "Yes"
  ' looking for uppercase YES
  lngResult = VERIFY(strData,"YES")
  '
  IF lngResult = 0 THEN
    strResult = " YES found"
  ELSE
    strResult = " YES not found"
  END IF
  '
  funLog(strData & strResult & $CRLF)
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funVerifyDNAbases(strData AS STRING, _
                           o_lngResult AS LONG) AS LONG
' verify the DNA bases
  LOCAL strDNAbases AS STRING      ' variable to hold match string
  strDNAbases = "ATCG"
  '
  ' verify against DNAbases
  o_lngResult = VERIFY(strData,strDNAbases)
  '
  ' Test result
  IF o_lngResult = 0 THEN
    FUNCTION = %TRUE
  ELSE
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
