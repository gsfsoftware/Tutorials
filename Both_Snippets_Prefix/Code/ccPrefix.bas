#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON

' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
TYPE udtUserInfo
  strFirstName AS STRING * 50
  strSurname AS STRING * 50
  strCity AS STRING * 50
  strCountry AS STRING * 50
  strTelephone AS STRING * 40
END TYPE
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Prefix",0,0,40,120)
  '
  funLog("Walk through on Prefix command")
  '
  DIM uUsers(5) AS udtUserInfo
  LOCAL lngR AS LONG
  '
  lngR = 1
  PREFIX "uUsers(lngR)."
    strFirstName = "Fred"
    strSurname = "Smith"
    strCity = "Edinburgh"
    strCountry = "Scotland"
    strTelephone = "01317777777"
  END PREFIX
  '
  PREFIX "funLog (trim$(uUsers(lngR)."
    strFirstName))
    strSurname))
    strCity))
    strTelephone))
  END PREFIX
  '
  LOCAL hWinVar AS DWORD
  GRAPHIC WINDOW NEW "Title", 600,150, 300, 300 TO hWinVar
  PREFIX "GRAPHIC LINE (10, 10) - "
    (10, 100)
    (40, 120)
    (80, 140)
  END PREFIX
  '
  funWait()
  '
END FUNCTION
