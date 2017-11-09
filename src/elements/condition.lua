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
      propriedades = {},
   }
   setmetatable(self, {__index = Condition})
   return self
end

function Condition:getMedia() return self.component end
function Condition:getParam() return self.conditionParam end

function Condition:check()
   self.component = tabelaSimbolos[self.component]

   if not self.component then
      utils.printErro("Component element invalid", self.linha)
      return
   end
   if self.component.tipo == "region" then
      utils.printErro("Invalid element in condition", self.linha)
      return
   end

   -- Se condition tem interface
   if self.interface then
      -- Se o component não tem interface, erro
      -- TODO: Checar propriedades
      if not self.component:getFilho(self.interface) then
         utils.printErro("Invalid interface "..self.interface, self.linha)
         return
      else
         self.interface = self.component:getFilho(self.interface).id
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
         NCL = NCL..indent.."   <bindParam name=\"keyCode\" value=\""..self.conditionParam.."\"/>"
      else
         NCL = NCL..indent.."   <bindParam name=\"conditionVar\" value=\""..self.conditionParam.."\"/>"
      end
   end

   NCL = NCL..indent.."</bind>"
   return NCL
end

return condition
