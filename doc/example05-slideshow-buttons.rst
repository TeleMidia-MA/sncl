Example 5: Slideshow with buttons (macros)
==========================================

This example builds upon the previous slideshow but replaces automatic timers with manual user navigation using 
the remote control arrow keys (CURSOR_LEFT and CURSOR_RIGHT).

Step 1: Defining the Macro
--------------------------

We define the macros as in the previous example, but with a small change: we use the ``CURSOR_RIGHT`` 
and ``CURSOR_LEFT`` keys to perform navigation.

.. code-block:: lua
  :linenos:

  macro createSlide(curr, src, prev, next)
    media curr
        src: src
        width: "100%"
        height: "100%"
    end

    onSelection curr.CURSOR_RIGHT do
        start next end
        abort curr end
    end

    onSelection curr.CURSOR_LEFT do
        start prev end
        abort curr end
    end
  end

Step 2: Using the Macro
-----------------------

Now we just need to call the macro.

.. code-block:: lua
  :linenos:

  port entry slide1

  createSlide("slide1", "media/photo1.jpg", "slide3", "slide2")
  createSlide("slide2", "media/photo2.jpg", "slide1", "slide3")
  createSlide("slide3", "media/photo3.jpg", "slide2", "slide1")

Full Source Code
----------------

.. code-block:: lua
  :linenos:

  macro createSlide(curr, src, prev, next)
    media curr
        src: src
        width: "100%"
        height: "100%"
    end

    onSelection curr.CURSOR_RIGHT do
        start next end
        abort curr end
    end

    onSelection curr.CURSOR_LEFT do
        start prev end
        abort curr end
    end
  end

  port entry slide1

  createSlide("slide1", "media/photo1.jpg", "slide3", "slide2")
  createSlide("slide2", "media/photo2.jpg", "slide1", "slide3")
  createSlide("slide3", "media/photo3.jpg", "slide2", "slide1")
