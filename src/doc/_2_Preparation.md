Preparation  {#PagPreparation}
===========
\tableofcontents

The \Proj source code is ready to use, just copy from folder `src/bas`
the files

  - `nettobac.bi` header with declarations
  - `nettobac_system.bi` header with system specific declarations
  - `nettobac.bas` source file with function bodies

in to your project source directory and prepend your code by

~~~{.bas}
#INCLUDE ONCE "nettobac.bas"
~~~

In order to see the code working, you can compile the examples directly
in the folder `src/bas` by executing

~~~{.sh}
fbc -w all "example_client.bas"
fbc -w all "example_server.bas"
~~~

and start the newly created binaries in that folder. See \ref
SecExa_Client and \ref SecExa_Server for a detailed description of what
should happen on your system.


# Tools  {#SecTools}

The further files in this package are related to the version control
system GIT and to automatical builds of the examples and the
documentation by the cross-platform CMake build management system. If
you want to use all package features, you can find in this chapter
information on

- how to prepare your system by installing necessary tools,
- how to get the package using GIT and
- how to automatical build the examples and the documentation.

The following table lists all dependencies for the \Proj package and
their types. At least, you have to install the FreeBASIC compiler on
your system to build any executable using the \Proj features. Beside
this mandatory (M) tool, the others are optional. Some are recommended
(R) in order to make use of all package features. LINUX users find some
packages in their distrubution management system (D).

|                                        Name  | Type |  Function                                                      |
| -------------------------------------------: | :--: | :------------------------------------------------------------- |
| [fbc](http://www.freebasic.net)              | M    | FreeBASIC compiler to compile the source code                  |
| [GIT](http://git-scm.com/)                   | R  D | version control system to organize the files                   |
| [CMake](http://www.cmake.org)                | R  D | build management system to build executables and documentation |
| [cmakefbc](http://github.com/DTJF/cmakefbc)  | R    | FreeBASIC extension for CMake                                  |
| [fb-doc](http://github.com/DTJF/fb-doc)      | R    | FreeBASIC extension tool for Doxygen                           |
| [Doxygen](http://www.doxygen.org/)           | R  D | documentation generator (for html output)                      |
| [Graphviz](http://www.graphviz.org/)         | R  D | Graph Visualization Software (caller/callee graphs)            |
| [LaTeX](https://latex-project.org/ftp.html)  | R  D | A document preparation system (for PDF output)                 |

It's beyond the scope of this guide to describe the installation for
those programming tools. Find detailed installation instructions on the
related websides, linked by the name in the first column.

-# First, install the distributed (D) packages of your choise.

-# Then make the FB compiler working. If you aren't confident about
   the task you can find a few notes on the [Installing
   FreeBASIC](http://www.freebasic.net/wiki/wikka.php?wakka=CompilerInstalling)
   wiki page.

-# Continue by installing cmakefbc (if wanted). That's easy, when you
   have GIT and CMake. Execute the commands
   ~~~{.sh}
   git clone https://github.com/DTJF/cmakefbc
   cd cmakefbc
   mkdir build
   cd build
   cmake ..
   make
   sudo make install
   ~~~
   \note Omit `sudo` in case of non-LINUX systems.

-# And finaly, install fb-doc (if wanted) by using GIT and CMake.
   Execute the commands
   ~~~{.sh}
   git clone https://github.com/DTJF/fb-doc
   cd fb-doc
   mkdir build
   cd build
   cmake ..
   make
   sudo make install
   ~~~
   \note Omit `sudo` in case of non-LINUX systems.


# Get Package  {#SecGet}

Depending on whether you installed the optional GIT package, there're
two ways to get the \Proj package.

## GIT  {#SecGet_Git}

Using GIT is the prefered way to download the \Proj package (since it
helps users to get involved in to the development process). Get your
copy and change to the source tree by executing

~~~{.sh}
git clone https://github.com/DTJF/nettobac
cd nettobac
~~~

## ZIP  {#SecGet_Zip}

As an alternative you can download a Zip archive by clicking the
[Download ZIP](https://github.com/DTJF/girtobac/archive/master.zip)
button on the \Proj website, and use your local Zip software to unpack
the archive. Then change to the newly created folder.

\note Zip files always contain the latest development version. You
      cannot switch to a certain point in the history.


# CMake Builds  {#Sec_CMakeBuilds}

The CMake build scripts are prepared to

- compile executables off examples example_client.bas and example_server.bas
- compile the documentation in several output formats (html, tex, pdf).

This can get done

- either in-source (the output and all auxiliary files get generated
  inside the source tree)

- or out-of-source (all new files get created in a separate build
  folder, multiple build folders can hold different configurations, ie.
  different targets)

The later is the prefered way, since it doesn't polute the source tree
and is more flexible.

\note In order to build the documentation, all recommended packages
      listed in section \ref SecTools have to get installed.


## In-Source-Build  {#SecExe_CMake_ISB}

In order to perform a in-source build go to the root folder of the
package and execute the following command:

~~~{.sh}
cmake .
~~~

This will check your system and on success it creates a set of
`Makefile`s and `CMake...` files to handle the build process. Those
files get generated in the source tree.

### Examples  {#SecExe_InExa}

The following command will compile the examples:

~~~{.sh}
make
~~~

It executes the files created by the priviuos `cmake .` command and
build the binaries in folder `src/bas`. You can now run the examples by
executing

~~~{.sh}
src/bas/example_client
src/bas/example_server
~~~

### Documentation  {#SecExe_InDoc}

The following command will compile the documentation in html, tex and
pdf format:

~~~{.sh}
make doc
~~~

\note Find the HTML start file at `doxy/html/index.html`.
\note Find the PDF file at `doxy/nettobac.pdf`.

Both targets can get build separately by executing

~~~{.sh}
make doc_htm
make doc_pdf
~~~


## Out-Of-Source-Build  {#SecExe_CMake_OSB}

In order to perform a out-of-source build go to the root folder of the
package and execute the following command triple:

~~~{.sh}
mkdir build
cd build
cmake ..
~~~

This will create a new folder `build`, change to that directory and in
the third step check your system. On success it creates a set of
`Makefile`s and `CMake...` files to handle the build process inside the
build folder. Those files are separated the source tree.


### Examples  {#SecExe_OutExa}

In order to compile the examples execute in the `build` folder

~~~{.sh}
make
~~~

This executes the files created by the priviuos `cmake ..` command and
build the binaries in subfolder `src/bas`. You can now run the examples
by executing

~~~{.sh}
build/src/bas/example_client
build/src/bas/example_server
~~~

### Documentation  {#SecExe_OutDoc}

The following command executed in the `build` folder will compile the
documentation in html, tex and pdf format:

~~~{.sh}
make doc
~~~

\note Find the HTML start file at `build/doxy/html/index.html`.
\note Find the PDF file at `build/doxy/nettobac.pdf`.

Both targets can get build separately by executing

~~~{.sh}
make doc_htm
make doc_pdf
~~~
