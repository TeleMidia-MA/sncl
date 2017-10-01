Action = {}
Action_mt = {}

Action_mt.__index = Action

function Action.new(action, component, interface, linha)
   local actionObject = {
      action = action,
      component = component,
      temEnd = false,
      pai = nil,
      interface = interface,
      linha = linha,
      propriedades = {},
      tipo = "action",
   }
   setmetatable(actionObject, Action_mt)
   return actionObject
end

function Action:getAction() return self.action end

function Action:addPropriedade (name, value) 
   self.propriedades[name] = value 
end

function Action:toNCL(indent)
   if self.temEnd == false then
      utils.printErro("Elemento Action não possui end.", self.linha)
      return ""
   end

   if tabelaSimbolos[self.component] == nil then
      utils.printErro("Elemento "..self.component.." não declarado.", self.linha)
      return ""
   else
      if self.interface then
         if tabelaSimbolos[self.component].refer ~= nil then
            local refer = tabelaSimbolos[self.component].refer
            local referredMedia = tabelaSimbolos[refer.media]
            if referredMedia ~= nil then
               if referredMedia:getFilho(self.interface) == false and tabelaSimbolos[self.component]:getFilho(self.interface) == false then
                  utils.printErro("Interface "..self.interface.." do elemento "..self.component.." não declarada.", self.linha)
                  return ""
               end
            else
               utils.printErro("Elemento "..self.component.." não declarada.", self.linha)
               return ""
            end
         elseif not tabelaSimbolos[self.component]:getFilho(self.interface) then
            utils.printErro("Elemento "..self.component.." não possui interface "..self.interface, self.linha)
            return ""
         end
      end
   end

   if self.pai then
      if tabelaSimbolos.body[self.component].pai then --Se component tem pai
         if self.pai.pai ~= tabelaSimbolos.body[self.component].pai then --Se pai do Link e do Component são diferentes
            utils.printErro("O elemento "..self.component.." não é um elemento válido nesse contexto.", self.linha)
            return ""
         end
      else --Se component não tem pai
         if self.pai.pai then --Se Link tem pai
            utils.printErro("O elemento "..self.component.." não é um elemento válido nesse contexto.", self.linha)
            return ""
         end
      end
   else
      utils.printErro("Action \'"..self.action.." "..self.component.."\' sem pai.", self.linha)
      return ""
   end

   local action = indent.."<bind role=\""..self.action.."\" component=\""..self.component.."\""
   if self.interface then
      action = action.." interface=\""..self.interface.."\""
   end
   action = action..">"

   for pos, val in pairs(self.propriedades) do
      action = action..indent.."   <bindParam name=\""..pos.."\" value="..val.."/>"
   end

   action = action..indent.."</bind>"
   return action
end

