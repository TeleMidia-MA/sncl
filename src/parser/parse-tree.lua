local ins = require"inspect"
local utils = require"utils"
local lpeg = require"lpeg"
local pT = {}

local R, P = lpeg.R, lpeg.P

function pT.makePort(str)
   return str / function(id, comp, iface)
      local element = {_type="port", id=id, component=comp, interface = iface}
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
      return {_type="property",[name]=value}
   end
end

function pT.makeDesc(id, region)
   gblHeadTbl[id] = {
      _type="descriptor",
      region=region,
      id = id
   }
end

function pT.addProperty(element, name, value)
   if name ~="_type" then
      if element.properties[name] then
         utils.printErro("Property "..name.." already declared")
         return nil
      else
         --[[ If the name of the property is "rg", it is a region
            Then the descriptor property must be added and
            the descriptor element that links the media and the region
            must be created --]]
         if name == "rg" then
            if element._region then
               utils.printErro("Region "..value.." already declared")
               return nil
            end
            element._region = value
            element.descriptor = "__desc"..value
            pT.makeDesc(element.descriptor, value)
            -- It it's not a region, then just add it
         elseif name=="src" then
            element.src = value
         elseif name=="type" then
            element.type = value
         else
            element.properties[name] = value
         end
      end
   end
end

function pT.makePresentationElement(str)
   return str / function(_type, id, ...)
      local tb = {...}
      local element = {_type=_type, id=id, hasEnd = false}

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
                  pT.addProperty(element, name, value)
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

      return element
   end
end

-- Make the each condition and action
function pT.makeRelationship(str)
   return str/ function(rl, cp, iface, ...)
      local element = {role = rl, component = cp, interface=iface,...}
      return element
   end
end

-- Join the conditions and actions that are linked by "and"
function pT.makeBind(str, _type)
   return str/function(...)
      local tb = {...}
      local element = {_type = _type, hasEnd = false}
      for pos, val in pairs(tb) do
         if type(val) == "table" then
            if val._type == "property" then
               if not element.properties then
                  element.properties = {}
               end
               for name, value in pairs(val) do
                  pT.addProperty(element, name, value)
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
      local element = {_type="link", hasEnd = false}
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
                  pT.addProperty(element, name, value)
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

function pT.makeMacroPresentationSon(str)
   return str / function(_type, id, ...)
      local tb = {...}
      local element = {_type=_type, id=id, sons = {}, hasEnd = false}
      for pos, val in pairs(tb) do
         if type(val) == 'table' then
            -- If val is a table, then it is either a son of the element or a
            -- property of the element
            if val._type == 'property' then
               if not element.properties then
                  element.properties = {}
               end
               for name, value in pairs(val) do
                  element.properties[name] = value
               end
               -- If it is not a property, it is an element that is a son
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
end

function pT.makeMacroLinkSon(str)
   return str/function(...)
      local tb = {...}
      local element = {_type="link", hasEnd = false}
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
                  if name ~= "_type" then
                     if element.properties[name] then
                        utils.printErro("Property "..name.." already declared")
                        return nil
                     end
                     element.properties[name] = value
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

function pT.makeMacro(str)
   return str/function(id, ...)
      local tb = {...}
      local element = {id = id, _type="macro", sons={}, hasEnd = false}

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
      local tb = {_type="macro-call", macro = mc, arguments = args, ...}
      table.insert(gblMacroCallTbl, tb)
      return tb
   end
end

function pT.makeTemplate(str)
   return str/function(iterator, start, class, ...)
      local tbl = {...}
      local element = {_type="for", iterator=iterator, start=start, class=class, sons = {} }
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

