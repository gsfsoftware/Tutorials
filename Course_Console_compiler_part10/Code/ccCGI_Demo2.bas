' ccCGI_Demo2.bas
' CGI demo form application
'
#COMPILE EXE "TimeClock.exe"
#DIM ALL
'
#INCLUDE "Win32api.inc"
#INCLUDE "PBCGI.INC"
#INCLUDE "PB_FileHandlingRoutines.inc"
'
FUNCTION PBMAIN () AS LONG
' create the web page
  funCreateWebPage_V1()
  '
END FUNCTION
'
FUNCTION funCreateWebPage_V1() AS LONG
  LOCAL strHTML AS STRING
  '
   ' first load the template
  strHTML = funBinaryFileAsString(EXE.PATH$ & "Data\FormTemplate.txt")
  '
  ' replace the time tag
  REPLACE "@@TIME@@" WITH TIME$ IN strHTML
  '
  ' write back to browser
  writeCGI(strHTML)
  '
END FUNCTION
