* Bugs:
   1. [ ] When the macro child do not have end, ex:
      macro m1()
         media media1
            type: "text/html"
      end
   2. [ ]
   3. 
   
* New language features:
   1. [ ] Element reuse
   2. [ ] Switch
   3. [ ] Multiples parameters in macro
   4. [ ] Named parameters in macros (a macro could be used in the same way of a native tag)
   5. [ ] Import
   6. [ ] Context?
   7. [ ] Do we need port? Couldn't we use an extern annotation to say that the media is acessible outside it context?

* Others
   1. [ ] Add a command-line option to run the resulted document (e.g. calling `ginga doc.ncl`)
   2. [ ] Web Editor / Player (using Web NCL?)
   
* Fixes:
   1. [ ] linkParam should be bindParam of Condition
   2. [ ] Check value of properties of Area element
   3. [X] Macro params should only accept strings
   4. [ ] Properties with value "default" in sNCL should have no value in NCL
   5. [X] Regions don't have property
   6. [X] Connect Descriptor and Region
   7. [X] Error messages in english
   8. [X] Condition "and" and "do"

