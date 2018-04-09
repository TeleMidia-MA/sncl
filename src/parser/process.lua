local utils = require"utils"
local ins = require"inspect"
local lpeg = require"lpeg"
local pT = require"parse-tree"

function resolveMacroPresentationSon(element, macro, call)
   local newEle = {_type = element._type, region = element.region, father = call.father, descriptor=element.descriptor, properties = {}, sons={}}
--, type=element.type, 
   -- Se o Id é um parametro
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

   -- O novo elemento vai ser filho do elemento que tem a macro
   if call.father then
      if utils.isMacroSon(call.father) then
         print("É filho de macro")
      else
         call.father.sons[newEle.id] = newEle
      end
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
      if son._type == "link" then
         resolveMacroLinkSon(son, macro, call)
      else
         resolveMacroPresentationSon(son, macro, call)
      end
   end
end

function resolveMacroCalls(tbl)
   for _, call in pairs(tbl) do
      if call.father then
      else
         local macro = gblMacroTbl[call.macro]
         if not macro then
            utils.printErro("Macro "..call.macro.." not declared")
            return nil
         end
         -- TODO: Nao tem que checar se o pai é um for, e sim se o argumento é um indice
         if #macro.parameters ~= #call.arguments and call.father._type ~= "for" then
            utils.printErro("Wrong number of arguments on call "..macro.id)
            return nil
         end
         resolveMacro(macro, call)
      end
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

function resolveTemplates(input, tbl)
   for _, _for in pairs(tbl) do -- Cada 'val' é um for
      local class = _for.class
      local elements = {}
      for pos, ele in pairs(input) do -- Separar os elementos que tem a classe do for
         ele.id = pos
         if ele.class == _for.class then
            table.insert(elements, ele)
         end
      end
      for i = _for.start, #elements do
         local element = elements[i]
         for _, son in pairs(_for.sons) do -- Pra cada chamada de macro
            local macro = gblMacroTbl[son.macro]
            local parameters = macro.parameters
            local call = {_type="macro-call", macro=macro.id, arguments = {}, father = _for.father}
            for pos, val in pairs(element) do
               if utils.containValue(parameters, pos) then
                  call.arguments[utils.getIndex(parameters, pos)] = element[pos]
               end
            end
            resolveMacro(macro, call)
         end
      end
   end
end

