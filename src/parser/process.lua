local utils = require"utils"
local ins = require"inspect"

function resolveMacroPresentationSon(element, macro, arguments)
   local newEle = {properties = {}, sons={}}
   -- If the Id is a parameter, a new element have to be created
   if utils.containValue(macro.parameters, element.id) then
      newEle.id = arguments[utils.getIndex(macro.parameters, element.id)]
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
         if utils.containValue(macro.parameters, value) then
            newEle.properties[name] = arguments[utils.getIndex(macro.parameters, value)]
         else
            newEle.properties[name] = value
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
      local newAct = {_type="action"}
      newAct.role = act.role
      if utils.containValue(macro.parameters, act.component) then
         newAct.component = args[utils.getIndex(macro.parameters, act.component)]
      else
         newAct.component = act.component
      end
      if act.interface then
         if utils.containValue(macro.parameters, act.interface) then
            newAct.interface = args[utils.getIndex(macro.parameters, act.interface)]
         else
            newAct.interface = act.interface
         end
      end
      if act.properties then
         newAct.properties = {}
         for name, value in pairs(act.properties) do
            -- TODO: Check if the name is a parameter?
            if utils.containValue(macro.parameters, value) then
               newAct.properties[name] = args[utils.getIndex(macro.parameters, value)]
            else
               newAct.properties[name] = value
            end
         end
      end
      table.insert(newEle.actions, newAct)
   end

   for _, cond in pairs(son.conditions) do
      local newCond = {_type="condition"}
      newCond.role = cond.role
      if utils.containValue(macro.parameters, cond.component) then
         newCond.component = args[utils.getIndex(macro.parameters, cond.component)]
      else
         newCond.component = cond.component
      end
      -- TODO: BUTTONS
      if cond.interface then
         if utils.containValue(macro.parameters, cond.interface) then
            newCond.interface = args[utils.getIndex(macro.parameters, cond.interface)]
         else
            newCond.interface = cond.interface
         end
      end
      table.insert(newEle.conditions, newCond)
   end

   if son.properties then
      newEle.properties = {}
      for name, value in pairs(son.properties) do
         -- TODO: Check if the name is a parameter?
         if utils.containValue(macro.parameters, value) then
            newEle.properties[name] = args[utils.getIndex(macro.parameters, value)]
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

function resolveXConnectorBinds(xconn, bind)
   if xconn[bind._type][bind.role] then
      xconn[bind._type][bind.role] = xconn[bind._type][bind.role]+1
   else
      xconn[bind._type][bind.role] = 1
   end
   if xconn.id:find(bind.role:gsub("^%l",string.upper)) then
      xconn.id = xconn.id.."N"
   else
      xconn.id = xconn.id..bind.role:gsub("^%l",string.upper)
   end
   if bind.properties then
      for name, _ in pairs(bind.properties) do
         table.insert(xconn.properties, name)
      end
   end
end

function resolveXConnectors(tbl)
   for _, link in pairs(tbl) do
      local newConn = {_type="xconnector", id="__", condition = {}, action = {}, properties={}}

      for _, cond in pairs(link.conditions) do
         resolveXConnectorBinds(newConn, cond)
      end
      for _, act in pairs(link.actions) do
         resolveXConnectorBinds(newConn, act)
      end
      if link.properties then
         for name, _ in pairs(link.properties) do
            table.insert(newConn.properties, name)
         end
      end
      -- TODO: Has to do all above to check if another equal
      -- connect is already created, wasting time. How to fix?
      link.xconnector = newConn.id
      if not gblHeadTbl[newConn.id] then
         gblHeadTbl[newConn.id] = newConn
      end
   end
end
