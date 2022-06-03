#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\PB_INI_Files.inc"

FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("INI Files",0,0,40,120)
  '
  funLog("INI Files")
  '
  LOCAL strIniFile AS STRING
  LOCAL strSection AS STRING
  LOCAL strPartName AS STRING
  LOCAL strDefault AS STRING
  LOCAL strOutput AS STRING
  LOCAL strValue AS STRING
  '
  ' read from INI file
  strIniFile  = EXE.PATH$ & "Test.ini"
  strSection  = "Section_one"
  strPartName = "Path1"
  strDefault  = "none"
  '
  strOutput = funRead_INI_Data(strIniFile , _
                               strSection , _
                               strPartName , _
                               strDefault )
  funLog("Value = " & strOutput)
  '
  ' write to INI file
  strIniFile  = EXE.PATH$ & "Test.ini"
  strSection  = "Section_one"
  strPartName = "Exe"
  strValue    = EXE.PATH$
  '
  IF ISTRUE funWrite_Ini_Data(strIniFile , _
                              strSection , _
                              strPartname , _
                              strValue ) THEN
  ' updated ok
    funLog("INI updated with " & strValue)
  ELSE
    funLog("INI not updated")
  END IF
  '
  ' write to INI file - new partname
  strIniFile  = EXE.PATH$ & "Test.ini"
  strSection  = "Section_one"
  strPartName = "Exe folder"
  strValue    = EXE.PATH$
  '
  IF ISTRUE funWrite_Ini_Data(strIniFile , _
                              strSection , _
                              strPartname , _
                              strValue ) THEN
  ' updated ok
    funLog("INI updated with " & strValue)
  ELSE
    funLog("INI not updated")
  END IF
  '
  ' write to INI file - new section & partname
  strIniFile  = EXE.PATH$ & "Test.ini"
  strSection  = "Section_three"
  strPartName = "New Exe folder"
  strValue    = "new data"
  '
  IF ISTRUE funWrite_Ini_Data(strIniFile , _
                              strSection , _
                              strPartname , _
                              strValue ) THEN
  ' updated ok
    funLog("INI updated with " & strValue)
  ELSE
    funLog("INI not updated")
  END IF
  '
  ' delete a part of INI file
  strIniFile  = EXE.PATH$ & "Test.ini"
  strSection  = "Section_five"
  strPartName = "Data01"
  '
  IF ISTRUE funDelete_INI_Partname(strIniFile, _
                                   strSection, _
                                   strPartName) THEN
    funLog(strPartname & " deleted")
  ELSE
    funLog(strPartname & " not deleted")
  END IF
  '
  ' delete a whole section
  strIniFile  = EXE.PATH$ & "Test.ini"
  strSection  = "Section_four"
  '
  IF ISTRUE funDelete_INI_Section(strIniFile, _
                                  strSection) THEN
    funLog(strSection & " deleted")
  ELSE
    funLog(strSection & " not deleted")
  END IF
  '
  funWait()
  '
END FUNCTION
'
