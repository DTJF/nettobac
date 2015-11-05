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

- how to prepare your system by installing tools,
- how to get the package and
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
two ways to get the \Proj package. After download, find the \Proj
source files in folder `src/bas`. The code is ready to get used in your
projects, just #`INCLUDE` file `nettobac.bas` (and also
`nettobac_http.bas` if you want to use the utilities for http
protocol).

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


# Build the examples  {#SecExecutable}

The best way to get familar with the \Proj features is to check the
examples source code and to compile and run them, in order to see the
code working. This can be done either

- by using the CMake build scripts, or
- by direct compiling (calling the FB compiler in the src folder).


## CMake build  {#SecExe_CMakeBuild}

The prefered way to build executables of the examples and the
documentation files is to use the scripts for the CMake build system.
If you don't want to install or to use CMake, then skip this section
and continue at \ref SecExe_Man.

The CMake scripts check your system and through warnings if anything is
missing. Otherwise you can either perform an in-source or an
out-of-source build. The later should be your prefered choise.


### In-Source-Build  {#SecExe_CMake_ISB}

The following command double will compile the examples in the source
tree and install it on your system:

~~~{.sh}
cmake .
make
~~~

\note In-Source-Builds polute the source tree by newly created files.


### Out-Of-Source-Build  {#SecExe_CMake_OSB}

The following command qaudtuple will create a new *build* folder,
change to that folder and compile the examples:

~~~{.sh}
mkdir build
cd build
cmake ..
make
~~~

Now you can start the executables by

~~~{.sh}
src/bas/example_client
src/bas/example_server
~~~

See \ref SecExa_Client and \ref SecExa_Server for a detailed
desrciption of what should happen.


### Documentation-Build  {#SecExe_CMake_DOC}

In order to build the documentation, all recommended packages listed in
section \ref SecTools have to get installed. The following command will
build the documentation in form of an HTML file tree and in form of a
PDF file (either in-source or out-of-source):

~~~{.sh}
make doc
~~~

\note Find the HTML start file at `doc/html/index.html`.
\note Find the PDF file at `doc/girtobac.pdf`.

Both targets can get build separately by executing

~~~{.sh}
make doc_htm
make doc_pdf
~~~
