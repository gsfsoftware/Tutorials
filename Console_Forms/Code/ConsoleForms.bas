#COMPILE EXE
#DIM ALL
'
#INCLUDE "Win32api.inc"
'
#INCLUDE "PB_FileHandlingRoutines.inc"
'
' set the name of the form to load
$ConsoleForm = "Form_1.txt"
'
FUNCTION PBMAIN () AS LONG
' create the console
  CON.COLOR 10,-1   ' amend the foreground colour
  LOCAL lngColWidth, lngRowHeight AS LONG
  CON.SCREEN TO lngRowHeight, lngColWidth
  '
  DIM a_strForm() AS STRING
  IF ISTRUE funReadTheFileIntoAnArray($ConsoleForm, a_strForm()) THEN
  ' position the cursor at the top left of the screen
    LOCAL lngRow, lngColumn AS LONG
    lngRow = 1: lngColumn = 1
    CON.CELL = lngRow, lngColumn
    '
    funDisplayForm(lngRow, lngColumn,a_strForm())
    '
    LOCAL lngField AS LONG
    lngField = 1
    funPositionCursor(a_strForm(),lngField)
    '
    ' now trap keypresses
    LOCAL strInput AS STRING
    DO
      strInput = CON.WAITKEY$
      '
      SELECT CASE LEN(strInput)
        CASE 1
        ' normal key
          IF GetAsyncKeyState(%VK_ESCAPE) THEN
          ' escape presed
            EXIT LOOP
            '
          ELSEIF GetAsyncKeyState(%VK_TAB) THEN
          ' tab key pressed
            INCR lngField
            funPositionCursor(a_strForm(),lngField)
            '
          ELSEIF GetAsyncKeyState(%VK_BACK) THEN
          ' backspace pressed
            CON.CELL TO lngRow, lngColumn
            DECR lngColumn
            ' stay within the field
            SELECT CASE CHR$(CON.SCREEN.CHAR(lngRow, lngColumn))
              CASE <> "["
                CON.CELL = lngRow, lngColumn
              CASE ELSE
                INCR lngColumn
                CON.CELL = lngRow, lngColumn
            END SELECT
          '
          ELSE
          ' normal key
            CON.CELL TO lngRow, lngColumn
            SELECT CASE CHR$(CON.SCREEN.CHAR(lngRow, lngColumn))
              CASE "[","]"
              ' dont allow data beyond field terminators
              CASE ELSE
                CON.PRINT strInput;
            END SELECT
          END IF
        '
        CASE 2
        ' extended key
          SELECT CASE ASC(RIGHT$(strInput,1))
            CASE 83
            ' delete key
              CON.CELL TO lngRow, lngColumn
              CON.PRINT " ";
              CON.CELL = lngRow, lngColumn
              '
            CASE 77
            ' right arrow
              CON.CELL TO lngRow, lngColumn
              INCR lngColumn
              SELECT CASE CHR$(CON.SCREEN.CHAR(lngRow, lngColumn))
                CASE <> "]"
                  CON.CELL = lngRow, lngColumn
                CASE ELSE
                  DECR lngColumn
                  CON.CELL = lngRow, lngColumn
              END SELECT
              '
            CASE 75
            ' left arrow
              CON.CELL TO lngRow, lngColumn
              DECR lngColumn
              ' stay within the field
              SELECT CASE CHR$(CON.SCREEN.CHAR(lngRow, lngColumn))
                CASE <> "["
                  CON.CELL = lngRow, lngColumn
                CASE ELSE
                  INCR lngColumn
                  CON.CELL = lngRow, lngColumn
              END SELECT
              '
            CASE 72
            ' up arrow
              CON.CELL TO lngRow, lngColumn
              DECR lngRow
              ' does line above have a field?
                IF INSTR(a_strForm(lngRow),"[") > 0 THEN
                  CON.CELL = lngRow, lngColumn
                ELSE
                  INCR lngRow
                  CON.CELL = lngRow, lngColumn
                END IF
              '
            CASE 80
            ' down arrow
              CON.CELL TO lngRow, lngColumn
              INCR lngRow
              ' does line below have a field?
              IF INSTR(a_strForm(lngRow),"[") > 0 THEN
                CON.CELL = lngRow, lngColumn
              ELSE
                DECR lngRow
                CON.CELL = lngRow, lngColumn
              END IF
          END SELECT
          '

        '
      END SELECT
      '
    LOOP
  '
  ELSE
  ' unable to load the form
  END IF

END FUNCTION
'
FUNCTION funPositionCursor(BYREF a_strForm() AS STRING, _
                           lngField AS LONG) AS LONG
' position the cursor at start of field specified
  LOCAL lngR AS LONG
  LOCAL lngCount AS LONG
  LOCAL strRow AS STRING
  LOCAL lngPos AS LONG
  LOCAL lngFound AS LONG
  '
  FOR lngR = 1 TO UBOUND(a_strForm)
    strRow = a_strForm(lngR)
    '
    ' check for field
    lngPos = INSTR(strRow,"[")
    IF lngPos > 0 THEN
      INCR lngCount ' advance field counter
       '
      IF lngCount = lngField THEN
      ' found the field
        CON.CELL = lngR, lngPos +1
        lngFound = %TRUE
        EXIT FOR
      END IF
      '
    END IF
    '
  NEXT lngR
 '
  IF lngFound = %FALSE THEN
  ' go back to first field
    lngField = 1
    funPositionCursor(a_strForm(),lngField)
  '
  END IF
  '
END FUNCTION
'
FUNCTION funDisplayForm(lngRow AS LONG, _
                        lngColumn AS LONG, _
                        BYREF a_strForm() AS STRING) AS LONG
' display the form on the console
  LOCAL lngColWidth, lngRowHeight AS LONG
  LOCAL lngR AS LONG
  ' get the size of the console
  CON.SCREEN TO lngRowHeight, lngColWidth
  ' for each row on the console
  ' see if there is a row in the array to display
  FOR lngR = lngRow TO lngRowHeight
    IF lngR > UBOUND(a_strForm) THEN EXIT FOR
    CON.CELL = lngR, lngColumn
    CON.PRINT a_strForm(lngR);
  NEXT lngR
  '
END FUNCTION
