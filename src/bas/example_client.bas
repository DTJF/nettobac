/'* \file example_client.bas
\brief Example code to test \Proj package in a server scenario

Copyright (C) GPLv3, see ReadMe.md for details.

\since 0.0.0
'/

#INCLUDE ONCE "nettobac.bas"
#INCLUDE ONCE "nettobac_http.bas"

'* \brief The folder to store the data
#DEFINE FOLD "data"
'* \brief The macro to report an error
#DEFINE ERR_MSG !"\n\n" _
                 & LEN(res) & " bytes received --> error " & *msg _
             & !"\n" & page & !" returns:" _
           & !"\n\n" & res


/'* \brief Store data in a file
\param Dat the data to store
\param Nam the path/name of the file to create (or override)

This function opens the file named `Nam` in the current folder for
output (overriding an existend file, if any) and writes the STRING
`Dat` in to it. The SUB gets called in order to store the downloaded
data on disk.

\since 0.0.0
'/
SUB saveData(BYREF Dat AS STRING, BYREF Nam AS STRING)
  VAR fnr = FREEFILE
  IF OPEN(Nam FOR OUTPUT AS fnr) THEN
    ? "open failed: " & Nam
  ELSE
    PRINT #fnr, Dat;
    CLOSE #fnr
    ? "saved: " & Nam
  END IF
END SUB


/'* \brief Operate as a client, download files
\returns the value to `END` the program

FIXME

\since 0.0.0
'/
FUNCTION doClientActions() AS INTEGER
  SCOPE
    VAR res = "" _
     , page = "users.freebasic-portal.de/tjf/Projekte/libpruio/doc/html/index.html" _
      , msg = httpLoad(res, page, , , &b1)
    IF msg THEN ?ERR_MSG : RETURN 1 _
           ELSE saveData(res, "index.htm")
  END SCOPE

  SCOPE
    VAR res = "" _
     , page = "freebasic.net/sites/default/files/horse_original_r_0.gif" _
      , msg = httpLoad(res, page, MIME_GIF)
    IF msg THEN ?ERR_MSG : RETURN 1 _
           ELSE saveData(res, "fb_logo.gif")
  END SCOPE

  SCOPE
    VAR res = "" _
     , page = "staticmap.openstreetmap.de/staticmap.php" _
            & "?center=40.714728,-73.998672" _
            & "&zoom=12" _
            & "&size=320x248" _
            & "&maptype=osmarenderer" _
      , msg = httpLoad(res, page, MIME_PNG, , &b1) ' note: raw data incl. header
    IF msg THEN
      ?ERR_MSG : RETURN 1
    ELSE
      VAR p = INSTR(res, CHR(137, 80, 78, 71)) ' get start of PNG data
      IF p THEN saveData(MID(Res, p), "osm.png") _
           ELSE ?"PNG data not found"
    END IF
  END SCOPE
  RETURN 0
END FUNCTION

'& int main(){

?MSG_ALL

IF CHDIR(FOLD) THEN MKDIR(FOLD) : IF CHDIR(FOLD) THEN ?"no write permission (press any key)" : SLEEP : END

END doClientActions()

'& doClientActions();};

