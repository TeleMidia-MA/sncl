local ins = require"inspect"
local utils = require"utils"
local lpeg = require"lpeg"
local pT = {}

local R, P = lpeg.R, lpeg.P

function pT.makePort(str)
   return str / function(id, comp, iface)
      local element = {
         _type="port", id=id, component=comp, interface = iface, line=gblParserLine-1
      }
      if gblPresTbl[id] then
         utils.printErr("Id "..id.." already declared")
         return nil
      end
      gblPresTbl[id] = element
      return element
   end
end

function pT.makeProperty(str)
   return str / function(name, value)
      return {_type="property",[name]=value, }
   end
end


function pT.makePresentationElement(str, isMacroSon)
   return str / function(_type, id, ...)
      local tb = {...}
      print("tb:", ins.inspect(tb))
      local element = {
         _type=_type, id=id, hasEnd = false, line = gblParserLine-1
      }

      if gblPresTbl[element.id] or gblMacroTbl[element.id] or gblHeadTbl[element.id ]then
         utils.printErro("Id "..element.id.." already declared")
         return nil
      end

      if element._type == "region" then
         gblHeadTbl[element.id] = element
      else
         gblPresTbl[element.id] = element
      end

      for pos, val in pairs(tb) do
         if type(val) == 'table' then
            -- If val is a table, then it is either a son of the element or a
            -- property of the element
            if val._type == 'property' then
               if not element.properties then
                  element.properties = {}
               end
               for name, value in pairs(val) do
                  utils.addProperty(element, name, value)
               end
               -- If it is not a property, it is an element that is a son
            else
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

      print("ele:", ins.inspect(element))
      return element
   end
end

-- Make the each condition and action
function pT.makeRelationship(str)
   return str/ function(rl, cp, iface, ...)
      local element = {
         role = rl, component = cp, interface=iface, line=gblParserLine
      }
      return element
   end
end

-- Join the conditions and actions that are linked by "and"
function pT.makeBind(str, _type)
   return str/function(...)
      local tb = {...}
      local element = {
         _type = _type, hasEnd = false, line=gblParserLine
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
end

function pT.makeLink(str)
   return str/function(...)
      local tb = {...}
      local element = {
         _type="link", hasEnd = false,
         line = gblParserLine
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
      table.insert(gblLinkTbl, element)
      return element
   end
end

function pT.makeMacro(str)
   return str/function(id, ...)
      local tb = {...}
      local element = {
         id = id, _type="macro", sons={}, hasEnd = false,
         line = gblParserLine
      }

      if (gblPresTbl[element.id] or gblMacroTbl[element.id]) then
         utils.printErro("Id "..element.id.." alreadt declared")
         return nil
      end
      gblMacroTbl[element.id] = element

      for _, val in pairs(tb) do
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
end

function pT.makeMacroCall(str)
   return str/function(mc, args, ...)
      local tb = {
         _type="macro-call", macro = mc, arguments = args, line = gblParserLine
      }
      table.insert(gblMacroCallTbl, tb)
      return tb
   end
end

function pT.makeTemplate(str)
   return str/function(iterator, start, class, ...)
      local tbl = {...}
      local element = {
         _type="for", iterator=iterator, start=start, class=class, sons = {}, line = gblParserLine-1
      }
      for pos, val in pairs(tbl) do
         if val._type == "macro-call" then
            val.father = element
            table.insert(element.sons, val)
         end
      end
      table.insert(gblTemplateTbl, element)
      return element
   end
end

return pT

