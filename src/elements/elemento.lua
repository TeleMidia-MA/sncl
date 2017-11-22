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
      temPort = false,
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
         table.insert(tabelaSimbolos.body, tabelaSimbolos[id])
      end
   end
end
function Elemento:setRefer(component, interface)
   self.refer = {
      component = component,
      interface = interface
   }
end

function Elemento:addFilho(filho)
   if self.tipo ~= "descriptor" then
      table.insert(self.filhos, filho)
   end
end

function Elemento:parsePropriedade(str)
   local name, value = utils.separateSymbol(str)
   local macroFather = utils.isMacroSon(self)

   if not (name and value) then
      utils.printErro("Error parsing", self.linha)
      return
   end
   if not propertiesValues[name] then
      utils.printErro("Invalid property "..name, linhaParser)
      return
   end

   -- Tem propriedade que pode ter mais de 1 valor
   -- Se tiver mais de 1 valor, não pode ser argumento de macro
   local values = {}
   for w in value:gmatch("([^,]*)") do
      w:gsub("%s+", "")
      table.insert(values, w)
   end

   if macroFather then
      if macroFather.params[value] then -- Se o valor eh um param
         self:addPropriedade(name, value)
         return
      end
   end

   -- Se for filho de macro, mas o valor não eh um param
   -- Se não for filho de macro
   -- continuar

   if #values ~= propertiesValues[name][1] then
      utils.printErro("Wrong quantity of arguments", linhaParser)
      return
   end

   if #values > 1 then
      for i=1, #values do
         if not lpegMatch(propertiesValues[name][2], values[i]) then
            utils.printErro("Invalid value in property "..name, linhaParser)
            return
         end
      end
      self:addPropriedade(name, "\""..value.."\"")
   else
      -- Checar se o valor ta certo sintaticamente
      if not lpegMatch(propertiesValues[name][2], values[1]) then
         utils.printErro("Invalid value in property "..name, linhaParser)
         return
      end
      if values[1]:match('".-"') then -- Se o valor tem aspas
         self:addPropriedade(name, values[1])
      else
         self:addPropriedade(name, "\""..values[1].."\"")
      end
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
   end
   self.propriedades[nome] = valor
end

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

function Elemento:check()
   if not self.temEnd then --Check se elemento tem end
   utils.printErro("Elemento "..self.id.." has no end.", self.linha)
end

-- Se for media, tem que ter source, type ou refer
if self.tipo == "media" then
   if self.src==nil and self._type==nil and self.refer==nil then
      utils.printErro("Media "..self.id.." must have a type, source or refer", self.linha)
   end
end
self:criarDescritor()
self:criarPort()
for _, val in pairs(self.filhos) do
   val:check()
end
end

function Elemento:toNCL(indent)
   local NCL = indent.."<"..self.tipo.." id=\""..self.id.."\""

   if self.descritor then
      NCL = NCL.." descriptor=\""..self.descritor.."\""
   end
   if self.refer then
      NCL = NCL.." refer=\""..self.refer.component.."\" instance=\"instSame\""
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

function Elemento:criarPort()
   if self.temPort then
      local newPort
      if self.tipo == "area" then
         newPort = Port.novo(self.pai.id, self.id, self.pai.pai) 
         newPort:setId("_p"..self.id.."_")
         if self.pai.pai then
            self.pai.pai:addFilho(newPort)
         end
      else
         newPort = Port.novo(self.id, nil, self.pai)
         newPort:setId("_p"..self.id.."_")
         if self.pai then
            self.pai:addFilho(newPort)
         end
      end
      self.port = newPort
   end
end

function Elemento:criarDescritor()
   if self.region then
      if tabelaSimbolos.regions[self.region:gsub("\"", "")] == nil then
         utils.printErro("Region "..self.region.." not declared", self.linha)
      end
      local id = self.region:gsub("\"", "").."Desc"
      self.descritor = id
      local newDesc = elemento.novo("descriptor", 0)
      utils.newElement(id, newDesc)
      newDesc:addPropriedade("region", self.region)
      newDesc.temEnd = true
   end
end



return elemento
