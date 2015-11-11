/'* \file nettobac.bi
\brief Delarations for the \Proj classes

This file contains the declarations for the classes, designed to handle
network client and server connections.

Copyright (C) LGPLv2.1, see ReadMe.md for details.

\since 0.0.0
'/

#INCLUDE ONCE "nettobac_system.bi"


/'* \brief The connections class, providing `nPut` / `nGet`

Do not create this class directly. It has to be constructed with a
nettobacServer::nOpen() or a nettobacClient::nOpen() call. Data can get
send or received to/from the peer with it.

See section \ref SecErr_Connection for a list of possible error messages.

\since 0.0.0
'/
TYPE n2bConnection
PUBLIC:
  DECLARE CONSTRUCTOR(BYVAL AS LONG, BYVAL AS ZSTRING PTR PTR)
  DECLARE DESTRUCTOR()
  DECLARE FUNCTION nPut OVERLOAD(BYVAL AS STRING, BYVAL AS USHORT = 100) AS INTEGER
  DECLARE FUNCTION nPut(BYVAL AS ANY PTR, BYVAL AS INTEGER, BYVAL AS USHORT = 100) AS INTEGER
  DECLARE FUNCTION nGet(BYREF AS STRING, BYVAL AS USHORT = 100) AS CONST ZSTRING CONST PTR
  AS ZSTRING PTR PTR Errr
PROTECTED:
  AS LONG _
      Sock   '*< The socket number
  AS fd_set _
      FdsR _ '*< file descriptor for read
    , FdsW   '*< file descriptor for write
  AS timeval _
    Timeout  '*< how long should we wait until network is ready
END TYPE
'& typedef n2bConnection* n2bConnection_PTR;


'
/'* \brief Utility class to handle n2bConnection pointers, providing `nClose`

The base class of the \Proj instances. It manages the connection
instances and provides the methods to open connections, to collects
their pointers in the array n2bFactory::Slots and to close a connection
manualy. The destructor closes all remaining connections.

See section \ref SecErr_Factory for a list of possible error messages.

\since 0.0.0
'/
TYPE n2bFactory EXTENDS OBJECT
PUBLIC:
  AS ZSTRING PTR Errr '*< the common error message (`NULL` in case of no error)
  /'* \brief the array to store open connections

    In case of a server instance use this array to scan over all open
    connections. See function #doServer() for an example.

  '/
  AS n2bConnection PTR Slots(ANY)
  DECLARE CONSTRUCTOR()
  DECLARE VIRTUAL DESTRUCTOR()
  DECLARE ABSTRACT FUNCTION nOpen() AS n2bConnection PTR
  DECLARE FUNCTION nClose(BYVAL AS n2bConnection PTR) AS CONST ZSTRING CONST PTR
PROTECTED:
  AS LONG Sock '*< the socket to use
  DECLARE FUNCTION slot(BYVAL AS LONG) AS n2bConnection PTR
END TYPE


/'* \brief The client class, providing `nOpen`

This class is an instance to act as a client. This is

- connecting to a server
- sending data requests
- receiving returned data

See section \ref SecErr_Client for a list of possible error messages.

\since 0.0.0
'/
TYPE nettobacClient EXTENDS n2bFactory
PUBLIC:
  DECLARE CONSTRUCTOR(BYREF AS STRING, BYVAL AS USHORT = 80)
  DECLARE VIRTUAL FUNCTION nOpen() AS n2bConnection PTR
END TYPE


/'* \brief The server class, providing `nOpen`

This class is an instance to act as a server. This is

- listening to a port
- accepting client connection requests
- receiving data requests
- sending data

See section \ref SecErr_Server for a list of possible error messages.

\since 0.0.0
'/
TYPE nettobacServer EXTENDS n2bFactory
PUBLIC:
  DECLARE CONSTRUCTOR(BYVAL AS USHORT = 80, BYVAL AS INTEGER = 64)
  DECLARE VIRTUAL FUNCTION nOpen() AS n2bConnection PTR
PRIVATE:
  AS timeval Timeout  '*< the timeout value to abort slow or impossible transmissions
END TYPE
