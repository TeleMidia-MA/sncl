Exemplo 6: Operadores de Allen (macros)
=======================================


Precedes e Preceded By
----------------------

A media1 acontece antes da media2, ou a media2 é precedida pela media1.

.. code-block:: lua

  macro precedes (A, B, delay)
    onBegin A do
      start B
        delay: delay
      end
    end
  end

  media media1
     src: "media2.mp4"
  end

  media media2
    src: "media2.mp4"
  end

  precedes(media1, media2)

Meets e Met By
--------------

A media1 encontra a media2

.. code-block:: lua

  macro meets (A, B)
    onEnd A do
      start B end
    end
  end

  media media1
    src: "media2.mp4"
  end

  media media2
    src: "media2.mp4"
  end

  meets (media1, media2)

Overlaps e Overlapped By
------------------------

A media1 sobrepõe a media2

.. code-block:: lua

  TODO.

Starts e Started By
-------------------

A media1 começa a media2, ou a media2 é começada pela media1.

.. code-block:: lua

  macro starts (A, B)
    onBegin A do
      start B end
    end
  end

  media media1
    src: "media1.mp4"
  end

  media media2
    src: "media2.mp4"
  end

  starts (media1, media2)

During e Contains
-----------------

A media1 acontece durante a media2, ou a media2 contém a media1.

.. code-block:: lua

  TODO.

Finishes e Finished By
----------------------

A media1 acaba a media 2, ou a media2 é acabada pela media1.

.. code-block:: lua

  macro finishes (A, B)
    onEnd A do
      stop B end
    end
  end

  media media1
    src: "media1.mp4"
  end

  media media2
    src: "media2.mp4"
  end

  finishes (media1, media2)

Equals
------

A duração de ambas as mídias são iguais.

.. code-block:: lua

  macro equals (A, B)
    onBegin A do
      start B end
    end
    onEnd A do
      stop B end
    end
  end

  media media1
    src: "media1.mp4"
  end

  media media2
    src: "media2.mp4"
  end

  equals (media1, media2)

