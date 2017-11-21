Context Element
===================

The context element defines 

Its syntax is defines as:

::

   Context = "context" * Id * (Comentario + Port + Propriedade + Media + Context + Link + MacroCall)^0 * "end"

As can be seen in the grammar especification, a context element can nest other elements, like :doc:`media-element`, :doc:`macro-element`, :doc:`link-element` and other contexts.

Elements that are inside of a context are only visible to the elements of the same context, meaning that, in the example below, the action of the link in the line 10 can not see the media **m1**, and the action of the line 18 neither.

.. code-block:: lua
   :linenos:

   context c1
      media m1
         src: "medias/image1.jpg"
      end
   end

   context c2
      media m2
         src: "medias/image2.jpg"
      end
      onBegin m2 do
         start m1 end
      end
   end

   media m3
      src: "medias/image3.jpg"
   end

   onBegin m3 do
      start m1 end
   end
