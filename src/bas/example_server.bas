/'* \file example_server.bas
\brief Example code to test the `bn` package

'/

#INCLUDE ONCE "nettobac.bas"
#INCLUDE ONCE "nettobac_http.bas"

DIM SHARED AS STRING _
    HTML1 _ '*< the startpage, loaded from local data folder
  , HTML2 _ '*< the second page, loaded from local data folder
  , ICON _  '*< an icon, loded from web
  , HTTP _  '*< the HTTP header
  , EMSG    '*< the HTTP error message


FUNCTION newConn(BYVAL Ser AS bnServer PTR, BYVAL Con AS bnConnection PTR) AS INTEGER
  ?"client connected"
  RETURN 0
END FUNCTION

FUNCTION disConn(BYVAL Ser AS bnServer PTR, BYVAL Con AS bnConnection PTR) AS INTEGER
  ?"client disconnected"
  RETURN 0
END FUNCTION

FUNCTION newData(BYVAL Con AS bnConnection PTR, BYREF Dat AS STRING) AS INTEGER
  ?"message: " & dat
  SELECT CASE LEFT(Dat, 4)
  CASE "GET "
    IF MID(Dat, 5,  2) = "/ " ORELSE _
       MID(Dat, 5, 11) = "/demo1.html" THEN
      ?"sending HTML1 ...";
      Con->PutData(HTTP & LEN(HTML1) & HEADEREND & HTML1)
      ?" done"
    ELSEIF MID(Dat, 5, 11) = "/demo2.html" THEN
      ?"sending HTML2 ...";
      Con->PutData(HTTP & LEN(HTML2) & HEADEREND & HTML2)
      ?" done"
    ELSEIF MID(Dat, 5, 12) = "/favicon.ico" THEN
      ?"sending ICON ...";
      Con->PutData(HTTP & LEN(ICON) & HEADEREND & ICON)
      ?" done"
    ELSEIF MID(Dat, 5, 9) = "/FORM?id=" THEN
      VAR p = INSTR(   Dat, "&password=") _
        , q = INSTR(p, Dat, "&button=") _
        , t = "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Transitional//EN"" ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"">" _
            & "<html><body>" _
            & "<b>Login data</b>" _
            & "<p>ID = " & urlDecode(MID(Dat, 14, p - 14)) _
            & "<p>Password = " & urlDecode(MID(Dat, p + 10, q - p - 10)) _
            & "<p><a href=""demo1.html"">Go back to start page</a>" _
            & "</body></html>"
      ?"sending FORM response ...";
      Con->PutData(HTTP & LEN(t) & HEADEREND & t)
      ?" done"
    ELSEIF MID(Dat, 5, 5) = "/EXIT" THEN
      ?"EXIT --> server shuts down"
      RETURN 1
    ELSE
       VAR e = "HTTP/1.1 404 Not Found" _
             & "Date: Sat, 31 Oct 2015 06:16:38 GMT" _
             & "Server: Apache" _
             & "Vary: Accept-Encoding" _
             & "Content-Length: 239" _
             & "Connection: close" _
             & "Content-Type: text/html; charset=iso-8859-1" _
             & HEADEREND _
             & "<!DOCTYPE HTML PUBLIC ""-//IETF//DTD HTML 2.0//EN"">" _
             & "<html><head>" _
             & "<title>404 Not Found</title>" _
             & "</head><body>" _
             & "<h1>Not Found</h1>" _
             & "<p>The requested URL was not found on this server.</p>" _
             & "</body></html>" _

      ?"sending ERROR ...";
      Con->PutData(HTTP & LEN(e) & HEADEREND & e)
      ?" done"
    END IF
  END SELECT : RETURN 0
END FUNCTION

?VERSION_TEXT

httpLoad(ICON, "freebasic.net/sites/default/files/horse_original_r_0_0.gif", MIME_GIF)

HTTP = !"HTTP/1.1 200 OK" _
 & !"\r\nServer: NetToBac-Server" _
 & !"\r\nAccept-Ranges: bytes" _
 & !"\r\nVary: Accept-Encoding" _
 & !"\r\nX-Content-Type-Options: nosniff" _
 & !"\r\nContent-Type: text/html" _
 & !"\r\nConnection: keep-alive" _
 & !"\r\nContent-Length: "

 '& !"\r\nETag: ""2ffde1-25e6-51aea94fd5f28""" _
 '& !"\r\nCache-Control: public, max-age=86400" _
 '& !"\r\nDate: Fri, 30 Oct 2015 09:16:52 GMT" _
 '& !"\r\nLast-Modified: Wed, 15 Jul 2015 14:15:07 GMT" _

VAR fnam = "data/demo1.html", fnr = FREEFILE
IF OPEN(fnam FOR INPUT AS fnr) THEN
  ?"Cannot open " & fnam
ELSE
  HTML1 = STRING(LOF(fnr), 0)
  GET #fnr, , HTML1
  CLOSE #fnr
END IF

fnam = "data/demo2.html"
fnr = FREEFILE
IF OPEN(fnam FOR INPUT AS fnr) THEN
  ?"Cannot open " & fnam
ELSE
  HTML2 = STRING(LOF(fnr), 0)
  GET #fnr, , HTML2
  CLOSE #fnr
END IF

VAR server = NEW bnServer(3491) ' create web server instance for port 3490

WITH *server
  IF .Errr THEN
    ?"error: " & *.Errr & " failed"
  ELSE
    ?"server started"
    WHILE 0 = LEN(INKEY())
      VAR con = .OpenSock()
      IF .Errr THEN
        SELECT CASE *.Errr
        CASE "server isset"                          ' drop this message
        CASE ELSE : ?"error: " & *.Errr & " failed"         ' show other
        END SELECT : .Errr = 0                     ' reset error message
      ELSE
        IF con THEN IF newConn(server, con)              THEN EXIT WHILE
      END IF

      FOR i AS INTEGER = UBOUND(.Slots) TO 0 STEP -1
        VAR dat = ""
        .Slots(i)->GetData(dat, 1) ' check for new message (single shot)
        IF LEN(dat) THEN                                      ' got data
          IF .Errr THEN                    ' ... but anything went wrong
            ?"error: " & *.Errr & " failed"                 ' show error
            .Errr = 0                              ' reset error message
          END IF
          IF newData(.Slots(i), dat)                     THEN EXIT WHILE
        ELSE
          SELECT CASE *.Errr                    ' no data, just an error
          CASE "retry"   ' drop message (it means nothing has been sent)
          CASE "disconnected"                         ' close connection
            IF disConn(server, .Slots(i))                THEN EXIT WHILE
            .CloseSock(.Slots(i))
          CASE ELSE : ?"error: " & *.Errr & " failed"       ' show other
          END SELECT : .Errr = 0                   ' reset error message
        END IF
      NEXT
      SLEEP 10
    WEND
  END IF
END WITH

DELETE server
