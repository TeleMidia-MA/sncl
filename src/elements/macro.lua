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

return macro
