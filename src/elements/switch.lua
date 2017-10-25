local utils = require("utils")

-- @module switch
local switch = {}
-- class table
local Switch = {}

function switch.novo(linha)
   local self = {
      id = "",
      tipo = "switch",
      ports = {},
      filhos = {},
      propriedades = {},
      rules = {},
      var, father, refer,
      linha = linha,
      temEnd = false,
   }
   setmetatable(self, {__index = Switch})
   return self
end

function Switch:setId(id)
   if tabelaSimbolos[id] then
      utils.printErro("Element "..id.." already declared", self.linha)
      return
   end
   self.id = id
   tabelaSimbolos[id] = self
   tabelaSimbolos.body[id] = tabelaSimbolos[id]
end

function Switch:addFilho(elemento)
   self.filhos[elemento.id] = elemento
end

function Switch:addPort(element)
   element = element:gsub("%s+", "")
   local ponto = element:find("%.")
   local interface = false
   if ponto then
      interface = element:sub(ponto+1)
      element = element:sub(1, ponto-1)
   end
   self.ports[element] = interface
end

function Switch:addPropriedade(nome, valor)
   self.propriedades[nome] = valor
end

function Switch:makeRules()
   for _, val in pairs(self.rules) do
      local newRule = Rule.novo()
      newRule:setId(self.id..val:gsub("\"", ""))
      newRule.value = val
      newRule.var = self.var
   end
end

function Switch:toNCL(indent)
   local NCL = indent.."<switch id=\""..self.id.."\">"

   --Switch Ports
   NCL = NCL..indent.."   <switchPort id=\""..self.id.."Port\">"
   for pos, val in pairs(self.ports) do
      if tabelaSimbolos[pos] then
         local mapping = indent.."      <mapping component=\""..pos.."\""
         if val then
            if tabelaSimbolos[pos]:getFilho(val) then
               mapping = mapping.." interface=\""..val.."\""
            else
               utils.printErro("Invalid interface "..val, self.linha)
               return ""
            end
         end
         mapping = mapping.."/>"
      else
         utils.printErro("Element "..pos.." not declared", self.linha)
         return ""
      end
      if mapping then
         NCL = NCL..mapping
      end
   end
   NCL = NCL..indent.."   </switchPort>"

   --Default Component
   for pos, val in pairs(self.propriedades) do
      if pos == "default" then
         if self.filhos[val] then
            NCL = NCL..indent.."   <defaultComponent component=\""..val.."\"/>"
         else
            utils.printErro("Elemento "..val.." invalido no context", self.linha)
            return ""
         end
      end
   end

   for _, val in pairs(self.filhos) do
      NCL = NCL..val:toNCL(indent.."   ")
      if val.propriedades["map"]  then
         NCL = NCL..indent.."   <bindRule constituent=\""..val.id.."\" rule=\""..self.id..val.propriedades["map"]:gsub("\"", "").."\"/>"
         table.insert(self.rules, val.propriedades["map"])
      elseif val:filhoTemPropriedade("map") then
         --TODO: cadeia de context->port->context->port->...->media
         local rule = val:filhoTemPropriedade("map").propriedades["map"]
         NCL = NCL..indent.."   <bindRule constituent=\""..val.id.."\" rule="..rule.."/>"
         table.insert(self.rules, rule)
      end
   end

   self:makeRules()

   NCL = NCL..indent.."</switch>"
   return NCL
end

return switch
