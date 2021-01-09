#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
#INCLUDE "..\Libraries\PBMonitor.inc"
'
%IDD_DIALOG1 = 101
%IDC_Button  = 102
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Screen Metrics",50,50,30,100)
  '
  funLog("Screen Metrics")
  '
  funlog (FORMAT$(METRICS(MAXIMIZED.X)) & " width")
  funlog (FORMAT$(METRICS(MAXIMIZED.Y)) & " height")
  '
  LOCAL lngWidth, lngHeight AS LONG
  DESKTOP GET SIZE TO lngWidth, lngHeight
  funLog ("Width = " & FORMAT$(lngWidth) & _
          ": Height = " & FORMAT$(lngHeight))
          '
  DESKTOP GET CLIENT TO lngWidth, lngHeight
  funLog ("Width = " & FORMAT$(lngWidth) & _
  ": Height = " & FORMAT$(lngHeight))
  '
  LOCAL lngX, lngY AS LONG
  DESKTOP GET LOC TO lngX, lngy
  funLog ("X = " & FORMAT$(lngX) & _
          ": Y = " & FORMAT$(lngY))
          '
  LOCAL lngMonitorCount AS LONG
  lngMonitorCount = funNoOfMonitors()
  '
  IF ISTRUE funMultipleMonitors THEN
    funLog("We have multiple monitors attached")
    funLog("Number of monitors = " & FORMAT$(lngMonitorCount))
  ELSE
    funLog("We have one monitor attached")
  END IF
  '
  LOCAL lngR AS LONG
  '
  FOR lngR = 1 TO lngMonitorCount
    funMonitorSize(lngR - 1, lngWidth, lngHeight)
    funLog("Monitor " & FORMAT$(lngR-1) & " is " & _
           FORMAT$(lngWidth) & " by " & _
           FORMAT$(lngHeight))
  NEXT lngR
  '
  funLog("")
  '
  LOCAL strTemp AS STRING
  FOR lngR = 1 TO lngMonitorCount
    strTemp = g_str_a_displays(lngR - 1)
    funLog("Monitor " & FORMAT$(lngR - 1) & " top left is " & _
           PARSE$(strTemp,"|", 1)  & " , " & _
           PARSE$(strTemp,"|", 2))
  NEXT lngR
  '
  ShowDIALOG1 0
  '
  funWait()
  '
END FUNCTION

'
FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG
  LOCAL hDlg  AS DWORD

  DIALOG NEW PIXELS, hParent, "Test dialog", 287, 247, 201, 121, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR OR %WS_EX_TOPMOST, _
    TO hDlg
    CONTROL ADD BUTTON, hDlg,%IDC_Button,"click me",50,50,100,20
  DIALOG SHOW MODAL hDlg, CALL ShowDIALOG1Proc TO lRslt

  FUNCTION = lRslt
END FUNCTION
'
CALLBACK FUNCTION ShowDIALOG1Proc()
  SELECT CASE AS LONG CB.MSG
    CASE %WM_COMMAND
      SELECT CASE AS LONG CB.CTL
        CASE %IDC_Button
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' button has been clicked
            MSGBOX "On Monitor " & FORMAT$(funWhichMonitor(CB.HNDL)) _
                   ,0, "Monitor detector"
          '
          END IF
      END SELECT
  END SELECT
END FUNCTION
'
