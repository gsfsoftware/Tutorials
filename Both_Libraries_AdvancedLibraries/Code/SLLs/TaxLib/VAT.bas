#COMPILE SLL
#DIM ALL
'
FUNCTION funReturnVATtax(lngAmount AS CURRENCYX) EXPORT AS CURRENCYX
' return the amount of Value Added Tax on an amount
  FUNCTION = lngAmount * 0.20
'
END FUNCTION
