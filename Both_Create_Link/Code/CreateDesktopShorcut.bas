#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
#INCLUDE "PBCreateLink.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Desktop shortcut",0,0,40,120)
  '
  funLog("Desktop shortcut")
  '
  LOCAL strFolderPath AS STRING
  LOCAL wstrLinkName AS WSTRING
  LOCAL wstrComment AS WSTRING
  LOCAL wstrFile AS STRING
  LOCAL lngReturn AS LONG
  '
  wstrComment = "Run the Demo app"
  wstrLinkName = "Demo_App - shortcut"
  wstrFile = EXE.PATH$ & "Demo.exe"
  '
  ' first get the path to the Desktop folder
  strFolderPath = funGetKnownFolder($FOLDERID_Desktop)
  '
  lngReturn = CreateLink(strFolderPath & wstrLinkName & ".lnk", _
              wstrFile, "", "", _
              wstrComment, "", 0, %SW_NORMAL)
  '
  funWait()
  '
END FUNCTION
'
