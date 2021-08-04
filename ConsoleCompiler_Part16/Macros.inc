' general useful macros

MACRO mConsoleWait()
  CON.STDOUT "Press any key to exit"
  WAITKEY$
END MACRO
'
MACRO mPrepConsole(Title)
  CON.CAPTION$ = Title
  CON.COLOR 6,0
  CON.SCREEN = 30,60
  '
  LOCAL Built AS IPOWERTIME
  LET built = CLASS "PowerTime"
  Built.Filetime = %PB_COMPILETIME
  CON.STDOUT "Compiled " & Built.DateString & " " & Built.TimeString
  '
  EXE.PATH$
END MACRO
