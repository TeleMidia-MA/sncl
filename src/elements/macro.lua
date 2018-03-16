local utils = require("utils")
local macro = {}
local Macro = {}

--[[
-- id<> ->
-- properties<> ->
-- sons<> ->
-- params<> ->
-- quantParams<> ->
-- hasEnd<> ->
-- father<> ->
-- line<> ->
--]]
function macro.new(id, line)
   local self = {
      id = id,
      properties = {},
      sons = {},
      params = {},
      line = line,
      _type = "macro",
      quantParams = 0,
   }
   setmetatable(self, {__index = Macro})
   return self
end

function Macro:setEnd(bool) self.hasEnd = bool end
function Macro:setParams(params) self.params = params end

function Macro:addProperty(name, value)
   print(name, value)
   value = value:gsub("\"", "")
   self.properties[name] = value
end

function Macro:parseProperty(str)
   local name, value = utils.splitSymbol(str, ":")
   self:addProperty(name, value)
end

function Macro:addSon(son) table.insert(self.sons, son) end

function Macro:check() end

function Macro:parseProperty(str)
   local name, value = utils.splitSymbol(str, ":")
   if name and value then
      if not value:match('".-"') then -- Se nao tem aspas
         if not self.params[value] and name ~= "rg" then
            utils.printErro("Value of property "..name.." in Macro invalid")
            return
         end
      end
      self.properties[name] = value
   else
   end
end

return macro
