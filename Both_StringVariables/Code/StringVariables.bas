#COMPILE EXE
#DIM ALL

' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
$ConstantString = "This is a constant"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("String Variables",0,0,40,80)
  '
  funLog("Walk through on string variables ")
  '
  LOCAL strAstring AS STRING
  LOCAL Astring$
  '
  strAstring = "this is the string data"
  strAstring = strAstring & " more data"
  '
  LOCAL strAString2 AS WSTRING
  funLog(strAstring & $ConstantString)
  '
  LOCAL strString3 AS STRING *10
  strString3 = "A short string and some more"
  funLog(strString3 & "")
  '
  LOCAL strString4 AS STRINGZ * 10
  strString4 = "some data"
  funLog(strString4 & "")
  '
  funLog(funPCComputerName())
  '
  funWait()
'
END FUNCTION
'
FUNCTION funPCComputerName() AS STRING
' get the PCs computer name
  LOCAL zComputerName AS ASCIIZ * %MAX_COMPUTERNAME_LENGTH
  LOCAL lngValid AS LONG
  LOCAL lngComputerNameLength AS LONG
  '
  lngComputerNameLength =  %MAX_COMPUTERNAME_LENGTH +1
  lngValid = GetComputerName(zComputerName,lngComputerNameLength)
  '
  IF NOT lngValid THEN
    FUNCTION = zComputerName
  ELSE
    FUNCTION = ""
  END IF
  '
END FUNCTION
