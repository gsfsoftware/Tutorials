' PB_Common_Windows.inc

#RESOURCE ICON, ColIcon, "Colour.ico"

%ctlColourPicked = 1     ' constant for Colour picked

TYPE CustomColours
  Colours(16) AS LONG
END TYPE

FUNCTION funTempDirectory() AS STRING
' return the path to the windows Temporary folder
  LOCAL zText AS ASCIIZ * 256
  GetTempPath 256, zText
  FUNCTION = zText
END FUNCTION
'
FUNCTION funPlaceColourPicker(hDlg AS DWORD, _
                              lngTarget AS LONG, _
                              lngColControl AS LONG) AS LONG
' create a colour picker control on hDlg
' to the right of lngTarget
  LOCAL lngX AS LONG
  LOCAL lngY AS LONG
  LOCAL lngWidth AS LONG
  LOCAL lngHeight AS LONG
  '
  CONTROL GET LOC hDlg, lngTarget TO lngX , lngY
  CONTROL GET SIZE hDlg, lngTarget TO lngWidth, lngHeight
  '
  ' work out where to place on screen
  lngX = lngX + lngWidth + 5
  CONTROL ADD IMGBUTTONX, hDlg, lngColControl,"ColIcon", _
    lngX, lngY, lngHeight, lngHeight,%WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %BS_ICON OR _
    %BS_PUSHBUTTON OR %BS_CENTER OR %BS_VCENTER, %WS_EX_LEFT OR _
    %WS_EX_LTRREADING , CALL funColorButtonCallback()
'
END FUNCTION
'
CALLBACK FUNCTION funColorButtonCallback()
' handle the events for te colour button
  LOCAL lngColour AS LONG
  LOCAL lngFlags AS LONG
  STATIC udtColours AS CustomColours
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
