Example 2: Playing a video and an image
=======================================

This example expands on the "Hello World" by introducing three fundamental concepts: 
**Layout** (using Regions), **Anchors** (using Areas), and **Synchronization** (using Links).

The goal of this example is to play a video in full screen and display an image (a logo) 
overlaid in the upper right corner, but only after a specific time (5 seconds).

Key concepts used:

1. **Regions:** We define distinct areas on the screen.
2. **Areas:** We define a temporal segment within the video to act as a trigger.
3. **Link:** We use an ``onBegin`` condition to start the logo at the right time.

Step 1: Defining the Layout
---------------------------

First, we need to define where the elements will appear on the screen. We use the **region** element for this.

We will create two regions:

1. ``rgFull``: Covers the entire screen for the video.
2. ``rgLogoCorner``: A smaller area for the logo.

.. note::

  We use the ``zIndex`` property to ensure that each media item appears in the correct place. 
  A higher value (1) for the logo region ensures it appears **on top** of the video region (0).

.. code-block:: lua
  :linenos:

   region rgFull
      width: "100%"
      height: "100%"
      zIndex: 0
   end

   region rgLogoCorner
      width: "150px"
      height: "100px"
      right: "5%"
      top: "5%"
      zIndex: 1
   end

Step 2: Defining the Media
--------------------------

Now we define the media and associate each one with the regions created in the previous step using the ``rg`` property.

For the video, we introduce the **area** element. The area ``segLogo`` defines a specific moment or segment within 
the video. In this case, it creates an anchor that begins 5 seconds into the video. We will use this anchor later to trigger the logo.

.. code-block:: lua
   :linenos:

   media mainVideo
      src: "media/video.mp4"
      rg: rgFull

      area segLogo
         begin: "5s"
      end
   end

   media imgLogo
      src: "media/logo.png"
      rg: rgLogoCorner
   end

Step 3: The Entry Point
-----------------------

We need to tell the player which media starts the application. We use the **port** element to point to our main video.

.. code-block:: lua
   :linenos:

   port pMain mainVideo

Step 4: Synchronization Logic
-----------------------------

To show the logo, we create a rule based on the anchor we defined.

Instead of listening to the start of the video (which would be ``onBegin mainVideo``), we listen 
to the start of the area (``onBegin mainVideo.segLogo``).

.. code-block:: lua

   onBegin mainVideo.segLogo do
      start imgLogo end
   end

Full Source Code
----------------

Here is the complete code combining all the steps above:

.. code-block:: lua
   :linenos:

   region rgFull
      width: "100%"
      height: "100%"
      zIndex: 0
   end

   region rgLogoCorner
      width: "150px"
      height: "100px"
      right: "5%"
      top: "5%"
      zIndex: 1
   end

   media mainVideo
      src: "media/video.mp4"
      rg: rgFull

      area segLogo
         begin: "5s"
      end
   end

   media imgLogo
      src: "media/logo.png"
      rg: rgLogoCorner
   end

   port pMain mainVideo

   onBegin mainVideo.segLogo do
      start imgLogo end
   end