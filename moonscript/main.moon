moon = require('moon')
lpeg = require('lpeg')

import Context, Media, Area from require('presentation')
import Link, Action, Condition from require('link')
import grammar from require('grammar')

__DEBUG__ = false

readFile = (path) ->
   return io.open(path)\read('*a')

parseText = (text using grammar) ->
   local symbol_table
   symbol_table = lpeg.match(grammar, text)
   if __DEBUG__
      moon.p(symbol_table)
   if not symbol_table
      error('Error parsing input', 2)
   return symbol_table


create_element = (grammar_ele) ->
   if grammar_ele == nil return nil
   local new_ele
   switch grammar_ele._type
      when 'context'
         print'creating context'
         new_ele = Context(grammar_ele.id)
      when 'media'
         print'creating media'
         new_ele = Media(grammar_ele.id)
      else
         return nil, 'Wrong Type'

   for k, v in pairs grammar_ele
      if k == 'children'
         new_child = create_element v[1]
         if new_child != nil
            new_ele\addChildren(new_child)

   return new_ele

createObjects = (symbol_table)->
   for element in *symbol_table
      local new_element
      new_element = create_element(element)
      moon.p new_element

symbol_table = parseText(readFile'test.sncl')
moon.p symbol_table
--createObjects symbol_table

sncl = {
   :readFile, :parseText
}

{:sncl}
