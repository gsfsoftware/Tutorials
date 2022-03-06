' PB_BitmapGraphics.inc

'
FUNCTION funGetBitmapSize(strBitmapFile AS STRING, _
                          lngWidth AS LONG, _
                          lngHeight AS LONG) AS LONG
' get the size of a bitmap from the file
  LOCAL lngFile AS LONG
  '
  TRY
    lngFile = FREEFILE
    OPEN strBitmapFile FOR BINARY AS lngFile
    GET #lngFile, 19, lngWidth
    GET #lngFile, 23, lngHeight
    FUNCTION = %TRUE
    '
  CATCH
    FUNCTION = %FALSE
  FINALLY
    CLOSE lngFile
  END TRY
  '
END FUNCTION
'
FUNCTION funPasteBitmap(strBitmap AS STRING, _
                        strBitmapMask AS STRING, _
                        lngWidth AS LONG, _
                        lngHeight AS LONG, _
                        lngXstart AS LONG, _
                        lngYstart AS LONG, _
                        lngGraphic AS LONG) AS LONG
' paste a bitmap and its mask to a graphics control
  LOCAL hBmp AS DWORD
  LOCAL hBmpMask AS DWORD
  '
  GRAPHIC BITMAP LOAD strBitmapMask, lngWidth, lngHeight TO hBmpMask
  GRAPHIC BITMAP LOAD strBitmap, lngWidth, lngHeight TO hBmp
  '
  GRAPHIC COPY hBmpMask, lngGraphic TO _
      (lngXstart, lngYstart), %MIX_MASKSRC
  GRAPHIC COPY hBmp, lngGraphic TO _
      (lngXstart, lngYstart), %MIX_MERGESRC

END FUNCTION
