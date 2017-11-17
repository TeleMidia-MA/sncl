The Media Element
=================

The media element defines an media object, that can be an image, video, text and even HTML 
documents or Lua scripts.

Its syntax is defined as:

::

   Media = "media" * Id *(Comentario + MacroCall + Area + Propriedade)^0 * end

It is identified univocally by the **id** field, for example, the code bellow declares a media object that is a HTML document and has the id "media1". In this case, no other element in the
entire application may have the id "media1".

.. code-block:: lua
   :linenos:

   media media1
      type: "text/html"
   end

The media element must have either a **type**, a **source** or **refer** to another element, so the player knows what is the type of the media object.

.. code-block:: lua
   :linenos:

   media media1
      type: "text/html" -- a type
   end
   media media2
      src: "docs/index.html" -- a source
   end
   media media3
      refer: media2 -- media3 refers to media2
   end

In addition to specifying the type of the media object, or what the object is, it can also be
specified where the object will appear in the screen, the location of it, the list of these
other possible properties is in :doc:`default-properties`

.. code-block:: lua
   :linenos:

   media media4
      -- a media with margin of 15 pixels on both sides
      src: "medias/image.jpg"
      left: 15px
      right: 15px
   end
