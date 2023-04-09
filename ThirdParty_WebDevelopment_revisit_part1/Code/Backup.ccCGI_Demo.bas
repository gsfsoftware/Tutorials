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
  WriteCGI "<html><body>" & _
           "This is a basic Web page <br>" & _
           "created on " & DATE$ & " at " & TIME$ & _
           "</body></html>"

END FUNCTION
