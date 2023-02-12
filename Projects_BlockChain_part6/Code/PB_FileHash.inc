' PB_FileHash.inc

TYPE SHA           ' type for SHA values
  H0 AS LONG
  H1 AS LONG
  H2 AS LONG
  H3 AS LONG
  H4 AS LONG
END TYPE
'
FUNCTION funGetStringSHA(strString AS STRING) AS STRING
' return the hash value of a string
  LOCAL SHA1 AS SHA
  '
  CalcSHA strString, SHA1
  '
  FUNCTION = SHABase16ToBase32(tSHA(SHA1))
  '
END FUNCTION
'
FUNCTION funGetSHA (BYREF strFile AS STRING) AS STRING
' return the hash value of a file
  DIM strTmp AS STRING
  DIM lngFile AS LONG
  DIM SHA1 AS SHA
  DIM strReturn AS STRING
  '
  lngFile = FREEFILE
  TRY
  ' open the file as shared access as windows
  ' process may have a lock on it
    OPEN strFile FOR BINARY SHARED AS #lngFile
    strTmp = SPACE$(LOF(#lngFile))
    GET$ #lngFile, LOF(#lngFile), strTmp
    CalcSHA strTmp, SHA1
    '
    strReturn= SHABase16ToBase32(tSHA(SHA1))
    '
  CATCH
    strReturn = "Unable to HASH" & $CRLF & ERROR$
    ERRCLEAR
  FINALLY
    CLOSE #lngFile
  END TRY
  '
  FUNCTION = strReturn
  '
END FUNCTION
'
FUNCTION CalcSHA (Str AS STRING, SHA1 AS sha) AS LONG
' calculate the SHA hash
     #REGISTER NONE

     DIM lStr AS LONG, nq AS LONG, n AS LONG, adrW AS LONG, adrWW AS LONG
     DIM H0 AS LONG, H1 AS LONG, H2 AS LONG, H3 AS LONG, H4 AS LONG, W(0 TO 79) AS LONG
     DIM A AS LONG, B AS LONG, C AS LONG, D AS LONG, E AS LONG, TEMP AS LONG

     lStr = LEN(Str)
     nq = FIX((lStr + 8) / 64) + 1
     n = 16 * nq
     REDIM WW(0 TO n - 1) AS LONG

     WW(n - 1) = lStr * 8
     adrW = VARPTR(W(0))
     adrWW = VARPTR(WW(0))
     A = STRPTR(Str)

     ! PUSH EDI
     ! PUSH ESI

     ! MOV EDI, adrWW
     ! MOV ESI, A
     ! MOV ECX, lStr
     ! REP MOVSB

     ! MOV CL, &H80
     ! MOV [EDI], CL

     ! MOV EDI, adrWW
     ! MOV ECX, 2
  CalcSHA_Lbl1:
     ! MOV AX, [EDI]
     ! MOV DX, [EDI + 2]
     ! MOV [EDI], DH
     ! MOV [EDI + 1], DL
     ! MOV [EDI + 2], AH
     ! MOV [EDI + 3], AL
     ! ADD EDI, 4
     ! INC ECX
     ! CMP ECX, n
     ! JNE CalcSHA_Lbl1

     ! MOV H0, &H67452301&
     ! MOV H1, &HEFCDAB89&
     ! MOV H2, &H98BADCFE&
     ! MOV H3, &H10325476&
     ! MOV H4, &HC3D2E1F0&

  CalcSHA_Lbl2:

     ! MOV EDI, adrW
     ! MOV ESI, adrWW
     ! MOV ECX, 64
     ! REP MOVSB
     ! MOV adrWW, ESI

     ! MOV ECX, 0
  CalcSHA_Lbl3:
     ! MOV ESI, ECX
     ! ADD ESI, ESI
     ! ADD ESI, ESI
     ! ADD ESI, adrW

     ! MOV EAX, [ESI + 52]
     ! XOR EAX, [ESI + 32]
     ! XOR EAX, [ESI + 8]
     ! XOR EAX, [ESI]

     ! MOV EDX, EAX
     ! SHL EAX, 1
     ! SHR EDX, 31
     ! OR  EAX, EDX
     ! MOV [ESI + 64], EAX

     ! INC ECX
     ! CMP ECX, 64
     ! JNE CalcSHA_Lbl3

     ! MOV EAX, H0
     ! MOV A, EAX
     ! MOV EAX, H1
     ! MOV B, EAX
     ! MOV EAX, H2
     ! MOV C, EAX
     ! MOV EAX, H3
     ! MOV D, EAX
     ! MOV EAX, H4
     ! MOV E, EAX

     ! MOV EDI, 0
  CalcSHA_Lbl4:
     ! CMP EDI, 19
     ! JA CalcSHA_Lbl5

     ! MOV ECX, B
     ! AND ECX, C
     ! MOV EAX, B
     ! NOT EAX
     ! AND EAX, D
     ! OR  ECX, EAX
     ! ADD ECX, &H5A827999&
     ! JMP CalcSHA_Lbl8

  CalcSHA_Lbl5:
     ! CMP EDI, 39
     ! JA CalcSHA_Lbl6

     ! MOV ECX, B
     ! XOR ECX, C
     ! XOR ECX, D
     ! ADD ECX, &H6ED9EBA1&
     ! JMP CalcSHA_Lbl8

  CalcSHA_Lbl6:
     ! CMP EDI, 59
     ! JA CalcSHA_Lbl7

     ! MOV EAX, B
     ! AND EAX, C
     ! MOV ECX, B
     ! AND ECX, D
     ! MOV EDX, C
     ! AND EDX, D
     ! OR  ECX, EAX
     ! OR  ECX, EDX
     ! ADD ECX, &H8F1BBCDC&
     ! JMP CalcSHA_Lbl8

  CalcSHA_Lbl7:
     ! MOV ECX, B
     ! XOR ECX, C
     ! XOR ECX, D
     ! ADD ECX, &HCA62C1D6&

  CalcSHA_Lbl8:
     ! MOV EAX, A
     ! MOV EDX, EAX
     ! SHL EAX, 5
     ! SHR EDX, 27
     ! OR  EAX, EDX
     ! ADD EAX, E
     ! ADD ECX, EAX

     ! MOV ESI, EDI
     ! ADD ESI, ESI
     ! ADD ESI, ESI
     ! ADD ESI, adrW
     ! MOV ESI, [ESI]
     ! MOV TEMP, ESI

     ! ADD Temp, ECX
     ! MOV EAX, D
     ! MOV E, EAX
     ! MOV EAX, C
     ! MOV D, EAX
     ! MOV EAX, B
     ! MOV EDX, EAX
     ! SHL EAX, 30
     ! SHR EDX, 2
     ! OR  EAX, EDX
     ! MOV C, EAX
     ! MOV EAX, A
     ! MOV B, EAX
     ! MOV EAX, TEMP
     ! MOV A, EAX

     ! INC EDI
     ! CMP EDI, 80
     ! JNE CalcSHA_Lbl4

     ! MOV EAX, A
     ! ADD H0, EAX
     ! MOV EAX, B
     ! ADD H1, EAX
     ! MOV EAX, C
     ! ADD H2, EAX
     ! MOV EAX, D
     ! ADD H3, EAX
     ! MOV EAX, E
     ! ADD H4, EAX

     ! SUB nq, 1
     ! JNE CalcSHA_Lbl2

     ! POP ESI
     ! POP EDI

     SHA1.H0 = H0: SHA1.H1 = H1: SHA1.H2 = H2: SHA1.H3 = H3: SHA1.H4 = H4

END FUNCTION

FUNCTION tSHA (BYREF SHA1 AS SHA) AS STRING
' eye friendly format
  FUNCTION = HEX$(SHA1.H0, 8) +  HEX$(SHA1.H1, 8) +  HEX$(SHA1.H2, 8) +  _
             HEX$(SHA1.H3, 8) +  HEX$(SHA1.H4, 8)
END FUNCTION
'
