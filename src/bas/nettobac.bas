/'* \file bn.bas

bn` is a synonym for [b]asic [n]etworking. This file contains classes
for the low level API, designed to handle network client and server
connections.

Copyright (C) lGPLv2.1, see ReadMe.md for details.

\since 0.0
'/


#INCLUDE ONCE "nettobac.bi"
#IFNDEF __FB_UNIX__
'#IFDEF __FB_UNIX__
 '#INCLUDE ONCE "crt/unistd.bi"     ' close_ ...
 '#INCLUDE ONCE "crt/netinet/in.bi" ' socket.bi ...
 '#INCLUDE ONCE "crt/sys/select.bi" ' FD_SET ...
 '#INCLUDE ONCE "crt/netdb.bi"      ' hostent ...
 '#INCLUDE ONCE "crt/arpa/inet.bi"  ' inet_ntoa ...
'#ELSE
 '#INCLUDE ONCE "windows.bi"
 '#INCLUDE ONCE "win/windef.bi"
 '#INCLUDE ONCE "win/winsock2.bi"
 '#IFNDEF opensocket
  '#DEFINE opensocket socket
 '#ENDIF
/'* \brief Startup WSA on non-LINUX systems

FIXME

\since 0.0
'/
SUB NetworkInit() CONSTRUCTOR 9999
  DIM AS WSAData wd
  WSAStartup(WINSOCK_VERSION, @wd)
  IsInit = 0
END SUB

/'* \brief Cleanup WSA on non-LINUX systems

FIXME

\since 0.0
'/
SUB NetworkExit() DESTRUCTOR 9999
  WSACleanup()
END SUB
'#ENDIF ' #IFDEF __FB_UNIX__
#ENDIF ' #IFNDEF __FB_UNIX__


/'* \brief Create a connection
\param Socket The socket to use
\param Ep the pointer for error messages

This class has to be constructed with a server or a client class. You
can send and receive messages to/from your peer with it.

\since 0.0
'/
CONSTRUCTOR bnConnection(BYVAL Socket AS LONG, BYVAL Ep AS ZSTRING PTR PTR)
  Sock = Socket
  Errr = Ep
  IF Sock <> SOCKET_ERROR THEN
    DIM AS LONG tmp = 1
    IF setsockopt(Sock, IPPROTO_TCP, TCP_NODELAY, CAST(ANY PTR, @tmp), SIZEOF(tmp)) = SOCKET_ERROR _
      THEN *Errr = @"setsockopt"
  ELSE
    *Errr = @"socket check"
  END IF
END CONSTRUCTOR


/'* \brief FIXME

FIXME

\since 0.0
'/
DESTRUCTOR bnConnection()
  IF Sock = -1 THEN EXIT DESTRUCTOR
?"closesocket(" & Sock & ")"
  closesocket(Sock)
END DESTRUCTOR


/'* \brief FIXME
\param Dat FIXME
\param Az FIXME
\param ReTry FIXME
\returns FIXME

FIXME
  ' Sends a any data note: if you send a string dataSize=len(txt)+1
  ' returns number of sended data
  ' returns -1 as error signal

\since 0.0
'/
FUNCTION bnConnection.PutData(BYVAL Dat AS STRING, BYVAL ReTry AS INTEGER = 100) AS INTEGER
  RETURN PutData(SADD(Dat), LEN(Dat), ReTry)
END FUNCTION


/'* \brief FIXME
\param Dat FIXME
\param Az FIXME
\param ReTry FIXME
\returns FIXME

FIXME
  ' Sends a any data note: if you send a string dataSize=len(txt)+1
  ' returns number of sended data
  ' returns -1 as error signal

\since 0.0
'/
FUNCTION bnConnection.PutData(BYVAL Dat AS ANY PTR, BYVAL Az AS INTEGER, BYVAL ReTry AS INTEGER = 100) AS INTEGER
  IF Sock = SOCKET_ERROR THEN        *Errr = @"socket check" : RETURN -1
  IF  Dat = 0 ORELSE Az < 1 THEN   *Errr = @"put data check" : RETURN -1
  FD_ZERO(@FdsW)
  DO
    FD_SET_(Sock, @FdsW)
    IF select_(Sock + 1, 0, @FdsW, 0, @Timeout) = SOCKET_ERROR _
                                      THEN *Errr = @"select" : RETURN -1
    SLEEP 20
    Retry -= 1 : IF Retry < 0          THEN *Errr = @"retry" : RETURN -1
  LOOP UNTIL FD_ISSET(Sock, @FdsW)
  VAR x = Az
  DO
    VAR n = send(Sock, Dat, x, 0)
    IF n = SOCKET_ERROR THEN            *Errr = @"send data" : RETURN -1
    Dat += n
    x   -= n
  LOOP UNTIL x <= 0 : RETURN Az - x
END FUNCTION


/'* \brief Receive data form socket.
\param R The `STRING` variable to append the downloaded bytes
\param ReTry A counter to limit the number of reties
\returns 0 (zero) on success, an error message otherwise

FIXME
  ' Receives any data (pData will be reallocated)
  ' returns received number of bytes
  ' returns  0 if other connection are closed
  ' returns SOCKET_ERROR (= -1) as error signal

\since 0.0
'/
FUNCTION bnConnection.GetData(BYREF R AS STRING, BYVAL ReTry AS INTEGER = 100) AS ZSTRING PTR
  IF Sock < 0 THEN                *Errr = @"socket check" : RETURN *Errr
  CONST size = &h400
  DIM AS STRING*size buf
  FD_ZERO(@FdsR)
  DO
    VAR try = Retry
    DO
      FD_SET_(Sock, @FdsR)
      IF select_(Sock + 1, @FdsR, 0, 0, @Timeout) = SOCKET_ERROR _
                                   THEN *Errr = @"select" : RETURN *Errr
      SLEEP 20
      try -= 1 : IF try < 0         THEN *Errr = @"retry" : RETURN *Errr
    LOOP UNTIL FD_ISSET(Sock, @FdsR)
    VAR n = recv(Sock, CAST(UBYTE PTR, @buf), size, 0)
    SELECT CASE n
    CASE SOCKET_ERROR :               *Errr = @"get data" : RETURN *Errr
    CASE 0 : IF 0 = LEN(r)   THEN *Errr = @"disconnected" : RETURN *Errr
      EXIT DO
    CASE ELSE : R &= LEFT(buf, n)
    END SELECT
  LOOP : RETURN 0
END FUNCTION


/'* \brief Constructor to open the socket

This constructor opens a socket for the new instance (client or server)
and checks the result.

\since 0.0
'/
CONSTRUCTOR bnConnectionFactory()
  Sock = opensocket(AF_INET, SOCK_STREAM, 0)
  IF Sock = SOCKET_ERROR THEN Errr = @"socket check"
END CONSTRUCTOR


/'* \brief Destructor to close all opened connections and the socket.

This destructor `DELETE`s all open connections and closes the socket
opened in the constructor.

\since 0.0
'/
DESTRUCTOR bnConnectionFactory()
  FOR i AS INTEGER = 0 TO UBOUND(Slots)
    DELETE Slots(i)
?"DELETE Connection: " & i, Slots(i)
  NEXT
  IF Sock <> SOCKET_ERROR THEN closesocket(Sock)
END DESTRUCTOR


/'* \brief Generate a new connection and add the instance to array Slots
\param Socket The socket number for that new connection
\returns a pointer to the new connection

This function collects pointers to newly created connections in the
array Slots, in order to auto `DELETE` the instances in the destructor.
If you want to get rid of a connection before the destructor gets
called, use method CloseSock().

\since 0.0
'/
FUNCTION bnConnectionFactory.slot(BYVAL Socket AS LONG) AS bnConnection PTR
  IF Socket = SOCKET_ERROR        THEN Errr = @"socket check" : RETURN 0
  VAR u = UBOUND(Slots) + 1
  REDIM PRESERVE Slots(u)
?"new slot " & u
  Slots(u) = NEW bnConnection(Socket, @Errr)           : RETURN Slots(u)
END FUNCTION


/'* \brief Close a connection
\param Con The pointer to the connection instance
\returns 0 (zero) on success, an error message otherwise

The class auto `DELETE`s all open connections in the destructor. Call
this function in order to close a connection before the destructor gets
called.

\since 0.0
'/
FUNCTION bnConnectionFactory.CloseSock(BYVAL Con AS bnConnection PTR) AS ZSTRING PTR
  VAR u = UBOUND(Slots)
  FOR i AS INTEGER = 0 TO u
    IF Slots(i) <> Con THEN CONTINUE FOR
    DELETE Con
    Slots(i) = Slots(u)
    if u > 0 then REDIM PRESERVE Slots(u - 1)          : RETURN 0
    REDIM PRESERVE Slots(-1 to -1)                     : RETURN 0
  NEXT :                  Errr = @"closing connection" : RETURN Errr
END FUNCTION


/'* \brief Generate a client instance
\param Address the adress to connect to (ie. `"freebasic.net"`)
\param Port the port number to use (defaults to 80)

Create a client instance to the specified server adress, resolve its IP
and connect to the destination port.

\since 0.0
'/
CONSTRUCTOR bnClient(BYREF Address AS STRING, BYVAL Port AS USHORT = 80)
  BASE()
  IF Sock = SOCKET_ERROR THEN Errr = @"client socket" : EXIT CONSTRUCTOR
  VAR he = gethostbyname(SADD(Address))
  IF he = 0          THEN Errr = @"client resolve IP" : EXIT CONSTRUCTOR

  DIM AS sockaddr_in sadr
  sadr.sin_family = AF_INET
  sadr.sin_port = htons(Port)
  sadr.sin_addr = *CPTR(in_addr PTR, he->h_addr_list[0])

  IF connect(Sock, CPTR(sockaddr PTR, @sadr), SIZEOF(sockaddr)) < 0 _
                                           THEN Errr = @"client connect"
END CONSTRUCTOR


/'* \brief Generate connection to a server
\returns a newly created connection (or zero on failure)

This function returns a client connection to the server specified in
the constructor call. The connection is ready to send
or receive data.

\note Manualy close the connection by calling method CloseSock(). This
      is usualy not necessary, since the class bnConnectionFactory will
      close all remaining connections in its destructor.

\since 0.0
'/
VIRTUAL FUNCTION bnClient.OpenSock() AS bnConnection PTR
  RETURN slot(Sock)
END FUNCTION



/'* \brief Generate a server instance
\param Port the port number to use (defaults to 80)
\param Max The maximum number of client connections

Create a server instance for a limited number of clients and start
listening on the specified port.

\since 0.0
'/
CONSTRUCTOR bnServer(BYVAL Port AS USHORT = 80, BYVAL Max AS INTEGER = 64)
  BASE()
  IF Sock = SOCKET_ERROR THEN Errr = @"server socket" : EXIT CONSTRUCTOR
  DIM AS sockaddr_in sadr
  sadr.sin_family = AF_INET
  sadr.sin_port = htons(port)
  sadr.sin_addr.s_addr = INADDR_ANY
  IF bind(Sock, CPTR(sockaddr PTR, @sadr), SIZEOF(sockaddr)) = SOCKET_ERROR THEN
    Errr = @"server bind"
  ELSEIF listen(Sock, Max) = SOCKET_ERROR THEN
    Errr = @"server listen"
  END IF
END CONSTRUCTOR


/'* \brief Open a connection to a client
\returns A pointer to a new bnConnection instance (or zero on failure)

When this function does not return 0 (zero), then a client request a
connection. This connection gets opened and is ready to send or receive
data. Close the connection by calling method CloseSock().

\note The class bnConnectionFactory will close all remaining
      connections in its destructor.

\since 0.0
'/
VIRTUAL FUNCTION bnServer.OpenSock() AS bnConnection PTR
  DIM AS fd_set readfd
  FD_ZERO(@readfd)
  FD_SET_(Sock, @readfd)
  IF select_(Sock + 1, @readfd, 0, 0, @Timeout) = SOCKET_ERROR _
                                 THEN Errr = @"server select" : RETURN 0
  IF 0 = FD_ISSET(Sock, @readfd)  THEN Errr = @"server isset" : RETURN 0
  VAR clientsock = accept(Sock, 0, 0)
  IF clientsock = SOCKET_ERROR THEN   Errr = @"server accept" : RETURN 0
  RETURN slot(clientsock)
END FUNCTION
