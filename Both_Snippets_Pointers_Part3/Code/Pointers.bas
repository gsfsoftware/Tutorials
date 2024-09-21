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
' prepare the Stars data UDT
TYPE udtStars
  sngX    AS SINGLE
  sngY    AS SINGLE
  sngZ    AS SINGLE
  sngMass AS SINGLE
END TYPE
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Pointers",0,0,40,120)
  '
  funLog("Pointers")
  '
  RANDOMIZE TIMER
  '
  ' create a structure to store information on stars
'  local uStar as udtStars
'  prefix "uStar."
'    sngX    = RND(1,1000) + RND()
'    sngY    = RND(1,1000) + RND()
'    sngZ    = RND(1,1000) + RND()
'    sngMass = RND(0,100)  + RND()
'  end prefix
'  '
'  funLog("Star X = " & format$(uStar.sngX) & $crlf & _
'         "Star Y = " & FORMAT$(uStar.sngY) & $CRLF & _
'         "Star Z = " & FORMAT$(uStar.sngZ) & $CRLF & _
'         "Star Mass = " & format$(uStar.sngMass))
  '
  ' now do this using the new routines
  ' create a local variable as the UDT
  LOCAL uStar AS udtStars
  ' prepare a pointer
  LOCAL pSingleStar AS udtStars POINTER
  ' populate the pointer
  pSingleStar = VARPTR(uStar)
  ' and pass to the function to populate
  ' that element
  funPrepStar(pSingleStar)
   ' and then print it
  funPrintStar(pSingleStar)
  '
  funLog("")
  '
  ' dimension an array of the UDT
  DIM a_sngStars(100) AS udtStars
  LOCAL lngR AS LONG
  '
  ' prepare a pointer
  LOCAL pStar AS udtStars POINTER
  '
  FOR lngR = 1 TO UBOUND(a_sngStars)
  ' for each star
  ' populate the pointer for the element of
  ' the array being processed
  ' Return the 32-bit address of the variable as a dword.
    pStar = VARPTR(a_sngStars(lngR))
    ' and pass to the function to populate
    ' that element
    funPrepStar(pStar)
    '
  NEXT lngR
  '
  ' print the first three stars
  FOR lngR = 1 TO 3
    pStar = VARPTR(a_sngStars(lngR))
    funPrintStar(pStar)
  NEXT lngR
  '
  ' printing without pointer
  lngR = 3
  funLog("Star X = " & FORMAT$(a_sngStars(lngR).sngX) & $CRLF & _
         "Star Y = " & FORMAT$(a_sngStars(lngR).sngY) & $CRLF & _
         "Star Z = " & FORMAT$(a_sngStars(lngR).sngZ) & $CRLF & _
         "Star Mass = " & FORMAT$(a_sngStars(lngR).sngMass) & $CRLF)
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funPrintStar(BYVAL pStar AS udtStars POINTER) AS LONG
' pointers require to be passed byval
' print the stars details
  funLog("Star X = " & FORMAT$(@pStar.sngX) & $CRLF & _
         "Star Y = " & FORMAT$(@pStar.sngY) & $CRLF & _
         "Star Z = " & FORMAT$(@pStar.sngZ) & $CRLF & _
         "Star Mass = " & FORMAT$(@pStar.sngMass) & $CRLF)
'
END FUNCTION
'
FUNCTION funPrepStar(BYVAL pStar AS udtStars POINTER) AS LONG
' pointers require to be passed byval
' populate the stars details
  PREFIX "@pStar."
    sngX    = RND(1,1000) + RND()
    sngY    = RND(1,1000) + RND()
    sngZ    = RND(1,1000) + RND()
    sngMass = RND(0,100)  + RND()
  END PREFIX
  '
END FUNCTION
