#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"

FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed

  PREFIX "CON."
    VIRTUAL = 40, 120
    CAPTION$= "The Console waitkey command"
    COLOR 10,-1       ' make the text green and default background
    LOC = 0,0         ' set the screen location of the console
  END PREFIX

  '
  CON.STDOUT "Write to the console"
  '
  'CON.STDOUT "Press Y or N to continue"
  LOCAL strInput AS STRING
  LOCAL lngTimeout AS LONG
  '
  lngTimeout = 3000
  '
  ' turn on capture of mouse events
  CON.MOUSE (2 OR 4 , 1 OR 2)
  CON.MOUSE.ON  ' turn mouse trapping on
  '
  'con.waitkey$("YyNn",lngTimeout) to strInput
  'con.stdout strInput
  CON.STDOUT "Press any key, or click mouse, to continue"
  '
  CON.WAITKEY$ TO strInput
  LOCAL strEventCode AS STRING
  LOCAL strButtoncode AS STRING
  '
  IF LEN(strInput) = 4 THEN
  '
    ' its a mouse event
    SELECT CASE MID$(strInput,3,1)
      CASE CHR$(1)
        CON.STDOUT "mouse movement"
       CASE CHR$(2)
        CON.STDOUT "double click"
      CASE CHR$(4)
        CON.STDOUT "button press"
      CASE CHR$(8)
        CON.STDOUT "button release"
    END SELECT
    '
    SELECT CASE MID$(strInput,4,1)
      CASE CHR$(0)
        CON.STDOUT "no button"
      CASE CHR$(1)
        CON.STDOUT "left button"
      CASE CHR$(2)
        CON.STDOUT "right button"
      CASE CHR$(4)
        CON.STDOUT "second left button"
      CASE CHR$(8)
        CON.STDOUT "third left button"
      CASE CHR$(16)
        CON.STDOUT "fourth left button"
    END SELECT
  '
  ELSE
    CON.STDOUT strInput
    IF UCASE$(strInput) = "N" THEN
      CON.STDOUT "Leaving app"
      SLEEP 2000
      EXIT FUNCTION
    END IF
    '
  END IF

  '
  CON.STDOUT "More processing - then exit"
  CON.WAITKEY$("",4000) ' wait for 4 seconds then exit
  '
END FUNCTION
'
