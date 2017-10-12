
local port = {}

local Port = {}

function port.novo (media, interface, pai, linha)
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

function Port:setId (id)
   if tabelaSimbolos[id] then
      utils.printErro("Elemento com id "..id.." já declarado.")
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
      utils.printErro("Nenhum elemento "..self.media..".", self.linha)
      return ""
   end

   if tabelaSimbolos[self.media].pai ~= self.pai then
      utils.printErro("O Elemento "..self.media.." deve estar no mesmo contexto do elemento port "..self.id..".", self.linha)
      return ""
   end

   if self.interface then
      if tabelaSimbolos[self.media]:getFilho(self.interface) == nil then
         utils.printErro("O elemento apontado pela interface é inválido.", self.linha)
         return ""
      end
   end

   local NCL = indent.."<port id=\""..self.id.."\" component=\""..self.media.."\"/>"

   return NCL
end

return port
