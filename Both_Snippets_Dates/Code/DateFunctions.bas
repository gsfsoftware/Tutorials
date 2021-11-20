#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\DateFunctions.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Date Functions",0,0,40,120)
  '
  funLog("Date Functions")
  '
  LOCAL strDate1 AS STRING
  LOCAL strDate2 AS STRING
  '
  ' firstly populate two dates
  strDate1 = funUKDate()   ' pick up todays date
  strDate2 = "25/12/2021"  ' set another date
  '
  IF ISTRUE funIsDateValid_dd_MM_yyyy(strDate2) THEN
  ' this date is valid
    IF funDateNumberUK(strDate2) > funDateNumberUK(strDate1) THEN
      funLog "Date 2 is greater than Date 1
    ELSE
      funLog "Date 2 is not greater than Date 1"
    END IF
  END IF
  '
  LOCAL strDate3 AS STRING
  strDate1 = "01/08/2021"  ' first date
  strDate2 = "01/11/2021"  ' period start
  strDate3 = "28/02/2022"  ' period end
  '
  IF ISTRUE funDateInPeriodUK(strDate1,strDate2, strDate3) THEN
    funlog "Selected date " & strDate1 & _
           " is within period " & strDate2 & "-" & strDate3
  ELSE
    funlog "Selected date " & strDate1 & _
           " is not within period " & strDate2 & "-" & strDate3
  END IF
  '
  funLog "Period length in days = " & _
          FORMAT$(funPeriodLengthUK(strDate2, strDate3))
  '
  '
  funWait()
  '
END FUNCTION
'
