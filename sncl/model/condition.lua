Condition = {}
Condition_mt = {}

Condition_mt.__index = Condition

function Condition.new(condition, conditionParam, component, interface, linha)
   local conditionObject = {
      condition = condition,
      conditionParam = conditionParam,
      component = component,
      interface = interface,
      linha = linha,
      pai = nil,
      tipo = "condition"
   }
   setmetatable(conditionObject, Condition_mt)
   return conditionObject
end

function Condition:addParam(param) end
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

   if self.pai then
      if self.pai.pai then --Se Link tiver pai
         if self.pai.pai.id ~= self.component and tabelaSimbolos.body[self.component].pai.id ~= self.pai.pai.id then
            utils.printErro("Elemento "..self.component.." não é válido nesse contexto.", self.linha)
            return ""
         end
      else
         if tabelaSimbolos.body[self.component].pai then
            utils.printErro("Elemento "..self.component.." não é válido nesse contexto.", self.linha)
            return ""
         end
      end
   end

   local condition = indent.."<bind role=\""..self.condition.."\" component=\""..self.component.."\" "
   if self.interface then
      condition = condition.." interface=\""..self.interface.."\""
   end
   condition = condition..">"

   if self.conditionParam then
      if self.condition == "onSelection" then
         condition = condition..indent.."   <bindParam name=\"keyCode\" value=\""..self.conditionParam.."\"/>"
      else
         condition = condition..indent.."   <bindParam name=\"conditionVar\" value=\""..self.conditionParam.."\"/>"
      end
   end

   condition = condition..indent.."</bind>"
   return condition
end

