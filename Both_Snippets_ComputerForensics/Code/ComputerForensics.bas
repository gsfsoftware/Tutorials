#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'


' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\PC_Info.inc"
#INCLUDE "..\Libraries\DriveInfo.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Computer Forensics",0,0,40,120)
  '
  funLog("Computer Forensics")
  '
  funLog("Computer name = " & funPCComputerName())
  funlog("User Name = " & funUserName())
  funlog("Domain = " & funGetDomain())
  '
  funlog("Memory = " & funGetMemory())
  funlog("Core count = " & funProcessorCount())
  '
  funlog("64 or 32bit = " & fun64or32bit())
  '
  funLog("C drive = " & FORMAT$(DISKSIZE("C")\ _
                        (1024*1024*1024)) & "GB")
                        '
  funLog("C drive free = " & FORMAT$(DISKFREE("C")\ _
                        (1024*1024*1024)) & "GB")
                        '
  funLog("DriveSizes (GB) = " & funGetDriveSize())
  '

  '
  funWait()
  '
END FUNCTION
'
