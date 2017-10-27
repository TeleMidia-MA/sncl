Installing sNCL
===============

sNCL relies on Lua and LuaRocks, which can be installed from the standard repositories of most distros. LuaRocks is a plugin manager for Lua.

For example, on **Ubuntu Linux** and **Arch Linux**:

::

    sudo apt-get install lua luarocks
    sudo pacman -S lua luarocks


After LuaRocks and Lua are installed, sNCL can be installed using LuaRocks. This command will install sncl and all the Lua plugins it requires.

::

    sudo luarocks install sncl

.. todo:: Instruções de como instalar clonando o repo do github
.. todo:: How to install on Windows and MacOS?

