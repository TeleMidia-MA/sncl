local ins = require"inspect"
local utils = require"utils"
local lpeg = require"lpeg"
local gbl = utils.globals

local R, P = lpeg.R, lpeg.P

local parsingTable = {
   parsePort = function(str)
      return str / function(id, comp, iface)
         local element = {
            _type = "port", 
            id = id,
            component = comp,
            interface = iface,
            line = gbl.parserLine
         }
         if gbl.presentationTbl[id] then
            utils.printErr("Id "..id.." already declared")
            return nil
         end
         gbl.presentationTbl[id] = element
         return element
      end
   end,

   parseProperty = function(str)
      return str / function(name, value)
         return {_type="property", [name]=value, }
      end
   end,

   parsePresentationElement = function(str, isMacroSon)
      return str / function(_type, id, ...)
         local tb = {...}
         local element = {
            _type=_type, id=id, 
            properties = {},
            sons = {},
            hasEnd = false,
            line = gbl.parserLine-1
         }

         if gbl.presentationTbl[element.id] or gbl.macroTbl[element.id] or gbl.headTbl[element.id]then
            utils.printErro("Id "..element.id.." already declared")
            return nil
         end

         if element._type == "region" then
            gbl.headTbl[element.id] = element
         elseif not isMacroSon then
            gbl.presentationTbl[element.id] = element
         end

         -- Se for uma tabela, ou é uma propriedade ou é um elemento filho
         for pos, val in pairs(tb) do
            if type(val) == 'table' then
               if val._type == 'property' then
                  for name, value in pairs(val) do
                     if isMacroSon then
                        element.properties[name] = value
                     else
                        utils.addProperty(element, name, value)
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
            interface=iface,
            line=gbl.parserLine
         }
         return element
      end
   end,

   -- Join the conditions and actions that are linked by "and"
   parseBind = function(str, _type)
      return str / function(...)
         local tb = {...}
         local element = {
            _type = _type,
            line = gbl.parserLine,
            hasEnd = false
         }

         for pos, val in pairs(tb) do
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
         local tb = {...}
         local element = {
            _type="link",
            line = gbl.parserLine,
            hasEnd = false
         }
         for pos, val in pairs(tb) do
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
         table.insert(gbl.linkTbl, element)
         return element
      end
   end,

   parseMacro = function(str)
      return str / function(id, ...)
         local tbl = {...}
         local element = {
            id = id, _type="macro", sons={}, hasEnd = false,
            line = gbl.parserLine
         }

         if (gbl.presentationTbl[element.id] or gbl.macroTbl[element.id]) then
            utils.printErro("Id "..element.id.." alreadt declared")
            return nil
         end
         gbl.macroTbl[element.id] = element

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

   parseMacroCall = function(str)
      return str / function(mc, args, ...)
         local element = {
            _type = "macro-call",
            macro = mc,
            arguments = args,
            line = gbl.parserLine
         }
         table.insert(gblMacroCallTbl, element)
         return element
      end
   end,

   parseTemplate = function(str)
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

         table.insert(gbl.templateTbl, element)
         return element
      end
   end
}
return parsingTable

