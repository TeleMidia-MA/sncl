local utils = require("utils")
local condition = {}
local Condition = {}

function condition.new(condition, conditionParam, component, interface, linha)
   local self = {
      condition = condition,
      conditionParam = conditionParam,
      component = component,
      interface = interface,
      linha = linha,
      pai = nil,
      tipo = "condition",
   }
   setmetatable(self, {__index = Condition})
   return self
end

function Condition:check()
   local componentElement = tabelaSimbolos[self.component]

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
         self.key = self.interface
         self.interface = nil
      elseif not self.component:getFilho(self.interface) then -- Se a interface não existir
         utils.printErro("Invalid interface "..self.interface.." of element "..self.component.id, self.linha)
         return ""
      end

      -- So pode ter key quando for onSelection
      if self.key then
         if self.condition ~= "onSelection" then
            utils.printErro("Invalid interface "..self.key..", buttons can not be an interface", self.linha)
         end
      end

      -- Se o component tem refer
      --[[
      if tabelaSimbolos[self.component].refer then
         local refer = tabelaSimbolos[self.component].refer
         local referredMedia = tabelaSimbolos[refer.media]
         if referredMedia then
            if referredMedia:getFilho(self.interface) == false and referredMedia:getPropriedade(self.interface) == false and tabelaSimbolos[self.component]:getFilho(self.interface) == false then
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

   -- Component tem pai
   if self.component.pai then
      if self.pai.pai ~= self.component and self.component.pai ~= self.pai.pai then
         utils.printErro("Invalid element", self.linha)
         return
      end
   -- Component não tem pai
   else
      if self.pai.pai then
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

   if self.conditionParam then
      if self.condition == "onSelection" then
         NCL = NCL..indent.."   <bindParam name=\"vKey\" value=\""..self.key.."\"/>"
      else
         NCL = NCL..indent.."   <bindParam name=\"conditionVar\" value=\""..self.conditionParam.."\"/>"
      end
   end

   NCL = NCL..indent.."</bind>"
   return NCL
end

return condition
