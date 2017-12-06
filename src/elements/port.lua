local utils = require("utils")

local port = {}
local Port = {}

function port.novo(component, interface, pai, linha)
   local self = {
      id = nil,
      pai = pai,
      component = component,
      interface = interface,
      linha = linha,
      tipo = "port",
   }
   setmetatable(self, {__index = Port})
   return self
end

function Port:setId(id)
   if tabelaSimbolos[id] then
      utils.printErro("Element "..id.." already declared", self.linha)
      return
   end
   self.id = id

   if not insideMacro then
      tabelaSimbolos[id] = self
      table.insert(tabelaSimbolos.body, tabelaSimbolos[id])
   end
end

function Port:check() 
   if tabelaSimbolos[self.component] == nil then
      utils.printErro("No element "..self.component, self.linha)
      return ""
   end

   if tabelaSimbolos[self.component].pai ~= self.pai then
      utils.printErro("Element "..self.component.." is invalid in this context", self.linha)
      return ""
   end
end

function Port:toNCL(indent)
   local NCL = indent.."<port id=\""..self.id.."\" component=\""..self.component.."\""
   if self.interface then
      if tabelaSimbolos[self.component]:getFilho(self.interface) == nil then
         utils.printErro("Element "..self.interface.." is invalid", self.linha)
         return ""
      end
      NCL = NCL.." interface=\""..self.interface.."\""
   end

   NCL = NCL.."/>"

   return NCL
end

return port
