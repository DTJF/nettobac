#
# nettobac - Create FB Headers from GObject Introspection *.gir files
#
# Copyright (C) 2013-2015, Thomas{ dOt ]Freiherr[ aT ]gmx[ DoT }net
#
# All rights reserved.
#
# See ReadMe.md for details.
#

CMAKE_MINIMUM_REQUIRED(VERSION 2.8.3)

# add search path if cmakefbc isn't installed
LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/Modules/")

# constants
SET(PROJ_NAME "nettobac"           CACHE STRING "project name" FORCE)
SET(PROJ_DESC "Basic network features for FreeBASIC code" CACHE STRING "project description" FORCE)
SET(PROJ_VERS "0.0.0"              CACHE STRING "project version" FORCE)
SET(PROJ_AUTH "DTJF"               CACHE STRING "project authors" FORCE)
SET(PROJ_MAIL "Thomas{ doT ]Freiherr[ At ]gmx[ DoT }net"  CACHE STRING "project mail address" FORCE)
SET(PROJ_WEBS "https://github.com/DTJF/nettobac" CACHE STRING "project website" FORCE)
SET(PROJ_LICE "LGPLv2.1"           CACHE STRING "project licence" FORCE)
SET(PROJ_YEAR "2015"               CACHE STRING "project year" FORCE)

# declare the project name and the language (compiler) to use
PROJECT(${PROJ_NAME} Fbc)

ADD_SUBDIRECTORY(src/bas)

#ADD_SUBDIRECTORY(src/doc)

CONFIGURE_FILE(src/doc/ReadMe.md.in ${CMAKE_SOURCE_DIR}/ReadMe.md @ONLY)

ADD_SUBDIRECTORY(doxy)

# declare installation rules
#INSTALL(DIRECTORY cmake/Modules DESTINATION ${CMAKE_ROOT})
