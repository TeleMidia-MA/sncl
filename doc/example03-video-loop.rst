Example 3: Playing a video in loop
==================================

This example demonstrates how to create a continuous loop and, importantly, how to provide a mechanism 
for the user to break that loop.

We will define a **media** to play in a loop and use an **interaction (key press)** to pause the video.

Step 1: Creating the Loop Logic
-------------------------------

.. code-block:: lua
  :linenos:

  port pVideo videoLoop

  media videoLoop
    src: "media/video1.mp4"
    width: "100%"
    height: "100%"
  end

  onEnd videoLoop do
    start videoLoop end
  end

Step 2: Breaking the Loop (Interaction)
---------------------------------------

A loop is dangerous if the user cannot exit it. We will add a rule that allows the user to press 
the **RED** key on the remote control to stop the presentation.

.. code-block:: lua
  :linenos:

  onSelection videoLoop.RED do
    abort videoLoop end
  end

Full Source Code
----------------

Here is the complete code. It configures the port, sets the video, establishes the loop, and provides 
the exit mechanism.

.. code-block:: lua
  :linenos:

  port pVideo videoLoop

  media videoLoop
    src: "media/video1.mp4"
    width: "100%"
    height: "100%"
  end

  onEnd videoLoop do
    start videoLoop end
  end

  onSelection videoLoop.RED do
    abort videoLoop end
  end