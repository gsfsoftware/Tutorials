#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\DriveInfo.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Disk Utilities",0,0,40,120)
  '
  funLog("Disk Utilities")
  '
  LOCAL qBytes AS QUAD
  LOCAL strDrive AS STRING
  '
  ' select the local or remote drive
  strDrive = "C:\"
  'strDrive = "\\disk001\Backups\"
  'strDrive = "H:\"
  '
  ' get the disk capacity of a drive
  qBytes = DISKSIZE(strDrive)/(1024*1024*1024)
  'qBytes = qBytes/1024 ' kilobytes
  'qBytes = qBytes/1024 ' megabytes
  'qBytes = qBytes/1024 ' gigabytes
  '
  funLog("The " & strDrive & " drive is " & _
          FORMAT$(qBytes,"#,###") & " GB in size")
  '
  ' get the amount of free capacity on a drive
  qBytes = DISKFREE(strDrive)/(1024*1024*1024)
  funLog("The " & strDrive & " drive has " & _
          FORMAT$(qBytes,"#,###") & " GB free")
  '
  ' return the type of a drive
  funLog(funGetDriveType(strDrive))
  '
  ' report disk capacity of all drives on the local system
  funLog("All drives are -> " & funGetDriveSize)
  '
  funWait()
  '
END FUNCTION
'
