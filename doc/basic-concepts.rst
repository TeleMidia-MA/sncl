=====================
Basic Concepts of sNCL
======================

The NCM Model
=============

sNCL (simpler Nested Context Language) is a language made to ease the
development of hypermedia applications for the Ginga-NCL middleware, which has
as the standard language NCL (Nested Context Language), a XML application.
The sNCL compiler translates sNCL files into NCL files, and then
these NCL files can be played by the Ginga middleware.

Since both are based on the same model, the NCM (Nested Context Model), many
of the concepts of NCL are used in sNCL, however, sNCL introduces new elements,
such as macros and templates, that are not comtemplated in the model.

One of the basic entities of the NCM is a node, that can be either a Media
node or a Composition node. Medias in sNCL be anything, from a image, video or
audio to a Lua script, HTML document or Java code, the type of Media node is
also called its subclass, which are used to better define the interpretation
of the content. 

A Media can have interfaces, which can be separated into properties, anchors,
ports and switch ports. A anchor is a subset of the informations of the node,
for example, a snippet of a video, or a part of a text file, and properties are
informations like the color of the background of a media or its position on the
screen.
The switch and switch port interfaces are not yet implemented in sNCL, a table
with the information of what elements are implemented, will be implemented
or won't be implemented can be found at ().

Another important element of the model is the Link element, which sets up
temporal and spacial relationships between nodes.


Medias
--------

Contexts
--------
.. todo:: Explain context, and access to elements inside of the context
In NCL, 

The compile process:
------------------
The compiler first turns the sNCl file in a Lua table (called symbol table), that
is indexed by the Ids of the elements. This table is then used to generate the
final NCL document.

For example, this sNCL file:

.. code-block:: lua
   :linenos
   media media1
      type: "text/html"
      left: 50%
   end

Generates the following Lua table:

::

   media1 = {
      _type = "media",
      hasEnd = true,
      id = "media1",
      line = 9,
      properties = {
         left: '"50%"'
      },
      sons = {},
      type = '"text/html"'
   }

This example is pretty straightforward. The table creates has the properties
of the sNCL element, plus some meta information, like the line number it was
created, the elements that are nested inside of it (its sons).

The next element shows the use of the Region element, which serves to reuse
the properties of the Media element:

.. code-block:: lua
   :linenos:

   region region1
      top: 10%
      left: 50%
   end
   media media1
      type: "text/html"
      rg: region1
   end
   media media2
      type: "text/html"
      rg: region1
   end

The element '__descregion1' is created by the compiler, and it is necessary
because in NCL, a Media can not refer directly to a Region. It has to refer to
a Descriptor, and then the Descriptor has to refer to said Region. Both Medias
now have the 'left' and 'top' properties, but you do not have to declare it twice
for each Media

::

   head = {
      __descregion1 = {
         _type = "descriptor",
         id = "__descregion1",
         region = "region1"
      },
      region1 = {
         _type = "region",
         hasEnd = true,
         id = "region1",
         line = 3,
         properties = {
            left = '"50%"',
            top = '"10%"'
         },
         sons = {}
      }
   }
   body = {
      media1 = {
         _type = "media",
         descriptor = "__descregion1",
         hasEnd = true,
         id = "media1",
         line = 7,
         properties = {},
         region = "region1",
         sons = {},
         type = '"text/html"'
      }
      media2 = {
         _type = "media",
         descriptor = "__descregion1",
         hasEnd = true,
         id = "media2",
         line = 11,
         properties = {},
         region = "region1",
         sons = {},
         type = '"text/html"'
      }
   }

As can be seen, all the tables up to look alike. This is because they
are all presentation elements, so they are created the same way. All have id,
_type, sons, properties and others informations that are exclusive to each, like
the descriptor and region in the case of the Medias that have a Region.

The next example shows the state of the symbol table with a Link element:

.. code-block:: lua
   :linenos:

   media media1
      type: "text/html"
   end
   media media2
      type: "text/html"
   end
   onBegin media1 do
      start media2
         delay: 20s
      end
   end

::

   head = {
      OnBeginStart = {
         _type = "xconnector",
         action = {
           start = 1
         },
         condition = {
           onBegin = 1
         },
         id = "OnBeginStart",
         properties = { "delay" }
      }
   }
   body = {
      [1] = {
         _type = "link",
         actions = { 
            [1] = {
               _type = "action",
               component = "media2",
               father = <table 1>,
               hasEnd = true,
               line = 10,
               properties = {
                  delay = '"20s"'
               },
               role = "start"
           } 
         },
         conditions = {
            [1] = {
               _type = "condition",
               component = "media1",
               father = <table 1>,
               hasEnd = false,
               line = 6,
               properties = {},
               role = "onBegin"
            }
         },
         hasEnd = true,
         line = 11,
         properties = {},
         xconnector = "OnBeginStart"
      },
      media1 = {
         _type = "media",
         hasEnd = true,
         id = "media1",
         line = 2,
         properties = {},
         sons = {},
         type = '"text/html"'
      },
      media2 = {
         _type = "media",
         hasEnd = true,
         id = "media2",
         line = 5,
         properties = {},
         sons = {},
         type = '"text/html"'
      }
   }


Macros
------

sNCL also has a new element, the **macro** element, that is neither a Representation
Element or a Relantionship Element.This new element behaves exactly like a macro
is supposed to.

.. code-block:: lua
   :linenos:

   macro macro1 (mName, mType)
      media mName
         type: mType
      end
   end

Templates
---------


