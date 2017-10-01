Elemento = {}
Elemento_mt = {}

Elemento_mt.__index = Elemento

function Elemento.novo(tipo, linha)
   local tabelaElemento = {
      id = "",
      tipo = tipo,
      temEnd = false,
      pai,
      linha,
      refer,
      propriedades = {},
      filhos = {},
   }
   setmetatable(tabelaElemento, Elemento_mt)
   return tabelaElemento
end

--Set
function Elemento:setId(id)
   if tabelaSimbolos[id] then
      utils.printErro("Id "..id.." já declarado.", self.linha)
      return nil
   end
   self.id = id
   if not insideMacro then
      tabelaSimbolos[id] = self
      if self.tipo == "region" then
         tabelaSimbolos.regions[id] = tabelaSimbolos[id]
      elseif self.tipo == "descriptor" then
         tabelaSimbolos.descriptors[id] = tabelaSimbolos[id]
      else
         tabelaSimbolos.body[id] = tabelaSimbolos[id]
      end
   end
end
function Elemento:setRefer(component, interface)
   self.refer = {
      component = component,
      interface = interface
   }
end
--Add
function Elemento:addFilho(filho)
   table.insert(self.filhos, filho)
end
function Elemento:addPropriedade(nome, valor)
   if self.tipo == "media" then
      if nome == "src" then
         self.src = valor
         return
      elseif nome == "type" then
         self._type = valor
         return
      elseif nome == "rg" then
         self.region = valor
         return
      end
   elseif self.tipo == "area" then
      for __, val in pairs(self.areaAttributes) do
         if val == nome then
            self.propriedades[nome] = valor
            return
         end
      end
      utils.printErro("Propriedade invalida em area.", self.linha)
      return
   end
   self.propriedades[nome] = valor
end

--Get
function Elemento:getFilho(filho)
   for pos, val in pairs(self.filhos) do
      if val.tipo ~= "link" then
         if val.id == filho then
            return val
         end
      end
   end
end
function Elemento:getPropriedade(propriedade)
   for pos, val in pairs(self.propriedades) do
      if pos == propriedade then
         return pos
      end
   end
end

--Misc
function Elemento:toNCL(indent)
   if not self.temEnd then
      utils.printErro("Elemento sem end.", self.linha)
      return ""
   end
   if not self.id then
      utils.printErro("Elemento sem id.", self.linha)
      return ""
   end

   if self.tipo == "media" then
      --[[
      if self.src==nil and self._type==nil and self.refer==nil then
         utils.printErro("Media deve ter source ou type ou refer.", self.linha)
         return ""
      end
      ]]
      self:criarDescritor()
   end

   local NCL = indent.."<"..self.tipo.." id=\""..self.id.."\""

   if self.descritor then
      NCL = NCL.." descriptor=\""..self.descritor.."\""
   end
   if self.refer then
      NCL = NCL.." refer="..self.refer.component.." instance=instSame"
      if self.refer.interface then
         NCL = NCL.." interface="..self.refer.interface
      end
   end
   if self.src then
      NCL = NCL.." src="..self.src
   end
   if self._type then
      NCL = NCL.." type="..self._type
   end
   if self.tipo ~= "area" then
      NCL = NCL..">"
   end

   if self.tipo == "area" then
      for pos, val in pairs(self.propriedades) do
         NCL = NCL.." "..pos.."="..val
      end
      NCL = NCL..">"
   else
      for pos, val in pairs(self.propriedades) do
         NCL = NCL..indent.."   <property name=\""..pos.."\""
         if val then
            NCL = NCL.." value="..val
         end
         NCL = NCL.."/>"
      end
   end

   for pos, val in pairs(self.filhos) do
      NCL = NCL..val:toNCL(indent.."   ")
   end

   NCL = NCL..indent.."</"..self.tipo..">"
   return NCL
end

function Elemento:criarDescritor()
   if self.region then
      if tabelaSimbolos.regions[self.region] == nil then
         utils.printErro("Region "..self.region.." não declarada.", self.linha)
      end
      local id = self.region.."Desc"
      self.descritor = id
      local newDesc = Elemento.novo("descriptor", 0)
      newElement(id, newDesc)
      newDesc.temEnd = true
   end
end

Elemento.areaAttributes = {
   "coords", "begin", "end", "text", "position", "first",
   "last", "label"
}
