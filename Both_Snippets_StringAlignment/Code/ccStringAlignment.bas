#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
'

FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("String Alingment",0,0,40,120)
  '
  funLog("String Alingment")
  funLog("")
  '
  DIM a_strAccounts(1 TO 4) AS STRING
  ARRAY ASSIGN a_strAccounts()= "John Smith", _
                                "Jane MacDonald", _
                                "Steven Jones", _
                                "Susan Brown"
  '
  DIM a_curBalances(1 TO 4) AS CURRENCYX
  ARRAY ASSIGN a_curBalances() = 455.00, _
                                 23567.90, _
                                 17865.25, _
                                 0.56
  '
  LOCAL lngR AS LONG
  LOCAL strName AS STRING
  LOCAL strBalance AS STRING
  '
  ' print a centered title
  LOCAL strTitle AS STRING
  strTitle = CSET$("Account Balances", 33)
  funLog(strTitle)
  '
  ' display each entry as two columns
  FOR lngR = 1 TO 4
    ' prepare a fixed length variable for account name
    strName = SPACE$(20)
    ' left justify your data into this variable
    LSET strName = a_strAccounts(lngR) USING "."
    'strName = a_strAccounts(lngR)
    '
    ' prepare a fixed length variable for balance
    strBalance = SPACE$(12)

    'strBalance = format$(a_curBalances(lngR))
    'RSET strBalance = FORMAT$(a_curBalances(lngR),"0.00")
    ' right justify your data into this variable
    RSET strBalance = FORMAT$(a_curBalances(lngR),"#,##0.00")
    '
    'funLog(a_strAccounts(lngR) & " " & format$(a_curBalances(lngR)) )
    ' print out to the log
    funLog(strName & " " & strBalance )
  NEXT lngR
  '
  funWait()
  '
END FUNCTION
'
