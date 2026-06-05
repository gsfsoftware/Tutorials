'==============================================================================
'
' CGI code for the PowerBASIC Console Compiler
'
' Copyright (c) 1998-2011 PowerBASIC, Inc.
' All Rights Reserved.
'
' We have provided wrappers for many common CGI environment variables here.
' Which variables are actually available depends on your specific web server.
'
'==============================================================================
#INCLUDE THIS ONCE

#IF NOT %DEF(%PBCGI_INC)

%PBCGI_INC = 1

#INCLUDE ONCE "Win32API.inc"



'------------------------------------------------------------------------------
' Auth_Type returns the authentication method used to validate a user. See
' Remote_Ident and Remote_User. Only applicable if the server supports user
' authentication and the script is protected.
'
MACRO Auth_Type () = ENVIRON$("AUTH_TYPE")



'------------------------------------------------------------------------------
' Content_Length returns the number of bytes or characters waiting as input.
' Used with queries such as POST and PUT.
'
MACRO Content_Length () = VAL(ENVIRON$("CONTENT_LENGTH"))



'------------------------------------------------------------------------------
' Content_Type returns the type of the query data, e.g., "text/html".
'
MACRO Content_Type () = ENVIRON$("CONTENT_TYPE")



'------------------------------------------------------------------------------
' Date_GMT returns the current time/date in UTC.
'
MACRO Date_GMT ()= ENVIRON$("DATE_GMT")



'------------------------------------------------------------------------------
' Date_Local returns the current time/date in local time.
'
MACRO Date_Local () = ENVIRON$("DATE_LOCAL")



'------------------------------------------------------------------------------
' Document returns the current document file name.
'
MACRO Document () = ENVIRON$("DOCUMENT")



'------------------------------------------------------------------------------
' Document_URI returns the virtual path of the current document.
'
MACRO Document_URI () = ENVIRON$("DOCUMENT_URI")



'------------------------------------------------------------------------------
' Gateway_Interface returns the CGI version supported by the server, e.g.,
' "CGI/1.1".
'
MACRO Gateway_Interface () = ENVIRON$("GATEWAY_INTERFACE")



'------------------------------------------------------------------------------
' Http_Accept returns a list of the MIME types accepted by the client. Values
' may contain wildcards and/or a list of types separated by commas, e.g.,
' "*/*".
'
MACRO Http_Accept () = ENVIRON$("HTTP_ACCEPT")



'------------------------------------------------------------------------------
' Http_Accept_Encoding returns a list of the encoding methods supported by the
' client, e.g., "gzip, deflate".
'
MACRO Http_Accept_Encoding () = ENVIRON$("HTTP_ACCEPT_ENCODING")



'------------------------------------------------------------------------------
' Http_Accept_Language returns a list of the (human) languages supported by
' the client, using ISO codes, e.g., "en-us".
'
MACRO Http_Accept_Language () = ENVIRON$("HTTP_ACCEPT_LANGUAGE")



'------------------------------------------------------------------------------
' Http_Connection returns the type of connection established, e.g.,
' "Keep-Alive".
'
MACRO Http_Connection () = ENVIRON$("HTTP_CONNECTION")



'------------------------------------------------------------------------------
' Http_Cookie returns the cookie string detected by the server.
'
MACRO Http_Cookie () = ENVIRON$("HTTP_COOKIE")



'------------------------------------------------------------------------------
' Http_From returns the user's email address. Rarely available.
'
MACRO Http_From () = ENVIRON$("HTTP_FROM")



'------------------------------------------------------------------------------
' Http_Host appears to return the web address of the server.
'
MACRO Http_Host () = ENVIRON$("HTTP_HOST")



'------------------------------------------------------------------------------
' Http_Referer returns the URL of the last document the client read before
' accessing the CGI program.
'
MACRO Http_Referer () = ENVIRON$("HTTP_REFERER")



'------------------------------------------------------------------------------
' Http_User_Agent returns the name of the client's browser software.
'
MACRO Http_User_Agent () = ENVIRON$("HTTP_USER_AGENT")



'------------------------------------------------------------------------------
' HttpS returns whether secure scripting is enabled, e.g., "off".
'
MACRO HttpS () = ENVIRON$("HTTPS")



'------------------------------------------------------------------------------
' Last_Modified returns the last edit date of the document.
'
MACRO Last_Modified () = ENVIRON$("LAST_MODIFIED")



'------------------------------------------------------------------------------
' Local_Addr returns the local machine IP address.
'
MACRO Local_Addr () = ENVIRON$("LOCAL_ADDR")



'------------------------------------------------------------------------------
' Path_Info returns the extra path information passed to a CGI program. This
' is any trailing part of the URL after the script name.
'
MACRO Path_Info () = ENVIRON$("PATH_INFO")



'------------------------------------------------------------------------------
' Path_Translated returns the Path_Info as translated by the server into a full
' physical path.
'
MACRO Path_Translated () = ENVIRON$("PATH_TRANSLATED")



'------------------------------------------------------------------------------
' Query_String returns the query information passed to the CGI program. This is
' the part appended to the URL after the question mark.
'
MACRO Query_String () = ENVIRON$("QUERY_STRING")



'------------------------------------------------------------------------------
' Query_String_Unescaped returns the query information passed to the CGI
' program. This is the part appended to the URL after the question mark. The
' information is not decoded, but has shell metacharacters escaped with a "\".
'
MACRO Query_String_Unescaped () = ENVIRON$("QUERY_STRING_UNESCAPED")



'------------------------------------------------------------------------------
' Remote_Addr returns the client's IP address.
'
MACRO Remote_Addr () = ENVIRON$("REMOTE_ADDR")



'------------------------------------------------------------------------------
' Remote_Host returns the client's host name.
'
MACRO Remote_Host () = ENVIRON$("REMOTE_HOST")



'------------------------------------------------------------------------------
' Remote_Ident returns the identity of the user.
'
MACRO Remote_Ident () = ENVIRON$("REMOTE_IDENT")



'------------------------------------------------------------------------------
' Remote_User returns the authenticated name of the user, if available.
'
MACRO Remote_User () = ENVIRON$("REMOTE_USER")



'------------------------------------------------------------------------------
' Request_Method returns the method used to issue the information request,
' e.g., "GET".
'
MACRO Request_Method () = ENVIRON$("REQUEST_METHOD")



'------------------------------------------------------------------------------
' Script_Name returns the full filespec of the script being executed.
'
MACRO Script_Name () = ENVIRON$("SCRIPT_NAME")



'------------------------------------------------------------------------------
' Server_Name returns the name or IP address of the server.
'
MACRO Server_Name () = ENVIRON$("SERVER_NAME")



'------------------------------------------------------------------------------
' Server_Port returns the port number being used by the server, e.g., "80".
'
MACRO Server_Port () = VAL(ENVIRON$("SERVER_PORT"))



'------------------------------------------------------------------------------
' Server_Port_Secure returns whether the connection is secure.
'
MACRO Server_Port_Secure () = (ENVIRON$("SERVER_PORT_SECURE") <> "0")



'------------------------------------------------------------------------------
' Server_Protocol returns the name and version of the server protocol, e.g.,
' "HTTP/1.1".
'
MACRO Server_Protocol () = ENVIRON$("SERVER_PROTOCOL")



'------------------------------------------------------------------------------
' Server_Software returns the name and version of the server software, e.g.,
' "Microsoft-IIS/5.0".
'
MACRO Server_Software () = ENVIRON$("SERVER_SOFTWARE")



'------------------------------------------------------------------------------
' AppPath returns the path of the CGI program.
'
MACRO FUNCTION AppPath ()

    MACROTEMP sFileSpec

    LOCAL sFileSpec AS ASCIIZ * %MAX_PATH

    GetModuleFileName 0, sFileSpec, SIZEOF(sFileSpec)

END MACRO = LEFT$(sFileSpec, INSTR(-1, sFileSpec, "\"))



'------------------------------------------------------------------------------
' ReadCGI returns the input data for the CGI program.
'
FUNCTION ReadCGI () AS STRING

    SELECT CASE Request_Method

    CASE "GET", "PUT", "HEAD"
        FUNCTION = ENVIRON$("QUERY_STRING")

    CASE "POST"
        LOCAL sPost AS STRING
        STDIN LINE sPost
        FUNCTION = sPost

    CASE ELSE
        FUNCTION = COMMAND$

    END SELECT

END FUNCTION

MACRO cgiRead = ReadCGI



'------------------------------------------------------------------------------
' WriteCGI writes an HTML string to the web server. It automatically takes care
' of the necessary header.
'
SUB WriteCGI (BYVAL st AS STRING)

    STATIC HtmlHeader AS LONG

    IF ISFALSE HtmlHeader THEN
        STDOUT "Content-type: text/html"
        STDOUT
        HtmlHeader = -1
    END IF

    STDOUT st

END SUB

MACRO cgiWrite = WriteCGI

MACRO cgiWriteLn(st) = WriteCGI(st + "<br>")



'------------------------------------------------------------------------------
' DecodeCGI decodes the special characters in a CGI string.
'
FUNCTION DecodeCGI (BYVAL sInput AS STRING) AS STRING

    LOCAL pbInput   AS BYTE PTR
    LOCAL pbOutput  AS BYTE PTR
    LOCAL ncbInput  AS LONG
    LOCAL ncbOutput AS LONG
    LOCAL ncHex     AS LONG

    ncbInput = LEN(sInput)
    IF ncbInput = 0 THEN EXIT FUNCTION

    pbInput = STRPTR(sInput)
    pbOutput = pbInput

    DO
        SELECT CASE CONST @pbInput

        CASE 37   ' "&"
            INCR pbInput
            DECR ncbInput
            ncHex = MIN(2, ncbInput)
            IF ncHex THEN
                @pbOutput = VAL("&H" + PEEK$(pbInput, ncHex))
                pbInput = pbInput + ncHex
                ncbInput = ncbInput - ncHex
            END IF

        CASE 43   ' "+"
            @pbOutput = 32   ' $SPC
            INCR pbInput
            DECR ncbInput

        CASE ELSE
            @pbOutput = @pbInput
            INCR pbInput
            DECR ncbInput
        END SELECT

        INCR pbOutput
        INCR ncbOutput

    LOOP WHILE ncbInput

    FUNCTION = LEFT$(sInput, ncbOutput)

END FUNCTION

MACRO cgiDecode = DecodeCGI



'------------------------------------------------------------------------------
' ParseParams parses the parameters passed to a CGI program. For best results,
' do not decode the params string first. The function returns the number of
' parameters parsed into the asParm() array.
'
FUNCTION ParseParams (BYVAL sParmList AS STRING, asParm() AS STRING) AS LONG

    LOCAL ncParms AS LONG

    IF LEN(sParmList) THEN
        ncParms = PARSECOUNT(sParmList, "&")

        REDIM asParm(1 TO ncParms) AS STRING

        PARSE sParmList, asParm(), "&"
    ELSE
        ERASE asParm()
    END IF

    FUNCTION = ncParms

END FUNCTION



'------------------------------------------------------------------------------
' CgiParam parses raw CGI data to return the parameter you specify. The target
' parameter name is not case-sensitive.
'
FUNCTION CgiParam (BYVAL sParmList AS STRING, BYVAL sTarget AS STRING) AS STRING

    LOCAL ix    AS LONG
    LOCAL sParm AS STRING

    sTarget = UCASE$(sTarget) + "="

    FOR ix = 1 TO PARSECOUNT(sParmList, "&")
        sParm = PARSE$(sParmList, "&", ix)
        IF UCASE$(LEFT$(sParm, LEN(sTarget))) = sTarget THEN
            FUNCTION = DecodeCGI(MID$(sParm, LEN(sTarget) + 1))
            EXIT FOR
        END IF
    NEXT

END FUNCTION



FUNCTION CookieDate (BYVAL days AS LONG) AS STRING

    LOCAL d  AS ASCIIZ * 64
    LOCAL t  AS ASCIIZ * 64
    LOCAL st AS SYSTEMTIME
    LOCAL v  AS DOUBLE

    GetSystemTime st
    SystemTimeToVariantTime st, v

    v = v + days

    VariantTimeToSystemTime v, st

    GetDateFormat 0, 0, st, "ddd',' dd'-'MMM'-'yyyy", d, 64
    GetTimeFormat 0, 0, st, "HH':'mm':'ss", t, 64

    FUNCTION = d + " " + t + " GMT"

END FUNCTION



MACRO SetCookie (cookie, value, days, url) = STDOUT "Set-Cookie: " + cookie + "=" + value + "; expires=" + CookieDate(IIF&(days, days, 30)) + "; path=" + url + ";"



#ENDIF  ' #IF NOT %DEF(%PBCGI_INC)
