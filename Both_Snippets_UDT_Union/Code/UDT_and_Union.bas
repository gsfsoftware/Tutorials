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
  funLog("UDT and Union")
  '
  ' declare a local UDT variable as the UDT
  LOCAL uAccount AS udtAccount
  '
  ' populate the data in the local UDT
  uAccount.curBalance = 95.99
  uAccount.lngTransactionCount = 1
  '
  ' print out the data
  funLog("Balance = " & FORMAT$(uAccount.curBalance))
  funLog("Transactions = " & FORMAT$(uAccount.lngTransactionCount))
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
  funWait()
  '
END FUNCTION
'
