' general useful macros

#IF %DEF(%PB_CC32)
MACRO mConsoleWait()
  CON.STDOUT "Press any key to exit"
  WAITKEY$
END MACRO
'
MACRO mPrepConsole(Title)
  CON.CAPTION$ = Title   ' caption the console
  CON.COLOR 6,0          ' set foreground and background colours
  CON.SCREEN = 30,60     ' set the screen size in rows and columns
  '
  LOCAL Built AS IPOWERTIME         'prep the PowerTime class
  LET built = CLASS "PowerTime"
  Built.Filetime = %PB_COMPILETIME  ' pick up the date/time of compilation
  CON.STDOUT "Compiled " & Built.DateString & " " & Built.TimeString
  '
END MACRO
#ENDIF
