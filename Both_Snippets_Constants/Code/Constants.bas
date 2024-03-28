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
' numeric equates.
%TotalDepartments = 20
%TotalRecords = 5
'
' String equates
$RecordLabel = "Record "
'
' VB approach to constants
MACRO CONST = MACRO
' define an constant
CONST c_lngTotalDepartments = 20&
'
' macro constant
MACRO c_sglHours = (375/10)
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Constants",0,0,40,120)
  '
  funLog("Constants")
  '
  LOCAL t AS STRING
  LOCAL s,d,h AS LONG
  '
  't = FORMAT$(42 * 20 * 40)
  ' put values in variables
  s = 42: d = 20 : h = 40
  t = FORMAT$(s * d * h)
  funLog("Total hours worked = " & t)
  '
  ' replace with descriptive names
  LOCAL lngStaff,lngDepartments,lngHours AS LONG
  LOCAL strTotal AS STRING
  lngStaff = 42        ' number of staff per department
  lngDepartments = 20  ' number of departments in company
  lngHours = 40        ' number of hours worked each week by 1 person
  '
  ' sum total hours
  strTotal = FORMAT$(lngStaff * lngDepartments * lngHours)
  funLog("Total hours worked = " & strTotal)
  '
  ' use a constant for departments and format output
  strTotal = FORMAT$(lngStaff * %TotalDepartments * lngHours,"#,")
  funLog("Total hours worked = " & strTotal)
  '
  'use a VB style constant
  strTotal = FORMAT$(lngStaff * c_lngTotalDepartments * lngHours,"#,")
  funLog("Total hours worked = " & strTotal)
  '
  ' replace hours with constant
  strTotal = FORMAT$(lngStaff * lngDepartments * c_sglHours,"#,")
  funLog("Total Reduced hours worked = " & strTotal)
  '
  LOCAL lngR AS LONG
  'for lngR = 1 to 5
  ' replace hard coding with constant
  FOR lngR = 1 TO %TotalRecords
    'funLog("Record " & format$(lngR))
    ' replace text with constant
    funLog($RecordLabel & FORMAT$(lngR))
    '
  NEXT lngR
  '
  funWait()
  '
END FUNCTION
'
