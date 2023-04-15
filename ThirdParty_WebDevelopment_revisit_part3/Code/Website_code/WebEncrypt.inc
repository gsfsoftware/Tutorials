' WebEncrypt.inc
' 128bit encryption/decryption
'
GLOBAL x1a0() AS LONG
GLOBAL cle() AS LONG
GLOBAL x1a2 AS LONG
GLOBAL inter AS LONG, RES AS LONG, ax AS LONG, bx AS LONG
GLOBAL cx AS LONG, dx AS LONG, si AS LONG, tmp AS LONG
GLOBAL lngI AS LONG, c AS BYTE
'
'
'DECLARE FUNCTION PBEncrypt (strPassword AS STRING, strStringToBeEncrypted AS STRING) AS STRING
'DECLARE FUNCTION PBDecrypt (strPassword AS STRING, strStringToBeDecrypted AS STRING) AS STRING
'
SUB codeASM()
ON ERROR RESUME NEXT
dx = (x1a2 + lngI) MOD 65536
ax = x1a0(lngI)
cx = &H15A
bx = &H4E35
tmp = ax
ax = si
si = tmp
tmp = ax
ax = dx
dx = tmp
IF (ax <> 0) THEN
  ax = (ax * bx) MOD 65536
END IF
tmp = ax
ax = cx
cx = tmp
IF (ax <> 0) THEN
  ax = (ax * si) MOD 65536
  cx = (ax + cx) MOD 65536
END IF
tmp = ax
ax = si
si = tmp
ax = (ax * bx) MOD 65536
dx = (cx + dx) MOD 65536
ax = ax + 1
x1a2 = dx
x1a0(lngI) = ax
RES = ax XOR dx
lngI = lngI + 1
END SUB

SUB Assemble()
ON ERROR RESUME NEXT
x1a0(0) = ((cle(1) * 256) + cle(2)) MOD 65536
codeASM
inter = RES
x1a0(1) = x1a0(0) XOR ((cle(3) * 256) + cle(4))
codeASM
inter = inter XOR RES
x1a0(2) = x1a0(1) XOR ((cle(5) * 256) + cle(6))
codeASM
inter = inter XOR RES
x1a0(3) = x1a0(2) XOR ((cle(7) * 256) + cle(8))
codeASM
inter = inter XOR RES
x1a0(4) = x1a0(3) XOR ((cle(9) * 256) + cle(10))
codeASM
inter = inter XOR RES
x1a0(5) = x1a0(4) XOR ((cle(11) * 256) + cle(12))
codeASM
inter = inter XOR RES
x1a0(6) = x1a0(5) XOR ((cle(13) * 256) + cle(14))
codeASM
inter = inter XOR RES
x1a0(7) = x1a0(6) XOR ((cle(15) * 256) + cle(16))
codeASM
inter = inter XOR RES
lngI = 0
END SUB

FUNCTION PBEncrypt(encPassword AS STRING, encStringOut AS STRING) AS STRING
ON ERROR RESUME NEXT
DIM encStringIn AS STRING
DIM fois AS LONG
DIM champ1 AS STRING
DIM lngchamp1 AS LONG
DIM cfc AS LONG, cfd AS LONG
DIM compte AS LONG
DIM c AS LONG, D AS LONG, E AS LONG
REDIM x1a0(9) AS LONG
REDIM cle(17) AS LONG
encStringIn = ""
si = 0
x1a2 = 0
lngI = 0
FOR fois = 1 TO 16
  cle(fois) = 0
NEXT fois
champ1 = encPassword
lngchamp1 = LEN(champ1)
FOR fois = 1 TO lngchamp1
  cle(fois) = ASC(MID$(champ1, fois, 1))
NEXT fois
champ1 = encStringOut
lngchamp1 = LEN(champ1)

FOR fois = 1 TO lngchamp1
  c = ASC(MID$(champ1, fois, 1))
  Assemble
  cfc = (((inter / 256) * 256) - (inter MOD 256)) / 256
  cfd = inter MOD 256
  FOR compte = 1 TO 16
    cle(compte) = cle(compte) XOR c
  NEXT compte
  c = c XOR (cfc XOR cfd)
  D = (((c / 16) * 16) - (c MOD 16)) / 16
  E = c MOD 16
  encStringIn = encStringIn + CHR$(&H61 + D)
  ' d+&h61 give one letter range from a to p for the 4 high bits of c
  encStringIn = encStringIn + CHR$(&H61 + E)
  ' e+&h61 give one letter range from a to p for the 4 low bits of c
NEXT fois
FUNCTION  = encStringIn
END FUNCTION

FUNCTION PBDecrypt(encPassword AS STRING, encStringIn AS STRING) AS STRING
ON ERROR RESUME NEXT
DIM encStringOut AS STRING
DIM fois AS LONG
DIM champ1 AS STRING
DIM lngchamp1 AS LONG
DIM cfc AS LONG, cfd AS LONG
DIM compte AS LONG
DIM c AS LONG, D AS LONG, E AS LONG
REDIM x1a0(9) AS LONG
REDIM cle(17) AS LONG
encStringOut = ""
si = 0
x1a2 = 0
lngI = 0
FOR fois = 1 TO 16
  cle(fois) = 0
NEXT fois
champ1 = encPassword
lngchamp1 = LEN(champ1)
FOR fois = 1 TO lngchamp1
  cle(fois) = ASC(MID$(champ1,fois, 1))
NEXT fois
champ1 = encStringIn
lngchamp1 = LEN(champ1)
FOR fois = 1 TO lngchamp1
    D = ASC(MID$(champ1, fois, 1))
    IF (D - &H61) >= 0 THEN
       D = D - &H61  ' to transform the letter to the 4 high bits of c
       IF (D >= 0) AND (D <= 15) THEN
          D = D * 16
       END IF
    END IF
    IF (fois <> lngchamp1) THEN
       fois = fois + 1
    END IF
    E = ASC(MID$(champ1, fois, 1))
    IF (E - &H61) >= 0 THEN
       E = E - &H61 ' to transform the letter to the 4 low bits of c
       IF (E >= 0) AND (E <= 15) THEN
          c = D + E
       END IF
    END IF
    Assemble
    cfc = (((inter / 256) * 256) -(inter MOD 256)) / 256
    cfd = inter MOD 256
    c = c XOR (cfc XOR cfd)
    FOR compte = 1 TO 16
        cle(compte) = cle(compte) XOR c
    NEXT compte
    encStringOut = encStringOut + CHR$(c)
    NEXT fois
    FUNCTION = encStringOut
END FUNCTION
'
FUNCTION funEncapsulateDecrypt(strPassword AS STRING, _
                               strString AS STRING) AS STRING
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL strValue AS STRING
  LOCAL lngCount AS LONG
  '
  strString = PBDecrypt(strPassword,strString)
  '
  FOR lngR = 1 TO LEN(strString)
    IF lngCount <6 THEN
      lngC = lngR +1
      SELECT CASE lngC MOD 3
        CASE 0
          '
          INCR lngCount
        CASE ELSE
          strValue = strValue & MID$(strString,lngR,1)
      END SELECT
    ELSE
      strValue = strValue & MID$(strString,lngR,1)
    END IF
    '
  NEXT lngR
  '
  FUNCTION = strValue
  '
END FUNCTION
'
FUNCTION funEncapsulateEncrypt(strPassword AS STRING, _
                               strString AS STRING) AS STRING
'
  LOCAL strValue AS STRING
  LOCAL strTime AS STRING
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  strTime = TIME$
  REPLACE ":" WITH "" IN strTime
  '
  lngC = 6
  '
  FOR lngR = 1 TO LEN(strString)
    IF lngC = 0 THEN
      strValue = strValue & MID$(strString,lngR,1)
    ELSE
      SELECT CASE lngR MOD 2
        CASE 0
          strValue = strValue & MID$(strString,lngR,1)
        CASE ELSE
          strValue = strValue & MID$(strString,lngR,1) & MID$(strTime,lngC,1)
          DECR lngC
      END SELECT
    END IF
  NEXT lngR
  '
  FUNCTION = PBEncrypt(strPassword,strValue)
'
END FUNCTION
'
FUNCTION funGetEncryptedUserName(BYVAL strUserID AS STRING) AS STRING
' get the encrypted userid
  LOCAL strUserIDTime AS STRING
  LOCAL strTime AS STRING
  LOCAL lngCount AS LONG
  '
  strTime = TIME$
  REPLACE ":" WITH "" IN strTime
  FOR lngCount = 6 TO 1 STEP -1
    strUserIDTime = strUserIDTime & _
                    MID$(strUserID,lngCount,1) & _
                    MID$(strTime,lngCount,1)

  NEXT lngCount
  strUserIDTime = strUserIDTime & MID$(strUserID,7)

  FUNCTION = FORMAT$(Adler32asm(strUserIDTime))
  EXIT FUNCTION
  '
END FUNCTION
'
FUNCTION Adler32asm(sBuffer AS STRING) AS LONG
  '
  #REGISTER NONE
  DIM Seed AS LONG, S1 AS LONG, S2 AS LONG, N AS LONG
  DIM sPtr AS LONG
  sPtr = STRPTR(sBuffer) - 1
  N = LEN(sBuffer) + sPtr
  '// S1 = Seed AND &HFFFF
    ! mov   Seed, 1
    ! xor   eax, eax
    ! add   eax, Seed
    ! mov   ebx, eax
    ! and   eax, &hFFFF
    ! mov   eax, ebx
    ! mov   S1, eax
  '// S2 = (Seed / 65536) AND &HFFFF
    ! mov   eax, Seed
    ! mov   ebx, &h10000
    ! xor   edx, edx
    ! div   ebx
    ! and   eax, &hFFFF
    ! mov   S2, eax
    ! mov   ecx, sPtr
    StartLoop: '// FOR N = 1 TO LEN(sBuffer)
    ! inc   ecx
    ! cmp   ecx, N
    ! jg    EndLoop
      '//S1 = (S1 + ASC(MID$(sBuffer, N,1))) MOD %CrcBase
        ! mov   eax, S1
        ! xor   ebx, ebx
        ! mov   bl, [ecx]
        ! add   eax, ebx
        ! mov   ebx, &hFFF1
        ! xor   edx, edx
        ! div   ebx
        ! mov   S1, edx
      '//S2 = (S2 + S1) MOD %CrcBase
        ! mov   eax, S2
        ! add   eax, S1
        ! mov   ebx, &hFFF1
        ! xor   edx, edx
        ! div   ebx
        ! mov   S2, edx
        ! jmp   StartLoop   ;// NEXT
    EndLoop:
    '// FUNCTION = (S2 * 65536) + S1
        ! mov   eax, S2
        ! mov   ecx, &h10000
        ! mul   ecx
        ! add   eax, S1
        ! mov   N, eax
    FUNCTION = N
END FUNCTION
