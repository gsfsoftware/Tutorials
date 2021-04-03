' general useful macros

#IF %DEF(%PB_WIN32)
MACRO mSetTextLimit(lngTextBox,lngLimit)
  CONTROL POST CB.HNDL,lngTextBox, %EM_SETLIMITTEXT,lngLimit, 0
END MACRO
#ENDIF

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

' -------------------------------------------------
' MACROS TO GET R, G, B values from RGB dword
' -------------------------------------------------
'MACRO mGetRed (RGBvalue) = RGBvalue AND &h0FF
'MACRO mGetGreen (RGBvalue) = (RGBvalue AND &h0FF00) \ &h100
'MACRO mGetBlue (RGBvalue) = (RGBvalue AND &h0FF0000) \ &h10000

MACRO mGetRed (lngResult) = lngResult MOD 256
MACRO mGetGreen (lngResult) = (lngResult\256) MOD 256
MACRO mGetBlue (lngResult) = (lngResult\256\256) MOD 256
