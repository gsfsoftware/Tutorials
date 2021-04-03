'==============================================================================
'
'  CGI code for the PowerBASIC Console Compiler
'  Copyright (c) 1998 by PowerBASIC, Inc. All Rights Reserved.
'
'  Note:  The POST method only works with Microsoft compatible web servers
'         including:  IIS, Peer Web Server, Personal Web Server, WebSite,
'         EMWAC, and Apache NT.
'
'==============================================================================


'------------------------------------------------------------------------------
' Return the user authentication and the script is protected. If server
' supports???
'
FUNCTION Auth_Type() AS STRING

  FUNCTION = ENVIRON$("AUTH_TYPE")

END FUNCTION


'------------------------------------------------------------------------------
' Return the length of the input string from the form
'
FUNCTION Content_Length() AS LONG

  FUNCTION = VAL( ENVIRON$("CONTENT_LENGTH") )

END FUNCTION


'------------------------------------------------------------------------------
' Return the content type of data supplied from the server.
'
FUNCTION Content_Type() AS STRING

  FUNCTION = ENVIRON$("CONTENT_TYPE")

END FUNCTION


'------------------------------------------------------------------------------
' Current document file name.
'
FUNCTION Document() AS STRING

  FUNCTION = ENVIRON$("DOCUMENT")

END FUNCTION


'------------------------------------------------------------------------------
' Virtual path to the current document
'
FUNCTION Document_URI() AS STRING

  FUNCTION = ENVIRON$("DOCUMENT_URI")

END FUNCTION


'------------------------------------------------------------------------------
' Return the current date in GMT
'
FUNCTION Date_GMT() AS STRING

  FUNCTION = ENVIRON$("DATE_GMT")

END FUNCTION


'------------------------------------------------------------------------------
' Return the current local date to the server.
'
FUNCTION Date_Local() AS STRING

  FUNCTION = ENVIRON$("DATE_LOCAL")

END FUNCTION


'------------------------------------------------------------------------------
' Return the gateway interface (eg: "CGI 1.1")
'
FUNCTION Gateway_Interface() AS STRING

  FUNCTION = ENVIRON$("GATEWAY_INTERFACE")

END FUNCTION


'------------------------------------------------------------------------------
' Last edit date of the document.
'
FUNCTION Last_Modified() AS STRING

  FUNCTION = ENVIRON$("LAST_MODIFIED")

END FUNCTION


'------------------------------------------------------------------------------
'
'
FUNCTION Local_Addr() AS STRING

  FUNCTION = ENVIRON$("LOCAL_ADDR")

END FUNCTION


'------------------------------------------------------------------------------
' Windows NT account details for the user.
'
FUNCTION Logon_User() AS STRING

  FUNCTION = ENVIRON$("LOGON_USER")

END FUNCTION


'------------------------------------------------------------------------------
' Return the extra path information as given by the client
'
FUNCTION Path_Info() AS STRING

  FUNCTION = ENVIRON$("PATH_INFO")

END FUNCTION


'------------------------------------------------------------------------------
' Return the server provided translated version of Path_Info.
'
FUNCTION Path_Translated() AS STRING

  FUNCTION = ENVIRON$("PATH_TRANSLATED")

END FUNCTION


'------------------------------------------------------------------------------
' Return the method used to send data from the web server to the application
'
FUNCTION Query_Method() AS STRING

  FUNCTION = ENVIRON$("QUERY_METHOD")

END FUNCTION


'------------------------------------------------------------------------------
'
'
FUNCTION Query_String() AS STRING

  FUNCTION = ENVIRON$("QUERY_STRING")

END FUNCTION

'------------------------------------------------------------------------------
'
'
FUNCTION Query_String_Unescaped() AS STRING

  FUNCTION = ENVIRON$("QUERY_STRING_UNESCAPED")

END FUNCTION

'------------------------------------------------------------------------------
' Returns the remote users connection address (not email address)
'
FUNCTION Remote_Addr() AS STRING

  FUNCTION = ENVIRON$("REMOTE_ADDR")

END FUNCTION


'------------------------------------------------------------------------------
' Returns the clients reverse DNS of their IP address
'
FUNCTION Remote_Host() AS STRING

  FUNCTION = ENVIRON$("REMOTE_HOST")

END FUNCTION


'------------------------------------------------------------------------------
' Return the user name retrieved from the server. If the client supports RFC931
' identification.
'
FUNCTION Remote_Ident() AS STRING

  FUNCTION = ENVIRON$("REMOTE_IDENT")

END FUNCTION


'------------------------------------------------------------------------------
' Return the username authentication and the script is protected. If server
' supports???
'
FUNCTION Remote_User() AS STRING

  FUNCTION = ENVIRON$("REMOTE_USER")

END FUNCTION


'------------------------------------------------------------------------------
' Return the method used to send data from the web server to the application
'
FUNCTION Request_Method() AS STRING

  FUNCTION = ENVIRON$("REQUEST_METHOD")

END FUNCTION


'------------------------------------------------------------------------------
' Return the name of the script which launched the CGI app
'
FUNCTION Script_Name() AS STRING

  FUNCTION = ENVIRON$("SCRIPT_NAME")

END FUNCTION


'------------------------------------------------------------------------------
' Return the server's host name
'
FUNCTION Server_Name() AS STRING

  FUNCTION = ENVIRON$("SERVER_NAME")

END FUNCTION


'------------------------------------------------------------------------------
' Return the port used to communicate with the server
'
FUNCTION Server_Port() AS LONG

  FUNCTION = VAL( ENVIRON$("SERVER_PORT") )

END FUNCTION


'------------------------------------------------------------------------------
' Return true (-1) if the connection is secure
'
FUNCTION Server_Port_Secure() AS LONG

  FUNCTION = ISFALSE ENVIRON$("SERVER_PORT_SECURE") = "0"

END FUNCTION


'------------------------------------------------------------------------------
' Return the name and revision of the information protocol from the server
'
FUNCTION Server_Protocol() AS STRING

  FUNCTION = ENVIRON$("SERVER_PROTOCOL")

END FUNCTION


'------------------------------------------------------------------------------
' Return the name and version of the server software
'
FUNCTION Server_Software() AS STRING

  FUNCTION = ENVIRON$("SERVER_SOFTWARE")

END FUNCTION


'------------------------------------------------------------------------------
' List of the MIME data types the browser can accept.  Values are seperated
' by commas.
'
FUNCTION Http_Accept() AS STRING

  FUNCTION = ENVIRON$("HTTP_ACCEPT")

END FUNCTION


'------------------------------------------------------------------------------
'
FUNCTION Http_Accept_Charset() AS STRING

  FUNCTION = ENVIRON$("HTTP_ACCEPT_CHARSET")

END FUNCTION


'------------------------------------------------------------------------------
'
FUNCTION Http_Accept_Encoding() AS STRING

  FUNCTION = ENVIRON$("HTTP_ACCEPT_ENCODING")

END FUNCTION


'------------------------------------------------------------------------------
' List of the human languages the client can accept.
'
FUNCTION Http_Accept_Language() AS STRING

  FUNCTION = ENVIRON$("HTTP_ACCEPT_LANGUAGE")

END FUNCTION


'------------------------------------------------------------------------------
'
FUNCTION Http_Connection() AS STRING

  FUNCTION = ENVIRON$("HTTP_CONNECTION")

END FUNCTION


'------------------------------------------------------------------------------
' Retrieves the Cookie string detected by the server
'
FUNCTION Http_Cookie() AS STRING

  FUNCTION = ENVIRON$("HTTP_COOKIE")

END FUNCTION


'------------------------------------------------------------------------------
' Returns the remote clients email address (if available); only works with
' Netscape
'
FUNCTION Http_From() AS STRING

  FUNCTION = ENVIRON$("HTTP_FROM")

END FUNCTION


'------------------------------------------------------------------------------
'
FUNCTION Http_Host() AS STRING

  FUNCTION = ENVIRON$("HTTP_HOST")

END FUNCTION


'------------------------------------------------------------------------------
'
FUNCTION Http_Pragma() AS STRING

  FUNCTION = ENVIRON$("HTTP_PRAGMA")

END FUNCTION


'------------------------------------------------------------------------------
' Return the URL of the document that the client points to before accessing the
' CGI application.
'
FUNCTION Http_Referer() AS STRING

  FUNCTION = ENVIRON$("HTTP_REFERER")

END FUNCTION


'------------------------------------------------------------------------------
' Product name of the clients browser software.
'
FUNCTION Http_User_Agent() AS STRING

  FUNCTION = ENVIRON$("HTTP_USER_AGENT")

END FUNCTION


'------------------------------------------------------------------------------
' Returns if secure pages are turned on or off
'
FUNCTION HttpS() AS STRING

  FUNCTION = ENVIRON$("HTTPS")

END FUNCTION

'------------------------------------------------------------------------------
' Return the physical path of the CGI application
'
$IF NOT %DEF(%WINAPI)
  DECLARE FUNCTION GetModuleFileName LIB "KERNEL32.DLL" ALIAS "GetModuleFileNameA" (BYVAL hModule AS LONG, lpFileName AS ASCIIZ, BYVAL nSize AS LONG) AS LONG
$ENDIF

FUNCTION AppPath() AS STRING

  LOCAL p AS ASCIIZ * 256
  LOCAL x AS LONG

  GetModuleFileName 0, p, SIZEOF(p)

  FOR x = LEN(p) TO 1 STEP - 1
    IF ASC(p, x) = 92 THEN
      EXIT FOR
    END IF
  NEXT

  FUNCTION = LEFT$(p, x)

END FUNCTION

'------------------------------------------------------------------------------
' Read data from the CGI script
'
FUNCTION ReadCGI() AS STRING

  LOCAL Temp AS STRING

  SELECT CASE Request_Method

    CASE "GET", "PUT", "HEAD"
      FUNCTION = ENVIRON$("QUERY_STRING")

    CASE "POST"
      CON.STDIN.LINE TO Temp
      FUNCTION = Temp

    CASE ELSE   'assume the command line
      FUNCTION = COMMAND$

  END SELECT

END FUNCTION


'------------------------------------------------------------------------------
' Write a string to the web server and automatically take care of the header
'
SUB WriteCGI(BYVAL x AS STRING)

  STATIC header AS LONG

  IF ISFALSE header THEN
    STDOUT "Content-type: text/html" + CHR$(13, 10)
    header = -1
  END IF

  REPLACE "''" WITH CHR$(34) IN x

  STDOUT x

END SUB


'------------------------------------------------------------------------------
' Decode all of the special characters in a CGI string
'
FUNCTION DecodeCGI(BYVAL t AS STRING) AS STRING

  DIM b_in  AS BYTE PTR
  DIM b_out AS BYTE PTR
  DIM h     AS STRING PTR * 2
  DIM a     AS ASCIIZ PTR

  IF LEN(t) = 0 THEN
    EXIT FUNCTION
  END IF

  b_in  = STRPTR(t)
  b_out = b_in

  DO

    IF @b_in = 43 THEN          'convert plus to space
      @b_out = 32

    ELSEIF @b_in = 37 THEN      'process special chars
      h = b_in + 1
      @b_out = VAL("&H" + @h)
      b_in = b_in + 2

    ELSE
      @b_out = @b_in

    END IF

    INCR b_in
    INCR b_out

  LOOP UNTIL @b_in = 0

  @b_out = 0

  a = STRPTR(t)

  FUNCTION = @a

END FUNCTION


'------------------------------------------------------------------------------
' For best effect, do not decode the params string first
'
FUNCTION ParseParams(BYVAL params AS STRING, Param() AS STRING) AS LONG

  LOCAL c AS LONG
  LOCAL x AS LONG

  c = PARSECOUNT(params, "&")

  REDIM Param(c) AS STRING

  FOR x = 1 TO c
    Param(x) = PARSE$(params, "&", x)
  NEXT x

  FUNCTION = c

END FUNCTION


'------------------------------------------------------------------------------
' Parse raw CGI data and return specified parameter
'
FUNCTION CgiParam(BYVAL param AS STRING, BYVAL which AS STRING) AS STRING

  LOCAL x AS LONG
  LOCAL p AS STRING

  which = which + "="

  FOR x = 1 TO PARSECOUNT(param, "&")
    p = PARSE$(param, "&", x)
    IF LEFT$(UCASE$(p), LEN(which)) = UCASE$(which) THEN
      FUNCTION = DecodeCGI(MID$(p, LEN(which) + 1))
      EXIT FUNCTION
    END IF
  NEXT

END FUNCTION
