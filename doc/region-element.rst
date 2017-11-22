Region Element
===================

The region element defines the initial values of the region of the screen where
the media element will appear.

::

   Region = "region" * Id * (Comentario + Region + Propriedade + MacroCall)^0 * "end"

On the example below, 

.. code-block:: lua
   :linenos:

   port pBody1 media1
   port pBody2 media2

   region rgFullScreen
      width: 100%
      height: 100%
      region rgMidScreen
         width: 50%
         height: 50%
         bottom: 25%
         right: 25%
      end
   end

   media media1
      rg: rgFullScreen
      src: "medias/image1.jpg"
   end

   media media2
      rg: rgMidScreen
      src: "medias/image2.jpg"
   end
