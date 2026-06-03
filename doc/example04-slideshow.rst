Example 4: Slideshow (macros)
=============================

This example demonstrates how to write a slideshow using **Macros**.

A slideshow usually involves a repetitive pattern: define an image, wait for a specific duration, and 
then start the next image. Instead of writing this logic manually for every single photo, we can create 
a macro that acts as a template.

Step 1: Defining the Macro
--------------------------

We will create a macro called ``createSlide``. It needs to know three things:

1. The **ID** of the current slide.
2. The **Source** file (image).
3. The **ID** of the next slide to trigger.

Inside the macro, we define the media object (image) with a fixed duration (using explicitDur) and a link that automatically 
starts the next slide when the time is up.

.. code-block:: lua
  :linenos:

  macro createSlide(id, fileSource, nextId)
    media id
        src: fileSource
        explicitDur: "5s"
    end

    onEnd id do
        start nextId end
    end
  end

Step 2: Using the Macro
-----------------------

Now, to create the slideshow, we just need to call the macro and set the starting slide (with **port** element).

.. code-block:: lua
  :linenos:

  port pSlide1 slide1

  createSlide("slide1", "media/photo1.jpg", "slide2")
  createSlide("slide2", "media/photo2.jpg", "slide3")
  createSlide("slide3", "media/photo3.jpg", "slide1")

Full Source Code
----------------

.. code-block:: lua
  :linenos:

  macro createSlide(id, fileSource, nextId)
    media id
        src: fileSource
        explicitDur: "5s"
    end

    onEnd id do
        start nextId end
    end
  end

  port pSlide1 slide1

  createSlide("slide1", "media/photo1.jpg", "slide2")
  createSlide("slide2", "media/photo2.jpg", "slide3")
  createSlide("slide3", "media/photo3.jpg", "slide1")