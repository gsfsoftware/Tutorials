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

#RESOURCE BITMAP 100, "BIG_Digits2.bmp"

#INCLUDE ONCE "WIN32API.INC"

%ID_TIMER1    = 100
%IDC_GRAPHIC1 = 120

$TargetDate = "13/06/2024"  ' set a target date in dd/MM/yyyy format


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

  DIALOG NEW PIXELS, 0, " Digital",,, 680, 120, _
                     %WS_CAPTION OR %WS_SYSMENU, _
                     %WS_EX_TOOLWINDOW OR %WS_EX_TOPMOST TO hDlg
  DIALOG SET COLOR hDlg, %BLACK, %BLACK

  '------------------------------------------------------------------
  CONTROL ADD GRAPHIC, hDlg, %IDC_GRAPHIC1, "", 0, 0, 680, 120
  GRAPHIC ATTACH hDlg, %IDC_GRAPHIC1, REDRAW
  GRAPHIC CLEAR %BLACK

  '------------------------------------------------------------------
  DIALOG SHOW MODAL hDlg, CALL DlgProc

END FUNCTION


'====================================================================
CALLBACK FUNCTION DlgProc() AS LONG
'--------------------------------------------------------------------
  ' MAIN DIALOG'S CALLBACK PROCEDURE
  ' A 3000 ms (30 sec.) timer is created under %WM_INITDIALOG
  ' and it will trigger a %WM_TIMER message every 0.5 second,
  '------------------------------------------------------------------
  LOCAL ac, c AS LONG, sTime AS STRING

  SELECT CASE CB.MSG
  CASE %WM_INITDIALOG                                ' <- sent right before the dialog is displayed.
      STATIC hBmp    AS DWORD                        ' Static bitmap handle
      STATIC idEvent AS LONG                         ' Keep SetTimer's result in a static variable
      idEvent = SetTimer(CB.HNDL, %ID_TIMER1, _      ' Create WM_TIMER events with the SetTimer API
                         30000, BYVAL %NULL)           ' at 500 ms (0.5 s) interval
      GRAPHIC BITMAP LOAD "#100", _                  ' load bitmap strip with digits
                     840, 120 TO hBmp
      DIALOG POST CB.HNDL, %WM_TIMER, %ID_TIMER1, 0  ' force an initial %WM_TIMER "event"

  CASE %WM_TIMER                                     ' Posted by the created timer
      IF CB.WPARAM = %ID_TIMER1 THEN                 ' Make sure it's corrent timer id
          sTime = funGetCountDown()                  ' grab time string (00:00:00)
          FOR c = 1 TO LEN(sTime)                    ' parse through it
              ac = ASC(sTime, c)                     ' look at ASCII code for each character
              SELECT CASE AS LONG ac                 ' copy bitmap parts via lookup "table"
              CASE 48 TO 57                          ' digits 0 to 9
                ac = ac - 48                       ' make the value zero-based and copy bmp part
                GRAPHIC COPY hBmp, 0, (ac * 60, 0)-(ac * 60 + 58, 80) TO ((c - 1) * 60, 40)
             ' CASE 58                                ' colon is the 13th image in the Bmp strip
             '     GRAPHIC COPY hBmp, 0, (12 * 60, 0)-(12 * 60 + 60, 80) TO ((c - 1) * 60, 0)
              END SELECT
          NEXT
          GRAPHIC COPY hBmp,0,(0,80)-(680,120) TO (0,0)
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
'
FUNCTION funGetCountDown() AS STRING
' return Months - Days - Hours - minutes
' countdown
' $TargetDate in dd/MM/yyyy format
  LOCAL strResult AS STRING      ' result to be returned
  ' prep the current date/time
  LOCAL DateCalc AS IPOWERTIME
  LET DateCalc = CLASS "PowerTime"
  DateCalc.Now   ' set to now
  '
  ' prep the future data/time
  LOCAL FutureDate AS IPOWERTIME
  LET FutureDate = CLASS "PowerTime"
  '
  ' create local vars to hold year/month/day
  LOCAL lngYear AS LONG
  LOCAL lngMonth AS LONG
  LOCAL lngDay AS LONG
  '
  '  store future date
  lngYear  = VAL(RIGHT$($TargetDate,4))
  lngMonth = VAL(MID$($TargetDate,4,2))
  lngDay   = VAL(LEFT$($TargetDate,2))
  FutureDate.NewDate(lngYear,lngMonth,lngDay)
  '
  ' prep local vars to be used in date and time diff
  LOCAL lngSign,lngYears, lngMonths, lngDays AS LONG
  LOCAL lngHours, lngMinutes AS LONG
  '
  ' calculate first part (years/months/days)
  DateCalc.DateDiff(FutureDate, lngSign,lngYears, lngMonths, lngDays)
  ' prep the result for months & days
  strResult = RIGHT$(" " & FORMAT$(lngMonths + (lngYears * 12)),2) & " " & _
              RIGHT$(" " & FORMAT$(lngDays),2) & " "
              '
  ' calculate second part (Days & hours & minutes)
  DateCalc.TimeDiff(FutureDate, lngSign,lngDays,lngHours, lngMinutes)
  '
  ' add on hours and minutes to result
  strResult = strResult & RIGHT$(" " & FORMAT$(lngHours),2) & " " & _
                          RIGHT$(" " & FORMAT$(lngMinutes),2)
                          '
  FUNCTION = strResult
'
END FUNCTION
