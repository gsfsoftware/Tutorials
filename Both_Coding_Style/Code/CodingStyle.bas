#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
%MaxDaysInEvent = 7
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Code Templates",0,0,40,120)
  '
  funLog("Code Templates")
  ' array to hold visitor count per day
  DIM a_strVisitorsPerDay(%MaxDaysInEvent) AS STRING
  LOCAL lngDay AS LONG   ' Day number of the event
  '
  ' output visitor numbers for each day of the evernt
  FOR lngDay = 1 TO UBOUND(a_strVisitorsPerDay)
    ' store a random number for testing the array
    a_strVisitorsPerDay(lngDay) = FORMAT$(RND(1,10))
    ' output vistors for this day
    funLog(FORMAT$(lngDay) & " = " & a_strVisitorsPerDay(lngDay))
  NEXT a
  '
  funWait()
  '
END FUNCTION
'
%a = 7
'
FUNCTION funNotTheBestApproach() AS LONG
' this will compile but will probably be confusing
  funLog("Code Templates")
  '
  DIM a(%a) AS STRING
  LOCAL a AS LONG
  '
  FOR a = 1 TO UBOUND(a)
    a(a) = FORMAT$(RND(1,10))
    funlog(FORMAT$(a) & " = " & a(a))
  NEXT a
  '
  funWait()
END FUNCTION
