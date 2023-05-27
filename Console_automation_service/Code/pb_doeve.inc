'
'  pb_doeve.bas
'
'  DESCRIPTION
'     Exports a "doevents" function
'
'  AUTHOR
'     Don Dickinson
'     ddickinson@usinternet.com
'     www.basicguru.com/dickinson
'
'  LICENSE and DISCLAIMER
'     Hereby Public Domain
'     Use this code as you see fit. By using or compiling this code or derivative
'     thereof, you are consenting to the hold the author, Don Dickinson, harmless
'     for all effects or side-effects its use. This code works great for me,
'     but you are using it at your own risk.
'
'  DEPENDS ON
'     win32api.inc  - windows api declarations from powerbasic.
'
#if not %def(%PB_DOEVE_BAS)
%PB_DOEVE_BAS = 1

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  apiDoevents
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Sub apiDoevents()

    Static Msg As tagMsg

    If PeekMessage(Msg, %NULL, 0, 0, %PM_REMOVE) Then
        TranslateMessage Msg
        DispatchMessage Msg
    End If

End Sub

#endif
