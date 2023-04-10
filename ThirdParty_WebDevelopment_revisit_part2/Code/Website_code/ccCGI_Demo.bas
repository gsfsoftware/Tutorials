' ccCGI_Demo.bas
' CGI demo application
'
#COMPILE EXE
#DIM ALL
'
#INCLUDE "Win32api.inc"
#INCLUDE "PBCGI.INC"
'
FUNCTION PBMAIN () AS LONG
' return a basic web page
  LOCAL strInput AS STRING
  DIM strParam() AS STRING
  LOCAL lngPcount AS LONG
  LOCAL strFirstParameter AS STRING
  LOCAL strUser AS STRING
  LOCAL strComputer AS STRING
  LOCAL strDomain AS STRING
  '
  ' Read from STDIN
  strInput = ReadCGI
  ' Count and parse the parameters into an array
  lngPcount = ParseParams(strInput, strParam())
  '
  IF lngPcount > 0 THEN
  ' pick up first parameter
    strFirstParameter = DecodeCGI(strParam(1))
    '
    strUser = PARSE$(strFirstParameter,"|",1)
    strComputer = PARSE$(strFirstParameter,"|",2)
    strDomain = PARSE$(strFirstParameter,"|",3)
    '
    WriteCGI "<html><body>" & _
           "<h1>User = " & strUser &" <br>" & _
           "Computer = " & strComputer &" <br>" & _
           "Domain = " & strDomain &" <br>" & _
           "occurred on " & DATE$ & " at " & TIME$ & "</h1>" & _
           "</body></html>"
    '
  ELSE
  ' no parameters - failure to authenticate
    WriteCGI "<html><body>" & _
           "<h1>Failure to authenticate <br>" & _
           "occurred on " & DATE$ & " at " & TIME$ & "</h1>" & _
           "</body></html>"
  END IF

END FUNCTION
