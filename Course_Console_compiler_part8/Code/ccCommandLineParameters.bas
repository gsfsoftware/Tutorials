#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
'#INCLUDE "CommonDisplay.inc"
#INCLUDE "PB_CommandLine.inc"
'
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  'funPrepOutput("Command line Parameters",0,0,40,120)
  '
  'funLog("Command line Parameters")
  '
  '/TimeSlotRef#"1" /Building#"2" /Hour#"3" /TimeSlot#"4"
  LOCAL strCommand AS STRING      ' entire command line
  LOCAL strTimeSlotRef AS STRING  ' named parameters
  LOCAL strBuilding AS STRING
  LOCAL strHour AS STRING
  LOCAL strTimeSlot AS STRING
  '
  strCommand = COMMAND$
  'funLog("Command line = " & strCommand)
  '
  strTimeSlotRef = funReturnNamedParameterEXP("/TimeSlotRef#" , _
                                              strCommand)
  strBuilding = funReturnNamedParameterEXP("/Building#" , _
                                           strCommand)                                              '
  strHour = funReturnNamedParameterEXP("/Hour#" , _
                                       strCommand)
  strTimeSlot = funReturnNamedParameterEXP("/TimeSlot#" , _
                                       strCommand)
                                       '
  'funLog("TimeSlotRef = " & strTimeSlotRef)
  'funLog("Building = " & strBuilding)
  'funLog("Hour = " & strHour)
  'funLog("TimeSlot = " & strTimeSlot)
  '
  IF strBuilding = "" THEN
  ' use alternate delimiter
    strBuilding = funReturnNamedParameterEXP("|Building#" , _
                                             strCommand)
  END IF
  '
  PREFIX "stdout"
    strCommand
    "TimeSlotRef = " & strTimeSlotRef
    "Building = " & strBuilding
    "Hour = " & strHour
    "TimeSlot = " & strTimeSlot
  END PREFIX
  '
  SLEEP 7000  ' wait 7 seconds                                          '
  'funWait()
  '
END FUNCTION
'
