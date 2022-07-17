' PBMonitor.inc
' This include file is used to gather information
' about displays connected to the system


GLOBAL g_lngMonitorCounter AS LONG
GLOBAL g_str_a_displays()AS STRING

FUNCTION EnumDisplay() AS LONG
  ' this function is used to call the api EnumDisplayMonitors
  ' function to gather details about displays connected to the system
  LOCAL lngDisplays AS LONG
  REDIM g_str_a_displays(0)
  lngDisplays = UBOUND(g_str_a_displays)
  EnumDisplayMonitors(BYVAL %NULL, BYVAL %NULL, _
                      BYVAL CODEPTR(MonInfoEnumProc), 0)
  '
END FUNCTION


FUNCTION MonInfoEnumProc(BYVAL hdc AS DWORD, _
                         BYVAL hmon AS DWORD, _
                         BYREF xy AS RECT, _
                         BYVAL pdat AS DWORD) AS LONG
  LOCAL strPosition AS LONG
  LOCAL lngDisplays AS LONG
  ' called by EnumDisplayMonitors used to calculated display sizes
  '
  lngDisplays = UBOUND(g_str_a_displays)
  g_str_a_displays(lngDisplays) = g_str_a_displays(lngDisplays) & _
            FORMAT$(xy.nLeft) & "|" & FORMAT$(xy.nTop) & "|" & _
            FORMAT$(xy.nRight) & "|" & FORMAT$(xy.nBottom) & "|"
            '
  g_str_a_displays(lngDisplays) = LTRIM$(g_str_a_displays(lngDisplays), " ")
  '
  REDIM PRESERVE g_str_a_displays(lngDisplays+1)
  g_lngMonitorCounter = g_lngMonitorCounter + 1
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funWhichMonitor(hDlg AS DWORD) AS LONG
' return the monitor the dialog is on
  LOCAL lngMonitorCount AS LONG
  LOCAL lngMonitor AS LONG
  LOCAL strTemp AS STRING
  LOCAL lngLeft AS LONG, lngRight AS LONG, lngTop AS LONG , lngBottom AS LONG
  LOCAL x1&, y1&
  '
  DIALOG GET LOC hDlg TO x1&, y1&
  '
  ' now work out which monitor this is
  lngMonitorCount =  funNoOfMonitors
  FOR lngMonitor = 0 TO lngMonitorCount -1
    strTemp = g_str_a_displays(lngMonitor)
    lngLeft = VAL(PARSE$(strTemp,"|", 1))
    lngTop = VAL(PARSE$(strTemp,"|", 2))
    lngRight = VAL(PARSE$(strTemp,"|", 3))
    lngBottom = VAL(PARSE$(strTemp,"|", 4))
    '
    IF x1& >= lngLeft AND x1&<=lngRight AND y1&>= lngTop AND y1& <= lngBottom THEN
    ' we are on this screen
      FUNCTION = lngMonitor
      EXIT FUNCTION
    END IF
    '
  NEXT lngMonitor
  '
  FUNCTION = 99 ' not on any screen
  '
END FUNCTION
'
FUNCTION funMultipleMonitors() AS LONG

  EnumDisplay()
  ' returns true if there are more than one monitor and false if not
  IF g_lngMonitorCounter > 1 THEN
    FUNCTION = %TRUE
  ELSE
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION

FUNCTION funNoOfMonitors() AS LONG
' returns a numerical value of the number of monitors connected to a system
  g_lngMonitorCounter = 0
  funMultipleMonitors()
  FUNCTION = g_lngMonitorCounter
  '
END FUNCTION
'
FUNCTION funMonitorSize(lngMonPostion AS LONG, lngWidth AS LONG, lngHeight AS LONG) AS LONG
  LOCAL temp AS STRING
  LOCAL strLeft AS STRING
  LOCAL strRight AS STRING
  LOCAL strTop AS STRING
  LOCAL strBottom AS STRING
   ' retrieves the size of a particular monitor based on the
   ' position number in the array, size starting from 0
   temp = g_str_a_displays(lngMonPostion)
   strLeft = PARSE$(temp,"|", 1)
   strTop = PARSE$(temp,"|", 2)
   strRight = PARSE$(temp,"|", 3)
   strBottom = PARSE$(temp,"|", 4)

   lngWidth = VAL(strRight) - VAL(strLeft)

   lngHeight = VAL(strBottom) - VAL(strTop)

END FUNCTION

FUNCTION FunMonitorsSize(a_sizes() AS STRING) AS LONG
  LOCAL strLeft AS STRING
  LOCAL strRight AS STRING
  LOCAL strTop AS STRING
  LOCAL strBottom AS STRING
  LOCAL i AS LONG
  LOCAL lngWidth AS LONG
  LOCAL lngHeight AS LONG
  LOCAL temp AS STRING

  ' retrieves the size of all monitors stored in the array
  REDIM a_sizes(0)AS STRING
  FOR i = 0 TO g_lngMonitorCounter
     temp = g_str_a_displays(i)
     strLeft = PARSE$(temp,"|", 1)
     strTop = PARSE$(temp,"|", 2)
     strRight = PARSE$(temp,"|", 3)
     strBottom = PARSE$(temp,"|", 4)
     lngWidth = VAL(strRight) - VAL(strLeft)
     lngHeight = VAL(strBottom) - VAL(strTop)
     a_sizes(UBOUND(a_sizes)) = a_sizes(UBOUND(a_sizes)) & STR$(lngWidth) & "|" &  STR$(lngHeight)
     REDIM PRESERVE a_sizes(UBOUND(a_sizes())+1)
  NEXT
  '
  REDIM PRESERVE a_sizes(UBOUND(a_sizes())-2)
  '
END FUNCTION

FUNCTION funCentreDialogOnMonitor(hDlg AS LONG, lngPos AS LONG) AS LONG
  LOCAL x AS LONG
  LOCAL y AS LONG
  LOCAL xx AS LONG
  LOCAL yy AS LONG
  LOCAL lngWidth AS LONG
  LOCAL lngHeight AS LONG
  LOCAL lngWidth2 AS LONG
  LOCAL lngHeight2 AS LONG
  LOCAL strTemp  AS STRING
  LOCAL newX AS LONG
  LOCAL newY AS LONG
  LOCAL WndRect AS RECT
  LOCAL lngTemp AS LONG

  'centres a dialog on the screen with the values previously gathered

  GetWindowRect hDlg, WndRect
  x = WndRect.nRight-WndRect.nLeft
  y = WndRect.nBottom-WndRect.nTop+GetSystemMetrics(%SM_CYCAPTION)

  funGetMonitorSize(lngPos, lngWidth, lngHeight)

  IF lngPos >= 1 THEN
    lngTemp = lngWidth/4
    newX = (lngWidth - x)/2 + lngTemp
    newY = (lngHeight - y)/2
  ELSE
    newX = (lngWidth - x)/2
    newY = (lngHeight - y)/2
  END IF

  SetWindowPos hDlg, %NULL, newX, newY, _
               x, y, %SWP_NOSIZE OR %SWP_NOZORDER

END FUNCTION

FUNCTION funGetMonitorSize(lngPos AS LONG, _
                           lngWidth AS LONG, _
                           lngHeight AS LONG)AS LONG
  LOCAL temp AS STRING
  LOCAL strRight AS STRING
  LOCAL strBottom AS STRING

 ' gets the monitor size from the position in the desktop,
 ' size starting from the end of the previous display
 temp = g_str_a_displays(lngPos)
 strRight = PARSE$(temp,"|", 3)
 strBottom = PARSE$(temp,"|", 4)

 lngWidth = VAL(strRight)
 lngHeight = VAL(strBottom)

END FUNCTION
