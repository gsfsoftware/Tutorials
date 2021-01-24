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
#RESOURCE "SQLTools_Testing.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
' add the sql tools libraries
#INCLUDE "..\SQL_Libraries\SQLT3.INC"
#LINK "..\SQL_Libraries\SQLT3Pro.PBLIB"
#INCLUDE "..\Libraries\PB_GenericSQLFunctions.inc"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%FoodDB           =    1
%YT_Projects      =    2
%IDD_dlgComboTest =  101
%IDC_STATUSBAR1   = 1001
%IDC_COMBOBOX1    = 1002
%IDC_COMBOBOX2    = 1003
%IDC_BUTTON1      = 1004
%IDC_BUTTON2      = 1005
%IDC_LABEL2       = 1007
%IDC_lblStatus    = 1006
%IDC_LABEL1       = 1008
%IDC_LABEL3       = 1009
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgComboTestProc()
DECLARE FUNCTION SampleComboBox(BYVAL hDlg AS DWORD, BYVAL lID AS LONG, BYVAL _
  lCount AS LONG) AS LONG
DECLARE FUNCTION ShowdlgComboTest(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
' prep databases
  LOCAL strStatus AS STRING
  LOCAL lngResult AS LONG
  '
  REDIM g_astrDatabases(2) AS STRING
  '
  g_astrDatabases(1) = "FoodStore"
  g_astrDatabases(2) = "A_YouTubeProjects"

  '
  ' check authorization to use SQLPro.dll
  IF SQL_Authorize(%MY_SQLT_AUTHCODE) <> %SUCCESS THEN
    MSGBOX "Licence problem", 0 , "SQL tools error"
    EXIT FUNCTION
  END IF
  '
  CALL SQL_Init
  '

  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)

  ShowdlgComboTest %HWND_DESKTOP
  '
  IF ISTRUE funUserCloseDB(%FoodDB, _
                           strStatus) THEN
  END IF
  '
  IF ISTRUE funUserCloseDB(%YT_Projects, _
                           strStatus) THEN
  END IF
  '
  lngResult = SQL_Shutdown ' close all open DBs and shutdown SQL tools
  '
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgComboTestProc()
  LOCAL strConnectionString AS STRING
  LOCAL lngResult AS LONG
  LOCAL strSQL AS STRING
  LOCAL lngR AS LONG
  LOCAL lngColumn AS LONG
  LOCAL strStatus AS STRING
  DIM a_strData() AS STRING
  LOCAL lngStatement AS LONG
  '
  LOCAL lngItem AS LONG
  LOCAL strTemp AS STRING
  LOCAL lngTemp AS LONG
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
    ' now we can connect to a DB
    '
    '  strConnectionString = "DRIVER=SQL Server;" & _
    '                        "UID=SQLUserName;" & _
    '                        "PWD=password;" & _
    '                        "DATABASE=FoodStore;" & _
    '                        "SERVER=Octal\SqlExpress"
    '
      strConnectionString = "DRIVER=SQL Server;" & _
                          "Trusted_Connection=Yes;" & _
                          "DATABASE=" & _
                          g_astrDatabases(%FoodDB) & ";" & _
                          "SERVER=Octal\SqlExpress"
                          '
      IF ISTRUE funUserOpenDB(%FoodDB, _
                            strConnectionString, _
                            strStatus) THEN
      ' db opened ok
        CONTROL SET TEXT CB.HNDL,%IDC_lblSTATUS, strStatus
        '
        ' connect to second db
        strConnectionString = "DRIVER=SQL Server;" & _
                          "Trusted_Connection=Yes;" & _
                          "DATABASE=" & _
                          g_astrDatabases(%YT_Projects) & ";" & _
                          "SERVER=Octal\SqlExpress"
                          '
        IF ISTRUE funUserOpenDB(%YT_Projects, _
                              strConnectionString, _
                              strStatus) THEN
        ' db opened ok
          CONTROL SET TEXT CB.HNDL,%IDC_lblSTATUS, strStatus
        ' now do stuff in the databases
        '
        '
          lngStatement = 1
          '
          'strSQL = "SELECT [idxFoodTypes] ,[FoodType] " & _
          '         "FROM [dbo].[tbl_FoodType]"
                   '
          'strSQL = "SELECT top 5 [FoodItemName], count(*) as [Total] " & _
          '         "FROM [dbo].[tbl_FoodItems] " & _
          '         "group by [FoodItemName] " & _
          '         "order by count(*) desc"
          '         '
          'strSQL = "EXEC [dbo].[sprGetTestData]"
          strSQL = "SELECT [FoodType],  [idxFoodTypes]" & _
                   "FROM [dbo].[tbl_FoodType]"
          funPopulateGenericComboFromDB(CB.HNDL, _
                                        %IDC_ComboBox1, _
                                        strSQL, _
                                        "Tins", _
                                        %FoodDB, _
                                        strStatus, _
                                        lngStatement)



'          IF ISTRUE funGetGenericSQLData(strSQL, _
'                                         a_strData(), _
'                                         %FoodDB, _
'                                         strStatus , _
'                                         lngStatement) THEN
'          '
'            CONTROL SET TEXT CB.HNDL,%IDC_lblSTATUS, "SQL run successfully" & _
'                                                     $CRLF & strSQL
'          ' data is now in the array
'            FOR lngR = 0 TO UBOUND(a_strData)
'
'            NEXT lngR
'          '
'          ELSE
'            CONTROL SET TEXT CB.HNDL,%IDC_lblSTATUS, strStatus
'          END IF
          '
        ELSE
          CONTROL SET TEXT CB.HNDL,%IDC_lblSTATUS, strStatus
        END IF
        '
      ELSE
      ' db didnt open ok
        CONTROL SET TEXT CB.HNDL,%IDC_lblSTATUS, strStatus
      END IF
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
        CASE %IDC_STATUSBAR1

        CASE %IDC_COMBOBOX1

        CASE %IDC_COMBOBOX2

        CASE %IDC_BUTTON1
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            COMBOBOX GET SELECT CB.HNDL,%IDC_COMBOBOX1 TO lngItem
            COMBOBOX GET TEXT CB.HNDL,%IDC_COMBOBOX1,lngItem TO strTemp
            COMBOBOX GET USER CB.HNDL,%IDC_COMBOBOX1,lngItem TO lngTemp
            '
            CONTROL SET TEXT CB.HNDL, %IDC_lblStatus, strTemp & _
                                      $CRLF & "Number = " & _
                                      FORMAT$(lngTemp)
            '
          END IF

        CASE %IDC_BUTTON2
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN

          END IF

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Sample Code **
'------------------------------------------------------------------------------
FUNCTION SampleComboBox(BYVAL hDlg AS DWORD, BYVAL lID AS LONG, BYVAL lCount _
  AS LONG) AS LONG
  LOCAL i AS LONG

  CONTROL SEND hDlg, lID, %CB_SETEXTENDEDUI, %TRUE, 0

  FOR i = 1 TO lCount
    COMBOBOX ADD hDlg, lID, USING$("Test Item #", i)
  NEXT i
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgComboTest(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgComboTest->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "SQL Tools Combo test", 277, 114, 595, 347, %WS_POPUP _
    OR %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR1, "", 0, 0, 0, 0
  CONTROL ADD COMBOBOX,  hDlg, %IDC_COMBOBOX1, , 50, 60, 140, 90, %WS_CHILD _
    OR %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR %CBS_DROPDOWNLIST OR _
    %CBS_SORT, %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD COMBOBOX,  hDlg, %IDC_COMBOBOX2, , 290, 60, 190, 90, %WS_CHILD _
    OR %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR %CBS_DROPDOWNLIST OR _
    %CBS_SORT, %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD BUTTON,    hDlg, %IDC_BUTTON1, "Combobox 1", 50, 190, 140, 15
  CONTROL ADD BUTTON,    hDlg, %IDC_BUTTON2, "Combobox 2", 290, 189, 195, 15
  CONTROL ADD LABEL,     hDlg, %IDC_lblStatus, "", 50, 240, 445, 85
  CONTROL ADD LABEL,     hDlg, %IDC_LABEL2, "Status", 50, 225, 100, 10
  CONTROL SET COLOR      hDlg, %IDC_LABEL2, %BLUE, -1
  CONTROL ADD LABEL,     hDlg, %IDC_LABEL1, "Combo 1", 50, 50, 100, 10
  CONTROL SET COLOR      hDlg, %IDC_LABEL1, %BLUE, -1
  CONTROL ADD LABEL,     hDlg, %IDC_LABEL3, "Combo 2", 290, 50, 100, 10
  CONTROL SET COLOR      hDlg, %IDC_LABEL3, %BLUE, -1
#PBFORMS END DIALOG

  'SampleComboBox hDlg, %IDC_COMBOBOX1, 30
  'SampleComboBox hDlg, %IDC_COMBOBOX2, 30

  DIALOG SHOW MODAL hDlg, CALL ShowdlgComboTestProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgComboTest
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
