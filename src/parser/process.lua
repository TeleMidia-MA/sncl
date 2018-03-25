local utils = require"utils"
local ins = require"inspect"

function containValue(tbl, arg)
   for _, val in pairs(tbl) do
      if val == arg then
         return true
      end
   end
   return false
end

function getIndex(tbl, arg)
   for pos, val in pairs(tbl) do
      if val == arg then
         return pos
      end
   end
   return nil
end

function resolveMacroPresentationSon(element, macro, arguments)
   local newEle = {properties = {}, sons={}}
   -- If the Id is a parameter, a new element have to be created
   if containValue(macro.parameters, element.id) then
      newEle.id = arguments[getIndex(macro.parameters, element.id)]
   else
      newEle.id = element.id
   end

   if gblPresTbl[newEle.id] then
      utils.printErro("Id "..newEle.id.." already declared")
      return nil
   end
   gblPresTbl[newEle.id] = newEle
   if element.properties then
      for name, value in pairs(element.properties) do
         -- If a property is a parameter, create the property
         -- with the new value
         if containValue(macro.parameters, name) then
            newEle.properties[name] = arguments[getIndex(macro.parameters, name)]
         end
      end
   end
   if element.sons then
      for _, son in pairs(element.sons) do
         local newSon = resolveMacroSon(son, macro, arguments)
         newSon.father = newEle
         table.insert(newEle.sons, newSon)
      end
   end
   newEle._type = element._type
   return newEle
end

function resolveMacroLinkSon(son, macro, args)
   local newEle = {_type="link", actions={}, conditions={}}

   for _, act in pairs(son.actions) do
      local newAct = {}
      newAct.role = act.role
      if containValue(macro.parameters, act.component) then
         newAct.component = args[getIndex(macro.parameters, act.component)]
      else
         newAct.component = act.component
      end
      if act.properties then
         newAct.properties = {}
         for name, value in pairs(act.properties) do
            -- TODO: Check if the name is a parameter?
            if containValue(macro.parameters, value) then
               newAct.properties[name] = args[getIndex(macro.parameters, value)]
            else
               newAct.properties[name] = value
            end
         end
      end
      table.insert(newEle.actions, newAct)
   end

   for _, cond in pairs(son.conditions) do
      local newCond = {}
      newCond.role = cond.role
      if containValue(macro.parameters, cond.component) then
         newCond.component = args[getIndex(macro.parameters, cond.component)]
      else
         newCond.component = cond.component
      end
      table.insert(newEle.conditions, newCond)
   end

   if son.properties then
      newEle.properties = {}
      for name, value in pairs(son.properties) do
         -- TODO: Check if the name is a parameter?
         if containValue(macro.parameters, value) then
            newEle.properties[name] = args[getIndex(macro.parameters, value)]
         else
            newEle.properties[name] = value
         end
      end
   end
   table.insert(gblLinkTbl, newEle)
end
function resolveMacro(macro, arguments)
   for _, son in pairs(macro.sons) do
      if son._type== "link" then
         resolveMacroLinkSon(son, macro, arguments)
      else
         resolveMacroPresentationSon(son, macro, arguments)
      end
   end
end

function resolveMacroCalls(tbl)
   for _, call in pairs(tbl) do
      local macro = gblMacroTbl[call.macro]
      if not macro then
         utils.printErro("Macro "..call.macro.." not declared")
         return nil
      end
      if #macro.parameters ~= #call.arguments then
         utils.printErro("Wrong number of arguments on call "..macro.id)
         return nil
      end
      resolveMacro(macro, call.arguments)
   end
end

function resolveXConnectors(tbl)
   for _, link in pairs(tbl) do
      local newConn = {_type="xconnector", conditions = {}, actions = {}, properties={}}
      local connId = "_"
      for _, cond in pairs(link.conditions) do
         if newConn.conditions[cond.role] then
            newConn.conditions[cond.role] = newConn.conditions[role]+1
         else
            newConn.conditions[cond.role] = 1
         end
         if connId:find(cond.role:gsub("^%l",string.upper)) then
            connId = connId.."N"
         else
            connId = connId..cond.role:gsub("^%l",string.upper)
         end
      end
      for _, act in pairs(link.actions) do
         if newConn.actions[act.role] then
            newConn.actions[act.role] = newConn.actions[act.role]+1
         else
            newConn.actions[act.role] = 1
         end
         if connId:find(act.role:gsub("^%l",string.upper)) then
            connId = connId.."N"
         else
            connId = connId..act.role:gsub("^%l",string.upper)
         end
         if act.properties then
            for name, _ in pairs(act.properties) do
               table.insert(newConn.properties, name)
            end
         end
      end
      if link.properties then
         for name, _ in pairs(link.properties) do
            table.insert(newConn.properties, name)
         end
      end
      -- TODO: Has to do all above to check if another equal
      -- connect is already created, wasting time. How to fix?
      newConn.id = connId.."_"
      link.xconnector = newConn.id
      if not gblHeadTbl[newConn.id] then
         gblHeadTbl[newConn.id] = newConn
      end
   end
end
