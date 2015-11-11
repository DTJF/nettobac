/'* \file example_server.bas
\brief Example code to test the \Proj package in a client scenario

Copyright (C) GPLv3, see ReadMe.md for details.

\since 0.0.0
'/

#INCLUDE ONCE "nettobac.bas"
#INCLUDE ONCE "nettobac_http.bas"

DIM SHARED AS STRING _
    HTML1 _ '*< the startpage, loaded from local data folder
  , HTML2 _ '*< the second page, loaded from local data folder
  , ICON _  '*< an icon, loded over web
  , HTTP _  '*< the HTTP header
  , EMSG    '*< the HTTP error message


/'* \brief Callback function to handle a new connection
\param Ser the calling server instance
\param Con the connection in use
\returns 0 (zero) to continue the server main loop, any other value to exit

This is a callback function that gets called by function doServer() in
case of a new client connection request. It just outputs a message
at the console window.

\since 0.0.0
'/
FUNCTION newConn(BYVAL Ser AS nettobacServer PTR, BYVAL Con AS n2bConnection PTR) AS INTEGER
  ?!"Client connected!\n"
  RETURN 0
END FUNCTION


/'* \brief Callback function to handle a disconnect
\param Ser the calling server instance
\param Con the connection in use
\returns 0 (zero) to continue the server main loop, any other value to exit

This is a callback function that gets called by function doServer() in
case of a client peer closed the connection. It just outputs a message
at the console window.

\since 0.0.0
'/
FUNCTION disConn(BYVAL Ser AS nettobacServer PTR, BYVAL Con AS n2bConnection PTR) AS INTEGER
  ?!"Client disconnected!\n"
  RETURN 0
END FUNCTION


/'* \brief Callback function to handle a client request
\param Con the connection in use
\param Dat the message from the client
\returns 0 (zero) to continue the server main loop, any other value to exit

This is a callback function that gets called by function doServer() in
case of a data request from a connected client peer. It analyses the
request (message in `Dat`) and sends an appropriate response (via hppt
protocol). Some responses are pre-defined (read from files), others get
generated depending on the client message.

\since 0.0.0
'/
FUNCTION newData(BYVAL Con AS n2bConnection PTR, BYREF Dat AS STRING) AS INTEGER
'&typedef n2bConnection* n2bConnection_PTR;
  ?!"Client message:\n" & dat
  SELECT CASE LEFT(Dat, 4)
  CASE "GET "
    IF MID(Dat, 5,  2) = "/ " ORELSE _
       MID(Dat, 5, 11) = "/demo1.html" THEN
      ?"sending HTML1 ...";
      Con->nPut(HTTP & LEN(HTML1) & HEADEREND & HTML1)
      ?!" done\n"
    ELSEIF MID(Dat, 5, 11) = "/demo2.html" THEN
      ?"sending HTML2 ...";
      Con->nPut(HTTP & LEN(HTML2) & HEADEREND & HTML2)
      ?!" done\n"
    ELSEIF MID(Dat, 5, 12) = "/favicon.ico" THEN
      ?"sending ICON ...";
      Con->nPut(HTTP & LEN(ICON) & HEADEREND & ICON)
      ?!" done\n"
    ELSEIF MID(Dat, 5, 9) = "/FORM?id=" THEN
      VAR p = INSTR(   Dat, "&password=") _
        , q = INSTR(p, Dat, "&button=") _
        , t = "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Transitional//EN"" " _
            & """http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"">" _
            & "<html><body>" _
            & "<b>Login data</b>" _
            & "<p>ID = " & urlDecode(MID(Dat, 14, p - 14)) _
            & "<p>Password = " & urlDecode(MID(Dat, p + 10, q - p - 10)) _
            & "<p><a href=""demo1.html"">Go back to start page</a>" _
            & "</body></html>"
      ?"sending FORM response ...";
      Con->nPut(HTTP & LEN(t) & HEADEREND & t)
      ?!" done\n"
    ELSEIF MID(Dat, 5, 5) = "/EXIT" THEN
      ?"EXIT --> server shuting down"
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
      Con->nPut(HTTP & LEN(e) & HEADEREND & e)
      ?!" done\n"
    END IF
  END SELECT : RETURN 0
END FUNCTION


/'* \brief Operate as a server
\returns the value to `END` the program

This function creates a nettobacServer instance and check in a loop for
new connection requests and for requests from already connected client
peers. In case of events is call callback functions

\Item{newConn} when a new client requests a connection

\Item{newData} when a connected client requests data

\Item{disConn} when a connection gets closed

The loop continues when the function returns 0 (zero). Ohterwise all
connections get closed and the nettobacServer instance gets `DELETE`d.
Also any keystroke breaks the main loop.

\since 0.0.0
'/
FUNCTION doServer(BYVAL Port AS USHORT = 3490) AS INTEGER
  VAR server = NEW nettobacServer(Port) ' create server instance for Port
  WITH *server
    IF .Errr             THEN ?"error: " & *.Errr & " failed" : RETURN 1
    ?"server started (port = " & Port & ")"
    WHILE 0 = LEN(INKEY())
      VAR con = .nOpen() '&nettobacServer.nOpen();
      IF .Errr THEN
        SELECT CASE *.Errr
        CASE "server isset"                          ' drop this message (it means no connection request pending)
        CASE ELSE : ?"error: " & *.Errr & " failed"         ' show other
        END SELECT : .Errr = 0                     ' reset error message
      ELSE
        IF con THEN IF newConn(server, con)              THEN EXIT WHILE
      END IF

      FOR i AS INTEGER = UBOUND(.Slots) TO 0 STEP -1
        VAR dat = "", con = .Slots(i) '&n2bConnection* con;
        con->nGet(dat, 0)                  ' check for new message (single shot)
        IF .Errr THEN                                        ' got error
          SELECT CASE *.Errr                    ' no data, just an error
          CASE "retry"                               ' drop this message (it means no data pending)
          CASE "disconnected"                       ' peer disconnection
            IF disConn(server, con)                      THEN EXIT WHILE
            .nClose(con)                              ' close connection
          CASE ELSE : ?"error: " & *.Errr & " failed"       ' show other
          END SELECT : .Errr = 0                   ' reset error message
        END IF
        IF LEN(dat) ANDALSO newData(con, dat)            THEN EXIT WHILE
      NEXT : SLEEP 10
    WEND
  END WITH
  DELETE server : RETURN 0
END FUNCTION


'& int main(){

?MSG_ALL

VAR e = httpLoad(ICON, "freebasic.net/sites/default/files/horse_original_r_0_0.gif", MIME_GIF)
IF e THEN ?"ICON error: " & *e & !" failed:\n" & ICON

HTTP = !"HTTP/1.1 200 OK" _
 & !"\r\nServer: NetToBac-Server" _
 & !"\r\nAccept-Ranges: bytes" _
 & !"\r\nVary: Accept-Encoding" _
 & !"\r\nX-Content-Type-Options: nosniff" _
 & !"\r\nContent-Type: text/html" _
 & !"\r\nConnection: close" _
 & !"\r\nContent-Length: "

 '& !"\r\nConnection: keep-alive" _
 '& !"\r\nETag: ""2ffde1-25e6-51aea94fd5f28""" _
 '& !"\r\nCache-Control: public, max-age=86400" _
 '& !"\r\nDate: Fri, 30 Oct 2015 09:16:52 GMT" _
 '& !"\r\nLast-Modified: Wed, 15 Jul 2015 14:15:07 GMT" _

CHDIR(EXEPATH())
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

END doServer(3490)

'& doServer();};
