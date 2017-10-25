local utils = require("utils")

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
      utils.printErro("Element Action does not have end", self.linha)
      return ""
   end

   if tabelaSimbolos[self.component] == nil then
      utils.printErro("Element "..self.component.." not declared", self.linha)
      return ""
   end
   if tabelaSimbolos[self.component].tipo == "region" then
      utils.printErro("Element in invalid context", self.linha)
      return ""
   end

   if self.interface then --Se a action tem interface
      if tabelaSimbolos[self.component].refer ~= nil then --Se o component tem refer
         local refer = tabelaSimbolos[self.component].refer
         local referredMedia = tabelaSimbolos[refer.media]
         if referredMedia ~= nil then --Se o refer do component tem a interface
            if not (referredMedia:getFilho(self.interface) and 
               tabelaSimbolos[self.component]:getFilho(self.interface)) then
               utils.printErro("Invalid interface "..self.interface.." of element "..self.component, self.linha)
               return ""
            end
         else
            utils.printErro("Element "..self.component.." not declared.", self.linha)
            return ""
         end
      elseif not tabelaSimbolos[self.component]:getFilho(self.interface) then --Se o component tem interface
         utils.printErro("Invalid interface "..self.interface.." of element "..self.component, self.linha)
         return ""
      end
   end

   if tabelaSimbolos.body[self.component].pai then --Se component tem pai
      if self.pai.pai ~= tabelaSimbolos.body[self.component].pai then --Se pai do Link e do Component são diferentes
         utils.printErro("Invalid element "..self.component.." in the context", self.linha)
         return ""
      end
   else --Se component não tem pai
      if self.pai.pai then --Se Link tem pai
         utils.printErro("Invalid element "..self.component.." in the context", self.linha)
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

function Action:parseProperty(str)
   local name, value = utils.separateSymbol(str)

   if name and value then
      self.propriedades[name] = value
   else
   end
end

return action
