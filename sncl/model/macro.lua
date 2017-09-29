Macro = {}
Macro_mt = {}

Macro_mt.__index = Macro

function Macro.new(id, linha)
   local macroObject = {
      id = id, 
      hasEnd = false,
      father = nil,
      properties = {},
      sons = {},
      params = {},
      quantParams = 0,
   }
   setmetatable(macroObject, Macro_mt)
   return macroObject
end

function Macro:getId() return self.id end
function Macro:getFather() return self.father end
function Macro:getType() return "macro" end
function Macro:getEnd() return self.hasEnd end

function Macro:setEnd(bool) self.hasEnd = bool end
function Macro:setParams(params) self.params = params end

function Macro:addProperty(name, value) self.properties[name] = value end
function Macro:addSon(son) table.insert(self.sons, son) end

