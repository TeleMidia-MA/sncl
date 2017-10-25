local utils = require("utils")

-- @module rule
local rule = {}
-- class table
local Rule = {}

function rule.novo(id)
   local self = {
      id, value,
      tipo = "rule",
   }
   setmetatable(self, {__index = Rule})
   return self
end

function Rule:setId(id)
   if tabelaSimbolos[id] then
      utils.printErro("Element "..id.." already declared", self.linha)
      return
   end
   tabelaSimbolos[id] = self
   tabelaSimbolos.rules[id] = tabelaSimbolos[id]
   self.id = id
end


function Rule:toNCL(indent)
   local NCL = indent.."<rule id=\""..self.id.."\" var="..self.var.." value="..self.value.." comparator=\"eq\"/>"
   return NCL
end

return rule

