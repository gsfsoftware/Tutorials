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
  funPrepOutput("Remain / Extract",0,0,40,120)
  '
  funLog("Remain / Extract")
  '
  LOCAL strTelephone AS STRING
  '
  ' first remain$ command
  strTelephone = "home number 0810 345 34560"
  ' look for first number and return everything after it
  strTelephone = REMAIN$(strTelephone, ANY "0123456789")
  funLog("Telephone = " & strTelephone)
  '
  strTelephone = "1234 home number 0810 345 34560"
  ' skip first 4 characters and start on 5th character
  strTelephone = REMAIN$(5,strTelephone, ANY "0123456789")
  funLog("Telephone = " & strTelephone)
  '
  strTelephone = "1234 home number 8101 345 34560"
  ' look for match and return characters after it
  strTelephone = REMAIN$(5,strTelephone, "8101")
  funLog("Telephone = " & strTelephone)
  '
  strTelephone = "home number 8101 345 34560 ext 1234"
  ' return just the extension
  strTelephone = REMAIN$(-8,strTelephone, "ext")
  funLog("Telephone = " & strTelephone)
  '
  ' now for Extract$ command
  LOCAL strAddress AS STRING
  strAddress = "12 Any Street, Anywhere, zip 12345-6789"
  '
  ' extract everything up until but not including first comma
  funLog(EXTRACT$(strAddress,","))
  '
  ' extract everything up until but not including "zip"
  funLog(EXTRACT$(strAddress,"zip"))
  ' extract up until but not including first comma
  ' but starting on 3rd character
  funLog(EXTRACT$(3,strAddress,","))
  '
  LOCAL strAddress1 AS STRING
  LOCAL strAddress2 AS STRING
  ' extract everything up until but not including first comma
  ' or semi colon character from the 3rd character onwards
  funLog($CRLF & "Multiple formats")
  strAddress1 = "12 Any Street, Anywhere, zip 12345-6789"
  strAddress2 = "12 Any Street; Anywhere, zip 12345-6789"
  '
  funLog(EXTRACT$(3,strAddress1,ANY ";,"))
  funLog(EXTRACT$(3,strAddress2,ANY ";,"))
  '
  funWait()
  '
END FUNCTION
'
