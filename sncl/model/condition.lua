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
      father = nil,
   }
   setmetatable(conditionObject, Condition_mt)
   return conditionObject
end

function Condition:setFather (father) self.father = father end
function Condition:addParam (param) end

function Condition:getMedia () return self.component end
function Condition:getLinha() return self.linha end
function Condition:getFather() return self.father end
function Condition:getType() return "condition" end
function Condition:getParam() return self.conditionParam end

function Condition:toNCL (indent)
   if tabelaSimbolos[self.component] == nil then --Checar se mídia existe
      utils.printErro("Elemento "..self.component.." nao declarado.", self.linha)
      return ""
   else --Se tiver mídia
      if self.interface then -- Se tiver interface
         if tabelaSimbolos[self.component]:getRefer() ~= nil then
            local refer = tabelaSimbolos[self.component]:getRefer()
            local referredMedia = tabelaSimbolos[refer.media]
            if referredMedia ~= nil then
               if referredMedia:getSon(self.interface) == false and tabelaSimbolos[self.component]:getSon(self.interface) == false then
                  utils.printErro("Interface "..self.interface.." do elemento"..self.component.." nao declarado.", self.linha)
               end
            else
               utils.printerro("Elemento "..self.component.." nao declarada.", self.linha)
            end
         elseif not tabelaSimbolos[self.component]:getSon(self.interface) then --Se interface não 
            utils.printErro("Interface "..self.interface.." do elemento "..self.component.." nao declarado.", self.linha)
            return ""
         end
      end
   end


   if self.father then
      if (tabelaSimbolos.body[self.component]:getFather() == nil and self.father:getFather() == nil)
         or (tabelaSimbolos.body[self.component]:getFather():getId() == self.father:getFather():getId()) then
      else
         utils.printErro("Elemento "..self.component.." e Link nao estao no mesmo contexto.", self.linha)
         return ""
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

