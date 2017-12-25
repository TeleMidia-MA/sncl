local utils = require("utils")
local condition = {}
local Condition = {}

function condition.new(condition, component, interface, linha)
   local self = {
      condition = condition,
      component = component,
      interface = interface,
      linha = linha,
      properties = {},
      father = nil,
      tipo = "condition",
   }
   setmetatable(self, {__index = Condition})
   return self
end

function Condition:check()
   local componentElement = symbolTable[self.component]

   if not componentElement then
      utils.printErro("Element "..self.component.." not declared", self.linha)
      return ""
   end
   self.component = componentElement

   if self.temEnd == false then
      utils.printErro("Element Action does not have end", self.linha)
      return ""
   end

   if self.component.tipo == "region" then
      utils.printErro("Element "..self.component.id.." invalid in this context", self.linha)
      return ""
   end

   -- Se condition tem interface
   if self.interface then
      -- Se o component não tem interface, erro
      if lpegMatch(dataType.button, self.interface) then -- Se a interface for um botão
         self.properties["key"] = self.interface
         self.interface = nil
      elseif not self.component:getSon(self.interface) then -- Se a interface não existir
         utils.printErro("Invalid interface "..self.interface.." of element "..self.component.id, self.linha)
         return ""
      end

      -- So pode ter key quando for onSelection
      if self.properties.key then
         if self.condition ~= "onSelection" then
            utils.printErro("Invalid interface "..self.key..", buttons can not be an interface", self.linha)
         end
      end

      -- Se o component tem refer
      --[[
      if symbolTable[self.component].refer then
         local refer = symbolTable[self.component].refer
         local referredMedia = symbolTable[refer.media]
         if referredMedia then
            if referredMedia:getSon(self.interface) == false and referredMedia:getPropriedade(self.interface) == false and symbolTable[self.component]:getSon(self.interface) == false then
               utils.printErro("Invalid interface "..self.interface, self.linha)
               return
            end
         else
            utils.printErro("Element "..self.component.." not declared.", self.linha)
            return
         end
      end
      ]]
   end

   -- Component tem father
   if self.component.father then
      if self.father.father ~= self.component and self.component.father ~= self.father.father then
         utils.printErro("Invalid element", self.linha)
         return
      end
   -- Component não tem father
   else
      if self.father.father then
         utils.printErro("Invalid element", self.linha)
         return
      end
   end
end

function Condition:toNCL (indent)
   local NCL = indent.."<bind role=\""..self.condition.."\" component=\""..self.component.id.."\" "
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

return condition
