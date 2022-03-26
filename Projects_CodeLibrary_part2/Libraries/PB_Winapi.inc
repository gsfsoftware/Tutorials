'  win api calls

SUB DrawGradient (BYVAL hDC AS DWORD, BYVAL lngColour AS LONG)
' draw a gradient fill
  LOCAL rectFill AS RECT
  LOCAL rectClient AS RECT
  LOCAL fStep AS SINGLE
  LOCAL hBrush AS DWORD
  LOCAL lngOnBand AS LONG
  '
  LOCAL lngStart AS LONG
  LOCAL lngEnd AS LONG
  '
  lngStart = 0
  lngEnd = 199
  '
  GetClientRect WindowFromDC(hDC), rectClient
  fStep = rectClient.nbottom / 200
  '
  FOR lngOnBand = lngStart TO lngEnd
    SetRect rectFill, 0, lngOnBand * fStep, rectClient.nright + 1, (lngOnBand + 1) * fStep
    '
    SELECT CASE lngColour
      CASE 1
      ' blue
        hBrush = CreateSolidBrush(RGB(0, 0, 255 - lngOnBand))
      CASE 2
      ' green
        hBrush = CreateSolidBrush(RGB(0, 255 - lngOnBand, 0))
      CASE 3
        ' red
        hBrush = CreateSolidBrush(RGB(255 - lngOnBand, 0, 0))
      '
      CASE ELSE
      ' grey
        hBrush = CreateSolidBrush(RGB(255 - lngOnBand, _
                                      255 - lngOnBand, _
                                      255 - lngOnBand))
    END SELECT
    '
    Fillrect hDC, rectFill, hBrush
    DeleteObject hBrush
  NEXT lngOnBand
  '
END SUB
