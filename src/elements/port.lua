local utils = require("utils")

local port = {}
local Port = {}

function port.novo(media, interface, pai, linha)
   local self = {
      id = nil,
      pai = pai,
      media = media,
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
      tabelaSimbolos.body[id] = tabelaSimbolos[id]
   end
end

function Port:setComponent(component)
   self.media = component
end

function Port:setInterface(interface)
   self.interface = interface
end

function Port:toNCL(indent)

   if tabelaSimbolos[self.media] == nil then
      utils.printErro("No element "..self.media, self.linha)
      return ""
   end

   if tabelaSimbolos[self.media].pai ~= self.pai then
      utils.printErro("Element "..self.media.." is invalid in this context", self.linha)
      return ""
   end

   if self.interface then
      if tabelaSimbolos[self.media]:getFilho(self.interface) == nil then
         utils.printErro("Element "..self.interface.." is invalid", self.linha)
         return ""
      end
   end

   local NCL = indent.."<port id=\""..self.id.."\" component=\""..self.media.."\"/>"

   return NCL
end

return port
