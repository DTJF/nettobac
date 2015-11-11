/'* \file nettobac_system.bi
\brief Header with informations on the executable

This file contains some macros to create informational texts about the
\Proj version, its compile date and target operating system. And also
constructor and destructor `SUB`s for non-UNIX systems.

Copyright (C) LGPLv2.1, see ReadMe.md for details.

\since 0.0.0
'/

#IF __FB_VERSION__ < "1.0"
 #ERROR  Fatal error: please compile WITH FreeBASIC version 1.0 OR above
#ENDIF

#IFDEF __FB_UNIX__
 #INCLUDE "crt/unistd.bi"
 #INCLUDE "crt/netinet/in.bi"
 #INCLUDE "crt/sys/select.bi"
 #INCLUDE "crt/netdb.bi"
 #INCLUDE "crt/arpa/inet.bi"
 '* The new line charater[s]
 #DEFINE NL !"\n" &
 '* The target operation system
 #DEFINE TARGET_OS "UNIX"
#ELSEIF DEFINED (__FB_DOS__)
 #ERROR Operating system not supported
#ELSE
'&/* Doxygen shouldn't see this
 #INCLUDE "windows.bi"
 #INCLUDE "win/windef.bi"
 #INCLUDE "win/winsock2.bi"
 #IFNDEF opensocket
  #DEFINE opensocket socket
 #ENDIF
 #DEFINE NL !"\r\n" &
 #DEFINE TARGET_OS "windows"
'&*/
/'* \brief Startup WSA on non-LINUX systems

On non-UNIX systems we have to call WSAStartup to initialize the
network features. This gets done here. The `SUB` runs as a constructor,
adapt the priority (`9999`) when your code uses further constructors
and you need a custom order.

\since 0.0.0
'/
SUB NetworkInit() CONSTRUCTOR 9999
  DIM AS WSAData wd
  WSAStartup(WINSOCK_VERSION, @wd)
END SUB

/'* \brief Cleanup WSA on non-LINUX systems

On non-UNIX systems we have to call WSACleanup to finish the network
features. This gets done here. The `SUB` runs as a destructor, adapt
the priority (`9999`) when your code uses further destructors and you
need a custom order.

\since 0.0.0
'/
SUB NetworkExit() DESTRUCTOR 9999
  WSACleanup()
END SUB
#ENDIF

#IFNDEF TCP_NODELAY
 #DEFINE TCP_NODELAY &h01 '*< add missing symbol
#ENDIF

'* The version message
#DEFINE MSG_VERS "@PROJ_VERS@"

'* The welcome message
#DEFINE MSG_WELCOME _
  "  @PROJ_NAME@-" & MSG_VERS & ", License @PROJ_LICE@" & NL  _
  "  Copyright (C) 2015-@PROJ_YEAR@ by @PROJ_MAIL@"

'* Compiler information
#DEFINE MSG_COMPILE _
  "  Compiled: " & __DATE__ & ", " & __TIME__ & " with " & __FB_SIGNATURE__ & " for " & TARGET_OS

'* The info text about the current version
#DEFINE MSG_ALL _
  MSG_WELCOME & NL MSG_COMPILE
