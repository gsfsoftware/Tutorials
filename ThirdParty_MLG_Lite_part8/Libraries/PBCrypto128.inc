' PBCrypto128.inc
'#compile exe
'#dim all

' 128bit encryption/decryption
'
GLOBAL glng_x1a0() AS LONG
GLOBAL glng_cle() AS LONG
GLOBAL glng_x1a2 AS LONG
GLOBAL glng_inter AS LONG, glng_res AS LONG, glng_ax AS LONG, glng_bx AS LONG
GLOBAL glng_cx AS LONG, glng_dx AS LONG, g_lng_si AS LONG, glng_tmp AS LONG
GLOBAL g_lngI AS LONG
'
'function pbmain() as long
'  local strPlain as string
'  local strEncrypt as string
'  local strKey as string
'  '
'  strKey = "wild wombat"
'  strPlain = "This is some text"
'  strEncrypt = PBEncrypt(strKey, strPlain)
'  '
'  msgbox strPlain & " = " & strEncrypt
'  msgbox "Decode = " & PBDecrypt(strKey,strEncrypt)
'  '
'end function
'
SUB codeASM()
  ON ERROR RESUME NEXT
  glng_dx = (glng_x1a2 + g_lngI) MOD 65536
  glng_ax = glng_x1a0(g_lngI)
  glng_cx = &H15A
  glng_bx = &H4E35
  glng_tmp = glng_ax
  glng_ax = g_lng_si
  g_lng_si = glng_tmp
  glng_tmp = glng_ax
  glng_ax = glng_dx
  glng_dx = glng_tmp
  IF (glng_ax <> 0) THEN
    glng_ax = (glng_ax * glng_bx) MOD 65536
  END IF
  glng_tmp = glng_ax
  glng_ax = glng_cx
  glng_cx = glng_tmp
  IF (glng_ax <> 0) THEN
    glng_ax = (glng_ax * g_lng_si) MOD 65536
    glng_cx = (glng_ax + glng_cx) MOD 65536
  END IF
  glng_tmp = glng_ax
  glng_ax = g_lng_si
  g_lng_si = glng_tmp
  glng_ax = (glng_ax * glng_bx) MOD 65536
  glng_dx = (glng_cx + glng_dx) MOD 65536
  glng_ax = glng_ax + 1
  glng_x1a2 = glng_dx
  glng_x1a0(g_lngI) = glng_ax
  glng_res = glng_ax XOR glng_dx
  INCR g_lngI
END SUB

SUB funAssemble() PRIVATE
  ON ERROR RESUME NEXT
  glng_x1a0(0) = ((glng_cle(1) * 256) + glng_cle(2)) MOD 65536
  codeASM
  glng_inter = glng_res
  glng_x1a0(1) = glng_x1a0(0) XOR ((glng_cle(3) * 256) + glng_cle(4))
  codeASM
  glng_inter = glng_inter XOR glng_res
  glng_x1a0(2) = glng_x1a0(1) XOR ((glng_cle(5) * 256) + glng_cle(6))
  codeASM
  glng_inter = glng_inter XOR glng_res
  glng_x1a0(3) = glng_x1a0(2) XOR ((glng_cle(7) * 256) + glng_cle(8))
  codeASM
  glng_inter = glng_inter XOR glng_res
  glng_x1a0(4) = glng_x1a0(3) XOR ((glng_cle(9) * 256) + glng_cle(10))
  codeASM
  glng_inter = glng_inter XOR glng_res
  glng_x1a0(5) = glng_x1a0(4) XOR ((glng_cle(11) * 256) + glng_cle(12))
  codeASM
  glng_inter = glng_inter XOR glng_res
  glng_x1a0(6) = glng_x1a0(5) XOR ((glng_cle(13) * 256) + glng_cle(14))
  codeASM
  glng_inter = glng_inter XOR glng_res
  glng_x1a0(7) = glng_x1a0(6) XOR ((glng_cle(15) * 256) + glng_cle(16))
  codeASM
  glng_inter = glng_inter XOR glng_res
  g_lngI = 0
END SUB

FUNCTION PBEncrypt(encPassword AS STRING, encStringOut AS STRING) PRIVATE AS STRING
  ON ERROR RESUME NEXT
  DIM encStringIn AS STRING
  DIM fois AS LONG
  DIM champ1 AS STRING
  DIM lngchamp1 AS LONG
  DIM cfc AS LONG, cfd AS LONG
  DIM compte AS LONG
  DIM c AS LONG, D AS LONG, E AS LONG
  REDIM glng_x1a0(9) AS LONG
  REDIM glng_cle(17) AS LONG
  encStringIn = ""
  g_lng_si = 0
  glng_x1a2 = 0
  g_lngI = 0
  FOR fois = 1 TO 16
    glng_cle(fois) = 0
  NEXT fois
  champ1 = encPassword
  lngchamp1 = LEN(champ1)
  FOR fois = 1 TO lngchamp1
    glng_cle(fois) = ASC(MID$(champ1, fois, 1))
  NEXT fois
  champ1 = encStringOut
  lngchamp1 = LEN(champ1)

  FOR fois = 1 TO lngchamp1
    c = ASC(MID$(champ1, fois, 1))
    CALL funAssemble
    cfc = (((glng_inter / 256) * 256) - (glng_inter MOD 256)) / 256
    cfd = glng_inter MOD 256
    FOR compte = 1 TO 16
      glng_cle(compte) = glng_cle(compte) XOR c
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

FUNCTION PBDecrypt(encPassword AS STRING, encStringIn AS STRING) PRIVATE AS STRING
  ON ERROR RESUME NEXT
  DIM encStringOut AS STRING
  DIM fois AS LONG
  DIM champ1 AS STRING
  DIM lngchamp1 AS LONG
  DIM cfc AS LONG, cfd AS LONG
  DIM compte AS LONG
  DIM c AS LONG, D AS LONG, E AS LONG
  REDIM glng_x1a0(9) AS LONG
  REDIM glng_cle(17) AS LONG
  encStringOut = ""
  g_lng_si = 0
  glng_x1a2 = 0
  g_lngI = 0
  FOR fois = 1 TO 16
    glng_cle(fois) = 0
  NEXT fois
  champ1 = encPassword
  lngchamp1 = LEN(champ1)
  FOR fois = 1 TO lngchamp1
    glng_cle(fois) = ASC(MID$(champ1,fois, 1))
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
    '
    IF (fois <> lngchamp1) THEN
       fois = fois + 1
    END IF
    '
    E = ASC(MID$(champ1, fois, 1))
    IF (E - &H61) >= 0 THEN
       E = E - &H61 ' to transform the letter to the 4 low bits of c
       IF (E >= 0) AND (E <= 15) THEN
          c = D + E
       END IF
    END IF
    CALL funAssemble
    cfc = (((glng_inter / 256) * 256) -(glng_inter MOD 256)) / 256
    cfd = glng_inter MOD 256
    c = c XOR (cfc XOR cfd)
    FOR compte = 1 TO 16
        glng_cle(compte) = glng_cle(compte) XOR c
    NEXT compte
    encStringOut = encStringOut + CHR$(c)
  NEXT fois
  FUNCTION = encStringOut
END FUNCTION
'
