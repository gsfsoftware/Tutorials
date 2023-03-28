#COMPILE EXE
#DIM ALL

' example backup SQL code
'SqlCmd -E -S DISK001\SQLEXPRESS01 -Q "BACKUP DATABASE A_YouTubeProjects TO DISK ='E:\Backups\SQL_Backups\A_YouTubeProjects.bak' WITH FORMAT"
'
#INCLUDE "Win32api.inc"
' include the file handling library
#INCLUDE "PB_FileHandlingRoutines.inc"
' include the Shell library
#INCLUDE "PB_Shell.inc"
' include the command line parameters library
#INCLUDE "PB_CommandLine.inc"
'
FUNCTION PBMAIN () AS LONG
  ' work out the day of the week
  ' and launch backup of SQL DB
  '
  LOCAL iToday AS IPOWERTIME     ' PowerTime variable
  LET iToday = CLASS "PowerTime"
  '
  LOCAL strDayOfWeek AS STRING   ' Day of the week
  LOCAL strCMD AS STRING         ' command line string
  LOCAL strBatch AS STRING       ' batch command to launch
  '
  LOCAL strDatabaseName AS STRING ' name of the DB to backup
  LOCAL strBackupFolder AS STRING ' path of the backup
  LOCAL strBackupName AS STRING   ' name of the backup
  LOCAL strSQLServer AS STRING    ' name of the SQL Server
  '
  strCMD = COMMAND$              ' pick up command line data
  '
  iToday.Now  ' pick up today
  ' get the name of the Day e.g. Monday
  strDayOfWeek = iToday.DayOfWeekString
  '
  ' hard code the key variables ?
  'strDatabaseName = "A_YouTubeProjects"
  'strBackupFolder = "'E:\Backups\SQL_Backups\"
  'strBackupName = strBackupFolder & strDayOfWeek & "_" & strDatabaseName & ".bak'"
  'strSQLServer  = "DISK001\SQLEXPRESS01"
  '
  ' take key variables on the command line
  ' pick up name of database to back up
  strDatabaseName = funReturnNamedParameterEXP("/DB#",strCMD)
  ' pick up folder to back up to
  strBackupFolder = funReturnNamedParameterEXP("/Folder#",strCMD)
  '
  ' form name and path to backup file - including day name
  strBackupName   = strBackupFolder & strDayOfWeek & "_" & _
                    strDatabaseName & ".bak'"
  ' pick up name of SQL server/instance name
  strSQLServer    = funReturnNamedParameterEXP("/SQLserver#",strCMD)
  '
  CON.STDOUT "DB = " & strDatabaseName
  CON.STDOUT "Back to " & strBackupFolder
  CON.STDOUT "Backup name " & strBackupName
  CON.STDOUT "From " & strSQLServer
  '
  'form up the command line call to SqlCmd
  strBatch = "SqlCmd -E -S " & strSQLServer & " -Q " & _
             $DQ & "BACKUP DATABASE " & strDatabaseName & _
             " TO DISK =" & strBackupName & " WITH FORMAT" & $DQ
             '
  ' now launch the batch command
  funExecCmd(strBatch & "")
  '
  CON.STDOUT "Exiting in 2 seconds"
  SLEEP 2000
  '
END FUNCTION
