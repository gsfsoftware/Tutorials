'
' Resize module
'
' this module will allow dynamic resizing of forms

' global and constants - these need placed in the main module
' that calls this module
'
'%IdCol           = 1
'%WidthCol        = 2
'%HeightCol       = 3
'%MinWindowHeight = 100        ' minimum size of the height - window will not shrink below this value
'%MaxWindowHeight = 99999      ' maximum size of the window height
'%MinWindowWidth  = 180        ' minimum size of the width - window will not shrink below this value
'%MaxWindowWidth  = 99999      ' maximum size of the width
'
' example code to be slotted into the main event handler
'  SELECT CASE CBMSG
'    CASE %WM_INITDIALOG
'     ' on dialog load
'    CASE %WM_SIZE:  'Called when window changes size
'    ' Dialog has been resized
'      CONTROL SEND CB.HNDL, %IDC_Status, CB.MSG, CB.WPARAM, CB.LPARAM
'      '
'      IF ISTRUE isIconic(CB.HNDL) THEN EXIT FUNCTION  ' Exit if minimized
'      '
'      funResize CB.HNDL, 0, "Initialize"  ' Must be called first
'      funResize CB.HNDL, %IDC_txtNoteEntry, "Scale-H"
'      '
'      funResize CB.HNDL, %IDC_txtNotes,     "Scale-V"
'      funResize CB.HNDL, %IDC_txtNotes,     "Scale-H"
'      '
'      funResize CB.HNDL, %IDC_cmdStart,     "Move-V"
'      funResize CB.HNDL, %IDC_cmdStart,     "Move-H"
'      funResize CB.HNDL, %IDC_cmdStop,      "Move-V"
'      funResize CB.HNDL, %IDC_cmdStop,      "Move-H"
'      '
'      funResize CB.HNDL, 0, "Repaint"    ' Must be called last
'
'
SUB funReSize(hDlg AS DWORD, _
              lngCntlID AS LONG, _
              strAction AS STRING)

  STATIC lngInitialWindowWidth AS LONG
  STATIC lngInitialWindowHeight AS LONG
  STATIC lngCurrentWindowWidth AS LONG
  STATIC lngCurrentWindowHeight AS LONG
  STATIC a_lngControlInfo() AS LONG
  STATIC lngControlCounter AS LONG
  STATIC lngInitialized AS LONG

  LOCAL hCtl AS DWORD
  LOCAL CurrentControlWidth AS LONG, CurrentControlHeight AS LONG
  LOCAL lngID AS LONG

  ' Refresh Window size
  DIALOG GET SIZE hDlg TO lngCurrentWindowWidth, lngCurrentWindowHeight
  '
  IF lngCurrentWindowWidth  < %MinWindowWidth THEN
    lngCurrentWindowWidth  = %MinWindowWidth
  END IF
  '
  IF lngCurrentWindowWidth  > %MaxWindowWidth THEN
    lngCurrentWindowWidth  = %MaxWindowWidth
  END IF
  '
  IF lngCurrentWindowHeight < %MinWindowHeight THEN
    lngCurrentWindowHeight = %MinWindowHeight
  END IF
  '
  IF lngCurrentWindowHeight > %MaxWindowHeight THEN
    lngCurrentWindowHeight = %MaxWindowHeight
  END IF
  '
  DIALOG SET SIZE hDlg, lngCurrentWindowWidth, lngCurrentWindowHeight

  SELECT CASE UCASE$(strAction)
    CASE "INITIALIZE"
      lngControlCounter = 0
      IF lngInitialWindowWidth = 0 THEN
        DIALOG GET SIZE hDlg TO lngInitialWindowWidth, lngInitialWindowHeight
        lngInitialized = %FALSE
        DIM a_lngControlInfo(3, 100)  ' Column 1 is CntlId
                                 ' Column 2 is initial Control height
                                 ' Column 3 is initial Control width (max 100 controls)
      ELSE
        lngInitialized = %TRUE
      END IF

    CASE "MOVE-V"   ' Moves the control so the relationship
                    ' with the bottom window edge is maintained
      IF ISFALSE lngInitialized THEN
        a_lngControlInfo(%IdCol, lngControlCounter) = lngCntlID
      END IF
      '
      lngID = a_lngControlInfo(%IdCol, lngControlCounter)
      CONTROL GET LOC hDlg, lngID TO CurrentControlWidth, CurrentControlHeight
      '
      IF ISFALSE lngInitialized THEN
        a_lngControlInfo(%WidthCol, lngControlCounter) = CurrentControlWidth
        a_lngControlInfo(%HeightCol,lngControlCounter) = CurrentControlHeight
      END IF
      '
      CONTROL SET LOC hDlg, lngID, CurrentControlWidth, _
                     (lngCurrentWindowHeight - lngInitialWindowHeight + _
                      a_lngControlInfo(%HeightCol, lngControlCounter))
      '
    CASE "SCALE-V"  ' Rescales the control so the bottom edge
                    ' follows with the bottom window edge
      IF ISFALSE lngInitialized THEN
        a_lngControlInfo(%IdCol, lngControlCounter) = lngCntlID
      END IF
      '
      lngID = a_lngControlInfo(%IdCol, lngControlCounter)
      CONTROL GET SIZE hDlg, lngID TO CurrentControlWidth, CurrentControlHeight
      IF ISFALSE lngInitialized THEN
        a_lngControlInfo(%WidthCol, lngControlCounter) = CurrentControlWidth
        a_lngControlInfo(%HeightCol,lngControlCounter) = CurrentControlHeight
      END IF
      '
      CONTROL SET SIZE hDlg, lngID, CurrentControlWidth, lngCurrentWindowHeight - lngInitialWindowHeight + a_lngControlInfo(%HeightCol, lngControlCounter)    ' 137

    CASE "MOVE-H"   ' Moves the control so the relationship
                    ' with the right window edge is maintained
      IF ISFALSE lngInitialized THEN
        a_lngControlInfo(%IdCol, lngControlCounter) = lngCntlID
      END IF
      '
      lngID = a_lngControlInfo(%IdCol, lngControlCounter)
      CONTROL GET LOC hDlg, lngID TO CurrentControlWidth, CurrentControlHeight
      '
      IF ISFALSE lngInitialized THEN
        a_lngControlInfo(%WidthCol,lngControlCounter) = CurrentControlWidth
        a_lngControlInfo(%HeightCol, lngControlCounter) = CurrentControlHeight
      END IF
      '
      CONTROL SET LOC hDlg, lngID, (lngCurrentWindowWidth - lngInitialWindowWidth + _
                            a_lngControlInfo(%WidthCol, lngControlCounter)), _
                            CurrentControlHeight

    CASE "SCALE-H"  ' Rescales the control so the right edge
                    ' follows with the right window edge
      IF ISFALSE lngInitialized THEN
        a_lngControlInfo(%IdCol, lngControlCounter) = lngCntlID
      END IF
      '
      lngID = a_lngControlInfo(%IdCol, lngControlCounter)
      CONTROL GET SIZE hDlg, lngID TO CurrentControlWidth, CurrentControlHeight
      '
      IF ISFALSE lngInitialized THEN
        a_lngControlInfo(%WidthCol,lngControlCounter) = CurrentControlWidth
        a_lngControlInfo(%HeightCol, lngControlCounter) = CurrentControlHeight
      END IF
      '
      CONTROL SET SIZE hDlg, lngID, lngCurrentWindowWidth - lngInitialWindowWidth + a_lngControlInfo(%WidthCol, lngControlCounter),CurrentControlHeight     ' 137

    CASE "REPAINT" ' Uses control refresh after all changes are complete
      lngControlCounter = 1
      DO
        IF a_lngControlInfo(%WidthCol, lngControlCounter) = 0 THEN EXIT DO
        '
        CONTROL HANDLE hDlg, a_lngControlInfo(%IdCol, lngControlCounter) TO hCtl
        InvalidateRect hCtl, BYVAL %NULL, 0
        UpdateWindow hCtl
        '
        INCR lngControlCounter
      LOOP
      '
      DIALOG GET SIZE hDlg TO lngCurrentWindowWidth, _
                              lngCurrentWindowHeight
      lngControlCounter = 0
      '
  END SELECT
  '
  INCR lngControlCounter
  '
END SUB
