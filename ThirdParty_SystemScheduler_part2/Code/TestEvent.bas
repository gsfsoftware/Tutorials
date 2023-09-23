#COMPILE EXE
#DIM ALL

FUNCTION PBMAIN () AS LONG
  LOCAL strData AS STRING
  LOCAL lngFile AS LONG
  '
  CON.COLOR 10,-1
  '
  strData = "Event AAA_MonitorFolderService is stopped " & TIME$
  '
  lngFile = FREEFILE
  OPEN EXE.PATH$ & "Status.txt" FOR APPEND AS #lngFile
  PRINT #lngFile,strData
  CLOSE #lngFile
  '
  CON.STDOUT strData
  SLEEP 2000
  '
END FUNCTION
