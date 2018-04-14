--local ins = require('inspect')
local utils = require('utils')
local gbl = require('globals')
local rS = require('resolve')
local lpeg = require('lpeg')

local parsingTable = {

   --- Generate a better formated table for the Port element
   -- Receives what the lpeg returns when it parses the port,
   -- then creates a better formated table
   -- then inserts it in the symbol table
   -- @param str The return of lpeg
   -- @param sT The symbol table
   -- @return The generated table
   makePort = function(str, sT)
      return str / function(id, comp, iface)
         local element = {
            _type = 'port',
            id = id,
            component = comp,
            interface = iface,
            line = gbl.parserLine
         }

         if utils:isIdUsed(element.id, sT) then
            return nil
         end

         sT.presentation[id] = element
         return element
      end
   end,

   --- Generate a better formated table for the Property element
   -- @param str The return of lpeg
   -- @return The generated table
   makeProperty = function(str)
      return str / function(name, value)
         return {
            _type = 'property',
            [name] = value,
            line = gbl.parseLine
         }
      end
   end,

   --- Generate a better formated table for the presentation elements
   -- The inicial table has an 'end' value, indicating that it has an end,
   -- and other tables as sons, those can be a property of
   -- the element, or another element, that is nested inside it.
   -- Then this table is processed to generated a better formated table, that is
   -- inserted in the symbol table
   -- @param str The return of lpeg
   -- @param sT The symbol table
   -- @param isMacroSon A boolean, indicating if the sncl element is inside of a macro
   -- @return The generated table
   makePresentationElement = function(str, sT, isMacroSon)
      return str / function(_type, id, ...)
         local tbl = {...}
         local element = {
            _type = _type,
            id = id,
            properties = {},
            sons = {},
            hasEnd = false,
            line = gbl.parserLine
         }

         if utils:isIdUsed(element.id, sT) then
            return nil
         end

         if element._type == 'region' then
            sT.head[element.id] = element
         --[[ If the element is a son of a macro, then it must not be inserted in the symbol table ]]
         elseif not isMacroSon then
            sT.presentation[element.id] = element
         end

         for _, val in pairs(tbl) do
            if type(val) == 'table' then
               if val._type == 'property' then
                  for name, value in pairs(val) do
                     -- TODO: dont add "line"
                     if isMacroSon then
                        element.properties[name] = value
                     else
                        if name == 'rg' then
                           if element.region then
                              utils.printErro(string.format('Region %s already declared', element.region), element.line)
                              return nil
                           end
                           element.region = value
                           element.descriptor = rS.makeDesc(value, sT)
                       else
                           utils:addProperty(element, name, value)
                        end
                     end
                  end
               else
                  table.insert(element.sons, val)
                  val.father = element
               end
            elseif val == 'end' then
               element.hasEnd = true
            end
         end

         return element
      end
   end,

   --- Parse the each condition and action
   -- @param str The return of lpeg
   -- @return The generated table
   makeRelationship = function(str)
      return str / function(rl, cp, iface)
         local element = {
            role = rl,
            component = cp,
            interface = iface,
            line = gbl.parserLine
         }
         return element
      end
   end,

   --- Join the conditions and actions that are linked by "and"
   -- @param str The return of lpeg
   -- @param _type The type of the bind, can be an action or a condition
   -- @return The generated table
   makeBind = function(str, _type)
      return str / function(...)
         local tbl = {...}
         local element = {
            _type = _type,
            properties = {},
            line = gbl.parserLine,
            hasEnd = false
         }

         for _, val in pairs(tbl) do
            if type(val) == 'table' then
               if val._type == 'property' then
                  for name, value in pairs(val) do
                     utils:addProperty(element, name, value)
                  end
               else
                  element.role = val.role
                  element.component = val.component
                  if val.interface then
                     if lpeg.match(utils.checks.buttons, val.interface) and val._type == 'condition' then
                        element.properties.__keyValue = val.interface
                     else
                        element.interface = val.interface
                     end
                  end
               end
            elseif val == 'end' then
               element.hasEnd = true
            end
         end

         return element
      end
   end,

   --- Generate a better formated table for the Link element
   -- @param str
   -- @param sT
   -- @return
   makeLink = function(str, sT, isMacroSon)
      return str / function(...)
         local tbl = {...}
         local element = {
            _type = 'link',
            conditions = {},
            actions = {},
            properties = {},
            line = gbl.parserLine,
            hasEnd = false
         }
         for _, val in pairs(tbl) do
            if type(val) == 'table' then
               if val._type == 'action' then
                  table.insert(element.actions, val)
               elseif val._type == 'condition' then
                  if not element.conditions then
                     element.conditions = {}
                  end
                  table.insert(element.conditions, val)
               else
                  for name, value in pairs(val) do
                     utils:addProperty(element, name, value)
                  end
               end
            elseif val == 'end' then
               element.hasEnd = true
            end
         end

         if not isMacroSon then
            table.insert(sT.presentation, element)
         end
         element.xconnector = rS:makeConn(element, sT)
         return element
      end
   end,

   -- TODO: Propriedades de uma macro devem ser propriedades
   -- do elemento em q a macro foi chamada

   --- Generates a better formated table for the Macro element
   -- @param str
   -- @param sT
   -- @return
   makeMacro = function(str, sT)
      return str / function(id, ...)
         local tbl = {...}
         local element = {
            _type = 'macro',
            id = id,
            properties = {},
            sons = {},
            parameters = {},
            hasEnd = false,
            line = gbl.parserLine
         }

         if utils:isIdUsed(element.id, sT) then
            return nil
         end

         sT.macro[element.id] = element

         for _, val in pairs(tbl) do
            if type(val) == 'table' then
               if val.parameters then -- If val is the parameter table
                  element.parameters = val.parameters
               else -- If val is the sons
                  table.insert(element.sons, val)
                  val.father = element
               end
            elseif val == 'end' then
               element.hasEnd = true
            end
         end

         return element
      end
   end,

   --- Generate a better formated table for the Macro Call element
   -- @param str
   -- @param sT
   -- @return
   makeMacroCall = function(str, sT)
      return str / function(mc, args)
         local element = {
            _type = 'macro-call',
            macro = mc,
            arguments = args,
            line = gbl.parserLine
         }
         table.insert(sT.macroCall, element)
         return element
      end
   end,

   --- Generate a better formated table for the Template element
   -- @param str
   -- @param sT
   -- @return
   makeTemplate = function(str, sT)
      return str / function(iterator, start, class, ...)
         local tbl = {...}
         local element = {
            _type = 'for',
            iterator = iterator,
            start = start,
            class = class,
            sons = {},
            line = gbl.parserLine-1
         }

         for _, val in pairs(tbl) do
            if val._type == 'macro-call' then
               val.father = element
               table.insert(element.sons, val)
            end
         end

         table.insert(sT.template, element)
         return element
      end
   end
}

return parsingTable
