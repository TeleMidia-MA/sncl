local utils = require("utils")
local element = {}
local Element = {}

-- Elements can be: <media>, <region>, <descriptor>

--[[
-- id<> ->
-- _type<> -> The type of the element
-- mType<string> -> if it's a media, the type of the media
-- hasPort<> ->
-- refer<> ->
-- properties<> ->
-- sons<> ->
-- father<> ->
-- hasEnd<> ->
-- line<> ->
--]]
function element.new(_type, line)
   local self = {
      id = "",
      _type = _type,
      line = line,
      properties = {},
      sons = {},
   }
   setmetatable(self, {__index = Element})
   return self
end

--Set
function Element:setId(id)
   -- If an element with this id is already declared (descriptors dont have id)
   if symbolTable[id] and self._type ~= "descriptor" then
      utils.printErro("Element "..id.." already declared", self.line)
      return nil
   end
   self.id = id
   -- If the element is inside a macro, dont add it to the symbolTable
   if not insideMacro then
      symbolTable[id] = self
      if self._type == "region" then
         symbolTable.regions[id] = symbolTable[id]
      elseif self._type == "descriptor" then
         symbolTable.descriptors[id] = symbolTable[id]
      else
         table.insert(symbolTable.body, symbolTable[id])
      end
   end
end

function Element:setRefer(component, interface)
   self.refer = {
      component = component,
      interface = interface
   }
end

function Element:addSon(son)
   if self._type ~= "descriptor" then
      table.insert(self.sons, son)
   end
end

function Element:parseProperty(str)
   local name, value = utils.splitSymbol(str, ":")
   local macroFather = utils.isMacroSon(self)

   if not (name and value) then
      utils.printErro("Error parsing", self.line)
      return
   end
   if not propertiesValues[name] then
      utils.printErro("Invalid property "..name, self.line)
      return
   end

   -- Tem property que pode ter mais de 1 value
   -- Se tiver mais de 1 value, não pode ser argumento de macro
   local values = {}
   for w in value:gmatch("([^,]*)") do
      w:gsub("%s+", "")
      table.insert(values, w)
   end

   if macroFather then
      if macroFather.params[value] then -- Se o value eh um param
         self:addProperty(name, value)
         return
      end
   end

   -- Se for son de macro, mas o value não eh um param
   -- Se não for son de macro
   -- continuar

   if #values ~= propertiesValues[name][1] then
      utils.printErro("Wrong quantity of arguments", self.line)
      return
   end

   if #values > 1 then
      for i=1, #values do
         if not lpegMatch(propertiesValues[name][2], values[i]) then
            utils.printErro("Invalid value in property "..name, self.line)
            return
         end
      end
      self:addProperty(name, value)
   else
      -- Checar se o value ta certo sintaticamente
      if not lpegMatch(propertiesValues[name][2], values[1]) then
         utils.printErro("Invalid value in property "..name, self.line)
         return
      end
      self:addProperty(name, values[1])
   end
end

function Element:addProperty(name, value)
   value = value:gsub("\"", "")
   if self._type == "media" then
      if name == "src" then
         self.src = value
         return
      elseif name == "type" then
         self.mType = value
         return
      elseif name == "rg" then
         self.region = value
         return
      end
   end
   self.properties[name] = value
end

function Element:getSon(son)
   for _, val in pairs(self.sons) do
      if val._type ~= "link" then
         if val.id == son then
            return val
         end
      end
   end
end

function Element:getProperty(property)
   for pos, val in pairs(self.properties) do
      if pos == property then
         return pos, val
      end
   end
end

function Element:sonHasProperty(prop)
   for _, val in pairs(self.sons) do
      if val.properties then
         if val.properties[prop] then
            return val
         else
            val:sonHasProperty(prop)
         end
      end
   end
end

function Element:check()
   if not self.hasEnd then
      utils.printErro("Element "..self.id.." has no end.", self.line)
   end

   if self._type == "media" then
      if self.src==nil and self.mType==nil and self.refer==nil then
         utils.printErro("Media "..self.id.." must have a type, source or refer", self.line)
      end
   end
   self:createDescritor()
   self:createPort()
   for _, val in pairs(self.sons) do
      val:check()
   end
end

function Element:toNCL(indent)
   local NCL = indent.."<"..self._type.." id=\""..self.id.."\""

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
      NCL = NCL.." src=\""..self.src.."\""
   end
   if self.mType then
      NCL = NCL.." type=\""..self.mType.."\""
   end
   if self._type ~= "area" and self._type ~= "region" and self._type ~= "descriptor" then
      NCL = NCL..">"
   end

   if self._type == "area" or self._type == "region" or self._type == "descriptor" then
      for pos, val in pairs(self.properties) do
         NCL = NCL.." "..pos.."=\""..val.."\""
      end
      NCL = NCL..">"
   else
      for pos, val in pairs(self.properties) do
         if pos ~= "map" then
            NCL = NCL..indent.."   <property name=\""..pos.."\""
            if val then
               NCL = NCL.." value=\""..val.."\""
            end
            NCL = NCL.."/>"
         end
      end
   end

   for _, val in pairs(self.sons) do
      NCL = NCL..val:toNCL(indent.."   ")
   end

   NCL = NCL..indent.."</"..self._type..">"
   return NCL
end

function Element:createPort()
   if self.hasPort then
      local newPort
      if self._type == "area" then
         newPort = Port.new(self.father.id, self.id, self.father.father) 
         newPort:setId("_p"..self.id.."_")
         if self.father.father then
            self.father.father:addSon(newPort)
         end
      else
         newPort = Port.new(self.id, nil, self.father)
         newPort:setId("_p"..self.id.."_")
         if self.father then
            self.father:addSon(newPort)
         end
      end
      self.port = newPort
   end
end

function Element:createDescritor()
   if self.region then
      if symbolTable.regions[self.region:gsub("\"", "")] == nil then
         utils.printErro("Region "..self.region.." not declared", self.line)
      end
      local id = self.region:gsub("\"", "").."Desc"
      self.descritor = id
      local newDesc = element.new("descriptor", 0)
      utils.newElement(id, newDesc)
      newDesc:addProperty("region", self.region)
      newDesc.hasEnd = true
   end
end

return element
