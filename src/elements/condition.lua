local utils = require("utils")
local condition = {}
local Condition = {}

--[[
-- condition<> ->
-- component<> ->
-- interface<> ->
-- properties<> ->
-- line<> ->
-- father<> ->
-- hasEnd<> ->
--]]
function condition.new (line)
   local self = {
      properties = {},
      _type = "condition",
   }
   setmetatable(self, {__index = Condition})
   return self
end

function Condition:parseStr(str)
   local words = {}
   for word in str:gmatch("%S+") do
      table.insert(words, word)
   end
   if #words < 3 then
      utils.printErro("Error in link declaration", gblParserLine)
   end
end

function Condition:check()
   if gblSymbolTable[self.component] then
      self.component = gblSymbolTable[self.component]
   else
      utils.printErro("Element "..self.component.." not declared", self.line)
      return ""
   end

   if not self.hasEnd  then
      utils.printErro("Element Condition does not have end", self.line)
      return ""
   end

   if self.component._type == "region" then
      utils.printErro("Element "..self.component.id.." invalid in this context", self.line)
      return ""
   end

   -- Se condition tem interface
   if self.interface then
      -- Se o component não tem interface, erro
      if lpegMatch(dataType.button, self.interface) then -- Se a interface for um botão
         self.properties["key"] = self.interface
         self.interface = nil
      elseif not self.component:getSon(self.interface) then -- Se a interface não existir
         utils.printErro("Invalid interface "..self.interface.." of element "..self.component.id, self.line)
         return ""
      end

      -- So pode ter key quando for onSelection
      if self.properties.key then
         if self.condition ~= "onSelection" then
            utils.printErro("Invalid interface "..self.key..", buttons can not be an interface", self.line)
         end
      end

      -- Se o component tem refer
      --[[
      if gblSymbolTable[self.component].refer then
         local refer = gblSymbolTable[self.component].refer
         local referredMedia = gblSymbolTable[refer.media]
         if referredMedia then
            if referredMedia:getSon(self.interface) == false and referredMedia:getPropriedade(self.interface) == false and gblSymbolTable[self.component]:getSon(self.interface) == false then
               utils.printErro("Invalid interface "..self.interface, self.line)
               return
            end
         else
            utils.printErro("Element "..self.component.." not declared.", self.line)
            return
         end
      end
      ]]
   end

   -- Component tem father
   if self.component.father then
      if self.father.father ~= self.component and self.component.father ~= self.father.father then
         utils.printErro("Invalid element", self.line)
         return
      end
   -- Component não tem father
   else
      if self.father.father then
         utils.printErro("Invalid element", self.line)
         return
      end
   end
end

function Condition:toNCL (indent)
   local NCL = indent.."<bind role=\""..self.condition.."\" component=\""..self.component.id.."\" "
   if self.interface then
      NCL = NCL.." interface=\""..self.interface.."\""
   end
   NCL = NCL..">"

   for pos, val in pairs(self.properties) do
      NCL = NCL..indent.."   <bindParam name=\""..pos.."\" value=\""..val.."\"/>"
   end

   NCL = NCL..indent.."</bind>"
   return NCL
end

return condition
