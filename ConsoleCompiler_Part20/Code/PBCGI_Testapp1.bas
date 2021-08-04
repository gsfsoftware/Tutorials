#COMPILE EXE
#DIM ALL

#INCLUDE "Win32api.inc"

#INCLUDE "../Libraries/PBCGI.inc"
#INCLUDE "../Libraries/PB_FileHandlingRoutines.inc"

FUNCTION PBMAIN () AS LONG
  LOCAL strInfo AS STRING
  LOCAL x AS STRING
  LOCAL p AS LONG
  DIM strParam(1) AS STRING
  LOCAL lngR AS LONG
  LOCAL strHTML AS STRING
  '
  ' read from stdIN
  x = ReadCGI
  ' count the parameters and put in an array
  p = ParseParams(x,strParam())
  '
  IF p THEN
    FOR lngR = 1 TO UBOUND(strParam)
      SELECT CASE lngR
        CASE 1
          strInfo = DecodeCGI(strParam(lngR))
      END SELECT
    NEXT lngR
  END IF

  strHTML = "<html>" & _
            "<p>You have reached the CGI app with - " & strInfo & "</p>" & _
            "</html>"
            '
  funAppendToFile(EXE.PATH$ & "htmlforms\info.htm", strHTML)
  STDOUT "LOCATION: http://quad002/CGI_BIN/htmlforms/info.htm" & $CRLF

END FUNCTION
