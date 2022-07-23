#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Tally command",0,0,40,120)
  '
  funLog("Tally command")
  '
  LOCAL strData AS STRING
  '
  strData = "PowerBASIC offers a selection of compilers " & _
            "and other tools for software development. " & _
            "Perfect for all programmers, whether you’re a " & _
            "novice, an expert , or somewhere in between. "
            '
  ' trim off leading or trailing space characters
  strData = TRIM$(strData)
  ' remove specified characters from the string
  strData = REMOVE$(strData,ANY ",.;:?!")
  ' leave only one space between each word
  strData = SHRINK$(strData)
  '
  ' count the instances of a single space character and add 1
  LOCAL lngWordCount AS LONG
  lngWordCount = TALLY(strData," ") +1
  '
  funLog("Number of words = " & FORMAT$(lngWordCount))
  '
  ' add more text to the string
  strData = strData & " 568 people online"
  '
  LOCAL lngNumberCount AS LONG
  ' report on number of instances of any number between 0-9
  lngNumberCount = TALLY(strData, ANY "0123456789")
  '
  funLog("Number of numeric characters = " & FORMAT$(lngNumberCount))
  '
  LOCAL strData2 AS STRING
  '
  strData2 = "Jones,1200,active" & $CRLF & _
             "Smith,1100,active" & $CRLF & _
             "MacDonald,1200,inactive" & $CRLF & _
             "Campbell,12001,active" & $CRLF
  '
  ' report on instances of the word 'active' preceded by a comma
  funlog("Active = " & FORMAT$(TALLY(strData2,",active")))
  ' report on instances of '1200' both preceded and followed by a comma
  funlog("1200 entries = " & FORMAT$(TALLY(strData2,",1200,")))
  '
  funWait()
  '
END FUNCTION
'
