'file Base32Str.inc
TYPE BytesInDwordType
  B0 AS BYTE
  B1 AS BYTE
  B2 AS BYTE
  B3 AS BYTE
END TYPE
UNION BytesInDwordUnion
  Dwd AS DWORD
  Byt AS BytesInDwordType
END UNION

FUNCTION SHABase16ToBase32( BYVAL Base16 AS STRING ) AS STRING
LOCAL Base32 AS STRING
LOCAL i, j, block, intermediate AS LONG
STATIC bpos(), ResetBits() AS LONG
DIM bpos( 0 TO 2 )
DIM ResetBits( 0 TO 2 )
STATIC Entry AS LONG

  IF ISFALSE Entry THEN
    bpos( 0 ) = 5  ' from 32 = 2^5
    bpos( 1 ) = 10 ' from 32 * 32 = 2^10
    bpos( 2 ) = 15 ' from 32 * 32 * 32 = 2^15
    ResetBits( 0 ) = &h1F   ' ie reset last 5 bits
    ResetBits( 1 ) = &h3FF  ' ie reset last 10 bits
    ResetBits( 2 ) = &h7FFF ' ie reset last 15 bits
    Entry = -1
  END IF

  FOR j = 1 TO 8

    block = VAL("&h" + MID$(Base16, j*5-4, 5)) ' ie blocks of 5

    ' build blocks of 4
    FOR i = 2 TO 0 STEP -1
      intermediate = block
      SHIFT RIGHT intermediate, bpos( i )
      Base32 = Base32 + CHR$(PEEK(BYTE, CODEPTR(Encode) + intermediate) )
      block = block AND ResetBits( i )
    NEXT

    Base32 = Base32 + CHR$(PEEK(BYTE, CODEPTR(Encode) + block))

  NEXT

  FUNCTION = Base32

  EXIT FUNCTION

Encode:
!DB "A","B","C","D","E","F","G","H"
!DB "I","J","K","L","M","N","O","P"
!DB "Q","R","S","T","U","V","W","X"
!DB "Y","Z","2","3","4","5","6","7"

END FUNCTION

SUB MakeBase32(BYVAL pSHA1 AS BYTE POINTER, _
               BYVAL pBase32_Out AS STRING POINTER * 1)
  LOCAL Base32Char AS STRING * 1
  LOCAL OutCnt AS LONG
  LOCAL ShftBuf AS BytesInDwordUnion
  LOCAL Base32_binary AS LONG
  '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ShftBuf.Byt.B2 = @pSHA1    '1st byte of SHA-1
  INCR pSHA1
  ShftBuf.Byt.B1 = @pSHA1    '2nd byte of SHA-1
  INCR pSHA1

  FOR OutCnt = 0 TO (32 - 3) 'Out length -2 for preload, -1 for 0 start
    SELECT CASE AS LONG (OutCnt MOD 8)
      CASE 0
        ShftBuf.Byt.B0 = @pSHA1
        INCR pSHA1
        SHIFT LEFT ShftBuf.Dwd, 5
      CASE 1
        SHIFT LEFT ShftBuf.Dwd, 3
        ShftBuf.Byt.B0 = @pSHA1
        INCR pSHA1
        SHIFT LEFT ShftBuf.Dwd, 2
      CASE 2, 5, 7
        SHIFT LEFT ShftBuf.Dwd, 5
      CASE 3
        SHIFT LEFT ShftBuf.Dwd, 1
        ShftBuf.Byt.B0 = @pSHA1
        INCR pSHA1
        SHIFT LEFT ShftBuf.Dwd, 4
      CASE 4
        SHIFT LEFT ShftBuf.Dwd, 4
        ShftBuf.Byt.B0 = @pSHA1
        INCR pSHA1
        SHIFT LEFT ShftBuf.Dwd, 1
      CASE 6
        SHIFT LEFT ShftBuf.Dwd, 2
        ShftBuf.Byt.B0 = @pSHA1
        INCR pSHA1
        SHIFT LEFT ShftBuf.Dwd, 3
    END SELECT
    GOSUB SetBase32_Out
  NEXT
  SHIFT LEFT ShftBuf.Dwd, 5
  GOSUB SetBase32_Out
  SHIFT LEFT ShftBuf.Dwd, 5
  GOSUB SetBase32_Out


  EXIT SUB 'don't "fall" into subroutine when done - - - - - - - - - - - - - - -
  SetBase32_Out:
    Base32_binary = (ShftBuf.Byt.B3 AND &b00011111)
    SELECT CASE AS CONST Base32_binary
      CASE 0
        Base32Char = "A"
      CASE 1
        Base32Char = "B"
      CASE 2
        Base32Char = "C"
      CASE 3
        Base32Char = "D"
      CASE 4
        Base32Char = "E"
      CASE 5
        Base32Char = "F"
      CASE 6
        Base32Char = "G"
      CASE 7
        Base32Char = "H"
      CASE 8
        Base32Char = "I"
      CASE 9
        Base32Char = "J"
      CASE 10
        Base32Char = "K"
      CASE 11
        Base32Char = "L"
      CASE 12
        Base32Char = "M"
      CASE 13
        Base32Char = "N"
      CASE 14
        Base32Char = "O"
      CASE 15
        Base32Char = "P"
      CASE 16
        Base32Char = "Q"
      CASE 17
        Base32Char = "R"
      CASE 18
        Base32Char = "S"
      CASE 19
        Base32Char = "T"
      CASE 20
        Base32Char = "U"
      CASE 21
        Base32Char = "V"
      CASE 22
        Base32Char = "W"
      CASE 23
        Base32Char = "X"
      CASE 24
        Base32Char = "Y"
      CASE 25
        Base32Char = "Z"
      CASE 26
        Base32Char = "2"
      CASE 27
        Base32Char = "3"
      CASE 28
        Base32Char = "4"
      CASE 29
        Base32Char = "5"
      CASE 30
        Base32Char = "6"
      CASE 31
        Base32Char = "7"
    END SELECT
    @pBase32_Out = Base32Char
    INCR pBase32_Out
  RETURN
END SUB
