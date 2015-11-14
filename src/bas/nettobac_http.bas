/'* \file nettobac_http.bas
\brief Utility functions to handle http requests

This file contains

- constants for end of line, header
- enumerators for mime types and a function to create a type string
- functions to create http requests (low level API)
- a function to download a file (high level API)

Copyright (C) LGPLv2.1, see ReadMe.md for details.

\since 0.0.0
'/

CONST AS STRING _
    LINEEND   = !"\r\n" _   '*< The line end characters
  , HEADEREND = !"\r\n\r\n" '*< The end of header characters

ENUM MimeTypes
  MIME_HTM = &b0000000000000 '*< Mime type "text/html"
  MIME_TXT = &b0000000000010 '*< Mime type "text/plain"
  MIME_BMP = &b0000000000100 '*< Mime type "image/bmp"
  MIME_GIF = &b0000000001000 '*< Mime type "image/gif"
  MIME_JPG = &b0000000010000 '*< Mime type "image/jpeg"
  MIME_PNG = &b0000000100000 '*< Mime type "image/png"
  MIME_TIF = &b0000001000000 '*< Mime type "image/tiff"
  MIME_WAV = &b0000010000000 '*< Mime type "audio/wav"
  MIME_MP3 = &b0000100000000 '*< Mime type "audio/mpeg"
  MIME_OGG = &b0001000000000 '*< Mime type "audio/ogg"
  MIME_PDF = &b0010000000000 '*< Mime type "application/pdf"
  MIME_ZIP = &b0100000000000 '*< Mime type "application/x-compressed"
  MIME_GZ  = &b1000000000000 '*< Mime type "application/gzip"
END ENUM


/'* \brief Create a text version of the mime type bit mask
\param Typ the bitmask containing the type bits (see enumerator #MimeTypes)
\returns the text list of mime types (`;` separated)

Mime types get handled as a bit mask at module level, for better
readability. This function translate the bit mask in to a STRING
representation.

\since 0.0.0
'/
FUNCTION MimeType(BYVAL Typ AS MimeTypes) AS STRING
  VAR r = ""
  IF Typ AND MIME_HTM THEN r &= ";text/html"
  IF Typ AND MIME_TXT THEN r &= ";text/plain"
  IF Typ AND MIME_BMP THEN r &= ";image/bmp"
  IF Typ AND MIME_GIF THEN r &= ";image/gif"
  IF Typ AND MIME_JPG THEN r &= ";image/jpeg"
  IF Typ AND MIME_PNG THEN r &= ";image/png"
  IF Typ AND MIME_TIF THEN r &= ";image/tiff"
  IF Typ AND MIME_WAV THEN r &= ";audio/wav"
  IF Typ AND MIME_MP3 THEN r &= ";audio/mpeg"
  IF Typ AND MIME_OGG THEN r &= ";audio/ogg"
  IF Typ AND MIME_PDF THEN r &= ";application/pdf"
  IF Typ AND MIME_ZIP THEN r &= ";application/x-compressed"
  IF Typ AND MIME_GZ  THEN r &= ";application/gzip"
  RETURN MID(r, 2)
END FUNCTION


/'* \brief Encode an URL text
\param Url the URL text
\returns the encoded version of the input

Encode special characters in an URL. Normal characters are

- A to Z
- a to z
- 0 to 9
- `_` (underscore), `/` (slash)

All other characters get replaced by their `%<hexval>` representation.

\since 0.0.0
'/
FUNCTION urlEncode(BYREF Url AS STRING) AS STRING
  VAR r = ""
  FOR i AS INTEGER = 0 TO LEN(Url) - 1
    SELECT CASE AS CONST Url[i]
    CASE ASC("_"), ASC("/") _
       , ASC("0") TO ASC("9") _
       , ASC("A") TO ASC("Z") _
       , ASC("a") TO ASC("z") : r += CHR(Url[i])
    CASE ELSE                 : r += "%" & LCASE(HEX(Url[i], 2))
    END SELECT
  NEXT : RETURN TRIM(r)
END FUNCTION


/'* \brief Decode an URL text
\param Url the encoded URL text
\returns the decodeded version of the input

Decode special characters in an URL. The `%<hexval>` representations
get resolved in to the related characters.

\since 0.0.0
'/
FUNCTION urlDecode(BYREF Url AS STRING) AS STRING
  Url = TRIM(Url)
  VAR l = LEN(Url), i = 0, r = ""
  FOR i AS INTEGER = 0 TO l - 1
    SELECT CASE AS CONST Url[i]
    CASE ASC("%") : i += 2 : r &= CHR(VAL("&H" & MID(Url, i, 2)))
    CASE ELSE              : r &= CHR(Url[i])
    END SELECT
  NEXT : RETURN r
END FUNCTION


/'* \brief Create a HTTP GET request
\param Host the host adress (ie. `"domain.com"`)
\param Targ the path to search for (ie. `"img/test.jpg"`)
\param Mime the mime type (ie. `MIME_JPG`, see #MimeTypes)
\returns the complete http request STRING

Requests a representation of the specified resource.

\since 0.0.0
'/
FUNCTION httpGetReq(BYREF Host AS STRING, BYREF Targ AS STRING, BYVAL Mime AS MimeTypes = MIME_HTM OR MIME_TXT) AS STRING
  VAR r = "GET "   & Targ & " HTTP/1.1" & LINEEND _
        & "Host: " & Host & LINEEND
  IF LEN(Mime) THEN r &= "Mime: " & MimeType(Mime) & LINEEND
  RETURN r & "Connection: close" & HEADEREND
END FUNCTION


/'* \brief Create a HTTP HEAD request
\param Host the host adress (ie. `"domain.com"`)
\param Targ the path to search for (ie. `"html/index.html"`)
\param Mime the mime type (ie. `MIME_HTM`, see #MimeTypes)
\returns the request STRING

Asks for the response identical to the one that would correspond to a
GET request, but without the response body. It's possible to extract
the content length and Mime type from it.

\since 0.0.0
'/
FUNCTION httpHeadReq(BYREF Host AS STRING, BYREF Targ AS STRING, BYVAL Mime AS MimeTypes = MIME_HTM OR MIME_TXT) AS STRING
  VAR r = "HEAD "  & Targ & " HTTP/1.1" & LINEEND _
        & "Host: " & Host & LINEEND
  IF LEN(Mime) THEN r &= "Mime: " & MimeType(Mime) & LINEEND
  RETURN r & "Connection: close" & HEADEREND
END FUNCTION


/'* \brief Create a HTTP POST request
\param Host the host adress (ie. `"domain.com"`)
\param Targ the path to search for (ie. `"data/script.php"`)
\param Query  (ie. `"key1=value&key2=value"`)
\param Refer if a `Referer:` should get added
\returns the request STRING

Requests that the server accept the entity enclosed in the request as a
new subordinate of the web resource identified by the URI.

\since 0.0.0
'/
FUNCTION httpPostReq(BYREF Host AS STRING, BYREF Targ AS STRING, BYREF Query AS STRING, BYVAL Refer AS INTEGER = 1) AS STRING
  VAR r = "POST "  & Targ & " HTTP/1.1" & LINEEND _
        & "Host: " & Host & LINEEND
  IF Refer THEN r &= "Referer: http://" & Host & Targ & "?" & LINEEND
  RETURN r _
        & "Content-type: application/x-www-form-urlencoded" & LINEEND _
        & "Content-length: " & LEN(Query) & LINEEND _
        & "Connection: close" & HEADEREND _
       & Query
END FUNCTION


/'* \brief Create a HTTP HEAD request
\param Host the host adress (ie. `"domain.com"`)
\param Targ the path to search for (ie. `"data/test.txt"`)
\param Content any content (defaults to `""`)
\returns the request STRING

Requests that the enclosed entity be stored under the supplied URI.

\since 0.0.0
'/
FUNCTION httpPutReq(BYREF Host AS STRING, BYREF Targ AS STRING, BYREF Content AS STRING = "") AS STRING
  VAR r = "PUT "   & Targ & " HTTP/1.1" & LINEEND _
        & "Host: " & Host & LINEEND
  RETURN r & Content
END FUNCTION


/'* \brief Load a file over network via http protocol
\param Res a STRING variable to append the result
\param Adr the address of the target (ie. `freebasic.net/index.html`)
\param Mim the mime type (see enumerators #MimeTypes)
\param Port The port number to use (defaults to 80)
\param Mo the modus which data the result variable `Res` should contain
\returns the requested file context, if OK

This function loads a file over a network connection. It tries to

- create a nettobacClient instance to the server adress
- open a n2bConnetion
- request the target file
- receive the http reponse
- check the http header
  - if header OK, strip header and return data only
  - if not OK, return all data unchanged
- delete the nettobacClient instance (and close the n2bConnetion)

An error check gets done after each step. In case of an error the
function breaks and the error text gets returned. Otherwise the return
value 0 (zero) indicates successful operation.

\note Although the result variable `Res` may contains data, the function
      can report an error (ie. when the connection gets lost during
      transfer). It's recommended to check `.Errr` always.

\note By default the http header gets checked and if it includes
      `200 OK` it gets extracted from the result variable `Res` (only
      data get returned). In order to receive the header (unchecked) as
      well, set bit 0 in the modus parameter (`Mo OR= &b1`).

\note The received data get appended to result variable `Res`. In order
      to reset the result STRING (`Res = ""`) before operaion, set bit
      1 in the modus parameter (`Mo OR= &b10`).

\since 0.0.0
'/
FUNCTION httpLoad(BYREF Res AS STRING, BYREF Adr AS STRING, BYVAL Mim AS MimeTypes = MIME_HTM OR MIME_TXT _
                , BYVAL Port AS USHORT = 80, BYVAL Mo AS SHORT = &b10) AS CONST ZSTRING CONST PTR
'&nettobacClient* client; n2bConnection* conn;
  VAR     p = INSTR(Adr, "/") _
   , server = LEFT(Adr, p - 1) _
   , client = NEW nettobacClient(server, Port) _ ' connect to web server at port (default 80)
        , r = client->Errr
  IF 0 = r THEN
    VAR conn = client->nOpen()                        ' get a connection
    WITH *client : DO
      IF .Errr                                         THEN r = .Errr : EXIT DO ' no connection

      VAR req = HttpGetReq(server, MID(Adr, p), Mim)     ' build request
      conn->nPut(SADD(req), LEN(req)) : IF .Errr       THEN r = .Errr : EXIT DO ' put failed

      IF BIT(Mo, 1) THEN Res = ""             ' user wants to reset data
      conn->nGet(Res) : IF .Errr                       THEN r = .Errr : EXIT DO ' get failed

      IF BIT(Mo, 0)        /' user wants all data, incl. header '/ THEN EXIT DO
      p = INSTR(Res, HEADEREND)     ' search position of HTTP header end
      IF INSTRREV(Res, "200 OK", p) < 1 THEN r = @"http header check" : EXIT DO
      Res = MID(Res, p + 4) : LOOP UNTIL 1
    END WITH
  END IF                                      : DELETE client : RETURN r
END FUNCTION
