local utils = require("utils")
-- @module elemento
local elemento = {}

-- class table
local Elemento = {}

function elemento.novo(tipo, linha)
   local self = {
      id = "",
      tipo = tipo,
      temEnd = false,
      pai, linha, refer,
      propriedades = {},
      filhos = {},
   }
   setmetatable(self, {__index = Elemento})
   return self
end

--Set
function Elemento:setId(id)
   if tabelaSimbolos[id] and self.tipo ~= "descriptor" then -- Se ja existe o Id
      utils.printErro("Element "..id.." already declared", self.linha)
      return nil
   end
   self.id = id
   -- Não é pra adicionar a tabela de simbolos
   -- se o elemento tiver dentro de uma macro
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
   if self.tipo ~= "descriptor" then
      table.insert(self.filhos, filho)
   end
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
   -- Checar se o atributo de area é valido
   elseif self.tipo == "area" then
      for _, val in pairs(self.areaAttributes) do
         if val == nome then
            self.propriedades[nome] = valor
            return
         end
      end
      utils.printErro("Invalid property "..nome, self.linha)
      return
   end
   self.propriedades[nome] = valor
end

--Get
function Elemento:getFilho(filho)
   for _, val in pairs(self.filhos) do
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
         return pos, val
      end
   end
end

function Elemento:filhoTemPropriedade(prop)
   for _, val in pairs(self.filhos) do
      if val.propriedades then
         if val.propriedades[prop] then
            return val
         else
            val:filhoTemPropriedade(prop)
         end
      end
   end
end

--Misc
function Elemento:toNCL(indent)
   if not self.temEnd then
      utils.printErro("Elemento "..self.id.." sem end.", self.linha)
      return ""
   end

   if self.tipo == "media" then
      if self.src==nil and self._type==nil and self.refer==nil then
         utils.printErro("Media "..self.id.." must have a type, source or refer", self.linha)
         return ""
      end
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
   if self.tipo ~= "area" and self.tipo ~= "region" and self.tipo ~= "descriptor" then
      NCL = NCL..">"
   end

   if self.tipo == "area" or self.tipo == "region" or self.tipo == "descriptor" then
      for pos, val in pairs(self.propriedades) do
         NCL = NCL.." "..pos.."="..val
      end
      NCL = NCL..">"
   else
      for pos, val in pairs(self.propriedades) do
         if pos ~= "map" then
            NCL = NCL..indent.."   <property name=\""..pos.."\""
            if val then
               NCL = NCL.." value="..val
            end
            NCL = NCL.."/>"
         end
      end
   end

   for _, val in pairs(self.filhos) do
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
      local newDesc = elemento.novo("descriptor", 0)
      utils.newElement(id, newDesc)
      newDesc:addPropriedade("region", "\""..self.region.."\"")
      newDesc.temEnd = true
   end
end

function Elemento:parseProperty(str)
   local name, value = utils.separateSymbol(str)

   if name and value then
      if utils.isMacroSon(self) then
         local macro = utils.isMacroSon(self)
         if not value:match('".-"') then
            if not macro.params[value] and name~="rg" then
               utils.printErro("Value of property "..name.." in "..self.tipo.." invalid.")
               return
            end
         end
      else
         if not value:match('".-"') then
            if name ~= "rg" and name ~= "default" then
               utils.printErro("Value of property "..name.." in "..self.tipo.." invalid.")
               return
            end
         end
      end
      self:addPropriedade(name, value)
   else
   end
end

Elemento.areaAttributes = { --TODO: Tirar isso daqui, fazer global?
   "coords", "begin", "end", "text", "position", "first",
   "last", "label"
}

return elemento
