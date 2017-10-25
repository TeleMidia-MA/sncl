local utils = require("utils")
local macro = {}
local Macro = {}

function macro.new(id, linha)
   local self = {
      id = id,
      temEnd = false,
      pai = nil,
      linha = linha,
      propriedades = {},
      filhos = {},
      params = {},
      tipo = "macro",
      quantParams = 0,
   }
   setmetatable(self, {__index = Macro})
   return self
end

function Macro:getId() return self.id end
function Macro:getFather() return self.father end
function Macro:getEnd() return self.hasEnd end

function Macro:setEnd(bool) self.hasEnd = bool end
function Macro:setParams(params) self.params = params end

function Macro:addPropriedade(name, value)
   self.propriedades[name] = value
end

function Macro:addFilho(son) table.insert(self.filhos, son) end

function Macro:parseProperty(str)
   local name, value = utils.separateSymbol(str)
   if name and value then
      if not value:match('".-"') then -- Se nao tem aspas
         if not self.params[value] and name ~= "rg" then
            utils.printErro("Value of property "..name.." in Macro invalid")
            return
         end
      end
      self.propriedades[name] = value
   else
   end
end

return macro
