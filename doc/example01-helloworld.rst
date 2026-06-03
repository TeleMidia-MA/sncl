Example 1: Hello world
======================

This first example shows a simple multimedia application, that only shows one
image on the screen. It consists of two main elements:

1. **Media:** The content to be displayed (image, video, etc.).
2. **Port:** The entry point that tells the player which media to start when the application loads.

.. code-block:: lua
  :linenos:
  
  port pIndex imgHello

  media imgHello
    src: "media/hello_world.png"
    width: "100%"
    height: "100%"
  end
