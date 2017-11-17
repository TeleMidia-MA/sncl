Basic Concepts of sNCL
======================

sNCL (simpler Nested Context Language) follows the NCM model, which is a conceptual model for
the representation and handling of hypermedia documents. The model separates its elements in
**representation elements**, that defines the representation of a media object in time and 
space and **relationship elements**, that defines the relationship between the media objects.

Thus, the elements in sNCL are divided in Representation elements and Relationship Elements.

Representation Elements are:
   1. Context
   2. Media
   3. Area
   4. Switch
   5. Region

Relationship Elements are:
   1. Link

As the name suggests, the language is composed of nested context. The whole body of the
document itself is seen as a context, the main context, in which the application starts, that
can have other contexts inside it.

.. todo:: Explain context, and access to elements inside of the context

sNCL also has a new element, the **macro** element, that is neither a Representation
Element or a Relantionship Element.This new element behaves exactly like a macro is supposed to.

.. code-block:: lua
   :linenos:

   macro macro1 (mName, mType)
      media mName
         type: mType
      end
   end


