#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
'
TYPE udtUser
  strFirstName AS STRING * 100
  strLastName AS STRING * 100
  strEmail AS STRING * 250
END TYPE
'
TYPE udtAccountSplit
  strDepartment AS STRING * 2
  strAccount AS STRING * 6
END TYPE
'
UNION udtAccountNumber
  strFullAcc AS STRING * 8
  strSplit AS udtAccountSplit
END UNION
'
TYPE udtAccount
  curBalance AS CURRENCY
  lngTransactionCount AS LONG
  strUser AS udtUser
  'strAccountNumber as string * 8
  strAccountNumber AS udtAccountNumber
END TYPE
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("UDT and Union",0,0,40,120)
  '
  funLog("UDT and Pointers")
  '
  ' declare a local UDT variable as the UDT
  LOCAL uAccount AS udtAccount
  '
  ' declare an Array as 10 elements of the UDT
  DIM a_uAllAccounts(1 TO 10) AS udtAccount
  LOCAL lngElement AS LONG
  '
  lngElement = 1
  a_uAllAccounts(lngElement).curBalance = 95.99
  a_uAllAccounts(lngElement).lngTransactionCount = 1
  '
  funLog("")
  funLog("Array")
  funLog("Balance = " & FORMAT$(a_uAllAccounts(lngElement).curBalance))
  funLog("Transactions = " & _
               FORMAT$(a_uAllAccounts(lngElement).lngTransactionCount))
               '
  ' now populate the user details
  'a_uAllAccounts(lngElement).strUser.strFirstname = "John"
  'a_uAllAccounts(lngElement).strUser.strLastname = "Smith"
  '
  PREFIX "a_uAllAccounts(lngElement).strUser."
    strFirstname = "John"
    strLastname = "Smith"
  END PREFIX
  '
  funLog("")
  funLog("user details")
  funLog("Firstname = " & a_uAllAccounts(lngElement).strUser.strFirstname)
  funLog("Surname = " & a_uAllAccounts(lngElement).strUser.strLastname)
  '
  ' populate the account number
  LOCAL strAccountNumber AS STRING
  strAccountNumber = "10123456"
  '
  a_uAllAccounts(lngElement).strAccountNumber.strFullAcc = strAccountNumber
  '
  funLog("A/c = " & _
         a_uAllAccounts(lngElement).strAccountNumber.strFullAcc)
  funLog("Dept = " & _
         a_uAllAccounts(lngElement).strAccountNumber.strSplit.strDepartment)
         '
  ' shortened code
  ' define a UDT to hold the Account number info
  LOCAL uUserAcc AS udtAccountNumber
  uUserAcc = a_uAllAccounts(lngElement).strAccountNumber
  '
  ' print out using the shortened code
  funLog("")
  funLog("A/c = " & uUserAcc.strFullAcc)
  funLog("Dept = " & uUserAcc.strSplit.strDepartment)
  '
  ' test the department directly
  SELECT CASE uUserAcc.strSplit.strDepartment
    CASE "10"
      funLog("Dept 10 found")
    CASE ELSE
      funLog("Other Dept found")
  END SELECT
  '
  ' now use a pointer on this specific element
  ' of the array, used above
  LOCAL p1 AS udtAccountNumber PTR
  p1 = VARPTR(uUserAcc)
  '
  funLog("")
  funLog("Using pointers")
  funLog("A/c = " & @p1.strFullAcc)
  '
  ' allow pointing at any element of the array
  LOCAL p2 AS udtAccount PTR
  p2 = VARPTR(a_uAllAccounts(1))
  funLog("")
  funLog("Using pointers on array")
  funLog("First name = " & @p2[0].strUser.strFirstname)
  funLog("Last name = " & @p2[0].strUser.strLastname)
  funLog("A/c = " & @p2[0].strAccountNumber.strFullAcc)
  funLog("Dept = " & @p2[0].strAccountNumber.strSplit.strDepartment)
  '
  ' populate the next element of the array with some data
  @p2[1].strUser.strFirstname = "Tom"
  @p2[1].strUser.strLastname = "Jones"
  '
  ' print that data out to the log
  lngElement = 1
  funLog("First name = " & @p2[lngElement].strUser.strFirstname)
  funLog("Last name = " & @p2[lngElement].strUser.strLastname)
  '
  funWait()
  '
END FUNCTION
'
