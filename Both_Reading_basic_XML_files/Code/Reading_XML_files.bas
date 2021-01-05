#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\PB_XML.inc"     ' new library
#INCLUDE "Config.inc"                  ' load specific XML include
'

FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Code Templates",0,0,40,120)
  '
  funLog("Code Templates")
  '
  ' read the config file values into global variables
  IF ISFALSE funGetXMLValues() THEN
  ' unable to read the xml config file
    funLog("Unable to read or find the XML config file")
  ELSE
  ' file read ok
    funLog("Config file read ok")
    funLog("Server = " & g_strServerName)
    funLog("Disk drive = " & g_strDiskDrive)
  END IF
  '
  funWait()
  '
END FUNCTION
'
