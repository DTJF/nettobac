Preparation  {#PagPreparation}
===========
\tableofcontents

This chapter is about

- how to prepare your system to use \Proj by installing tools,
- how to get the package and
- how to build the executable and the documentation.


# Tools  {#SecTools}

The following table lists all dependencies for \Proj and their types.
At least, you have to install the FreeBASIC compiler on your system to
build any executable using the \Proj features. Beside this mandatory
(M) tool, the others are optional. Some are recommended (R) in order to
make use of all package features. LINUX users find some packages in
their distrubution management system (D).

|                                        Name  | Type |  Function                                                      |
| -------------------------------------------: | :--: | :------------------------------------------------------------- |
| [fbc](http://www.freebasic.net)              | M    | FreeBASIC compiler to compile the source code                  |
| [GIT](http://git-scm.com/)                   | R  D | version control system to organize the files                   |
| [CMake](http://www.cmake.org)                | R  D | build management system to build executables and documentation |
| [cmakefbc](http://github.com/DTJF/cmakefbc)  | R    | FreeBASIC extension for CMake                                  |
| [fb-doc](http://github.com/DTJF/fb-doc)      | R    | FreeBASIC extension tool for Doxygen                           |
| [Doxygen](http://www.doxygen.org/)           | R  D | documentation generator (ie. for this text)                    |
| [Graphviz](http://www.graphviz.org/)         | R  D | Graph Visualization Software (caller/callee graphs)            |

It's beyond the scope of this guide to describe the installation for
those programming tools. Find detailed installation instructions on the
related websides, linked by the name in the first column.

-# First, install the distributed (D) packages of your choise.

-# Then make the FB compiler working. If you aren't confident about
   the task you can find a few notes on the [Installing
   FreeBASIC](http://www.freebasic.net/wiki/wikka.php?wakka=CompilerInstalling)
   wiki page.

-# Continue by installing cmakefbc, if wanted. That's easy, when you
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


# Build the examples  {#SecExecutable}

Find the \Proj source files in folder `src/bas`. The code is ready to
get used in your project, just #`INCLUDE` file `nettobac.bas` (and also
`nettobac_http.bas` if you want to utilities for http protocol).

Check the source code in the examples to get inspirations. Or compile
the examples to see the code working, either by

- using the CMake build scripts, or
- direct compiling by calling the FB compiler in the src folder.


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


## Direct compiling  {#SecExe_Man}

### Executable  {#SecExe_Man_EXE}

In order to build the executable change from the package root directory
to the *src* folder and compile by executing

~~~{.sh}
cd src
fbc -e -w all girtobac.bas
~~~

This creates an executable binary named

- *girtobac* (on UNIX-like systems) or
- *girtobac.exe* (on other systems).

that you can install wherever you need it.

### Documentation  {#SecExe_Man_DOC}

In order to build the documentation, install the tools fb-doc, Doxygen
and Graphviz. Then change from the package root directory to the `doxy`
folder, up-date the file *fb-doc.lfn*, execute the Doxygen generator
and adapt correct listings by executing

~~~{.sh}
cd doxy
fb-doc -l
doxygen Doxyfile
fb-doc -s
~~~

to build the documentation in subfolders *html* (start file =
index.html) and *latex* (call `make` in that folder to build
refman.pdf).

\note Adapt the configuration file *Doxyfile* (or your customized copy)
      in order to fit the output to your needs.

