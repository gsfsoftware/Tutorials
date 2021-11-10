' PB_Common_Windows.inc

#RESOURCE ICON, ColIcon,   "Colour.ico"
#RESOURCE ICON, BKColIcon, "BKColour.ico"
#RESOURCE ICON, FonIcon,   "Font.ico"

%ctlColourPicked = 1     ' constant for Colour picked
%ctlColourTarget = 2     ' constant for Target control for position
%ctlColourZone   = 3     ' constant for Colour Zone (forground/background)
%ctlPaintHandle  = 4     ' constant for Target control for painting
%ctlFontHandle   = 5     ' constant for font handle in global array
%ctlFontDescHandle = 6   ' constant for handle of font desc box

%ctlForegroundColour  = 1 ' constant for changing foreground colour
%ctlBackgroundColour  = 2 ' constant for changing background colour

GLOBAL g_lngFontHandles() AS LONG ' global array to hold font handles
GLOBAL g_strFontDescription() AS STRING ' global array to hold font
                                        ' descriptions


TYPE CustomColours
  Colours(16) AS LONG
END TYPE

TYPE ctlColourParams
  hDlg AS DWORD                  ' handle of the dialog
  lngRootControlHandle AS LONG   ' handle of the control to place beside
  lngCtlHandle AS LONG           ' handle of the colour picker control
  lngPaintHandle AS LONG         ' handle of the control you want to paint
  lngColourZone AS LONG          ' foreground or background
END TYPE
'
TYPE ctlFontParams
  hDlg AS DWORD                  ' handle of the dialog
  lngRootControlHandle AS LONG   ' handle of the control to place beside
  lngCtlHandle AS LONG           ' handle of the font picker control
  lngPaintHandle AS LONG         ' handle of the control you want to change font on
  lngFontNumber AS LONG          ' the font number to be applied
  lngFontPicked AS LONG          ' handle to txt box containing picked font
END TYPE
'
FUNCTION funInitialiseFonts(OPTIONAL lngTotalFonts AS LONG) AS LONG
' prepare the global array for fonts
  LOCAL lngFont AS LONG
  LOCAL lngMaxFonts AS LONG
  '
  IF ISTRUE ISMISSING(lngTotalFonts) THEN
    lngMaxFonts = 20
  ELSE
    lngMaxFonts = lngTotalFonts
  END IF
  '
  REDIM g_lngFontHandles(lngMaxFonts) AS LONG
  REDIM g_strFontDescription(lngMaxFonts) AS STRING
  '
  FONT NEW "Verdana",12,0,0,0,0 TO lngFont
  '
  g_lngFontHandles(1) = lngFont
  g_strFontDescription(1) = "Verdana. Regular. 12pt."
  '
END FUNCTION
'
FUNCTION funTempDirectory() AS STRING
' return the path to the windows Temporary folder
  LOCAL zText AS ASCIIZ * 256
  GetTempPath 256, zText
  FUNCTION = zText
END FUNCTION
'
FUNCTION funPlaceFontPicker(u_ctlFontParams AS _
                            ctlFontParams) AS LONG
' create a font picker control on hDlg
' to the right of the last control
  LOCAL lngX AS LONG
  LOCAL lngY AS LONG
  LOCAL lngWidth AS LONG
  LOCAL lngHeight AS LONG
  '
  LOCAL ctl AS ctlFontParams POINTER
  ctl = VARPTR(u_ctlFontParams)
  '
  LOCAL strIcon AS STRING ' name of the resource icon
  strIcon = "fonIcon"
  '
  CONTROL GET LOC @ctl.hDlg, @ctl.lngRootControlHandle TO lngX , lngY
  CONTROL GET SIZE @ctl.hDlg, @ctl.lngRootControlHandle TO lngWidth, lngHeight
  '
  ' work out where to place it on screen
  lngX = lngX + lngWidth + 5
  CONTROL ADD IMGBUTTONX, @ctl.hDlg, @ctl.lngCtlHandle,strIcon, _
    lngX, lngY, lngHeight, lngHeight,%WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %BS_ICON OR _
    %BS_PUSHBUTTON OR %BS_CENTER OR %BS_VCENTER, %WS_EX_LEFT OR _
    %WS_EX_LTRREADING , CALL funFontButtonCallback()
    '
  ' now add the font description
  CONTROL GET SIZE @ctl.hDlg, @ctl.lngPaintHandle TO lngWidth , lngHeight
  lngX = lngX + lngHeight +5
  lngWidth = lngWidth + 40
  CONTROL ADD TEXTBOX, @ctl.hDlg, @ctl.lngFontPicked,"", lngX, lngY, _
     lngWidth, lngHeight,%WS_CHILD OR %WS_VISIBLE OR %ES_READONLY , _
    %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
    '
  ' show font description
  CONTROL SET TEXT @ctl.hDlg, @ctl.lngFontPicked, _
                   g_strFontDescription(@ctl.lngFontNumber)
                   '
  ' store the font details
  PREFIX "Control set user @ctl.hDlg,@ctl.lngCtlHandle,"
    %ctlColourTarget, @ctl.lngRootControlHandle  ' store target ctl
    %ctlPaintHandle, @ctl.lngPaintHandle    ' store control to be painted
    %ctlFontDescHandle, @ctl.lngFontPicked  ' store the handle to font description box
  END PREFIX
  ' now store the font handle in the control that contains the font
  PREFIX "Control set user @ctl.hDlg, @ctl.lngPaintHandle,"
    %ctlFontHandle, @ctl.lngFontNumber
  END PREFIX
  '
END FUNCTION
'
FUNCTION funPlaceColourPicker(u_ctlColourParams AS _
                              ctlColourParams) AS LONG
' create a colour picker control on hDlg
' to the right of lngTarget
  LOCAL lngX AS LONG
  LOCAL lngY AS LONG
  LOCAL lngWidth AS LONG
  LOCAL lngHeight AS LONG
  '
  LOCAL ctl AS ctlColourParams POINTER
  ctl = VARPTR(u_ctlColourParams)
  '
  LOCAL strIcon AS STRING ' name of the resource icon
  '
  IF @ctl.lngColourZone = %ctlForegroundColour THEN
  ' set the resource icon depending on forground or background
    strIcon = "ColIcon"
  ELSE
    strIcon = "BKColIcon"
  END IF
  '
  CONTROL GET LOC @ctl.hDlg, @ctl.lngRootControlHandle TO lngX , lngY
  CONTROL GET SIZE @ctl.hDlg, @ctl.lngRootControlHandle TO lngWidth, lngHeight
  '
  ' work out where to place on screen
  lngX = lngX + lngWidth + 5
  CONTROL ADD IMGBUTTONX, @ctl.hDlg, @ctl.lngCtlHandle,strIcon, _
    lngX, lngY, lngHeight, lngHeight,%WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %BS_ICON OR _
    %BS_PUSHBUTTON OR %BS_CENTER OR %BS_VCENTER, %WS_EX_LEFT OR _
    %WS_EX_LTRREADING , CALL funColorButtonCallback()
    '
  ' store the target control in %ctlColourTarget
  PREFIX "control set user @ctl.hDlg,@ctl.lngCtlHandle,"
    %ctlColourTarget, @ctl.lngRootControlHandle ' store the target control
    %ctlColourZone, @ctl.lngColourZone ' store the back/forground
    %ctlPaintHandle , @ctl.lngPaintHandle ' store control to be painted
  END PREFIX
  '
  ' now store the foreground and background colours in the control
  ' to be painted
  PREFIX "control set user @ctl.hDlg, @ctl.lngPaintHandle,"
    %ctlForegroundColour, %BLACK
    %ctlBackgroundColour, %WHITE
  END PREFIX
'
END FUNCTION
'
FUNCTION funGetFontDetails(lngFontNumber AS LONG _
                          ,o_strFontName AS STRING, _
                          o_lngPointsize AS LONG, _
                          o_lngStyle AS LONG ) AS LONG
' get the values for font selected
' "Verdana. Regular. 12pt."
  LOCAL strTemp AS STRING
  o_strFontName = PARSE$(g_strFontDescription(lngFontNumber),".",1)
  strTemp = PARSE$(g_strFontDescription(lngFontNumber),".",3)
  strTemp = TRIM$(RTRIM$(strTemp,"pt"))
  o_lngPointsize = VAL(strTemp)
  strTemp = PARSE$(g_strFontDescription(lngFontNumber),".",2)
  '
  SELECT CASE strTemp
    CASE "Regular"
      o_lngStyle = 0
    CASE ELSE
      o_lngStyle = 0
  END SELECT
  '
END FUNCTION
'
CALLBACK FUNCTION funFontButtonCallback()
' handle the events for the font button
  LOCAL strDefaultFont AS STRING
  LOCAL lngDefPoints AS LONG
  LOCAL lngDefStyle AS LONG
  LOCAL lngFlags AS LONG
  '
  LOCAL strFontName AS STRING
  LOCAL lngPoints AS LONG
  LOCAL lngStyle AS LONG
  LOCAL lngColour AS LONG
  LOCAL lngCharset AS LONG
  LOCAL strFontString AS STRING
  LOCAL lngTarget AS LONG
  '
  funGetFontDetails(1,strDefaultFont, _
           lngDefPoints, lngDefStyle)
  lngFlags = %CF_TTONLY OR %CF_EFFECTS OR %CF_FORCEFONTEXIST
  '
  SELECT CASE AS LONG CB.MSG
  ' handle the call back messages
    CASE %WM_COMMAND
    ' process control notifcations
      IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
      ' font button has been clicked
        DISPLAY FONT CB.HNDL,200,200, strDefaultFont, _
           lngDefPoints, lngDefStyle, lngFlags _
           TO strFontName, lngPoints, lngStyle, _
           lngColour, lngCharset
           '
        IF strFontName <> "" THEN
        ' return the selection an display it
          strFontString = strFontName & ". " & _
                          funGetFontStyle(lngStyle) & ". " & _
                          FORMAT$(lngPoints) & "pt."
                          '
          ' now put this text in the font description box
          CONTROL GET USER CB.HNDL,CB.CTL, %ctlFontDescHandle TO lngTarget
          CONTROL SET TEXT CB.HNDL, lngTarget, strFontString
        '
        END IF
      '
      END IF
  END SELECT
'
END FUNCTION
'
FUNCTION funGetFontStyle(lngStyle AS LONG) AS STRING
' return the style as a description
  LOCAL strStyle AS STRING
  '
  SELECT CASE lngStyle
    CASE 0
      strStyle = "Regular"
    CASE 1
      strStyle = "Bold"
    CASE 2
      strStyle = "Italic"
    CASE 3
      strStyle = "Bold & Italic"
    CASE 4
      strStyle = "Underline"
    CASE 5
      strStyle = "Bold & Underline"
    CASE 6
      strStyle = "Italic & Underline"
    CASE 7
      strStyle = "Bold, Italic & Underline"
    CASE 8
      strStyle = "Strikeout"
  END SELECT
  '
  FUNCTION = strStyle
  '
END FUNCTION
'
CALLBACK FUNCTION funColorButtonCallback()
' handle the events for te colour button
  LOCAL lngColour AS LONG
  LOCAL lngFlags AS LONG
  STATIC udtColours AS CustomColours
  '
  LOCAL lngColourZone AS LONG
  LOCAL lngPaintHandle AS LONG
  LOCAL lngForeColour AS LONG   ' current background colour
  LOCAL lngBackcolour AS LONG   ' current foreground colour
  LOCAL hControl AS DWORD       ' windows handle for Control
  '
  lngFlags = %CC_FULLOPEN  ' display the selection
  '
  SELECT CASE AS LONG CB.MSG
  ' handle the call back messages
    CASE %WM_COMMAND
    ' process control notifcations
      IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
        DISPLAY COLOR CB.HNDL , , ,%BLACK,udtColours, _
                lngFlags TO lngColour
        ' save the colour picked
        IF lngColour <> -1 THEN
          CONTROL SET USER CB.HNDL, CB.CTL,%ctlColourPicked, lngColour
          ' has a target control been set?
          CONTROL GET USER CB.HNDL, CB.CTL, %ctlPaintHandle TO _
                                            lngPaintHandle
          '
          ' are we changing foreground or background
          CONTROL GET USER CB.HNDL, CB.CTL, %ctlColourZone TO _
                                           lngColourZone
          IF lngPaintHandle <> 0 THEN
            IF lngColourZone = %ctlForegroundColour THEN
            ' foreground
              CONTROL GET USER CB.HNDL, lngPaintHandle, _
                               %ctlBackgroundColour TO lngBackColour
              CONTROL SET COLOR CB.HNDL, lngPaintHandle, _
                               lngColour, lngBackColour
              CONTROL SET USER CB.HNDL, lngPaintHandle, _
                               %ctlForegroundColour, lngColour
              '
            ELSE
            ' background colour changing
              CONTROL GET USER CB.HNDL, lngPaintHandle, _
                               %ctlForegroundColour TO lngForeColour
              CONTROL SET COLOR CB.HNDL, lngPaintHandle, _
                               lngForeColour, lngColour
              CONTROL SET USER CB.HNDL, lngPaintHandle, _
                               %ctlBackgroundColour, lngColour

            END IF
            CONTROL REDRAW CB.HNDL, lngPaintHandle
          ELSE
          ' nothing to do as no target to be painted
          END IF

        END IF
        '
      END IF
  END SELECT

END FUNCTION
'
FUNCTION funGetColourPickerColour(hDlg AS DWORD,_
                                  lngControl AS LONG) AS LONG
' return the colour selected for this control
  LOCAL lngColour AS LONG
  '
  CONTROL GET USER hDlg,lngControl,%ctlColourPicked TO lngColour
  '
  FUNCTION = lngColour
'
END FUNCTION
'
FUNCTION funGetTextValue(hdlg AS DWORD, _
                         lngControl AS LONG) AS STRING
' get the text value from the specified control
  LOCAL strText AS STRING
  '
  CONTROL GET TEXT hDlg, lngControl TO strText
  FUNCTION = strText
'
END FUNCTION
