moon = require('moon')
lpeg = require('lpeg')

import Context, Media, Area from require('presentation')
import Property from require('property')
import Link, Action, Condition from require('link')
import grammar from require('grammar')

__DEBUG__ = false

readFile = (path) ->
   return io.open(path)\read('*a')

parseText = (text using grammar) ->
   local raw_elements
   raw_elements = lpeg.match(grammar, text)
   if __DEBUG__
      moon.p(raw_elements)
   if not raw_elements
      error('Error parsing input', 2)
   return raw_elements

createElement = (grammar_ele, symbol_table) ->
   if grammar_ele == nil return nil

   local new_ele
   switch grammar_ele._type
      when 'context'
         new_ele = Context(grammar_ele.id)
      when 'media'
         new_ele = Media(grammar_ele.id)
      when 'area'
         new_ele = Area(grammar_ele.id)
      when 'property'
         new_ele = Property(grammar_ele.name, grammar_ele.value)
      else
         error("Wrong Type")

   if new_ele.id
      if symbol_table[new_ele.id]
         -- TODO: this shouldn't be an error
         error('Element Already Declared')
      symbol_table[new_ele.id] = new_ele

   if grammar_ele['children']
      for child in *grammar_ele['children']
         local new_child
         new_child = createElement(child, symbol_table)
         new_ele\addChildren(new_child)

   return new_ele

transverseSymbolTable = (raw_elements, symbol_table)->
   local elements
   elements = {}
   for element in *raw_elements
      local new_element
      new_element = createElement(element, symbol_table)
      elements[new_element.id] = new_element
   return elements

main = () ->
   raw_elements = parseText(readFile'test.sncl')
   symbol_table = {}
   transverseSymbolTable(raw_elements, symbol_table)

main!

sncl = {
   :readFile, :parseText
}

{:sncl}
