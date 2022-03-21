' Demo class

CLASS DaysArray
  INSTANCE a_strDays() AS STRING   ' The array to hold data
  INSTANCE errString AS STRING     ' variable for any erros
  INSTANCE ArrayName AS STRING     ' the name of the array
  '
  CLASS METHOD CREATE
  ' setting up code
  END METHOD
  '
  CLASS METHOD DESTROY
  ' close off class code
  END METHOD
  '
  CLASS METHOD TestBounds(n AS LONG) AS LONG
    errString = ""
    IF n > UBOUND(a_strDays()) THEN
      METHOD = 1
      errString = FORMAT$(n) + " is above ubound (currently " & _
                  FORMAT$(UBOUND(a_strDays)) + ") for this array"
    END IF
    '
    IF n < LBOUND(a_strDays()) THEN
      METHOD = 1
      errString = FORMAT$(n) + " is below lbound (currently " & _
               FORMAT$(LBOUND(a_strDays)) + ") for this array"
    END IF
    '
  END METHOD
  '
  CLASS METHOD ReportError AS STRING
    METHOD = "There is an error with the " & ArrayName & _
             " object" & $CRLF & ". Error = " & errString
  END METHOD
  '
  INTERFACE iDaysArray
    INHERIT IUNKNOWN   ' inherit base class
    '
    METHOD Set_Bounds(low AS LONG , high AS LONG) AS LONG
      REDIM a_strDays(low TO high)
    END METHOD
    '
    PROPERTY GET ArrayName () AS STRING
      PROPERTY = ArrayName
    END PROPERTY
    '
    PROPERTY SET ArrayName(BYVAL strName AS STRING)
      ArrayName = strName
    END PROPERTY
    '
    PROPERTY GET DayName(n AS LONG) AS STRING
      IF me.TestBounds(n) = 0 THEN
        PROPERTY = a_strDays(n)
      END IF
    END PROPERTY
    '
    PROPERTY SET DayName(n AS LONG, BYVAL in_arr AS STRING)
      IF me.TestBounds(n) = 0 THEN
        a_strDays(n) = in_arr
      END IF
    END PROPERTY
    '
    METHOD errorstatus AS LONG
      METHOD = LEN(errString)
    END METHOD
    '
    METHOD error_msg AS STRING
      METHOD = me.ReportError
    END METHOD
    '
  END INTERFACE
  '
END CLASS
