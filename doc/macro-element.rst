Macro Element
=============

The macro element is

::

   Macro = "macro" Id * (Comentario * MacroCall * Propriedade + Media + Area + Context + Link + Port + Region)^0 * "end"

It behaves like the standard definition of macro, it replaces the words of what
it receives as an argument:

.. code-block:: lua
   :linenos:

   macro macro1 (mName, mSource)
      media mName
         src: mSource
      end
   end

   *macro1("media1", "medias/image1.png")

The example above creates the one shown below. Note that, even if the argument
is passed as a string *"media1"*, when the macro is resolved, it don't become a
string, since it is an Id.

.. code-block:: lua
   :linenos:

   media media1
      src: "medias/image1.png"
   end

Macro can contain other macros, and call other macros inside of them, however,
recursion is not allowed (it can not call itself, its parent macros or macros
that are declared after itself).

.. code-block:: lua
   :linenos:

   macro macro1()
      *macro3() -- NOT ALLOWED, macro3 is declared after
      macro macro2()
         *macro1() -- NOT ALLOWED, macro1 is the parent of macro2
         macro macro3()
            *macro1() -- NOT ALLOWED EITHER
         end
      end
      *macro1() -- NOT ALLOWED, macro1 can not call itself
   end

   macro macro4()
   end

   macro macro5()
      *macro4() -- ALLOWED
   end

