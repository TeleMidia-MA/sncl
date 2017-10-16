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

function Condition:toNCL (indent)
   if tabelaSimbolos[self.component] == nil then --Checar se mídia existe
      utils.printErro("Elemento "..self.component.." nao declarado.", self.linha)
      return ""
   else --Se tiver component
      if tabelaSimbolos[self.component].tipo == "region" then
         utils.printErro("Elemento inválido em condição.", self.linha)
         return ""
      end
      if self.interface then -- Se tiver interface
         if tabelaSimbolos[self.component].refer then
            local refer = tabelaSimbolos[self.component].refer
            local referredMedia = tabelaSimbolos[refer.media]
            if referredMedia ~= nil then
               if referredMedia:getFilho(self.interface) == false and referredMedia:getPropriedade(self.interface) == false and tabelaSimbolos[self.component]:getFilho(self.interface) == false then
                  utils.printErro("Interface "..self.interface.." do elemento"..self.component.." nao declarado.", self.linha)
                  return ""
               end
            else
               utils.printErro("Elemento "..self.component.." nao declarado.", self.linha)
               return ""
            end
         elseif not tabelaSimbolos[self.component]:getFilho(self.interface) then --Se interface não 
            utils.printErro("Interface "..self.interface.." do elemento "..self.component.." nao declarado.", self.linha)
            return ""
         end
      end
   end
   if tabelaSimbolos.body[self.component].pai then --Se component tem pai
      if self.pai.pai ~= tabelaSimbolos.body[self.component].pai then --Se pai do Link e do Component são diferentes
         utils.printErro("O elemento "..self.component.." nao é um elemento válido nesse contexto.", self.linha)
         return ""
      end
   else --Se component não tem pai
      if self.pai.pai then --Se Link tem pai
         utils.printErro("O elemento "..self.component.." não é um elemento válido nesse contexto.", self.linha)
         return ""
      end
   end

   local NCL = indent.."<bind role=\""..self.condition.."\" component=\""..self.component.."\" "
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
