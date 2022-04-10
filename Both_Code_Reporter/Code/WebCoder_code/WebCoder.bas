'いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
' webcoder.bas
' code for a small "bas2html" dll that converts a given string with
' pb code (bas, inc) to "syntax colored" plain html formatted result.
' see also demo prog at [url="http://www.powerbasic.com/support/pbforums/showthread.php?t=23773"]http://www.powerbasic.com/support/pbforums/showthread.php?t=23773[/url]
'
' html is bloated garbage - usually given code becomes 2-3 times
' larger as syntax colored html. i have tried make it create as small
' result as possible. to change html header and syntax colors, etc,
' see bastosyntaxcolhtml routine.
'
' one exported function - bastosyntaxcolhtml. see "webcdemo" sample
' for "how to" declare and use this dll. uses byte pointer parsing and
' indexed array for compare, so should be fast enough for most needs..
'
' public domain by borje hagsten, march 2003.
'
' this code plus compiled exe and dll can also be found at my
' pb web-page: [url="http://www.tolkenxp.com/pb"]http://www.tolkenxp.com/pb[/url]
'--------------------------------------------------------------------
#COMPILE DLL
#INCLUDE  "win32api.inc"  'basic win api definitions
'--------------------------------------------------------------------
GLOBAL astart() AS LONG, acount() AS LONG
'--------------------------------------------------------------------
DECLARE SUB loadpbdata(darray() AS STRING)
'--------------------------------------------------------------------
' in exe:
'declare function bastosyntaxcolhtml lib "webcoder.dll" _
'          alias "bastosyntaxcolhtml" (byval txt as string) as string

'いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
' dll entry/exit point..
'--------------------------------------------------------------------
FUNCTION LIBMAIN (BYVAL hinstance   AS LONG, _
                  BYVAL fwdreason   AS LONG, _
                  BYVAL lpvreserved AS LONG) AS LONG
    SELECT CASE fwdreason
        CASE %dll_process_attach : FUNCTION = 1
        CASE %dll_process_detach : FUNCTION = 1
        CASE %dll_thread_attach  : FUNCTION = 1
        CASE %dll_thread_detach  : FUNCTION = 1
    END SELECT
END FUNCTION

'いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
' redim, load and index an array with data
'--------------------------------------------------------------------
SUB loadpbdata(darray() AS STRING)
  LOCAL ii AS LONG, jj AS LONG, kk AS LONG, c AS LONG

  c = DATACOUNT
  REDIM darray(c - 1) AS STRING 'zero based, so -1
  REDIM astart(26), acount(26)   'for index

  FOR ii = 1 TO c               'read the data into the array
     darray(ii - 1) = UCASE$(READ$(ii))
  NEXT

  ARRAY SORT darray() 'make sure array is sorted, to enable indexing for fast search

  jj = 64  'index on first character, $%? = 0, a = 1, etc..
  FOR ii = 0 TO UBOUND(darray)
     kk = ASC(darray(ii))
     IF kk > jj THEN    'a - z
        acount(jj - 64) = MAX&(0, ii - 1) 'indexed end
        jj = kk
        astart(kk - 64) = ii
     END IF
  NEXT
  acount(jj - 64) = MAX&(0, ii - 1)

  FOR ii = 0 TO 26 're-calculate count
     IF acount(ii) THEN acount(ii) = MAX&(0, acount(ii) - astart(ii) + 1)
  NEXT

'pb/win (dll) keywords - think at least most of them..  :-)
DATA #bloat, #compile, #debug, #dim, #else, #elseif, #endif, #if, #include, #option, #register, #resource
DATA #segment, #stack, #tools, $bel, $bs, $compile, $cr, $crlf, $debug, $dim, $dq, $else, $elseif, $endif
DATA $eof, $esc, $ff, $if, $include, $lf, $nul, $option, $register, $resource, $segment, $spc, $stack
DATA $tab, $vt, %def, %false, %null, %pb_exe, %true
DATA abs, accel, accept, access, acode$, add, addr, alias, all, and, any, append, array, arrayattr
DATA as, asc, ascend, asciz, asciiz, at, atn, attach, attrib, bar, base, baud, bdecl, beep
DATA bin$, binary, bit, bits%, bits&, bits?, bits??, bits???, break, button, bycmd, bycopy, byref
DATA byte, byval, calc, call, callback, callstk, callstk$, callstkcount, case, catch, cbctl, cbctlmsg
DATA cbhndl, cblparam, cbmsg, cbwparam, cbyt, ccur, ccux, cd, cdbl, cdecl, cdwd, ceil, cext, chdir
DATA chdrive, check, check3state, checkbox, choose, choose&, choose%, choose$, chr$, cint, client, clng
DATA close, cls, clsid$, codeptr, collate, color, combobox, comm, command$, con, connect, const, control
DATA cos, cqud, create, cset, cset$, csng, ctsflow, cur, curdir$, currency, currencyx, cux, cvbyt, cvcur
DATA cvcux, cvd, cvdwd, cve, cvi, cvl, cvq, cvs, cvwrd, cwrd, data, datacount, date$, declare, decr, default
DATA defbyt, defcur, defcux, defdbl, defdwd, defext, defint, deflng, defqud, defsng, defstr, defwrd, delete
DATA descend, dialog, dim, dir$, disable, diskfree, disksize, dispatch, dll, dllmain, do, doevents, double
DATA down, draw, dsrflow, dsrsens, dtrflow, dtrline, dword, else, elseif, empty, enable, end, environ$
DATA eof, eqv, erase, err, errapi, errclear, error, error$, exe, exit, exp, exp10, exp2, explicit, export
DATA ext, extended, extract$, fileattr, filecopy, filename$, filescan, fill, finally, fix, flow, flush, focus
DATA font, for, format$, formfeed, frac, frame, freefile, from, function, funcname$, get, get#, get$
DATA getattr, global, gosub, goto, guid$, guidtxt$, handle, hex$, hibyt, hiint, hiwrd, host, icase, icon
DATA idn, if, iface, iif, iif&, iif%, iif$, image, imagex, imgbutton, imgbuttonx, imp, in, incr, inp, inout
DATA input, input#, inputbox$, insert, instr, int, interface, integer, inv, isfalse, isnothing
DATA isobject, istrue, iterate, join$, kill, label, lbound, lcase$, left, left$, len, let, lib, libmain
DATA line, listbox, lobyt, loc, local, lock, lof, log, log10, log2, loint, long, loop, lowrd, lprint
DATA lset, lset$, ltrim$, macro, macrotemp, main, makdwd, makint, maklng, makptr, makwrd, mat, max, max$
DATA max%, max&, mcase$, member, menu, mid$, min, min$, min%, min&, mkbyt$, mkcur$, mkcux$, mkd$
DATA mkdir, mkdwd$, mke$, mki$, mkl$, mkq$, mks$, mkwrd$, mod, modal, modeless, mouseptr, msgbox
DATA name, new, next, none, not, nothing, notify, null, objactive, object, objptr, objresult, oct$, of
DATA off, on, open, opt, option, optional, or, out, output, page, parity, paritychar, parityrepl, paritytype
DATA parse, parse$, parsecount, pbd, pbmain, peek, peek$, pixels, pointer, poke, poke$, popup, port, post
DATA preserve, print, print#, private, profile, progid$, ptr, put, put$, quad, qword, random, randomize, read
DATA read$, receive, records, recv, redim, redraw, regexpr, register, regrepl, remain$, remove$, repeat$
DATA replace, reset, resume, ret16, ret32, ret87, retain$, retp16, retp32, retprm, return, rgb, right
DATA right$, ring, rlsd, rmdir, rnd, rotate, round, rset, rset$, rtrim$, rtsflow, rxbuffer, rxque, scan
DATA scrollbar, sdecl, seek, select, send, server, set, setattr, seteof, sgn, shared, shell
DATA shift, show, signed, sin, single, size, sizeof, sleep, sort, space$, spc, sqr, state, static, status
DATA stdcall, step, stop, str$, strdelete$, string, string$, strinsert$, strptr, strreverse$, sub, suspend
DATA swap, switch, switch&, switch%, switch$, tab, tab$, tagarray, tally, tan, tcp, text, textbox, then
DATA thread, threadcount, threadid, time$, timeout, timer, to, toggle, trace, trim$, trn, try, txbuffer
DATA txque, type, ubound, ucase, ucase$, ucode$, udp, union, units, unlock, until, up, user, using, using$
DATA val, variant, variant#, variant$, variantvt, varptr, verify, version3, version4, version5
DATA wend, while, width, width#, winmain, with, word, write, write#, xor, xinpflow, xoutflow, zer

END SUB

'いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
' dll call - convert and return syntax colored html from pb code string
'--------------------------------------------------------------------
FUNCTION bastosyntaxcolhtml _
  ALIAS "bastosyntaxcolhtml" (BYVAL txt AS STRING) EXPORT AS STRING

  LOCAL ii AS LONG, ac AS LONG, stoppos AS LONG, result AS LONG
  LOCAL wflag AS LONG, remflag AS LONG, dqflag AS LONG, isrem AS LONG
  LOCAL plet AS BYTE PTR, plet2 AS BYTE PTR
  LOCAL tmpword AS STRING, outbuf AS STRING, ucasebuf AS STRING
  LOCAL htmlprefix AS STRING, htmlpostfix AS STRING
  LOCAL greenstr AS STRING, bluestr AS STRING, redstr AS STRING, pbfstr AS STRING
  LOCAL endblock AS STRING, endblue AS STRING, endgreen AS STRING

  DIM cdata() AS STRING
  loadpbdata cdata()

  htmlprefix = "<html>" + $CRLF + _
               "<head>" + $CRLF + _
               "<meta http-equiv=""content-type"" content=""text/html; charset=iso-8859-1"">" + $CRLF + _
               "<meta name=""generator"" content=""webcoder 1.0"">" + $CRLF + _
               "<title>webcoder result</title>" + $CRLF + _
               "</head>" + $CRLF + $CRLF + _
               "<body bgcolor=""#ffffff"">" + $CRLF + _
               "<pre>" + $CRLF

  htmlpostfix = "</pre>" + $CRLF + "</body>" + $CRLF + "</html>" + $CRLF
  greenstr    = "<font color=""#008000"">"
  bluestr     = "<font color=""#0000ff"">"
  pbfstr      = "<font color=""#c06400"">"
  redstr      = "<font color=""#ff0000"">"
  endblock    = "</font>"
  endblue     = "</font2>"
  endgreen    = "</font3>"

  REPLACE "<" WITH "<" IN TXT

  TXT = TXT + " "            'add a space to ensure last word will be checked if nothing follows it
  outbuf   = STRING$(MAX&(1000, 5 * LEN(TXT) ), 0)  '5 times bigger mem for result should be enough
  ucasebuf = UCASE$(TXT)     'use uppercase string for compare
  plet     = STRPTR(TXT)     'pointer to global string (input)
  plet2    = STRPTR(outbuf)  'pointer to output buffer

  FOR ii = 1 TO LEN(TXT)
     SELECT CASE @plet            'the characters we need to inlude in a word
        CASE 65 TO 90, 97 TO 122, 35 TO 38, 48 TO 57, 63, 95
           IF wflag = 0 AND remflag = 0 AND dqflag = 0 THEN
              wflag = 1 : stoppos = ii
           END IF

        CASE 34 ' double quote -> "
           IF dqflag = 0 AND remflag = 0 THEN  'if start of string literal
              POKE$ plet2, redstr              'poke rtf code into output string
              plet2 = plet2 + 22               'and move pointer forward
              dqflag = 1 : wflag = 0           'set flags - since now inside dq, wordflag is off
           ELSEIF dqflag = 1 THEN              'should be end of dq block
              @plet2 = @plet                   'set value in output string
              INCR plet2                       'move one character ahead
              POKE$ plet2, endblock            'poke rtf end block string into output
              plet2 = plet2 + 7                'and move pointer forward
              dqflag = 3                       'end of dq - set dq flag
           END IF

        CASE 59 ' asm uncomment character -> ;
           IF remflag = 0 AND dqflag = 2 THEN
              POKE$ plet2, endblock            'poke rtf end block string into output
              plet2 = plet2 + 7                'and move pointer forward
              POKE$ plet2, greenstr
              plet2 = plet2 + 22
              remflag = 1 : wflag = 0
           END IF

        CASE 39 ' uncomment character -> '
           IF remflag = 0 AND dqflag <> 1 THEN
              IF dqflag = 2 THEN
                 POKE$ plet2, endblock            'poke rtf end block string into output
                 plet2 = plet2 + 7                'and move pointer forward
              END IF
              POKE$ plet2, greenstr
              plet2 = plet2 + 22
              remflag = 1 : wflag = 0 : isrem = 1
           END IF

        CASE 33 ' asm character -> !
           IF remflag = 0 AND dqflag = 0 THEN
              POKE$ plet2, redstr
              plet2 = plet2 + 22
              dqflag = 2 : wflag = 0
           END IF

        CASE ELSE  'word is ready
           IF @plet = 13 THEN    'if crlf - end of line
              IF remflag OR dqflag THEN  'in rem or asm
                 IF isrem = 0 THEN
                    POKE$ plet2, endblock
                    plet2 = plet2 + 7
                 ELSE
                    POKE$ plet2, endgreen
                    plet2 = plet2 + 8
                 END IF
                 remflag = 0 : wflag = 0 : dqflag = 0 : isrem = 0 'reset flags
              END IF
           END IF

           IF wflag = 1 THEN 'if we have a word
              tmpword = MID$(ucasebuf, stoppos, ii - stoppos)  'get word

              ac = ASC(tmpword)         'look at first letter
              IF ac < 91 THEN           'if within english alphabet
                 ac = MAX&(0, ac - 64)  'convert for index array
                 ARRAY SCAN cdata(astart(ac)) FOR acount(ac), = tmpword, TO result 'is it in the array?
              END IF

              IF result THEN                  'if match was found, it's a pb keyword
                 plet2 = plet2 - LEN(tmpword) 'set position to start of word
                 POKE$ plet2, bluestr         'and poke rtf string for blue color into output string
                 plet2 = plet2 + 22           'move pointer ahead
                 POKE$ plet2, tmpword         'poke the word into output string
                 plet2 = plet2 + LEN(tmpword) 'move pointer ahead
                 POKE$ plet2, endblue         'and finally poke rtf end block string into output-
                 plet2 = plet2 + 8            'move pointer ahead
                 result = 0                   'and reset result
              ELSE
                 IF tmpword = "rem" THEN  'extra for rem keyword
                    plet2 = plet2 - 3     'set position to start of word
                    POKE$ plet2, greenstr
                    plet2 = plet2 + 22
                    POKE$ plet2, tmpword
                    plet2 = plet2 + 3
                    remflag = 1 : isrem = 1

                 ELSEIF tmpword = "#pbforms" THEN  'extra for #pbforms statement
                    plet2 = plet2 - 8              'set position to start of word
                    POKE$ plet2, pbfstr
                    plet2 = plet2 + 22
                    POKE$ plet2, tmpword
                    plet2 = plet2 + 8
                    remflag = 1

                 ELSEIF tmpword = "asm" THEN  'extra for asm keyword
                    plet2 = plet2 - 3         'set position to start of word
                    POKE$ plet2, redstr
                    plet2 = plet2 + 22
                    POKE$ plet2, tmpword
                    plet2 = plet2 + 3
                    dqflag = 2
                 END IF

              END IF
              wflag = 0
           END IF
     END SELECT

     IF dqflag <> 3 THEN       'if not handled matching double-quote
        @plet2 = @plet         'copy original character to output
        INCR plet2             'and increase pos in output
     ELSE
        dqflag = 0             'else reset dq flag
     END IF
     INCR plet                 'move ahead to next character
  NEXT ii

  outbuf = EXTRACT$(outbuf, CHR$(32, 0))      'extract result (and remove the added space)

  REPLACE endblue + " " + bluestr WITH " " IN outbuf    'trim size: if keywords are next to each other,
  REPLACE endblue WITH endblock IN outbuf               'replace remaining blue endblocks with proper html

  REPLACE endgreen + $CRLF + greenstr WITH $CRLF IN outbuf 'remmed out lines..
  REPLACE endgreen WITH endblock IN outbuf              'replace remaining green endblocks with proper html

  FUNCTION = htmlprefix + outbuf + htmlpostfix

END FUNCTION
