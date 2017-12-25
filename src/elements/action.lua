local utils = require("utils")

local action = {}
local Action = {}

function action.new(action, component, interface, line, variable)
   local self = {
      action = action,
      component = component,
      interface = interface,
      variable = nil,
      hasEnd = false,
      father = nil,
      line = line,
      properties = {},
      _type = "action",
   }
   setmetatable(self, {__index= Action})
   return self
end

function Action:getAction() return self.action end

function Action:addProperty (name, value)
   value = value:gsub("\"", "") -- Remover aspas
   self.properties[name] = value
end

function Action:check()
   local componentElement = symbolTable[self.component]

   if not componentElement then
      utils.printErro("Element "..self.component.." not declared", self.line)
      return ""
   end
   self.component = componentElement

   if self.hasEnd == false then
      utils.printErro("Element Action does not have end", self.line)
      return ""
   end

   -- Component can not be a region
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

   --Se a action tem interface
   if self.interface then
      -- Se o component não tem interface, erro
      if not (self.component:getSon(self.interface) or self.component:getProperty(self.interface)) then
         utils.printErro("Invalid interface "..self.interface.." of element "..self.component.id, self.line)
         return ""
      end

      -- Se o component tem refer, chechar se o refer pode ser uma interface
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

   if self.component.father then --Se component tem father
      if self.father.father ~= self.component.father then --Se father do Link e do Component são diferentes
         utils.printErro("Invalid element "..self.component.id.." in the context", self.line)
         return ""
      end
   else --Se component não tem father
      if self.father.father then --Se Link tem father
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
