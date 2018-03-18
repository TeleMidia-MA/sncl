local utils = require("utils")
local port = {}
local Port = {}

--[[
-- id<> ->
-- component<> ->
-- interface<> ->
-- hasEnd<> ->
-- father<> ->
-- line<> ->
--]]
function port.new(component, interface, father, line)
   local self = {
      father = father,
      component = component,
      interface = interface,
      line = line,
      _type = "port",
   }
   setmetatable(self, {__index = Port})
   return self
end

function Port:setId(id)
   if gblSymbolTable[id] then
      utils.printErro("Element "..id.." already declared", self.line)
      return
   end
   self.id = id

   if not insideMacro then
      gblSymbolTable[id] = self
      table.insert(gblSymbolTable.body, gblSymbolTable[id])
   end
end

function Port:check() 
   if gblSymbolTable[self.component] == nil then
      utils.printErro("No element "..self.component, self.line)
      return ""
   end

   if gblSymbolTable[self.component].father ~= self.father then
      utils.printErro("Element "..self.component.." is invalid in this context", self.line)
      return ""
   end
end

function Port:toNCL(indent)
   local NCL = indent.."<port id=\""..self.id.."\" component=\""..self.component.."\""
   if self.interface then
      if gblSymbolTable[self.component]:getSon(self.interface) == nil then
         utils.printErro("Element "..self.interface.." is invalid", self.line)
         return ""
      end
      NCL = NCL.." interface=\""..self.interface.."\""
   end

   NCL = NCL.."/>"

   return NCL
end

return port
