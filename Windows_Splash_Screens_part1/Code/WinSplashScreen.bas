#PBFORMS CREATED V2.01
'------------------------------------------------------------------------------
' The first line in this file is a PB/Forms metastatement.
' It should ALWAYS be the first line of the file. Other
' PB/Forms metastatements are placed at the beginning and
' end of "Named Blocks" of code that should be edited
' with PBForms only. Do not manually edit or delete these
' metastatements or PB/Forms will not be able to reread
' the file correctly.  See the PB/Forms documentation for
' more information.
' Named blocks begin like this:    #PBFORMS BEGIN ...
' Named blocks end like this:      #PBFORMS END ...
' Other PB/Forms metastatements such as:
'     #PBFORMS DECLARATIONS
' are used by PB/Forms to insert additional code.
' Feel free to make changes anywhere else in the file.
'------------------------------------------------------------------------------

#COMPILE EXE
#DIM ALL

'------------------------------------------------------------------------------
'   ** Includes **
'------------------------------------------------------------------------------
#PBFORMS BEGIN INCLUDES
#RESOURCE "WinSplashScreen.pbr"
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
#LINK "zSpinPB10.sll"
'
' store the animated loading screen
#RESOURCE RCDATA, 4000 ,"SpinFolder\loading.ski"
#RESOURCE RCDATA, 4001 ,"SpinFolder\wait.ski"
#RESOURCE RCDATA, 4002 ,"Spinfolder\gear01.ski"


'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_FIRSTDIALOG =  101
%IDC_LABEL1      = 1001
%IDABORT         =    3
%IDOK            =    1
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowFIRSTDIALOGProc()
DECLARE FUNCTION ShowFIRSTDIALOG(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
  '
  ' save the spinner file
  funSaveSpinner()
  ' launch the spinner busy graphic
  CALL zSpinnerInit(%HWND_DESKTOP, funTempDirectory & "gear01.ski", 0)
  '
  ShowFIRSTDIALOG %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funSaveSpinner() AS LONG
' save spinned graphics to temporary folder
  LOCAL lngFreeFile AS LONG
  LOCAL strSpin AS STRING
  '
  ' save current spinner to disk
  strSpin  = RESOURCE$(RCDATA, 4000)
  lngFreeFile = FREEFILE
  TRY
    OPEN funTempDirectory & "loading.ski" FOR OUTPUT AS #lngFreeFile
    PRINT #lngFreeFile, strSpin  ;
  CATCH
  FINALLY
    CLOSE #lngFreeFile
  END TRY
  '
  strSpin  = RESOURCE$(RCDATA, 4001)
  lngFreeFile = FREEFILE
  TRY
    OPEN funTempDirectory & "wait.ski" FOR OUTPUT AS #lngFreeFile
    PRINT #lngFreeFile, strSpin  ;
  CATCH
  FINALLY
    CLOSE #lngFreeFile
  END TRY
  '
  strSpin  = RESOURCE$(RCDATA, 4002)
  lngFreeFile = FREEFILE
  TRY
    OPEN funTempDirectory & "gear01.ski" FOR OUTPUT AS #lngFreeFile
    PRINT #lngFreeFile, strSpin  ;
  CATCH
  FINALLY
    CLOSE #lngFreeFile
  END TRY
  '
END FUNCTION
'
FUNCTION funTempDirectory() AS STRING
  LOCAL zText AS ASCIIZ * 256
  GetTempPath 256, zText
  FUNCTION = zText
END FUNCTION
'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowFIRSTDIALOGProc()

  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler
      SLEEP 5000            ' simulate a delay
      CALL zSpinnerClose()  ' close the busy graphic
      '
    CASE %WM_NCACTIVATE
      STATIC hWndSaveFocus AS DWORD
      IF ISFALSE CB.WPARAM THEN
        ' Save control focus
        hWndSaveFocus = GetFocus()
      ELSEIF hWndSaveFocus THEN
        ' Restore control focus
        SetFocus(hWndSaveFocus)
        hWndSaveFocus = 0
      END IF

    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL
        CASE %IDOK
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            ' launch the spinner busy graphic
            CALL zSpinnerInit(CB.HNDL, funTempDirectory & _
                              "loading.ski", 0)
            SLEEP 5000 ' wait 5 seconds to simulate a delay
            '
            CALL zSpinnerClose()  ' close the busy graphic
            MSGBOX "Finished"
          END IF

        CASE %IDABORT
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            DIALOG END CB.HNDL
          END IF

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowFIRSTDIALOG(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt  AS LONG

#PBFORMS BEGIN DIALOG %IDD_FIRSTDIALOG->->
  LOCAL hDlg   AS DWORD
  LOCAL hFont1 AS DWORD

  DIALOG NEW hParent, "First Dialog", 79, 188, 462, 245, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR _
    %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD LABEL,  hDlg, %IDC_LABEL1, "First Dialog loaded", 20, 15, 165, _
    30
  CONTROL SET COLOR   hDlg, %IDC_LABEL1, %BLUE, -1
  CONTROL ADD BUTTON, hDlg, %IDOK, "Next", 380, 210, 50, 15
  DIALOG  SEND        hDlg, %DM_SETDEFID, %IDOK, 0
  CONTROL ADD BUTTON, hDlg, %IDABORT, "Exit", 25, 210, 50, 15

  FONT NEW "MS Sans Serif", 18, 0, %ANSI_CHARSET TO hFont1

  CONTROL SET FONT hDlg, %IDC_LABEL1, hFont1
#PBFORMS END DIALOG

  DIALOG SHOW MODAL hDlg, CALL ShowFIRSTDIALOGProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_FIRSTDIALOG
  FONT END hFont1
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
