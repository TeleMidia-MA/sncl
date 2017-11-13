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

function Action:check()
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

   --Se a action tem interface
   if self.interface then
      -- Se o component não tem interface, erro
      if not self.component:getFilho(self.interface) then
         utils.printErro("Invalid interface "..self.interface.." of element "..self.component.id, self.linha)
         return ""
      else
         self.interface = self.component:getFilho(self.interface)
         if self.interface.port then
            self.interface = self.interface.port.id
         end
      end

      -- Se o component tem refer, chechar se o refer pode ser uma interface
      --[[
      if self.component.refer then
         local refer = self.component.refer
         local referredMedia = tabelaSimbolos[refer.media]
         if referredMedia then
            if not (referredMedia:getFilho(self.interface) and 
               self.component:getFilho(self.interface)) then
               utils.printErro("Invalid interface "..self.interface.." of element "..self.component, self.linha)
               return ""
            end
         else
            utils.printErro("Element "..self.interface.." not declared.", self.linha)
            return ""
         end
      end
      ]]
   end

   if self.component.pai then --Se component tem pai
      if self.pai.pai ~= self.component.pai then --Se pai do Link e do Component são diferentes
         utils.printErro("Invalid element "..self.component.id.." in the context", self.linha)
         return ""
      end
   else --Se component não tem pai
      if self.pai.pai then --Se Link tem pai
         utils.printErro("Invalid element "..self.component.id.." in the context", self.linha)
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
