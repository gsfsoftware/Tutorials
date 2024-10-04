#COMPILE EXE
#DIM ALL
'
' designate the number of rows and columns
' for the console
%Rows    = 25
%Columns = 80
'
GLOBAL g_astrColours() AS STRING
'
'
FUNCTION PBMAIN () AS LONG
' prepare the screen
  RANDOMIZE TIMER
  '
  LOCAL lngRow, lngColumn AS LONG
  LOCAL strText AS STRING
  LOCAL lngCount AS LONG
  '
  REDIM g_astrColours(15) AS STRING
  funPrepColours()
  '
  funPrepScreen("Monitor Display")
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
