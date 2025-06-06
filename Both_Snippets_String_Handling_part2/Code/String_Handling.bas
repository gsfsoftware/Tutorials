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
$ParaStart = "<p>"
$ParaEnd   = "</p>"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("String Handling",0,0,40,120)
  '
  funLog("String Handling")
  '
  LOCAL strHTML AS STRING     ' html page
  LOCAL strData AS STRING     ' data to insert
  LOCAL strHTMLdata AS STRING ' formated HTML
  '
  ' create an HTML string
  strHTML = "<html><body><p>Some data</p>@@TAG@@</body></html>"
  ' send to log
  funLog("HTML = " & $CRLF & strHTML & $CRLF)
  '
  ' prepare new text to insert
  strData = "Some more text to place in a paragraph"
  '
  ' wrap double quotes round the text
  strData = WRAP$(strData,$DQ,$DQ)
  '
  ' wrap paragraph tags around text
  strHTMLdata = WRAP$(strData,$ParaStart,$ParaEnd)
  '
  ' replace the TAG string in the HTML
  REPLACE "@@TAG@@" WITH strHTMLdata IN strHTML
  '
  ' send to log
  funLog("HTML now = " & $CRLF & strHTML & $CRLF)
  '
  LOCAL strExtractedData AS STRING
  ' pull the 2nd paragraph out of the HTML
  strExtractedData = PARSE$(strHTML,$ParaStart,3)
  '
  strExtractedData = PARSE$(strExtractedData,$ParaEnd,1)
  '
  strExtractedData = UNWRAP$(strExtractedData,$DQ,$DQ)
  '
  ' send to log
  funLog("Extracted string = " & $CRLF & strExtractedData & $CRLF)
  '
  LOCAL strNewHTML AS STRING
  '
  strNewHTML = WRAP$(WRAP$(strExtractedData,$DQ,$DQ), _
                     "<html><body>@@TIME@@<p>Some data</p><p>", _
                     "</p></body></html>")
                     '
  ' replace the time tag with the actual time
  ' wrapping it in paragraph tags
  REPLACE "@@TIME@@" WITH _
          WRAP$(TIME$,$ParaStart,$ParaEnd) _
          IN strNewHTML
          '
  ' send to log
  funLog("Reformed string = " & $CRLF & strNewHTML & $CRLF)
  '
  funWait()
  '
END FUNCTION
'
