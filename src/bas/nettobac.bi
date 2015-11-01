/'* \file nettobac.bi

`snc` is a synonym for [S]imple [N]etwork [C]onnection. This file
contains classes designed to handle network client and server
connections.

Copyright (C) LGPLv2, see bn.md for details.

\since 0.0
'/

#include once "nettobac_text.bi"

#IFDEF __FB_WIN32__
 #INCLUDE "windows.bi"
 #INCLUDE "win/windef.bi"
 #INCLUDE "win/winsock2.bi"
 #IFNDEF opensocket
  #DEFINE opensocket socket
 #ENDIF
#ELSE
 #INCLUDE "crt/unistd.bi"     ' close_ ...
 #INCLUDE "crt/netinet/in.bi" ' socket.bi ...
 #INCLUDE "crt/sys/select.bi" ' FD_SET ...
 #INCLUDE "crt/netdb.bi"      ' hostent ...
 #INCLUDE "crt/arpa/inet.bi"  ' inet_ntoa ...
#ENDIF

#IFNDEF TCP_NODELAY ' "tcp.bi" does not exist, ...
 #DEFINE TCP_NODELAY &h01 ' so add the missing symbol
#ENDIF


/'* \brief FIXME

It has to be constructed with a nettobacServer or a nettobacClient class. Data can
get send or received to/from the peer with it.

'/
TYPE n2bConnection
PUBLIC:
  DECLARE CONSTRUCTOR(BYVAL AS LONG, BYVAL AS ZSTRING PTR PTR)
  DECLARE DESTRUCTOR()
  DECLARE FUNCTION PutData OVERLOAD(BYVAL AS STRING, BYVAL AS INTEGER = 100) AS INTEGER
  DECLARE FUNCTION PutData(BYVAL AS ANY PTR, BYVAL AS INTEGER, BYVAL AS INTEGER = 100) AS INTEGER
  DECLARE FUNCTION GetData(BYREF AS STRING, BYVAL AS INTEGER = 100) AS ZSTRING PTR
  AS ZSTRING PTR PTR Errr
PROTECTED:
  AS LONG _
      Sock '*< The socket number
  AS fd_set _
      FdsR _ '*< file descriptor for red
    , FdsW   '*< file descriptor for write
  AS timeval _
    Timeout  '*< how long should we wait until network is ready
END TYPE


'
/'* \brief Construct n2bConnection pointers

This class manages the connection data. It provides the method to open
connections and collects their pointer in the array Slots.

\since 0.0
'/
TYPE n2bFactory EXTENDS OBJECT
PUBLIC:
  AS ZSTRING PTR Errr '*< the common error message (`NULL` in case of no error)
  DECLARE CONSTRUCTOR()
  DECLARE VIRTUAL DESTRUCTOR()
  DECLARE ABSTRACT FUNCTION OpenSock() AS n2bConnection PTR
  DECLARE FUNCTION CloseSock(BYVAL AS n2bConnection ptr) AS zstring ptr
  REDIM AS n2bConnection PTR Slots(-1 TO -1)
PROTECTED:
  AS LONG Sock '*< socket to listen at (server only)
  DECLARE FUNCTION slot(BYVAL AS LONG) AS n2bConnection PTR
END TYPE


/'* \brief The client class

Class creating an instance to act as a client. This is

- connecting to a server
- sending data requests
- receiving returned data

\since 0.0
'/
TYPE nettobacClient EXTENDS n2bFactory
PUBLIC:
  '* \brief create a client instance to a server, default port is 80
  DECLARE CONSTRUCTOR(BYREF AS STRING, BYVAL AS USHORT = 80)
  '* \brief open a client connection to a server
  DECLARE VIRTUAL FUNCTION OpenSock() AS n2bConnection PTR
END TYPE


/'* \brief The server class

Class creating an instance to act as a server. This is

- listening to a port
- accepting client connection requests
- receiving data requests
- sending data

\since 0.0
'/
TYPE nettobacServer EXTENDS n2bFactory
PUBLIC:
  '* \brief create a server instance (defaults: port is 80, maximum 64 client connections)
  DECLARE CONSTRUCTOR(BYVAL AS USHORT = 80, BYVAL AS INTEGER = 64)
  '* \brief open the server connection to a connecting client
  DECLARE VIRTUAL FUNCTION OpenSock() AS n2bConnection PTR
PRIVATE:
  AS timeval Timeout  '*< the timeout value to abort slow or impossible transmissions
END TYPE
