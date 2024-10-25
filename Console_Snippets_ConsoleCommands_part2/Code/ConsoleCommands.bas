#COMPILE EXE
#DIM ALL
'
' designate the number of rows and columns
' for the console
%Rows    = 50     ' increase the height
%Columns = 100    ' and width of the console
'
%TemplatePage = 8 ' page number of template page
'
GLOBAL g_astrColours() AS STRING
'
#INCLUDE "win32api.inc"
'
FUNCTION PBMAIN () AS LONG
' prepare the screen
  RANDOMIZE TIMER
  '
  REDIM g_astrColours(15) AS STRING
  funPrepColours()
  '
  ' prepare the monitor display
  funPrepScreen("Monitor Display")
  '
  ' display the screen
  funDisplayScreen()
  '
  ' now scroll up 10 lines
  ' moving the text on page downwards
  CON.SCROLL.UP(10)
  '
  LOCAL strInput AS STRING
  LOCAL strPage AS STRING
  LOCAL lngPage AS LONG
  '
  DO
    ' position cursor
    CON.CELL = 2,2
    ' set colour to black with white background
    CON.COLOR 0,7
    ' prompt user
    CON.INPUT("Do you wish to exit Yes/No ",strInput)
    '
    IF UCASE$(strInput) = "YES" THEN
    ' exit if YES entered
      EXIT LOOP
    ELSE
    '
      CON.CELL = 3,2
      CON.INPUT("Select page needed 1-2 ",strPage)
      lngPage = VAL(strPage)
      SELECT CASE lngPage
        CASE 1 TO 2
        ' set the visible and active console pages
          CON.PAGE.VISIBLE = lngPage
          CON.PAGE.ACTIVE  = lngPage
      END SELECT
      '
      ' otherwise redisplay the screen
      ' reset colour to green with black background
      CON.COLOR 2,0
      funDisplayScreen()
      ' now scroll up 10 lines
      CON.SCROLL.UP(10)
      '
    END IF
    '
  LOOP
  '
  ' now show each page to the user
  FOR lngPage = 1 TO 2
  ' show each page
    CON.PAGE.VISIBLE = lngPage
    WAITKEY$
  NEXT lngPage
  '
END FUNCTION
'
FUNCTION funDisplayScreen() AS LONG
' display details to the screen
  LOCAL lngRow, lngColumn AS LONG
  LOCAL strText AS STRING
  LOCAL lngCount AS LONG
  '
  CON.CLS  ' clear the screen
  '
  funDisplayHeaders() ' display the form headers
  '
  DO UNTIL lngCount = 10
    INCR lngCount
    ' print text to fixed locations on the console
    ' for each item
    lngRow = 4: lngColumn = 10
    strText = funSystemPolling()
    funPrintToConsole(lngRow,lngColumn,strText,"WHITE")
    '
    lngRow = 8: lngColumn = 13
    strText = FORMAT$(RND(60,85))
    funPrintToConsole(lngRow,lngColumn,strText,"WHITE")
    '
    lngRow = 8: lngColumn = 32
    strText = FORMAT$(RND(30,80))
    funPrintToConsole(lngRow,lngColumn,strText,"WHITE")
    '
    lngRow = 8: lngColumn = 47
    strText =  RSET$(FORMAT$(RND(10,2250),"#,##0"),5)
    funPrintToConsole(lngRow,lngColumn,strText,"WHITE")
    '
    SLEEP 1000
    '
  LOOP
  '
END FUNCTION
'
FUNCTION funSystemPolling() AS STRING
' is the system polling or not
' randomly select active/inactive
' ensure both strings are same length
  SELECT CASE RND(1,2)
    CASE 1
      FUNCTION = "active  "
    CASE 2
      FUNCTION = "inactive"
  END SELECT
'
END FUNCTION
'
FUNCTION funDisplayHeaders() AS LONG
' display header
  LOCAL lngRow, lngColumn AS LONG
  LOCAL strText AS STRING
  LOCAL lngActivePage AS LONG  ' console page number active
  LOCAL lngVisiblePage AS LONG ' console page number visible
  '
  STATIC lngStatus AS LONG     ' has the template been created?
  '
  CON.PAGE.ACTIVE TO lngActivePage
  CON.PAGE.VISIBLE TO lngVisiblePage
  '
  IF ISTRUE lngStatus THEN
  ' template has already been created
    CON.PCOPY %TemplatePage,lngActivePage
    ' set the location to print to
    lngRow = 1: lngColumn = 2
    ' call the print function
    funPrintToConsole(lngRow,lngColumn,"Page = " & _
                      FORMAT$(lngVisiblePage),"CYAN")
    EXIT FUNCTION
  '
  END IF
  '
   ' set status to true
  lngStatus = %TRUE
  '
  ' set the location to print to
  lngRow = 1: lngColumn = 2
  ' call the print function
  funPrintToConsole(lngRow,lngColumn,"Page = " & _
                    FORMAT$(lngVisiblePage),"CYAN")
                    '
  ' set the location to print to
  lngRow = 2: lngColumn = 2
  ' call the print function
  funPrintToConsole(lngRow,lngColumn,"MONITOR SYSTEM","RED")
  '
  lngRow = 4: lngColumn = 2
  strText = "Polling"
  funPrintToConsole(lngRow,lngColumn,strText,"GREEN")
  '
  lngRow = 6: lngColumn = 2
  strText = "Server stats"
  funPrintToConsole(lngRow,lngColumn,strText,"LIGHT CYAN")
  '
  lngRow = 8: lngColumn = 2
  strText = "CPU load %    CPU response ms     User Count "
  funPrintToConsole(lngRow,lngColumn,strText,"GREEN")
  '
  ' now copy to the template
  CON.PCOPY lngActivePage,%TemplatePage
  '
END FUNCTION
'
FUNCTION funPrintToConsole(lngRow AS LONG, _
                           lngColumn AS LONG, _
                           strText AS STRING, _
                           OPTIONAL strColour AS STRING) AS LONG
' print text to console
  IF ISFALSE ISMISSING(strColour) THEN
  ' if colour parameter given
  ' get the colour number associated
  ' with the colour name
    CON.COLOR funGetColour(strColour),-1
  END IF
  '
  ' set location to print to
  CON.CELL = lngRow, lngColumn
  ' print text to console with no CR/LF
  CON.PRINT strText;
  '
END FUNCTION
'
FUNCTION funGetColour(strColour AS STRING) AS LONG
' return the colour number
  LOCAL lngR AS LONG
  ' sweep through the array to find a match
  ' and return the element number
  ' which is the console colour number
  '
  FOR lngR = 0 TO UBOUND(g_astrColours)
    IF UCASE$(strColour) = UCASE$(g_astrColours(lngR)) THEN
      FUNCTION = lngR
      EXIT FUNCTION
    END IF
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funPrepScreen(strConsoleName AS STRING) AS LONG
' prepare the screen
  ' set the location of the console window
  ' on the screen using pixel coordinates
  ' from top left corner
  CON.LOC = 50, 50
  '
  ' set the size of the console window
  CON.VIRTUAL = %Rows, %Columns
  '
  ' title the console window
  CON.CAPTION$= strConsoleName
  '
  ' make the text green and default background
  CON.COLOR 10,-1
  '
END FUNCTION
'
FUNCTION funPrepColours() AS LONG
' assign the colours in the global array
' the position in the area is the console
' colour number
  ARRAY ASSIGN g_astrColours() = "Black", "Blue","Green", _
                                 "Cyan","Red","Magenta", _
                                 "Brown","White","Gray", _
                                 "Light Blue","Light Green", _
                                 "Light Cyan","Light Red", _
                                 "Light Magenta","Yellow", _
                                 "Intense White"
END FUNCTION
