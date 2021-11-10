' PB_Common_Windows.inc

#RESOURCE ICON, ColIcon,   "Colour.ico"
#RESOURCE ICON, BKColIcon, "BKColour.ico"

%ctlColourPicked = 1     ' constant for Colour picked
%ctlColourTarget = 2     ' constant for Target control for position
%ctlColourZone   = 3     ' constant for Colour Zone (forground/background)
%ctlPaintHandle  = 4     ' constant for Target control for painting

%ctlForegroundColour  = 1 ' constant for changing foreground colour
%ctlBackgroundColour  = 2 ' constant for changing background colour


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

FUNCTION funTempDirectory() AS STRING
' return the path to the windows Temporary folder
  LOCAL zText AS ASCIIZ * 256
  GetTempPath 256, zText
  FUNCTION = zText
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
