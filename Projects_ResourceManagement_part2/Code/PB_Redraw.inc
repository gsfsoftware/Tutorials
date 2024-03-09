'
' Resize module
'
' this module will allow dynamic resizing of forms

' global and constants - these need placed in the main module that calls this module
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
'      CONTROL SEND CBHNDL, %IDC_Status, CBMSG, CBWPARAM, CBLPARAM
'      '
'      funResize CBHNDL, 0, "Initialize"  ' Must be called first
'      IF ISTRUE isIconic(CBHNDL) THEN EXIT FUNCTION  ' Exit if minimized
'      '
'      funResize CBHNDL, %IDC_txtNoteEntry, "Scale-H"
'      '
'      funResize CBHNDL, %IDC_txtNotes,     "Scale-V"
'      funResize CBHNDL, %IDC_txtNotes,     "Scale-H"
'      '
'      funResize CBHNDL, %IDC_cmdStart,     "Move-V"
'      funResize CBHNDL, %IDC_cmdStart,     "Move-H"
'      funResize CBHNDL, %IDC_cmdStop,      "Move-V"
'      funResize CBHNDL, %IDC_cmdStop,      "Move-H"
'      '
'      funResize CBHNDL, 0, "Repaint"    ' Must be called last
'
'
SUB funReSize(hDlg AS DWORD, CntlID AS LONG, Action AS STRING)

  STATIC InitialWindowWidth AS LONG, InitialWindowHeight AS LONG
  STATIC CurrentWindowWidth AS LONG, CurrentWindowHeight AS LONG
  STATIC ControlInfo() AS LONG, ControlCounter AS LONG, Initialized AS LONG

  LOCAL hCtl AS DWORD
  LOCAL CurrentControlWidth AS LONG, CurrentControlHeight AS LONG, Id AS LONG

  ' Refresh Window size
  DIALOG GET SIZE hDlg TO CurrentWindowWidth, CurrentWindowHeight
  IF CurrentWindowWidth  < %MinWindowWidth  THEN CurrentWindowWidth  = %MinWindowWidth
  IF CurrentWindowWidth  > %MaxWindowWidth  THEN CurrentWindowWidth  = %MaxWindowWidth
  IF CurrentWindowHeight < %MinWindowHeight THEN CurrentWindowHeight = %MinWindowHeight
  IF CurrentWindowHeight > %MaxWindowHeight THEN CurrentWindowHeight = %MaxWindowHeight
  DIALOG SET SIZE hDlg, CurrentWindowWidth, CurrentWindowHeight

  SELECT CASE UCASE$(Action)
    CASE "INITIALIZE"
      ControlCounter = 0
      IF InitialWindowWidth = 0 THEN
        DIALOG GET SIZE hDlg TO InitialWindowWidth, InitialWindowHeight
        Initialized = %FALSE
        DIM ControlInfo(3, 100)  ' Column 1 is CntlId
                                 ' Column 2 is initial Control height
                                 ' Column 3 is initial Control width (max 100 controls)
      ELSE
        Initialized = %TRUE
      END IF

    CASE "MOVE-V"   ' Moves the control so the relationship with the bottom window edge is maintained
      IF ISFALSE Initialized THEN ControlInfo(%IdCol, ControlCounter) = CntlId
      Id = ControlInfo(%IdCol, ControlCounter)
      CONTROL GET LOC hDlg, Id TO CurrentControlWidth, CurrentControlHeight

      IF ISFALSE Initialized THEN ControlInfo(%WidthCol,  ControlCounter) = CurrentControlWidth: _
                                  ControlInfo(%HeightCol, ControlCounter) = CurrentControlHeight

      CONTROL SET LOC hDlg, Id, CurrentControlWidth, (CurrentWindowHeight - InitialWindowHeight + ControlInfo(%HeightCol, ControlCounter))

    CASE "SCALE-V"  ' Rescales the control so the bottom edge follows with the bottom window edge
      IF ISFALSE Initialized THEN ControlInfo(%IdCol, ControlCounter) = CntlId
      Id = ControlInfo(%IdCol, ControlCounter)
      CONTROL GET SIZE hDlg, Id TO CurrentControlWidth, CurrentControlHeight
      IF ISFALSE Initialized THEN ControlInfo(%WidthCol,  ControlCounter) = CurrentControlWidth: _
                                  ControlInfo(%HeightCol, ControlCounter) = CurrentControlHeight

      CONTROL SET SIZE hDlg, Id, CurrentControlWidth, CurrentWindowHeight - InitialWindowHeight + ControlInfo(%HeightCol, ControlCounter)    ' 137

    CASE "MOVE-H"   ' Moves the control so the relationship with the right window edge is maintained
      IF ISFALSE Initialized THEN ControlInfo(%IdCol, ControlCounter) = CntlId
      Id = ControlInfo(%IdCol, ControlCounter)
      CONTROL GET LOC hDlg, Id TO CurrentControlWidth, CurrentControlHeight

      IF ISFALSE Initialized THEN ControlInfo(%WidthCol,  ControlCounter) = CurrentControlWidth: _
                                  ControlInfo(%HeightCol, ControlCounter) = CurrentControlHeight
      CONTROL SET LOC hDlg, Id, (CurrentWindowWidth - InitialWindowWidth + ControlInfo(%WidthCol, ControlCounter)), CurrentControlHeight

    CASE "SCALE-H"  ' Rescales the control so the right edge follows with the right window edge
      IF ISFALSE Initialized THEN ControlInfo(%IdCol, ControlCounter) = CntlId
      Id = ControlInfo(%IdCol, ControlCounter)
      CONTROL GET SIZE hDlg, Id TO CurrentControlWidth, CurrentControlHeight
      IF ISFALSE Initialized THEN ControlInfo(%WidthCol,  ControlCounter) = CurrentControlWidth: _
                                  ControlInfo(%HeightCol, ControlCounter) = CurrentControlHeight

      CONTROL SET SIZE hDlg, Id, CurrentWindowWidth - InitialWindowWidth + ControlInfo(%WidthCol, ControlCounter),CurrentControlHeight     ' 137

    CASE "REPAINT" ' Uses control refresh after all changes are complete
      ControlCounter = 1
      DO
        IF ControlInfo(%WidthCol, ControlCounter) = 0 THEN EXIT DO
        CONTROL HANDLE hDlg, ControlInfo(%IdCol, ControlCounter) TO hCtl
        InvalidateRect hCtl, BYVAL %NULL, 0
        UpdateWindow hCtl

        INCR ControlCounter
      LOOP

      DIALOG GET SIZE hDlg TO CurrentWindowWidth, CurrentWindowHeight
      ControlCounter = 0

  END SELECT

  INCR ControlCounter

END SUB
