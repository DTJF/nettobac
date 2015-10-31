# Build / install the executable.
#

CMAKE_MINIMUM_REQUIRED(VERSION 2.8.3)

CONFIGURE_FILE(nettobac_text.bi.in ${CMAKE_CURRENT_SOURCE_DIR}/nettobac_text.bi @ONLY)

SET(fb_tar
  "example_client"
  "example_server"
  )

FOREACH(tar ${fb_tar})
  ADD_EXECUTABLE(${tar} ${tar}.bas)
  SET_TARGET_PROPERTIES(${tar} PROPERTIES COMPILE_FLAGS "-m ${tar}")
  ADD_Fbc_SRC_DEPS(${tar})
ENDFOREACH(tar)
