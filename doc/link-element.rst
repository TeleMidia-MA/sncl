Link Element
============

The syntax of the link element is:

::

   Link = Condition^1 * (Comentario + Propriedade + Action)^0 * end

   Condition = AlphaNumeric * Id * TermCond
   TermCond = ("and" * Condition) + ("do")

   Action = AlphaNumeric * Id * (Comentario + Propriedade) * "end"

.. code-block:: lua
   :linenos:

   onBegin media1 do
      start media2 end
   end

The link element must have at least 1 condition and 1 action, in the case above,
the condition is "*onBegin media1*" and the action is "*start media2*", meaning
that, when the media1 begin, the media2 will start.

The condition and the action can also have properties, like a delay:

.. code-block:: lua
   :linenos:

   onBegin media1 do
      start media2 end
      delay: 10s
   end

   onBegin media1 do
      start media2
         delay: 10s
      end
   end

As seen in the syntax of the element, it can have multiple conditions and 
actions. To declare more than 1 action, you simply add it, like a son element:

.. code-block:: lua
   :linenos:

   onBegin media1 do
      start media2 end
      start media3 end
   end

And for multiple conditions, you can concatenate then with the "*and*" keyword:

.. code-block:: lua
   :linenos:

   onBegin media1 and onEnd media2 do
      start media3 end
   end

In this stage of development, the compiler only accepts the *and* value, so, the
link will only activate when media1 begin and media2 end. Adding the *or* value
will come in later stages.


Below is a list of the accepted conditions and actions:

==================== ============
 Conditions           Event Type
==================== ============
onBegin
onEnd
onAbort
onPause
onResume
onSelection
onBeginSelection
onEndSelection
onAbortSelection
onPauseSelection
onResumeSelection
onBeginAttribution
onEndAttribution
onPauseAttribution
onResumeAttribution
onAbortAttribution
==================== ============


========= ============
 Actions   Event Type
========= ============
start
stop
abort
pause
resume
set
========= ============

