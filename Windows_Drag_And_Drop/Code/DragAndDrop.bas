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
#RESOURCE "DragAndDrop.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgDragAndDrop =  101
%IDC_txtDropZone    = 1001
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgDragAndDropProc()
DECLARE FUNCTION ShowdlgDragAndDrop(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)

  ShowdlgDragAndDrop %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgDragAndDropProc()
  LOCAL lngItem AS LONG
  LOCAL lngFileCount AS LONG
  LOCAL strFileName AS STRINGZ * %MAX_PATH
  LOCAL strList AS STRING
  '
  SELECT CASE AS LONG CB.MSG
    ' /* Inserted by PB/Forms 04-08-2022 21:09:18
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
    ' */

    CASE %WM_INITDIALOG
      ' Initialization handler

    CASE %WM_DROPFILES
      ' handle objects being dragged to the dialog
      lngFileCount = DragQueryFile(CB.WPARAM, -1, BYVAL 0, 0)
      '
      FOR lngItem = 0 TO lngFileCount-1
      ' for each file that has been dropped
      ' get the path & filename
        DragQueryFile CB.WPARAM, lngItem, strFileName, SIZEOF(strFileName)
        '
        IF lngFileCount = 1 AND _
           LCASE$(RIGHT$(strFileName,4)) = ".bas" THEN
        ' single BAS file dropped
          strList = funBinaryFileAsString(strFileName & "")
        '
        ELSE
        ' more than one file, or non-BAS file, so just build up list
          strList = strList & $CRLF & strFileName
        END IF
        '
      NEXT lngItem
      ' tell windows drag and drop has completed
      DragFinish CB.WPARAM
      '
      ' now update the text box
      CONTROL SET TEXT CB.HNDL,%IDC_txtDropZone,strList
      '
    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL
        CASE %IDC_txtDropZone

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgDragAndDrop(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgDragAndDrop->->
  LOCAL hDlg   AS DWORD
  LOCAL hFont1 AS DWORD

  DIALOG NEW hParent, "Drag and Drop demo", 299, 193, 752, 314, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR _
    %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD TEXTBOX, hDlg, %IDC_txtDropZone, "", 45, 55, 670, 180, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR %ES_LEFT OR _
    %ES_MULTILINE OR %ES_AUTOHSCROLL OR %ES_WANTRETURN, %WS_EX_CLIENTEDGE OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR

  FONT NEW "MS Sans Serif", 18, 0, %ANSI_CHARSET TO hFont1

  CONTROL SET FONT hDlg, %IDC_txtDropZone, hFont1
#PBFORMS END DIALOG
  ' set dialog to accept drag and drop
  DragAcceptFiles hDlg, %True
  '
  DIALOG SHOW MODAL hDlg, CALL ShowdlgDragAndDropProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgDragAndDrop
  FONT END hFont1
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
