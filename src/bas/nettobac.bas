/'* \file nettobac.bas

This file contains the function bodies of the classes, designed to
handle network client and server connections.

Copyright (C) LGPLv2.1, see ReadMe.md for details.

\since 0.0.0
'/


#INCLUDE ONCE "nettobac.bi"


/'* \brief Create a connection
\param Socket the socket to use
\param Ep the pointer for error messages

This constructor checks the socket and sets some options for fast
access.

\since 0.0.0
'/
CONSTRUCTOR n2bConnection(BYVAL Socket AS LONG, BYVAL Ep AS ZSTRING PTR PTR)
  Sock = Socket
  Errr = Ep
  DIM AS LONG tmp = 1
  IF setsockopt(Sock, IPPROTO_TCP, TCP_NODELAY, CAST(ANY PTR, @tmp), SIZEOF(tmp)) = SOCKET_ERROR _
    THEN *Errr = @"setsockopt"
END CONSTRUCTOR


/'* \brief Finish a connection

This destructor closes the open socket, if any.

\since 0.0.0
'/
DESTRUCTOR n2bConnection()
  IF Sock = SOCKET_ERROR THEN EXIT DESTRUCTOR
  closesocket(Sock)
END DESTRUCTOR


/'* \brief Send a `STRING` over socket
\param Dat the data to send
\param ReTry the number of re-tries when socket isn't ready
\returns the number of bytes sent (-1 in case of error)

This function sends a `STRING` variable to the peer, sending all bytes
from parameter `Dat`.

The function waits until the socket is ready to send. The maximum
waiting time can get specified by parameter `ReTry` in steps of 1 / 50
seconds.

\note `ReTry = 0` specifies a single shot.

\since 0.0.0
'/
FUNCTION n2bConnection.nPut(BYVAL Dat AS STRING, BYVAL ReTry AS USHORT = 100) AS INTEGER
  RETURN nPut(SADD(Dat), LEN(Dat), ReTry)
END FUNCTION


/'* \brief Send any data over socket
\param Dat a pointer to the data in memory
\param Az the number of bytes to send
\param ReTry the number of re-tries when socket isn't ready
\returns the number of bytes sent (-1 in case of error)

This function sends data to the peer, reading `Az` number of bytes from
the buffer `Dat`.

The function waits until the socket is ready to send. The maximum
waiting time can get specified by parameter `ReTry` in steps of 1 / 50
seconds.

\note `ReTry = 0` specifies a single shot.

\since 0.0.0
'/
FUNCTION n2bConnection.nPut(BYVAL Dat AS ANY PTR, BYVAL Az AS INTEGER, BYVAL ReTry AS USHORT = 100) AS INTEGER
  IF Sock = SOCKET_ERROR THEN    *Errr = @"put socket check" : RETURN -1
  IF  Dat = 0 ORELSE Az < 1 THEN   *Errr = @"put data check" : RETURN -1
  FD_ZERO(@FdsW)
  DIM AS INTEGER try = ReTry
  DO
    FD_SET_(Sock, @FdsW)
    IF select_(Sock + 1, 0, @FdsW, 0, @Timeout) = SOCKET_ERROR _
                                      THEN *Errr = @"select" : RETURN -1
    try -= 1 : IF try < -1             THEN *Errr = @"retry" : RETURN -1
    SLEEP 20
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
\param Res The `STRING` variable to append the downloaded bytes
\param ReTry A counter to limit the number of re-tries
\returns 0 (zero) on success, an error message otherwise

This function receives data from the peer. The incomming bytes get
appended to the result variable `Res`.

The function waits until the socket is ready to send before each chunk
of data (1024 bytes). The waiting time can get limited by parameter
`ReTry` in steps of 1 / 50 seconds.

\note The maximum waiting time depend on the value of `ReTry` and the
      number of chunks to send.

\note `ReTry = 0` specifies a single shot.

\since 0.0.0
'/
FUNCTION n2bConnection.nGet(BYREF Res AS STRING, BYVAL ReTry AS USHORT = 100) AS CONST ZSTRING CONST PTR
  IF Sock = SOCKET_ERROR THEN *Errr = @"get socket check" : RETURN *Errr
  CONST size = &h400
  DIM AS STRING*size buf
  FD_ZERO(@FdsR)
  DO
    DIM AS INTEGER try = ReTry
    DO
      FD_SET_(Sock, @FdsR)
      IF select_(Sock + 1, @FdsR, 0, 0, @Timeout) = SOCKET_ERROR _
                                   THEN *Errr = @"select" : RETURN *Errr
      try -= 1 : IF try < -1        THEN *Errr = @"retry" : RETURN *Errr
      SLEEP 20
    LOOP UNTIL FD_ISSET(Sock, @FdsR)
    VAR n = recv(Sock, CAST(UBYTE PTR, @buf), size, 0)
    SELECT CASE n
    CASE SOCKET_ERROR :           *Errr = @"receive data" : RETURN *Errr
    CASE 0 : IF 0 = LEN(Res) THEN *Errr = @"disconnected" : RETURN *Errr
      EXIT DO
    CASE ELSE : Res &= LEFT(buf, n)
    END SELECT
  LOOP : RETURN 0
END FUNCTION


/'* \brief Constructor to open the socket

The constructor opens a socket for the new instance (client or server)
and checks the result.

\since 0.0.0
'/
CONSTRUCTOR n2bFactory()
  Sock = opensocket(AF_INET, SOCK_STREAM, 0)
  IF Sock = SOCKET_ERROR THEN Errr = @"opensocket"
END CONSTRUCTOR


/'* \brief Destructor to close all opened connections and the socket.

The destructor `DELETE`s all open connections and closes the socket
opened in the constructor.

\since 0.0.0
'/
DESTRUCTOR n2bFactory()
  FOR i AS INTEGER = 0 TO UBOUND(Slots)
    DELETE Slots(i)
  NEXT
  IF Sock <> SOCKET_ERROR THEN closesocket(Sock)
END DESTRUCTOR


/'* \brief Generate a new connection and add the instance to array Slots
\param Socket The socket number for that new connection
\returns a pointer to the new connection

This function collects pointers to newly created connections in the
array Slots, in order to auto `DELETE` the instances in the destructor.
If you want to get rid of a connection before the destructor gets
called, use method nClose().

\since 0.0.0
'/
FUNCTION n2bFactory.slot(BYVAL Socket AS LONG) AS n2bConnection PTR
  'IF Socket = SOCKET_ERROR   THEN Errr = @"slot socket check" : RETURN 0
  VAR r = NEW n2bConnection(Socket, @Errr) _
    , u = UBOUND(Slots) + 1
  IF r THEN REDIM PRESERVE Slots(u) : Slots(u) = r
  RETURN r
END FUNCTION


/'* \brief Close a connection
\param Con The pointer to the connection instance
\returns 0 (zero) on success, an error message otherwise

Call this function in order to close a connection.

\note The destructor n2bFactory::~n2bFactory() will close all remaining
      connections, so it's optional to call this function.

\since 0.0.0
'/
FUNCTION n2bFactory.nClose(BYVAL Con AS n2bConnection PTR) AS CONST ZSTRING CONST PTR
  VAR u = UBOUND(Slots)
  FOR i AS INTEGER = 0 TO u
    IF Slots(i) <> Con THEN CONTINUE FOR
    DELETE Con
    Slots(i) = Slots(u)
    IF u > 0 THEN REDIM PRESERVE Slots(u - 1)          : RETURN 0
    REDIM PRESERVE Slots(-1 TO -1)                     : RETURN 0
  NEXT :                     Errr = @"find connection" : RETURN Errr
END FUNCTION


/'* \brief Generate a client instance
\param Uri the URI adress to connect to (ie. `"www.freebasic.net"`)
\param Port the port number to use (defaults to 80)

Create a client instance to the specified server adress, resolve its IP
and connect to the destination port.

\since 0.0.0
'/
CONSTRUCTOR nettobacClient(BYREF Uri AS STRING, BYVAL Port AS USHORT = 80)
  BASE()
  IF Sock = SOCKET_ERROR                           THEN EXIT CONSTRUCTOR
  VAR he = gethostbyname(SADD(Uri))
  IF he = 0          THEN Errr = @"client resolve IP" : EXIT CONSTRUCTOR

  DIM AS sockaddr_in sadr
  sadr.sin_family = AF_INET
  sadr.sin_port = htons(Port)
  sadr.sin_addr = *CPTR(in_addr PTR, he->h_addr_list[0])

  IF connect(Sock, CPTR(sockaddr PTR, @sadr), SIZEOF(sockaddr)) < 0 _
                                           THEN Errr = @"client connect"
END CONSTRUCTOR


/'* \brief Open a client connection to a server
\returns a newly created connection (or zero on failure)

This function opens a client connection to the server, which was
specified in the privious constructor call. The connection is ready to
send or receive data.

Use function n2bFactory::nClose() to close the connection.

\since 0.0.0
'/
VIRTUAL FUNCTION nettobacClient.nOpen() AS n2bConnection PTR
  IF Sock = SOCKET_ERROR   THEN Errr = @"client socket check" : RETURN 0
  RETURN slot(Sock)
END FUNCTION


/'* \brief Generate a server instance
\param Port the port number to use (defaults to 80)
\param Max The maximum number of client connections

Create a server instance for a limited number of clients and start
listening on the specified port.

\since 0.0.0
'/
CONSTRUCTOR nettobacServer(BYVAL Port AS USHORT = 80, BYVAL Max AS INTEGER = 64)
  BASE() : IF Sock = SOCKET_ERROR                  THEN EXIT CONSTRUCTOR

  DIM AS LONG yes = 1
  IF SOCKET_ERROR = setsockopt(Sock, SOL_SOCKET, SO_REUSEADDR, @yes, SIZEOF(LONG)) _
    THEN Errr = @"setsockopt"

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


/'* \brief Open a server connection to a client
\returns A pointer to a new n2bConnection instance (or zero on failure)

This function opens a connection to a client, if a request is pending.
It opens a new #n2bConnection to the client and returns its pointer.
Otherwise it returns 0 (zero), meaning there is no client connection
request pending.

Use function n2bFactory::nClose() to close the connection.

\note The `BASE` class n2bFactory will close all remaining connections
      in its destructor, so it's optional to call function
      n2bFactory::nClose().

\since 0.0.0
'/
VIRTUAL FUNCTION nettobacServer.nOpen() AS n2bConnection PTR
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
