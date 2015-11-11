Changelog & Credits  {#PagChangelog}
===================
\tableofcontents


# Further Development  {#SecToDo}

\Proj is already a powerful tool to handle internet connection in FB
source code. But there's still some optimization potential, like:

- more stuff in nettobac_http.bas, ie. https protocol

- further utility files like ie. nettobac_ftp.bas, nettobac_smtp.bas, ...

- ...

Feel free to post your ideas, bug reports, wishes or patches, either
to the project page at

- \Webs

or to the

- [forum page](http://www.freebasic.net/forum/viewtopic.php?f=8&t=24133#p213232)

or feel free to send your ideas directly to the author (\Mail).


# Versions  {#SecVersions}

## nettobac-0.0.0  {#SubSecV-0-0-0}

Initial release on 2015 November, 11.


# \Proj vs. SNC

There's a similar solution called
[SNC](http://www.freebasic.net/forum/viewtopic.php?p=206316#p206316).
Here're the differences between both packages (vs. \Proj-0.0.0, SNC has
no version number yet, effective Nov. 2015):

- \Proj uses a syntax similar to the FB keywords (`nOpen`, `nPut`, `nGet`, `nClose`)

- the source is reduced to the essentials

  - GetErrr functions removed, instead n2bFactory.Errr indicates an error and contains the message (zero in case of no error)
  - `CanPut` and `CanGet` functions removed, features integrated in `nGet` and `nPut` methods, parameter `ReTry` defends against endless loops
  - `nGet` returns a STRING now, syntax similar to FB `GET #...` statement
  - method `GetConnection` renamed by `nOpen`

- additional features

  - the instances collect a list of opened connections, automaticaly closing them in the destructor
  - new method `nClose` for manual closing a connection

- instead of one file `snc.bi` there're `nettobac.bi` and `nettobac.bas` (for usage in build management systems)

- `snc_utilities.bas` renamed to `nettobac_http.bas`, new function httpLoad(), mime type handled as bit mask

- additional `example_server.bas` and `demo[12].html` files

- the source is fully documented in Doxygen style


# Credits  {#SecCredits}

Thanks go to:

- The FreeBASIC developer team for creating a great compiler.

- mf0102 for developing Allegro Simplificator.

- D.J.Peters for his FB transformation.

- Dimitri van Heesch for creating the Doxygen tool, which is used to
  generate this documentation.

- Bill Hoffman, Ken Martin, Brad King, Dave Cole, Alexander Neundorf,
  Clinton Stimpson for developing the CMake tool and publishing it
  under an open licence (the documentation has optimization potential).

- All others I forgot to mention.
