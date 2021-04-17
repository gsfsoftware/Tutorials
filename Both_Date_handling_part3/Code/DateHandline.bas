#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON

' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Date verification",0,0,40,120)
  '
  funLog("Walk through on easy date verification")
  '
  LOCAL strDate AS STRING
  '
  ' Test UK date format
  strDate = "31/06/2021"
  '
  IF ISTRUE funIsDateValid_dd_MM_yyyy(strDate) THEN
    CON.STDOUT strDate & " is valid"
  ELSE
    CON.STDOUT strDate & " is not valid"
  END IF

  ' Test US Date format
  strDate = "02/29/2020"
  IF ISTRUE funIsDateValid_MM_dd_yyyy(strDate) THEN
    CON.STDOUT strDate & " is valid"
  ELSE
    CON.STDOUT strDate & " is not valid"
  END IF

  funWait()
  '
END FUNCTION
'
FUNCTION funIsDateValid_dd_MM_yyyy(strDate AS STRING) AS LONG
' accept date in dd/MM/yyyy format
  LOCAL lngYear AS LONG
  LOCAL lngMonth AS LONG
  LOCAL lngDay AS LONG
  '
  lngYear  = VAL(RIGHT$(strDate,4))
  lngMonth = VAL(MID$(strDate,4,2))
  lngDay   = VAL(LEFT$(strDate,2))
  '
  FUNCTION = funIsDateValid(lngYear,lngMonth,lngDay)
  '
END FUNCTION
'
FUNCTION funIsDateValid_MM_dd_yyyy(strDate AS STRING) AS LONG
' accept date in MM/DD/yyyy format
  LOCAL lngYear AS LONG
  LOCAL lngMonth AS LONG
  LOCAL lngDay AS LONG
  '
  lngYear  = VAL(RIGHT$(strDate,4))
  lngMonth = VAL(LEFT$(strDate,2))
  lngDay   = VAL(MID$(strDate,4,2))
  '
  FUNCTION = funIsDateValid(lngYear,lngMonth,lngDay)
  '
END FUNCTION
'
FUNCTION funIsDateValid(lngYear AS LONG, _
                        lngMonth AS LONG, _
                        lngDay AS LONG) AS LONG
' accept Date in three variable format
' and return true/false if date is valid of not
  LOCAL lngDate AS IPOWERTIME
  LET lngDate = CLASS "PowerTime"
  '
  ' attempt to populate the date
  lngDate.Newdate(lngYear,lngMonth,lngDay)
  '
  IF OBJRESULT = %S_OK THEN
  ' no error occurred - date must be valid
    FUNCTION = %TRUE
  ELSE
  ' error occurred - date is not valid
    FUNCTION = %FALSE
  END IF
'
END FUNCTION
