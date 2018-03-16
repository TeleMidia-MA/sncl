local utils = require("utils")
local action = {}
local Action = {}

--[[
-- action<string> -> 
-- component<string> ->
-- interface<string> ->
-- properties<> ->
-- variable<> ->
-- line<int> -> The line that the action is declared
-- father<string> -> The Link that is father of the action
-- hasEnd<bool> -> If the sncl element has the "end"
--]]
function action.new (action, component, interface, line)
   local self = {
      action = action,
      component = component,
      interface = interface,
      line = line,
      properties = {},
      _type = "action",
   }
   setmetatable(self, {__index= Action})
   return self
end

function Action:getAction() return self.action end

function Action:addProperty (name, value)
   value = value:gsub("\"", "") -- Remove ""
   self.properties[name] = value
end

function Action:check()
   -- Check if the component points to an element that was declared
   if symbolTable[self.component] then
      self.component = symbolTable[self.component]
   else
      utils.printErro("Element "..self.component.." not declared", self.line)
      return ""
   end

   if not self.hasEnd then
      utils.printErro("Element Action does not have end", self.line)
      return ""
   end

   -- The component cannot be a region
   if self.component._type == "region" then
      utils.printErro("Element "..self.component.id.." invalid in this context", self.line)
      return ""
   end

   -- Check if is a valid action property
   for pos,_ in pairs(self.properties) do
      if not lpegMatch(dataType.actionProperties, pos) then
         utils.printErro("Invalid property "..pos.." in Action")
         return ""
      end
   end

   --[[ If the action has an interface, check if it's correct
      The component must have the interface, or the component must refer to an element
      that has the interface ]]
   if self.interface then
      -- If the component don't have that interface, the action cannot point to it
      if not (self.component:getSon(self.interface) or self.component:getProperty(self.interface)) then
         utils.printErro("Invalid interface "..self.interface.." of element "..self.component.id, self.line)
         return ""
      end
      -- If the component is a reference, check if the reference has the interface

      --[[
      if self.component.refer then
         local refer = self.component.refer
         local referredMedia = symbolTable[refer.media]
         if referredMedia then
            if not (referredMedia:getSon(self.interface) and 
               self.component:getSon(self.interface)) then
               utils.printErro("Invalid interface "..self.interface.." of element "..self.component, self.line)
               return ""
            end
         else
            utils.printErro("Element "..self.interface.." not declared.", self.line)
            return ""
         end
      end
      ]]
   end

   --[[ If the component has a father, then the father of the Link must be the same
   --as the father of the component ]]
   if self.component.father then
      -- If the Father of the Link is different from the father of the component
      if self.father.father ~= self.component.father then
         utils.printErro("Invalid element "..self.component.id.." in the context", self.line)
         return ""
      end
   else
      -- If the component don't have a father, then the Link can't have one either
      if self.father.father then
         utils.printErro("Invalid element "..self.component.id.." in the context", self.line)
         return ""
      end
   end
end

function Action:toNCL(indent)
   local NCL = indent.."<bind role=\""..self.action.."\" component=\""..self.component.id.."\""
   if self.interface then
      NCL = NCL.." interface=\""..self.interface.."\""
   end
   NCL = NCL..">"

   for pos, val in pairs(self.properties) do
      NCL = NCL..indent.."   <bindParam name=\""..pos.."\" value=\""..val.."\"/>"
   end

   NCL = NCL..indent.."</bind>"
   return NCL
end

function Action:parseProperty(str)
   local name, value = utils.splitSymbol(str, ":")

   if name and value then
      self.properties[name] = value
   end
end

return action
