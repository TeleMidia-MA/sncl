local utils = require"utils"
local ins = require"inspect"
local lpeg = require"lpeg"
local pT = require"parse-tree"

function resolveMacroPresentationSon(element, macro, call)
   local newEle = {_type = element._type, father = call.father, descriptor=element.descriptor, type=element.type, properties = {}, sons={}, }
   -- If the Id is a parameter, a new element have to be created
   if utils.containValue(macro.parameters, element.id) then
      newEle.id = call.arguments[utils.getIndex(macro.parameters, element.id)]
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
            pT.addProperty(newEle, name, call.arguments[utils.getIndex(macro.parameters, value)])
         else
            pT.addProperty(newEle, name, value)
         end
      end
   end
   if call.father then
      call.father.sons[newEle.id] = newEle
   end
   return newEle
end

function resolveMacroLinkSon(son, macro, call)
   local newEle = {_type="link", actions={}, conditions={}}

   for _, act in pairs(son.actions) do
      local newAct = {_type="action"}
      newAct.role = act.role
      if utils.containValue(macro.parameters, act.component) then
         newAct.component = call.arguments[utils.getIndex(macro.parameters, act.component)]
      else
         newAct.component = act.component
      end
      if act.interface then
         if utils.containValue(macro.parameters, act.interface) then
            newAct.interface = call.arguments[utils.getIndex(macro.parameters, act.interface)]
         else
            newAct.interface = act.interface
         end
      end
      if act.properties then
         newAct.properties = {}
         for name, value in pairs(act.properties) do
            -- TODO: Check if the name is a parameter?
            if utils.containValue(macro.parameters, value) then
               newAct.properties[name] = call.arguments[utils.getIndex(macro.parameters, value)]
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
         newCond.component = call.arguments[utils.getIndex(macro.parameters, cond.component)]
      else
         newCond.component = cond.component
      end
      -- TODO: BUTTONS
      if cond.interface then
         if utils.containValue(macro.parameters, cond.interface) then
            newCond.interface = call.arguments[utils.getIndex(macro.parameters, cond.interface)]
         else
            newCond.interface = cond.interface
         end
         if lpeg.match(Buttons, newCond.interface) then
            newCond.properties = {__keyValue=newCond.interface}
            newCond.interface = nil
         end
      end
      table.insert(newEle.conditions, newCond)
   end

   if son.properties then
      newEle.properties = {}
      for name, value in pairs(son.properties) do
         -- TODO: Check if the name is a parameter?
         if utils.containValue(macro.parameters, value) then
            newEle.properties[name] = call.arguments[utils.getIndex(macro.parameters, value)]
         else
            newEle.properties[name] = value
         end
      end
   end
   table.insert(gblLinkTbl, newEle)

end
function resolveMacro(macro, call)
   for _, son in pairs(macro.sons) do
      if son._type== "link" then
         resolveMacroLinkSon(son, macro, call)
      else
         resolveMacroPresentationSon(son, macro, call)
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
      resolveMacro(macro, call)
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

function resolveTemplate()
   for pos, val in pairs(gblTemplateTbl[1]) do
      if gblMacroTbl[pos] then
         local parameters = gblMacroTbl[pos].parameters
         for id, element in pairs(val) do
            local call = {_type="macro-call", macro=pos, arguments={}}
            call.arguments[utils.getIndex(parameters, "id")] = id
            for _, par in pairs(parameters) do
               if par ~= "id" then
                  call.arguments[utils.getIndex(parameters, par)] = element[par]
               end
            end
            table.insert(gblMacroCallTbl, call)
         end
      end
   end
end
