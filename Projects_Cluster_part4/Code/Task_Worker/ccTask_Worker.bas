#COMPILE EXE
#DIM ALL

#DEBUG ERROR ON

#INCLUDE ONCE "WIN32API.INC"
#INCLUDE "..\..\Libraries\UDPcomms.inc"
'
$TargetServer = "Octal002"
'
GLOBAL g_lngProccessorCount AS LONG
'
ENUM Condition      ' Current condition of worker
  Active = 1        ' Awaiting work
  Processing        ' Processing work
  Completed         ' Completed work
  NotActive         ' Not available for work
END ENUM
'
FUNCTION PBMAIN () AS LONG
  LOCAL strMessage AS STRING
  LOCAL lngCore AS LONG
  '
  g_strUDPServer = $TargetServer
  '
  ' work out the number of processors
  g_lngProccessorCount = funProcessorCount
' and the computer name
  g_strThisComputer = funPCComputerName
  '
  ' set amber colour and report
  COLOR 14,0
  PREFIX "con.stdout "
    "Launching " & g_strThisComputer
    "With " & FORMAT$(g_lngProccessorCount) & " cores"
  END PREFIX
  '
  ' now launch each of the Worker Cores
  FOR lngCore = 1 TO g_lngProccessorCount
    strMessage = funQueryUDPServer("ACTIVE|" & FORMAT$(lngCore))
    CON.STDOUT strMessage
  NEXT lngCore
  '
  SLEEP 4000
  '
END FUNCTION
'
FUNCTION funProcessorCount() AS LONG
' return the core count
  '
  FUNCTION = VAL(ENVIRON$("NUMBER_OF_PROCESSORS"))
'
END FUNCTION
