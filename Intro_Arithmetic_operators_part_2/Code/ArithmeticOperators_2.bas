#COMPILE EXE    ' compile to an executable
#DIM ALL        ' ensure all variables are declared before use
#DEBUG ERROR ON ' catch any attempt to read beyond array
                ' boundaries
'
#TOOLS OFF      ' turn off integrated development tool
                ' code in compiled code
'
' include the windows 32bit API library
#INCLUDE "win32api.inc"
' include the common display library
#INCLUDE "CommonDisplay.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Arithmetic Operators",0,0,40,120)
  '
  funLog("Arithmetic Operators")
  '
  ? "Answer = ";5.00 + 4.50
  '
  LOCAL a,b,c AS CURRENCYX   ' define as extended currency variables
  '                            to avoid any rounding errors
  '                            this gives us 2 decimal places
  LET a = 5.00   ' set their values
  LET b = 4.50
  '
  '
  LET c = a + b   ' add two variables together
                  ' and store the result in the third variable
  ? "Answer = ";c ' print the result out to screen
  '
  LOCAL curAccountBalance AS CURRENCYX
  LOCAL curDeposit AS CURRENCYX
  LOCAL curNewAccountBalance AS CURRENCYX
  '
  curAccountBalance = 1005.00  ' current account balance
  curDeposit        = 14.50    ' new deposit
  '
  ' determine new balance
  curNewAccountBalance = curAccountBalance + curDeposit
  '
  PRINT "New account balance = £" ; curNewAccountBalance
  '
  ' print out variables using reformatting commands
  PRINT ""
  PRINT "Original balance    = £" ; _
        RSET$(FORMAT$(curAccountBalance,"#,##0.00"),10)
  PRINT "Customer deposit    = £" ; _
        RSET$(FORMAT$(curDeposit,"#,##0.00"),10)
  PRINT "New account balance = £" ; _
        RSET$(FORMAT$(curNewAccountBalance,"#,##0.00"),10)
  PRINT ""
  '
  LOCAL lngVisitsToBank AS LONG
  '
  lngVisitsToBank = 5      ' number of times customer has visited bank
  '
  lngVisitsToBank = lngVisitsToBank + 1
  PRINT "Visit count = " ; lngVisitsToBank
  '
  lngVisitsToBank += 1
  PRINT "Visit count = " ; lngVisitsToBank
  '
  INCR lngVisitsToBank     ' increment by 1
  PRINT "Visit count = " ; lngVisitsToBank
  '
  LOCAL lngCustomersInBank AS LONG
  LOCAL lngCustomersEntering AS LONG
  LOCAL lngCustomersLeaving AS LONG
  '
  lngCustomersInBank = 20
  '
  lngCustomersLeaving = 5
  lngCustomersEntering = 1
  '
  PRINT ""
  PRINT "Customers in Bank = " ; lngCustomersInBank
  '
  lngCustomersInBank = lngCustomersInBank + lngCustomersEntering _
                                          - lngCustomersLeaving
  '
  PRINT "Customers in Bank = " ; lngCustomersInBank
  '
  lngCustomersInBank -= 2
  PRINT "Customers in Bank = " ; lngCustomersInBank
  '
  ' decrement by 1 , twice
  DECR lngCustomersInBank : DECR lngCustomersInBank
  PRINT "Customers in Bank = " ; lngCustomersInBank
  '
  funWait()
  '
END FUNCTION
'
