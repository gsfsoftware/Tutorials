#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON

' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
$CSVFile = "Myfile.csv"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Path Scan",0,0,40,120)
  '
  funLog("Walk through on PathScan command")
  '
  LOCAL strFileToSearchFor AS STRING
  LOCAL strFoldersToSearch AS STRING
  LOCAL strFolderFound AS STRING
  '
  ' name fo file to search for
  strFileToSearchFor = "ODBC32.dll"
  ' to search the inbuilt folders inc Window & Environment Path
  strFoldersToSearch = ""
  ' to search a specific path or list of paths
  ' strFoldersToSearch = exe.path$ & ";" & exe.path$ & "Folder1"
  '

  ' search for the file
  strFolderFound = PATHSCAN$(FULL, _
                             strFileToSearchFor, _
                             strFoldersToSearch)
                             '
  IF strFolderFound <> "" THEN
  ' file has been found
    funLog("Found in " & strFolderFound)
  ELSE
  ' file has not been found
    funLog("Not Found")
  END IF
  '
  funWait()
  '
END FUNCTION
