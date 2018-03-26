* New language features:
   1. [ ] Element reuse
   3. [ ] Multiple parameters in macro
   4. [ ] Named parameters in macros (a macro could be used in the same way of a native tag)
   5. [ ] Import
   7. [ ] Do we need port? Couldn't we use an extern annotation to say that the media is acessible outside it context?
   8. [ ] Add key to link

* Others
   1. [ ] Web Editor / Player (using Web NCL?)

* Fixes:
   1. [ ] linkParam should be bindParam of Condition
   2. [ ] Multiple properties in a line
   3. [ ] Revert port to how it was
   4. [ ] Add transition properties in Media

# Templates

### Slideshow example:

```
-- Producer
slideshow:
   fotos(m1, "src1", m2, "src2")
end

-- Programmer
macro createFoto(id, src)
   media id
      src: src

   end
end

macro createLink(m1, m2)
   onEnd m1 do
      start m2 end
   end
end

macro createSlideshow(table)
   context slideshow
      createLink()
      createFoto()

      media buttonNext
         focusIndex: 1
         moveLeft: 2
         moveRight: 2
      end
      media buttonPrev
         focusIndex: 2
         moveLeft: 1
         moveRight: 1
      end

      assert medias[photo] > 0
   end
end

createSlideshow(slideshow)
```
