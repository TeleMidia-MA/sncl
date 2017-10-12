local action = {}

local Action = {}

function action.new(action, component, interface, linha)
   local self = {
      action = action,
      component = component,
      temEnd = false,
      pai = nil,
      interface = interface,
      linha = linha,
      propriedades = {},
      tipo = "action",
   }
   setmetatable(self, {__index= Action})
   return self
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
   end
   if tabelaSimbolos[self.component].tipo == "region" then
      utils.printErro("Elemento inválido em ação.", self.linha)
      return ""
   end

   if self.interface then --Se a action tem interface
      if tabelaSimbolos[self.component].refer ~= nil then --Se o component tem refer
         local refer = tabelaSimbolos[self.component].refer
         local referredMedia = tabelaSimbolos[refer.media]
         if referredMedia ~= nil then --Se o refer do component tem a interface
            if not (referredMedia:getFilho(self.interface) and tabelaSimbolos[self.component]:getFilho(self.interface)) then
               utils.printErro("Interface "..self.interface.." do elemento "..self.component.." não declarada.", self.linha)
               return ""
            end
         else
            utils.printErro("Elemento "..self.component.." não declarada.", self.linha)
            return ""
         end
      elseif not tabelaSimbolos[self.component]:getFilho(self.interface) then --Se o component tem interface
         utils.printErro("Elemento "..self.component.." não possui interface "..self.interface, self.linha)
         return ""
      end
   end

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

   local NCL = indent.."<bind role=\""..self.action.."\" component=\""..self.component.."\""
   if self.interface then
      NCL = NCL.." interface=\""..self.interface.."\""
   end
   NCL = NCL..">"

   for pos, val in pairs(self.propriedades) do
      NCL = NCL..indent.."   <bindParam name=\""..pos.."\" value="..val.."/>"
   end

   NCL = NCL..indent.."</bind>"
   return NCL
end

return action
