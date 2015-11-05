# Build / install the documentation.
#
# Note: this script needs an fb-doc version (0.4).

CMAKE_MINIMUM_REQUIRED(VERSION 2.8.3)

IF(NOT COMMAND FB_DOCUMENTATION)
  INCLUDE(UseFb-Doc)
ENDIF()

FB_DOCUMENTATION(
BAS_SRC
  ../src/bas/nettobac.bas
  ../src/bas/nettobac.bi
  ../src/bas/nettobac_system.bi
  ../src/bas/nettobac_http.bas
  ../src/bas/example_client.bas
  ../src/bas/example_server.bas
DEPENDS
  ../src/doc/ReadMe.md.in
  ../src/doc/_1_Introduction.md
  ../src/doc/_2_Preparation.md
  ../src/doc/_3_Examples.md
  ../src/doc/_4_Errormsg.md
  ../src/doc/_z_ChangeLog.md
  ../CMakeLists.txt
  Doxyfile
  nettobac.css
  nettobac.xml
  )
