Changelog & Credits  {#PagChangelog}
===================
\tableofcontents


# Further Development  {#SecToDo}

\Proj is already a powerful tool to handle internet connection in FB
source code. But there's still some optimization potential, like:

- ???
- ...

Feel free to post your ideas, bug reports, wishes or patches, either
to the project page at

- \Webs

or to the

- [forum page](http://www.freebasic.net/forum/viewtopic.php?p=???)

or feel free to send your ideas directly to the author (\Mail).


# Versions  {#SecVersions}

## GirToBac-0.0  {#SubSecV-0-0}

Initial release on 2015 November, ??.


# Proj vs. SNC

There's a similar solution called
[SNC](http://www.freebasic.net/forum/viewtopic.php?p=206316#p206316).
Here're the differences between both packages (effective Oct. 2015):

- \Proj uses a syntax similar to the FB keywords (`Open`, `Put`, `Get`, `Close`)

- the source is separated in *.bi and *.bas files (for usage in build management systems)

- the source is fully documented in Doxygen style

- the source is reduced to the essentials

  - GetErrr functions removed, error message is a public ZSTRING PTR now (zero in case of no error)
  - `CanPut` and `CanGet` functions removed, features integrated in `Get` and `Put` methods
  - `Get` returns a STRING now, syntax similar to FB `GET #...` statement
  - method `GetConnection` renamed by `Open`

- additional features

  - `n2bFactory` collects a list of opened connections,
     automaticaly closing them in the destructor

  - new method `Close` for manual closing a connection

- additional `example_server.bas` and demo[12].htlm files


# Credits  {#SecCredits}

Thanks go to:

- The FreeBASIC developer team for creating a great compiler.

- mf0102 for developing Allegro Simplificator.

- Dimitri van Heesch for creating the Doxygen tool, which is used to
  generate this documentation.

- All others I forgot to mention.
