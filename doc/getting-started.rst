Getting started
===============

Installing sNCL
---------------

sNCL relies on Lua and LuaRocks, which can be installed from the standard
repositories of most distros. LuaRocks is a plugin manager for Lua.

For example, on **Ubuntu Linux** and **Arch Linux**:

::

    sudo apt-get install lua luarocks
    sudo pacman -S lua luarocks


After LuaRocks and Lua are installed, sNCL can be installed using LuaRocks.
This command will install sncl and all the Lua plugins it requires.

::

    sudo luarocks install sncl

.. todo:: How to install cloning the github repo

::

   git clone https://github.com/TeleMidia-MA/sncl
   cd sncl
   sudo luarocks make

.. todo:: How to install on Windows and MacOS?

Running an sNCL program
-----------------------

.. todo:: Add some instructions on how to run an sncl program.

::

   cd sncl/spec
   sncl example.sncl

It will generate a file called example.ncl, to specify a different file, you
can use

::

   sncl example.sncl -o other-file.ncl

