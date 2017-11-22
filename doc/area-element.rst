Area Element
============

The area element defines an anchor ( a part of the information of the media
element) that may be used in relationships with other objects.

::

   Area = "area" * Id * (Comentario + Propriedade)^0 * "end"

Anchors can represent:
   * Spatial portions of images (begin, end, first, last)
   * Temporal portions of continuous media content (begin, end, coords, first, last)
   * Textual segments

For example, a temporal portion of a video can used like the example below. When the
*media1* gets in 20s, *media2* will start.

.. code-block:: lua
   :linenos:

   port pBody media1

   media media1
      src: "medias/video1.jpg"
      area area1
         begin: 20s
      end
   end

   media media2
      src: "medias/image2.jpg"
   end

   onBegin media1.area1 do
      start media2 end
   end




