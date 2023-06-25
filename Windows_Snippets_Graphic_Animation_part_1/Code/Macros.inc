' general useful macros
' Macros.inc
'
' mSetTextLimit(lngTextBox,lngLimit) - Put a limit on the
'                               maximum number of characters that
'                               a text box can hold
'
' mSetTextReadOnly(lngTextBox, lngState) - set the text box to
'                               read only {%TRUE} or
'                               editable {%FALSE}
'
' mSetTextPreSelect(lngTextBox) - preselect any text in the text box
'


#IF %DEF(%PB_WIN32)
MACRO mSetTextLimit(lngTextBox,lngLimit)
' set the character limit on text control
  CONTROL POST CB.HNDL,lngTextBox, %EM_SETLIMITTEXT,lngLimit, 0
END MACRO
'
MACRO mSetTextReadOnly(lngTextBox, lngState)
  CONTROL POST CB.HNDL,lngTextBox, %EM_SETREADONLY,lngState,0
END MACRO
'
MACRO mSetTextPreSelect(lngTextBox)
  CONTROL POST CB.HNDL, lngTextBox, %EM_SETSEL, 0,-1
END MACRO
'
MACRO macDialogToPixels(hDlg , x, y)
' convert Dialog units to Pixels
  LOCAL xx&, yy&
  DIALOG UNITS hDlg, x +20, y+20 TO PIXELS xx&, yy&
  '
  #IF %PB_REVISION = &H1004 ' if compiler PBWIN10.04
    SWAP xx&, yy&           ' swap variables
  #ENDIF                    ' fix for flaw in dialog units cmd
  '
END MACRO
'
#ENDIF

#IF %DEF(%PB_CC32)
MACRO mConsoleWait()
' prompt for console exit
  CON.STDOUT "Press any key to exit"
  WAITKEY$
END MACRO
'
MACRO mPrepConsole(Title)
' prep console with build date/time
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

'MACRO mGetRed (lngResult) = lngResult MOD 256
'MACRO mGetGreen (lngResult) = (lngResult\256) MOD 256
'MACRO mGetBlue (lngResult) = (lngResult\256\256) MOD 256
