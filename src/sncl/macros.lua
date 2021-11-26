local lpeg = require('lpeg')
local utils = require('sncl.utils')
local ins = require('sncl.inspect')

local resolveMacros = {

   --- Resolve the properties of an element that is being generated by a macro
   -- Check if the property is a parameter, if it is then the value of the
   -- property is the value that is being passed by the call. If it is not,
   -- then the value is the value that is in the macro
   -- @param ele The macro-son element
   -- @param newEle The element that is being generated
   -- @param call The call
   elementProperties = function(ele, newEle, call, sT)
      for name, value in pairs(ele.properties) do
         --[[ If the property is a parameter ]]
         local parameters = sT.macro[call.macro].parameters
         if utils.containValue(parameters, value) then
            local index = utils.getIndex(parameters, value)
            utils:addProperty(newEle, name, call.arguments[index])
         else
            utils:addProperty(newEle, name, value)
         end
      end
   end

}

--- Generate the elements of the macro that are presentation ones
-- Receives the presentation element that is inside the macro
-- and the call, and then makes the generates presentation
-- @param ele The element that is inside the macro
-- @param call The call to the macro
-- @param stack The stack of calls
-- @param sT The symbol table
function resolveMacros:presentation(ele, call, stack, sT)
   local newEle = {
      id = ele.id,
      _type = ele._type,
      properties = {},
      children = {},
      line = call.line
   }

   local parameters = sT.macro[call.macro].parameters
   if ele._type == 'port' then
      newEle.component = self.getArgument(call.arguments, parameters, ele.component)
   end

   local newId = self.getArgument(call.arguments, parameters, ele.id)
   --[[ Check is an element with the same Id is already declared ]]
   if sT.presentation[newId] then
      utils.printErro(string.format('Id %s already declared.', newId), call.line)
      return nil
   end
   newId = newId:gsub('"', '') -- Remove "", because the argument has ""
   newEle.id = newId

   if ele.properties then
      self.elementProperties(ele, newEle, call, sT)
   end

   sT.presentation[newEle.id] = newEle

   if ele.children then
      for _, son in pairs(ele.children) do
         if son._type == 'link' then
            local newLink = self:link(son, call, sT)
            if newLink then
               table.insert(newEle.children, newLink)
               newLink.father = newEle
            end
         elseif son._type == 'macro-call' then
            self:aux(son, stack, sT)
         else
            local newSon = self:presentation(son, call, stack, sT)
            if newSon then
               newEle.children[newSon.id] = newSon
               newSon.father = newEle
            end
         end
      end
   end

   if call.father then
      if call.father._type == 'for' then
         -- If the call is inside a for, then the father of the element is the father of the for
         newEle.father = call.father.father
      else
         newEle.father = call.father
      end
      if newEle.father then
         newEle.father.children[newEle.id] = newEle
      end
   end

   return newEle
end

--- Checks if a value inside a macro is a parameter of the macro.
-- This function checks if a value inside a macro is a parameter of a macro.
-- If it is, then the value is actually the argument of the call that corresponds
-- to the parameter.
-- Else, then the value is the value itself
-- @param arguments
-- @param parameters
-- @param argument
function resolveMacros.getArgument(arguments, parameters, value)
   if utils.containValue(parameters, value) then
      return arguments[utils.getIndex(parameters, value)]
   end
   return value
end

--- Generates a <bind> element of a <link> element
-- @param bind
-- @param call
-- @param sT
function resolveMacros:bind(bind, call, sT)
   local newBind = {
      _type = bind._type,
      role = bind.role,
      component = bind.component,
      interface = bind.interface,
      properties = {},
      line = call.line
   }
   local macro = sT.macro[call.macro]

   newBind.component = self.getArgument(call.arguments, macro.parameters, bind.component)
   newBind.interface = self.getArgument(call.arguments, macro.parameters, bind.interface)
   if newBind.interface then
      if lpeg.match(utils.checks.buttons, newBind.interface) then
         newBind.properties.__keyValue = newBind.interface
         newBind.interface = nil
      end
   end

   for name, value in pairs(bind.properties) do
      newBind.properties[name] = self.getAgument(macro.parameters, value)
   end

   return newBind
end

--- Generates a <link> element
-- @param ele
-- @param call
-- @param sT
function resolveMacros:link(ele, call, sT)
   local newEle = {
      _type = ele._type,
      xconnector = ele.xconnector,
      properties = {},
      actions = {},
      conditions = {},
      line = call.line
   }

   local macro = sT.macro[call.macro]

   for _, action in pairs(ele.actions) do
      local newAction = self:bind(action, call, sT)
      newAction.father = newEle
      table.insert(newEle.actions, newAction)
   end

   for _, condition in pairs(ele.conditions) do
      local newCond = self:bind(condition, call, sT)
      newCond.father = newEle
      table.insert(newEle.conditions, newCond)
   end

   for name, value in pairs(ele.properties) do
      newEle.properties[name] = self.getArgument(call.arguments, macro.parameters, value)
   end

   return newEle
end

--- An auxiliary function, necessary because a macro can have calls
-- inside of it, so a stack of calls is necessary. This function is called
-- everytime a call is processed, so all the generated elements that it
-- returns can be inserted inside of the macro, or the call.
-- @param call
-- @param stack
-- @param sT
function resolveMacros:aux(call, stack, sT)
   local newEles = {}

   local macro = sT.macro[call.macro]
   table.insert(stack, call)
   for _, son in pairs(macro.children) do
      if son._type == 'link' then
         local newLink = self:link(son, call, sT)
         table.insert(newLink)
         -- resolveLinkMacro
      else
         local newPres = self:presentation(son, call, stack, sT)
         newEles[newPres.id] = newPres
      end
      -- TODO: The son can also be a property, or a macro-call
   end
   table.remove(stack)

   return newEles
end

--- Resolve the call, generating an element
-- @param call The call element itself
-- @param stack The stack of calls
-- @param sT The symbol table
function resolveMacros:call(call, stack, sT)
   local macro = sT.macro[call.macro]
   local abv = stack[#stack]

   --[[ If the called macro is not declared ]]
   if not macro then
      utils.printErro(string.format("Macro %s not declared.", call.macro), call.line)
      return nil
   end

   --[[ Check if the call has the same number of arguments as
      specified in the called macro --]]
   if #macro.parameters ~= #call.arguments then
      if call.father then
         --[[ But if the call is inside a template, then the element in
            the padding document must have the same number of properties as
            the number of arguments of the macro --]]
         if call.father._type ~= 'for' then
            utils.printErro('Wrong number of arguments.', call.line)
            return nil
         end
      else
         utils.printErro('Wrong number of arguments.', call.line)
         return nil
      end
   end

   --[[If the argument has "", then it is being passed by the call
      else, then the call is inside a macro, and the argument of the call is
      a parameter of the macro]]
   for p, val in pairs(call.arguments) do
      if val:match("\"*\"") then
         call.arguments[p] = val
      else
         if abv then
            --[[ Check if the macro really has the argument as a parameter
               If it does, then the call must pass the value of the argument
               is what is being passed to the macro that the call is inside]]
            if utils.containValue(sT.macro[abv.macro].parameters, val) then
               local index = utils.getIndex(sT.macro[abv.macro].parameters, val)
               call.arguments[p] = abv.arguments[index]
            else
               utils.printErro(string.format('Argument %s is not a parameter of a macro.',
                  val), call.line)
               return nil
            end
         else
            utils.printErro(string.format('Argument %s invalid.', val), call.line)
            return nil
         end
      end
   end
   self:aux(call, stack, sT)

end

return resolveMacros