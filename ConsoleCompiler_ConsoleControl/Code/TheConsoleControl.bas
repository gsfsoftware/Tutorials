#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'#console off   ' launch app with no initial console visible
'
' include the Windows API library
#INCLUDE "win32api.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
'
  PREFIX "CON."
    VIRTUAL = 40, 120
    CAPTION$= "Console control"
    COLOR 10,-1       ' make the text green and default background
    LOC = 0,0         ' set the screen location of the console
  END PREFIX
  '
  LOCAL strInput AS STRING
  ' prompt user for single character input
  CON.STDOUT "Start processing Y/N?"
  ' only accept Y,y,N or n keys
  strInput = CON.WAITKEY$("YyNn")
  IF UCASE$(strInput) = "Y" THEN
    funStartProcessing()
  END IF
'  funStartProcessing()
  '
  CON.STDOUT "Exiting App in 3 seconds"
  ' wait for any single key press or exit in 3 seconds
  CON.WAITKEY$("",3000)
  '
END FUNCTION
'
FUNCTION funStartProcessing() AS LONG
' start the processing
  'con.new   ' create a new console if one does not exist
  CON.PAGE.ACTIVE = 2  ' set active console page to 2
  '
  LOCAL lngPage AS LONG
  lngPage = CON.PAGE.ACTIVE ' detect current console page
  CON.PRINT "Current console page = " & FORMAT$(lngPage)
  ' print out to console
  CON.PRINT "test"       ' this cannot be redirected to a file
  ' this can be redirected to a file
  CON.STDOUT "New messages go here"
  '
  ' output numbers with spaces between on the console
  LOCAL lngR AS LONG
  FOR lngR = 1 TO 5
    CON.PRINT FORMAT$(lngR) SPC(4);
  NEXT lngR
  '
  SLEEP 2000
  CON.STDOUT "Finishing"
  CON.PAGE.VISIBLE = 2  ' set the visible page
  SLEEP 3000
  CON.CLS   ' clear the console
  CON.PAGE.ACTIVE = 1
  CON.PAGE.VISIBLE = 1
  CON.STDOUT "Switch back"
'
END FUNCTION
