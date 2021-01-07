' libDynamicFormRunner.inc
' load libraries needed
#INCLUDE ONCE "..\Libraries\PB_FileHandlingRoutines.inc"
  '
  GLOBAL g_strDynamicForms() AS STRING ' holds form data
  GLOBAL g_lngDynamicHandles() AS LONG ' holds form obj handles
  '
  %DynamicBaseHandle = 5000  ' starting handle of objects
  GLOBAL g_lngDynamicLastHandle AS LONG ' Current highest obj handle
  '
  ENUM DFCols
    SortOrder = 1
    Form
    OBJECT
    SizeX
    SizeY
    Location
    Title
    Action
    Colour
    FOCUS
    Multi_line
    Resize1
    ResizeFrom1
    ResizeTo1
    Resize2
    ResizeFrom2
    ResizeTo2
  END ENUM
'
FUNCTION funLoadDynamicFormFile() AS LONG
' load the Dynamic Form file
  LOCAL strFile AS STRING
  LOCAL lngRecords AS STRING
  ' establish the current object handle number
  g_lngDynamicLastHandle = %DynamicBaseHandle
  '
  strFile = EXE.PATH$ & EXE.NAME$ & "_def.txt"
  '
  IF ISFALSE ISFILE(strFile) THEN
  ' unable to find the config file

    FUNCTION = %FALSE
  ELSE
  ' found the config file ok - so load it
    IF ISTRUE funReadTheFileIntoAnArray(strFile,g_strDynamicForms() ) THEN
      REDIM g_lngDynamicHandles(UBOUND(g_strDynamicForms))
      FUNCTION = %TRUE
    END IF
  '
  END IF
  '
END FUNCTION
'
FUNCTION funDisplayDynamicForm(strFormName AS STRING, _
                               hParent AS DWORD) AS LONG
' display the dynamic form on screen
  LOCAL strProperties AS STRING
  LOCAL strObject AS STRING
  LOCAL hDlg  AS DWORD
  '
  strObject = "Form"
  '
  IF ISTRUE funFindDynamicFormProperties(strFormName, _
                                         strObject, _
                                         strProperties) THEN
  ' found the form entry - so display the form
  ' strProperties has the information
  LOCAL lRslt AS LONG
  LOCAL strTitle AS STRING
  LOCAL strX AS STRING
  LOCAL strY AS STRING
  LOCAL strWidth AS STRING
  LOCAL strHeight AS STRING
  LOCAL lngStyle AS STRING
  LOCAL strLocation AS STRING
  LOCAL lngFocus AS LONG
  '
  strTitle = funGetObjProperty(strProperties,%DFCols.Title)
  strWidth = funGetObjProperty(strProperties,%DFCols.SizeX)
  strHeight = funGetObjProperty(strProperties,%DFCols.SizeY)
  '
  strLocation = funGetObjProperty(strProperties,%DFCols.Location)
  IF strLocation = "center" THEN
    strX = "0"
    strY = "0"
  ELSE
  ' get specific starting location
    strX = PARSE$(strLocation,"-",1)
    strY = PARSE$(strLocation,"-",2)
  END IF
  '
    DIALOG NEW hParent, strTitle , VAL(strX), VAL(strY), VAL(strWidth), VAL(strHeight), _
     %WS_POPUP OR %WS_BORDER OR %WS_DLGFRAME OR %WS_THICKFRAME OR %WS_CAPTION _
     OR %WS_SYSMENU OR %WS_MINIMIZEBOX OR %WS_MAXIMIZEBOX OR %WS_CLIPSIBLINGS _
     OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR %DS_3DLOOK OR _
     %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR _
     %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
    '
    ' now are there any controls on the form?
    lngFocus = funDisplayDynamicControls(strFormName, hDlg)
    DIALOG SET USER hDlg,1, lngFocus  ' save the focus object
    '
    ' set limits on the form
    macDialogToPixels(hDlg, VAL(strWidth), VAL(strHeight))
    Layout_AddLimit hDlg, %Form,xx&, yy&
    '
    DIALOG SHOW MODAL hDlg, CALL DynamicDialogProc TO lRslt
    '
    FUNCTION = %TRUE
  '
  ELSE
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
CALLBACK FUNCTION DynamicDialogProc()
  LOCAL strData AS STRING
  LOCAL strObject AS STRING
  LOCAL strAction AS STRING
  LOCAL lngFocus AS LONG
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
      DIALOG GET USER CB.HNDL, 1 TO lngFocus
      '
      IF lngFocus <> 0 THEN
        CONTROL SET FOCUS CB.HNDL,lngFocus
      END IF
    '
    CASE %WM_COMMAND
    ' Process control notifications
    ' where CB.CTL is the object handle
      strData = funFindDynamicObjPropertiesByObj(CB.CTL)
      IF strData <> "" THEN
      ' its an object we created
        strObject = funGetObjProperty(strData, %DFCols.Object)
        '
        SELECT CASE LCASE$(strObject)
          CASE "button"
            IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            ' button has been clicked
              strAction = funGetObjProperty(strData, %DFCols.Action)
              '
              SELECT CASE LCASE$(strAction)
                CASE "close dialog"
                  DIALOG END CB.HNDL
              END SELECT
            '
            END IF
        END SELECT
      '
      END IF
    '
  END SELECT
  '
END FUNCTION
'
FUNCTION funDisplayDynamicControls(strFormName AS STRING, _
                                   hDlg AS DWORD) AS LONG
' display any controls on this form
  LOCAL lngR AS LONG
  LOCAL strData AS STRING
  LOCAL strObject AS STRING
  LOCAL strTitle AS STRING
  LOCAL strWidth AS STRING
  LOCAL strHeight AS STRING
  LOCAL strLocation AS STRING
  LOCAL strX AS STRING
  LOCAL strY AS STRING
  LOCAL lngObjHandle AS LONG
  LOCAL strColour AS STRING
  LOCAL strFocus AS STRING
  LOCAL lngFocus AS LONG
  LOCAL strMultiLine AS STRING
  LOCAL lngFlags AS LONG
  '
  LOCAL strResize1 AS STRING
  LOCAL strResizeFrom1 AS STRING
  LOCAL strResizeTo1 AS STRING
  LOCAL lngResizeFrom1 AS LONG
  LOCAL lngResizeTo1 AS LONG
  '
  LOCAL strResize2 AS STRING
  LOCAL strResizeFrom2 AS STRING
  LOCAL strResizeTo2 AS STRING
  LOCAL lngResizeFrom2 AS LONG
  LOCAL lngResizeTo2 AS LONG
  '
  FOR lngR = 1 TO UBOUND(g_strDynamicForms)
    strData = g_strDynamicForms(lngR)
    '
    IF LCASE$(TRIM$(PARSE$(strData,"|",%DFCols.Form))) = LCASE$(strFormName) _
      AND LCASE$(TRIM$(PARSE$(strData,"|",%DFCols.Object))) <> "form" THEN
    ' found an object to put on this form
      strObject = funGetObjProperty(strData, %DFCols.Object)
      strTitle =  funGetObjProperty(strData, %DFCols.Title)
      strWidth =  funGetObjProperty(strData, %DFCols.SizeX)
      strHeight =  funGetObjProperty(strData, %DFCols.SizeY)
      strLocation = funGetObjProperty(strData, %DFCols.Location)
      strColour = funGetObjProperty(strData, %DFCols.Colour)
      strFocus =  funGetObjProperty(strData, %DFCols.Focus)
      strMultiLine = funGetObjProperty(strData, %DFCols.Multi_Line)
      strResize1 = funGetObjProperty(strData, %DFCols.Resize1)
      strResizeFrom1 = funGetObjProperty(strData, %DFCols.ResizeFrom1)
      strResizeTo1 = funGetObjProperty(strData, %DFCols.ResizeTo1)
      '
      strResize2 = funGetObjProperty(strData, %DFCols.Resize2)
      strResizeFrom2 = funGetObjProperty(strData, %DFCols.ResizeFrom2)
      strResizeTo2 = funGetObjProperty(strData, %DFCols.ResizeTo2)
      '
      SELECT CASE LCASE$(strResizeFrom1)
        CASE "left"
          lngResizeFrom1 = %Left
        CASE "top"
          lngResizeFrom1 = %Top
        CASE "right"
          lngResizeFrom1 = %Right
        CASE "bottom"
          lngResizeFrom1 = %Bottom
      END SELECT
      '
      SELECT CASE LCASE$(strResizeTo1)
        CASE "left"
          lngResizeTo1 = %Left
        CASE "top"
          lngResizeTo1 = %Top
        CASE "right"
          lngResizeTo1 = %Right
        CASE "bottom"
          lngResizeTo1 = %Bottom
      END SELECT
      '
      SELECT CASE LCASE$(strResizeFrom2)
        CASE "left"
          lngResizeFrom2 = %Left
        CASE "top"
          lngResizeFrom2 = %Top
        CASE "right"
          lngResizeFrom2 = %Right
        CASE "bottom"
          lngResizeFrom2 = %Bottom
      END SELECT
      '
      SELECT CASE LCASE$(strResizeTo2)
        CASE "left"
          lngResizeTo2 = %Left
        CASE "top"
          lngResizeTo2 = %Top
        CASE "right"
          lngResizeTo2 = %Right
        CASE "bottom"
          lngResizeTo2 = %Bottom
      END SELECT
      '
      IF INSTR(strLocation,"-") >0 THEN
        strX = PARSE$(strLocation,"-",1)
        strY = PARSE$(strLocation,"-",2)
      ELSE
      ' assume centered
        strX = "0"
        strY = "0"
      END IF
      '
      lngObjHandle = funGetNextDynamicHandle(lngR)
      '
      SELECT CASE LCASE$(strObject)
        CASE "button"
        ' handle buttons
          CONTROL ADD BUTTON,hDlg, lngObjHandle, strTitle, _
                             VAL(strX), VAL(strY), _
                             VAL(strWidth), VAL(strHeight)
          funHasItFocus(lngObjHandle, lngFocus, strFocus)
          '
        CASE "label"
          CONTROL ADD LABEL, hDlg, lngObjHandle, strTitle, _
                             VAL(strX), VAL(strY), _
                             VAL(strWidth), VAL(strHeight)
          funHasItFocus(lngObjHandle, lngFocus, strFocus)
          SELECT CASE LCASE$(strColour)
            CASE "blue"
              CONTROL SET COLOR hDlg, lngObjHandle, %BLUE, -1
          END SELECT
          '
        CASE "text"
          lngFlags = %WS_TABSTOP OR %ES_LEFT OR _
                     %ES_AUTOHSCROLL OR %WS_BORDER

          '
          IF LCASE$(strMultiline)="yes" THEN
            lngFlags = lngFlags OR %ES_MULTILINE OR _
                                   %ES_WANTRETURN OR _
                                   %WS_VSCROLL

          END IF
          '
          CONTROL ADD TEXTBOX, hDlg,lngObjHandle, strTitle, _
                               VAL(strX), VAL(strY), _
                               VAL(strWidth), VAL(strHeight), _
                               lngFlags

          funHasItFocus(lngObjHandle, lngFocus, strFocus)
                               '
      END SELECT
    '
    END IF
    '
    ' apply any resize rules
    SELECT CASE LCASE$(strResize1)
      CASE "hcenter"
        Layout_AddRule hDlg, %HCenter,%Group, MAKLNG(lngObjHandle,lngObjHandle)
      CASE "move"
        Layout_AddRule hDlg, %Move ,lngResizeFrom1,lngObjHandle ,lngResizeTo1
      CASE "stretch"
        Layout_AddRule hDlg, %Stretch ,lngResizeFrom1,lngObjHandle ,lngResizeTo1
    END SELECT
    '
    SELECT CASE LCASE$(strResize2)
      CASE "hcenter"
        Layout_AddRule hDlg, %HCenter,%Group, MAKLNG(lngObjHandle,lngObjHandle)
      CASE "move"
        Layout_AddRule hDlg, %Move ,lngResizeFrom2,lngObjHandle ,lngResizeTo2
      CASE "stretch"
        Layout_AddRule hDlg, %Stretch ,lngResizeFrom2,lngObjHandle ,lngResizeTo2
    END SELECT
    '
  NEXT lngR
  '
  ' return the object that has focus to the calling routine
  FUNCTION = lngFocus
  '
END FUNCTION
'
FUNCTION funHasItFocus(lngObjHandle AS LONG, _
                       lngFocus AS LONG, _
                       strFocus AS STRING) AS LONG
' has this object intended to have focus?
  IF LCASE$(strFocus) = "yes" THEN
  ' store the object handle
    lngFocus = lngObjHandle
  END IF
END FUNCTION
'
FUNCTION funGetNextDynamicHandle(lngObject AS LONG) AS LONG
' get the next object handle and store it
  INCR g_lngDynamicLastHandle
  '
  g_lngDynamicHandles(lngObject) = g_lngDynamicLastHandle
  '
  FUNCTION = g_lngDynamicLastHandle
'
END FUNCTION
'
FUNCTION funGetObjProperty(strProperties AS STRING, _
                           lngObj AS LONG ) AS STRING
' return the value as a trimmed string
  FUNCTION = TRIM$(PARSE$(strProperties,"|",lngObj))
  '
END FUNCTION
'
FUNCTION funFindDynamicObjPropertiesByObj(lngObj AS LONG) AS STRING
' look for form properties
  LOCAL lngR AS LONG
  LOCAL strData AS STRING
  '
  FOR lngR = 1 TO UBOUND(g_lngDynamicHandles)
    IF g_lngDynamicHandles(lngR) = lngObj THEN
      FUNCTION = g_strDynamicForms(lngR)
      EXIT FUNCTION
    END IF
  NEXT lngR
  '
  FUNCTION = ""
  '
END FUNCTION
'
FUNCTION funFindDynamicFormProperties(strFormName AS STRING, _
                                      strObject AS STRING, _
                                      strProperties AS STRING) AS LONG
' look for form properties
  LOCAL lngR AS LONG
  LOCAL strData AS STRING
  '
  FOR lngR = 1 TO UBOUND(g_strDynamicForms)
    strData = g_strDynamicForms(lngR)
    IF LCASE$(TRIM$(PARSE$(strData,"|",%DFCols.Form))) = LCASE$(strFormName) _
      AND LCASE$(TRIM$(PARSE$(strData,"|",%DFCols.Object))) = LCASE$(strObject)THEN
      strProperties = strData
      '
      FUNCTION = %TRUE
      EXIT FUNCTION
    END IF
  NEXT lngR
  '
  strProperties = ""
  FUNCTION = %FALSE
'
END FUNCTION
'
MACRO macDialogToPixels(hDlg , x, y)
  LOCAL xx&, yy&
  DIALOG UNITS hDlg, x +20, y+20 TO PIXELS xx&, yy&
  '
  #IF %PB_REVISION = &H1004 ' if compiler PBWIN10.04
    SWAP xx&, yy&           ' swap variables
  #ENDIF                    ' fix for flaw in dialog units cmd
  '
END MACRO
