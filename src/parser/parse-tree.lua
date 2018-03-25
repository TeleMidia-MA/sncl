local ins = require"inspect"
local utils = require"utils"

local parseTree = {}

function parseTree.makeProperty(str)
   return str / function(name, value)
      return {_type="property",[name]=value}
   end
end

function parseTree.addProperties(element, properties)
   for name, val in pairs(properties) do
      if name ~="_type" then
         if element.properties[name] then
            utils.printErro("Property "..name.." already declared")
            return nil
         end
         element.properties[name] = val
      end
   end
end

function parseTree.makePresentationElement(str)
   return str / function(_type, id, ...)
      local tb = {...}
      local element = {_type=_type, id=id, hasEnd = false}

      if gblPresTbl[element.id] or gblMacroTbl[element.id] then
         utils.printErro("Id "..element.id.." already declared")
         return nil
      end
      gblPresTbl[element.id] = element

      for pos, val in pairs(tb) do
         if type(val) == 'table' then
            -- If val is a table, then it is either a son of the element or a
            -- property of the element
            if val._type == 'property' then
               if not element.properties then
                  element.properties = {}
               end
               parseTree.addProperties(element, val)
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

function parseTree.makeRelationship(str)
   return str/ function(rl, cp, iFace, ...)
      return {role=rl, component=cp, interface=iFace, ...}
   end
end

function parseTree.makeBind(str, _type)
   return str/function(...)
      local tb = {...}
      local element = {_type = _type, hasEnd = false}
      for pos, val in pairs(tb) do
         if type(val) == "table" then
            if val._type == "property" then
               if not element.properties then
                  element.properties = {}
               end
               parseTree.addProperties(element, val)
            else
               element.role = val.role
               element.component = val.component
               element.interface = val.interface
            end
         elseif val == "end" then
            element.hasEnd = true
         end
      end
      return element
   end
end


function parseTree.makeLink(str)
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
               parseTree.addProperties(element, val)

            end
         elseif val == "end" then
            element.hasEnd = true
         end
      end
      table.insert(gblLinkTbl, element)
      return element
   end
end

function parseTree.makeMacroPresentationSon(str)
   return str / function(_type, id, ...)
      local tb = {...}
      local element = {_type=_type, id=id, hasEnd = false}
      for pos, val in pairs(tb) do
         if type(val) == 'table' then
            -- If val is a table, then it is either a son of the element or a
            -- property of the element
            if val._type == 'property' then
               if not element.properties then
                  element.properties = {}
               end
               parseTree.addProperties(element, val)
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
function parseTree.makeMacroLinkSon(str)
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
function parseTree.makeMacro(str)
   return str/function(id, ...)
      local tb = {...}
      local element = {id = id, _type="macro", sons={}, hasEnd = false}

      if (gblPresTbl[element.id] or gblMacroTbl[element.id]) then
         utils.printErro("Id "..element.id.." alreadt declared")
         return nil
      end
      gblMacroTbl[element.id] = element

      for pos, val in pairs(tb) do
         if type(val) == 'table' then
            if val.parameters then -- If it is the parameters table
               element.parameters = val.parameters
            else -- If it is the elements in the macro body
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

function parseTree.makeMacroCall(str)
   return str/function(mc, args, ...)
      local tb = {macro = mc, arguments = args}
      table.insert(gblMacroCallTbl, tb)
   end
end

return parseTree
