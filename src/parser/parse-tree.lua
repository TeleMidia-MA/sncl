local ins = require('inspect')
local utils = require('utils')
local gbl = require('globals')
local rS = require('resolve')

local parsingTable = {
   parsePort = function(str, sT)
      return str / function(id, comp, iface)
         local element = {
            _type = "port", 
            id = id,
            component = comp,
            interface = iface,
            line = gbl.parserLine
         }

         if utils.isIdUsed(element.id, sT) then
            return nil
         end

         sT.presentation[id] = element
         return element
      end
   end,

   parseProperty = function(str)
      return str / function(name, value)
         return {
            _type = "property",
            [name] = value,
            line = gbl.parseLine
         }
      end
   end,

   parsePresentationElement = function(str, sT, isMacroSon)
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

         if utils.isIdUsed(element.id, sT) then
            return nil
         end

         if element._type == "region" then
            sT.head[element.id] = element
         elseif not isMacroSon then
            sT.presentation[element.id] = element
         end

         -- Se for uma tabela, ou é uma propriedade ou é um elemento filho
         for pos, val in pairs(tbl) do
            if type(val) == 'table' then
               if val._type == 'property' then
                  for name, value in pairs(val) do
                     -- TODO: dont add "line"
                     if isMacroSon then
                        element.properties[name] = value
                     else
                        if name == 'rg' then
                           if element.region then
                              utils.printErro(string.format("Region %s already declared", element.region))
                           end
                           element.region = value
                           element.descriptor = '__desc'..value
                           rS.makeDesc(element.descriptor, value, sT)
                        else
                           utils.addProperty(element, name, value)
                        end
                     end
                  end
               else
                  table.insert(element.sons, val)
                  val.father = element
               end
            elseif val == "end" then
               element.hasEnd = true
            end
         end

         return element
      end
   end,

   -- parse the each condition and action
   parseRelationship = function(str)
      return str / function(rl, cp, iface, ...)
         local element = {
            role = rl,
            component = cp,
            interface = iface,
            line = gbl.parserLine
         }
         return element
      end
   end,

   -- Join the conditions and actions that are linked by "and"
   parseBind = function(str, _type)
      return str / function(...)
         local tbl = {...}
         local element = {
            _type = _type,
            line = gbl.parserLine,
            hasEnd = false
         }

         for pos, val in pairs(tbl) do
            if type(val) == "table" then
               if val._type == "property" then
                  if not element.properties then
                     element.properties = {}
                  end
                  for name, value in pairs(val) do
                     utils.addProperty(element, name, value)
                  end
               else
                  element.role = val.role
                  element.component = val.component
                  if val.interface then
                     if lpeg.match(Buttons, val.interface) and _type=="condition" then
                        element.properties = {__keyValue=val.interface}
                     else
                        element.interface = val.interface
                     end
                  end
               end
            elseif val == "end" then
               element.hasEnd = true
            end
         end

         return element
      end
   end,

   parseLink = function(str)
      return str / function(...)
         local tbl = {...}
         local element = {
            _type="link",
            line = gbl.parserLine,
            hasEnd = false
         }
         for pos, val in pairs(tbl) do
            if type(val) == "table" then
               if val._type == "action" then
                  if not element.actions then
                     element.actions = {}
                  end
                  table.insert(element.actions, val)
               elseif val._type == "condition" then
                  if not element.conditions then
                     element.conditions = {}
                  end
                  table.insert(element.conditions, val)
               else
                  if not element.properties then
                     element.properties = {}
                  end
                  for name, value in pairs(val) do
                     utils.addProperty(element, name, value)
                  end
               end
            elseif val == "end" then
               element.hasEnd = true
            end
         end
         table.insert(sT.link, element)
         return element
      end
   end,

   -- TODO: Propriedades de uma macro devem ser propriedades
   -- do elemento em q a macro foi chamada
   parseMacro = function(str, sT)
      return str / function(id, ...)
         local tbl = {...}
         local element = {
            _type="macro",
            id = id,
            properties = {},
            sons = {},
            hasEnd = false,
            line = gbl.parserLine
         }

         if utils.isIdUsed(element.id, sT) then
            return nil
         end

         sT.macro[element.id] = element

         for _, val in pairs(tbl) do
            if type(val) == 'table' then
               if val.parameters then -- If val is the parameter table 
                  element.parameters = val.parameters
               else -- If val is the sons
                  if not element.sons then
                     element.sons = {}
                  end
                  table.insert(element.sons, val)
                  val.father = element
               end
            elseif val == "end" then
               element.hasEnd = true
            end
         end

         return element
      end
   end,

   parseMacroCall = function(str, sT)
      return str / function(mc, args, ...)
         local element = {
            _type = "macro-call",
            macro = mc,
            arguments = args,
            line = gbl.parserLine
         }
         table.insert(sT.macroCall, element)
         return element
      end
   end,

   parseTemplate = function(str, sT)
      return str / function(iterator, start, class, ...)
         local tbl = {...}
         local element = {
            _type = "for",
            iterator = iterator,
            start = start,
            class = class,
            sons = {},
            line = gbl.parserLine-1
         }

         for _, val in pairs(tbl) do
            if val._type == "macro-call" then
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
