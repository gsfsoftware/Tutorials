'====================================================================
'
'  DIGITAL.BAS for PowerBASIC Compiler for Windows
'  Copyright (c) 2005-2011 PowerBASIC, Inc.
'  All Rights Reserved.
'
'  Shows how to use GRAPHIC COPY to copy desired parts from a bitmap
'  to create a "fancy" digital clock.
'
'====================================================================

#COMPILER PBWIN 10
#COMPILE EXE
#DIM ALL

#RESOURCE BITMAP 100, "BIG_Digits.bmp"

#INCLUDE ONCE "WIN32API.INC"

%ID_TIMER1    = 100
%IDC_GRAPHIC1 = 120


'====================================================================
FUNCTION PBMAIN () AS LONG
'--------------------------------------------------------------------
  ' PROGRAM ENTRANCE
  ' The dialog is created with Pixels option, which gives its child
  ' controls a pixel coordinates system. Exstyle& %WS_EX_TOPMOST is
  ' set to make it float on top and %WS_EX_TOOLWINDOW gives it a
  ' smaller Caption height, plus hides it from the taskbar.
  '------------------------------------------------------------------
  LOCAL hDlg AS DWORD

  DIALOG NEW PIXELS, 0, " Digital",,, 480, 80, _
                     %WS_CAPTION OR %WS_SYSMENU, _
                     %WS_EX_TOOLWINDOW OR %WS_EX_TOPMOST TO hDlg
  DIALOG SET COLOR hDlg, %BLACK, %BLACK

  '------------------------------------------------------------------
  CONTROL ADD GRAPHIC, hDlg, %IDC_GRAPHIC1, "", 0, 0, 480, 80
  GRAPHIC ATTACH hDlg, %IDC_GRAPHIC1, REDRAW
  GRAPHIC CLEAR %BLACK

  '------------------------------------------------------------------
  DIALOG SHOW MODAL hDlg, CALL DlgProc

END FUNCTION


'====================================================================
CALLBACK FUNCTION DlgProc() AS LONG
'--------------------------------------------------------------------
  ' MAIN DIALOG'S CALLBACK PROCEDURE
  ' A 500 ms (0.5 sec.) timer is created under %WM_INITDIALOG
  ' and it will trigger a %WM_TIMER message every 0.5 second,
  ' which in turn calls SUB DrawClock, where all drawing is done.
  '------------------------------------------------------------------
  LOCAL ac, c AS LONG, sTime AS STRING

  SELECT CASE CB.MSG
  CASE %WM_INITDIALOG                                ' <- sent right before the dialog is displayed.
      STATIC hBmp    AS DWORD                        ' Static bitmap handle
      STATIC idEvent AS LONG                         ' Keep SetTimer's result in a static variable
      idEvent = SetTimer(CB.HNDL, %ID_TIMER1, _      ' Create WM_TIMER events with the SetTimer API
                         500, BYVAL %NULL)           ' at 500 ms (0.5 s) interval
      GRAPHIC BITMAP LOAD "#100", _                  ' load bitmap strip with digits
                     840, 80 TO hBmp
      DIALOG POST CB.HNDL, %WM_TIMER, %ID_TIMER1, 0  ' force an initial %WM_TIMER "event"

  CASE %WM_TIMER                                     ' Posted by the created timer
      IF CB.WPARAM = %ID_TIMER1 THEN                 ' Make sure it's corrent timer id
          sTime = TIME$                              ' grab time string (00:00:00)
          FOR c = 1 TO LEN(sTime)                    ' parse through it
              ac = ASC(sTime, c)                     ' look at ASCII code for each character
              SELECT CASE AS LONG ac                 ' copy bitmap parts via lookup "table"
              CASE 48 TO 57                          ' digits 0 to 9
                  ac = ac - 48                       ' make the value zero-based and copy bmp part
                  GRAPHIC COPY hBmp, 0, (ac * 60, 0)-(ac * 60 + 58, 80) TO ((c - 1) * 60, 0)
              CASE 58                                ' colon is the 13th image in the Bmp strip
                  GRAPHIC COPY hBmp, 0, (12 * 60, 0)-(12 * 60 + 60, 80) TO ((c - 1) * 60, 0)
              END SELECT
          NEXT
          GRAPHIC REDRAW                             ' Now we can redraw it all
      END IF

  CASE %WM_DESTROY                                   ' Sent when the dialog is being destroyed
      IF idEvent THEN                                ' If a timer identifier exists
          KillTimer CB.HNDL, idEvent                 ' make sure to stop the timer events
      END IF
      GRAPHIC ATTACH hBmp, 0                         ' clean up memory
      GRAPHIC BITMAP END

  CASE %WM_COMMAND                                   ' <- A control is calling
      SELECT CASE CB.CTL                             ' <- Look at control's id
      CASE %IDCANCEL
          IF CB.CTLMSG = %BN_CLICKED THEN            ' Exit on Esc
              DIALOG END CB.HNDL
          END IF
      END SELECT

  END SELECT
END FUNCTION
