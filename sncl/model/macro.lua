Macro = {}
Macro_mt = {}

Macro_mt.__index = Macro

function Macro.new(id, linha)
   local macroObject = {
      id = id, 
      temEnd = false,
      pai = nil,
      propriedades = {},
      filhos = {},
      params = {},
      tipo = "macro",
      quantParams = 0,
   }
   setmetatable(macroObject, Macro_mt)
   return macroObject
end

function Macro:getId() return self.id end
function Macro:getFather() return self.father end
function Macro:getEnd() return self.hasEnd end

function Macro:setEnd(bool) self.hasEnd = bool end
function Macro:setParams(params) self.params = params end

function Macro:addPropriedade(name, value) self.propriedades[name] = value end
function Macro:addFilho(son) table.insert(self.filhos, son) end

