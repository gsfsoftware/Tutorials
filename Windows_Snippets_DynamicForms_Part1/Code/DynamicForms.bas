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
#RESOURCE "DynamicForms.pbr"
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
%IDR_IMGFILE1        =  102
%IDR_IMGFILE2        =  103
%IDD_DlgDynamicForms =  101
%IDC_STATUSBAR1      = 1001
%IDC_LABEL1          = 1002
%IDC_LABEL2          = 1003
%IDC_LABEL3          = 1004
%IDC_LABEL4          = 1005
%IDC_LABEL5          = 1006
%IDC_LABEL6          = 1007
%IDC_TEXTBOX1        = 1008
%IDC_TEXTBOX2        = 1009
%IDC_TEXTBOX3        = 1010
%IDC_TEXTBOX4        = 1011
%IDC_TEXTBOX5        = 1012
%IDC_TEXTBOX6        = 1013
%IDABORT             =    3
%IDC_IMGBUTTON1      = 1015
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
' set up constants for start of ranges
%LabelStart = %IDC_LABEL1
%TextboxStart = %IDC_TEXTBOX1
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowDlgDynamicFormsProc()
DECLARE FUNCTION ShowDlgDynamicForms(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)

  ShowDlgDynamicForms %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDlgDynamicFormsProc()
  LOCAL lngR AS LONG
  STATIC lngObjectCount AS LONG
  STATIC lngIncrement AS LONG
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
      lngObjectCount = 1 ' set the object count at one
      lngIncrement = 1   ' default to adding objects
      '
      ' initially hide all but the first label and text box
      FOR lngR = 1 TO 5
        PREFIX "control hide cb.hndl,lngR + "
          %LabelStart
          %TextBoxStart
        END PREFIX
      NEXT lngR
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
        ' /* Inserted by PB/Forms 02-06-2021 15:03:49
        CASE %IDC_IMGBUTTON1
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' button has been pressed
          ' add a new set of objects on the form
            SELECT CASE lngObjectCount
              CASE 1 TO 5
              ' more objects can be added/removed
                IF lngIncrement = 1 THEN
                  PREFIX "control normalize cb.hndl, lngObjectCount + "
                    %LabelStart
                    %TextBoxStart
                  END PREFIX
                ELSE
                ' handle what happens when you are removing objects
                  IF lngObjectCount > 1 THEN
                  ' don't let user remove the first object
                    PREFIX "control hide cb.hndl, "
                      %LabelStart + lngObjectCount - 1
                      %TextBoxStart + lngObjectCount - 1
                    END PREFIX
                  END IF
                END IF
                ' change the number of objects count
                lngObjectCount = lngObjectCount + lngIncrement
                '
                SELECT CASE lngObjectCount
                  CASE 6
                  ' reached the last object
                    lngIncrement = (-1) ' switch to removing objects
                    ' change the image on the button to the Minus icon
                    CONTROL SET IMGBUTTON CB.HNDL,%IDC_IMGBUTTON1, _
                          "#" + FORMAT$(%IDR_IMGFILE2)
                '
                  CASE 1
                  ' reached the first object
                    lngIncrement = 1 ' switch to adding objects
                    ' change the image on the button to the Add icon
                    CONTROL SET IMGBUTTON CB.HNDL,%IDC_IMGBUTTON1, _
                          "#" + FORMAT$(%IDR_IMGFILE1)
                END SELECT
                '
              CASE 6
              ' we've reached the last object so user
              ' must be trying to remove objects
                PREFIX "control hide cb.hndl, "
                  %LabelStart + lngObjectCount - 1
                  %TextBoxStart + lngObjectCount - 1
                END PREFIX
                '
                ' change the number of objects count
                lngObjectCount = lngObjectCount + lngIncrement
              '
            END SELECT
            '
          END IF
        ' */

        CASE %IDC_STATUSBAR1

        CASE %IDC_TEXTBOX1

        CASE %IDC_TEXTBOX2

        CASE %IDC_TEXTBOX3

        CASE %IDC_TEXTBOX4

        CASE %IDC_TEXTBOX5

        CASE %IDC_TEXTBOX6

        CASE %IDABORT
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' exit the form
            DIALOG END CB.HNDL
          END IF

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowDlgDynamicForms(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_DlgDynamicForms->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Dynamic forms", 279, 172, 451, 285, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR1, "", 0, 0, 0, 0
  CONTROL ADD LABEL,     hDlg, %IDC_LABEL1, "Field 1", 25, 56, 100, 10, _
    %WS_CHILD OR %WS_VISIBLE OR %SS_CENTER, %WS_EX_LEFT OR %WS_EX_LTRREADING
  CONTROL SET COLOR      hDlg, %IDC_LABEL1, %BLUE, -1
  CONTROL ADD LABEL,     hDlg, %IDC_LABEL2, "Field 2", 25, 71, 100, 10, _
    %WS_CHILD OR %WS_VISIBLE OR %SS_CENTER, %WS_EX_LEFT OR %WS_EX_LTRREADING
  CONTROL SET COLOR      hDlg, %IDC_LABEL2, %BLUE, -1
  CONTROL ADD LABEL,     hDlg, %IDC_LABEL3, "Field 3", 25, 86, 100, 10, _
    %WS_CHILD OR %WS_VISIBLE OR %SS_CENTER, %WS_EX_LEFT OR %WS_EX_LTRREADING
  CONTROL SET COLOR      hDlg, %IDC_LABEL3, %BLUE, -1
  CONTROL ADD LABEL,     hDlg, %IDC_LABEL4, "Field 4", 25, 101, 100, 10, _
    %WS_CHILD OR %WS_VISIBLE OR %SS_CENTER, %WS_EX_LEFT OR %WS_EX_LTRREADING
  CONTROL SET COLOR      hDlg, %IDC_LABEL4, %BLUE, -1
  CONTROL ADD LABEL,     hDlg, %IDC_LABEL5, "Field 5", 25, 116, 100, 10, _
    %WS_CHILD OR %WS_VISIBLE OR %SS_CENTER, %WS_EX_LEFT OR %WS_EX_LTRREADING
  CONTROL SET COLOR      hDlg, %IDC_LABEL5, %BLUE, -1
  CONTROL ADD LABEL,     hDlg, %IDC_LABEL6, "Field 6", 25, 131, 100, 11, _
    %WS_CHILD OR %WS_VISIBLE OR %SS_CENTER, %WS_EX_LEFT OR %WS_EX_LTRREADING
  CONTROL SET COLOR      hDlg, %IDC_LABEL6, %BLUE, -1
  CONTROL ADD TEXTBOX,   hDlg, %IDC_TEXTBOX1, "TextBox1", 130, 55, 100, 13
  CONTROL ADD TEXTBOX,   hDlg, %IDC_TEXTBOX2, "TextBox2", 130, 70, 100, 13
  CONTROL ADD TEXTBOX,   hDlg, %IDC_TEXTBOX3, "TextBox3", 130, 85, 100, 13
  CONTROL ADD TEXTBOX,   hDlg, %IDC_TEXTBOX4, "TextBox4", 130, 100, 100, 13
  CONTROL ADD TEXTBOX,   hDlg, %IDC_TEXTBOX5, "TextBox5", 130, 115, 100, 13
  CONTROL ADD TEXTBOX,   hDlg, %IDC_TEXTBOX6, "TextBox6", 130, 130, 100, 13
  CONTROL ADD BUTTON,    hDlg, %IDABORT, "Exit", 30, 245, 50, 15
  CONTROL ADD IMGBUTTON, hDlg, %IDC_IMGBUTTON1, "#" + FORMAT$(%IDR_IMGFILE1), _
    295, 50, 30, 30, %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %BS_ICON OR _
    %BS_PUSHBUTTON OR %BS_CENTER OR %BS_VCENTER, %WS_EX_LEFT OR _
    %WS_EX_LTRREADING
#PBFORMS END DIALOG

  DIALOG SHOW MODAL hDlg, CALL ShowDlgDynamicFormsProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DlgDynamicForms
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
