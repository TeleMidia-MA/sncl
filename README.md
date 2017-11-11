# sNCL
sNCL (simple NCL) is a DSL (Domain Specific Language) to ease the creation of interactive multimedia applications based on [NCL (Nested Context Language)](http://www.ncl.org.br).  After creating a program using sNCL, you can compile it to NCL and run it using the [Ginga](http://www.ginga.org.br) middleware.

Please, go to the [language documentation](https://sncl.readthedocs.io/) page to find out details about the language, and the [installation](https://sncl.readthedocs.io/en/latest/getting-started.html#installing-sncl) and [program execution](https://sncl.readthedocs.io/en/latest/getting-started.html#running-an-sncl-program) procedures.  Here, just to give you a taste of the language, the following source code shows a simple example that plays two videos in sequence:

```
port pBody video1
media video1
  src: "video2.mp4"
  bounds: "0,0,100%,100%"
end
media video2
  src: "video2.mp4"
  bounds: "25%,25%,50%,50%"
end

onEnd video1 do
  start video2 end
end
```

## Requirements:
* [Lua](https://www.lua.org/)
* [LuaRocks](https://luarocks.org/)
 
## More information:
* [sNCL documentation](https://sncl.readthedocs.io)
* [wiki](https://github.com/TeleMidia-MA/sncl/wiki)
* [To-Do List](https://github.com/TeleMidia-MA/sncl/wiki/To-Do)

## Other useful links:
* [NCL](http://ncl.org.br)
* [NCL handbook](http://handbook.ncl.org.br)
* [Ginga](http://ginga.org.br) and [Ginga's source code](http://github.com/telemidia/ginga)

---
Copyright (C) 2016-2017 UFMA/TeleMídia-MA

Permission is granted to copy, distribute and/or modify this document under
the terms of the GNU Free Documentation License, Version 1.3 or any later
version published by the Free Software Foundation; with no Invariant
Sections, with no Front-Cover Texts, and with no Back-Cover Texts. A copy of
the license is included in the "GNU Free Documentation License" file as part
of this distribution.

