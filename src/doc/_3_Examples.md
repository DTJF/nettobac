Examples  {#PagExamples}
========
\tableofcontents

Each \Proj session performs the following events

-# create an instance (#nettobacClient or #nettobacServer)
-# `nOpen()` a connection
-# exchange data over the connection (by `nPut` or `nGet`)
-# `nClose()` the connection (optional)
-# `DELETE` the instance

When using the http utilities in file nettobac_http.bas, the minimum
source code is

~~~{.bas}
#INCLUDE ONCE "nettobac.bas"
#INCLUDE ONCE "nettobac_http.bas"

VAR res = "" _
  , msg = httpLoad(res, "www.freebasic.net/index.html")
IF msg THEN ?"error: " & *msg & " failed" : END 1

' here variable res contains the web page context
~~~

The above five steps are inside the function httpLoad(). After each
step an error check gets done, and in case of an error the function
breaks and returns the error code. See page \ref PagErrormsg for
details on possible error messages.

In case of success the function returns 0 (zero) and the downloaded
context is in variable `res`.

A little more complex code is used in the package examples, described
in the folloing sections.


# example_client  {#SecExa_Client}

This example perfomrs a

- client scenario by

- downloading files from different servers and

- store them in the local folder `data`

  \Item{index.html} a text file (via http protocol)
  \Item{fb_logo.gif} an image file (via http protocol)
  \Item{osm.png} an image file created by php script (custom protocol)

The downloads get done in function doClientActions(). Each one is
enclosed by a `SCOPE` block, in order to make it easy to add or remove
further blocks.

When you execute this example (on the command line), it

- checks for the folder `data` in the executable path
- creates that folder if not present
- changes to that folder
- downloads the above mentioned files
- and stores them in folder `data`
- thereby generating the following messages

~~~{.sh}
  nettobac-0.0.0, License LGPLv2.1
  Copyright (C) 2015-2015 by Thomas{ doT ]Freiherr[ At ]gmx[ DoT }net
  Compiled: 11-11-2015, 10:29:16 with FreeBASIC 1.01.0 for UNIX
saved: index.htm
saved: fb_logo.gif
saved: osm.png
~~~

Check the files in folder `src/bas/data`.


# example_server  {#SecExa_Server}

This example performs a

- http server scenario

- by opening a port on localhost and

- listening at this port for client connections.

- It opens connections to client peers,

- receives http requests from clients and

- responds to requests by sending http data.

When you execute this example (on the command line), it outputs the
following message

~~~{.sh}
  nettobac-0.0.0, License LGPLv2.1
  Copyright (C) 2015-2015 by Thomas{ doT ]Freiherr[ At ]gmx[ DoT }net
  Compiled: 11-11-2015, 10:29:17 with FreeBASIC 1.01.0 for UNIX
server started (port = 3490)
~~~

and waits for a client to connect. You can test this by starting your
web browser and request the adress

~~~
localhost:3490
~~~

That will open the "NetToBac HTML Demo #1" page, containing two links
and a button.

- The first link jumps to a second (internal) page.

- The second link jumps to an external page loaded from the web.

- The button exits the demo and shuts down the server.

Before you test the links, check the output on the command line. It
shows further information on the actions performed by the
example_server.bas code, ie. like

~~~{.unparsed}
...
Client connected!

Client message:
GET / HTTP/1.1
Host: localhost:3490
User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:42.0) Gecko/20100101 Firefox/42.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: de,en-US;q=0.7,en;q=0.3
Accept-Encoding: gzip, deflate
DNT: 1
Connection: keep-alive


sending HTML1 ... done

Client disconnected!

Client connected!

Client message:
GET /favicon.ico HTTP/1.1
Host: localhost:3490
User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:42.0) Gecko/20100101 Firefox/42.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: de,en-US;q=0.7,en;q=0.3
Accept-Encoding: gzip, deflate
DNT: 1
Connection: keep-alive


sending ICON ... done

Client disconnected!
~~~

When the second link gets clicked, no further message gets shown in the
command line window, since the browser connects to an external server
to get the context.

When you click on the first (internal) link, further message occur in
the command line window. The second page opens. It contains a form with
two entries for a pseudo login and a button. When clicking the button,
the server gets the form context and extracts the user input from the
entries, to create a new page showing the results.

When the button `Exit demo -> shutdown server` gets clicked, the server
closes all connections and shuts down. This can also get achieved by
pressing any key in the command line window.
