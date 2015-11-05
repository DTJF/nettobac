# Build / install the executable.
#

CMAKE_MINIMUM_REQUIRED(VERSION 2.8.3)

CONFIGURE_FILE(nettobac_system.bi.in ${CMAKE_CURRENT_SOURCE_DIR}/nettobac_system.bi @ONLY)
CONFIGURE_FILE(data/demo1.html ${CMAKE_CURRENT_BINARY_DIR}/data/demo1.html COPYONLY)
CONFIGURE_FILE(data/demo2.html ${CMAKE_CURRENT_BINARY_DIR}/data/demo2.html COPYONLY)

SET(fb_tar
  "example_client"
  "example_server"
  )

FOREACH(tar ${fb_tar})
  ADD_EXECUTABLE(${tar} ${tar}.bas)
  SET_TARGET_PROPERTIES(${tar} PROPERTIES COMPILE_FLAGS "-m ${tar}")
  ADD_Fbc_SRC_DEPS(${tar})
ENDFOREACH(tar)
