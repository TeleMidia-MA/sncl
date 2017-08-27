Media = {}
Media_mt = {}

Media_mt.__index = Media

function Media.new(linha)
   local mediaObject = {
      id = nil,
      hasEnd = false,
      father = nil,
      descriptor = nil,
      refer = nil,
      linha = linha,
      properties = {},
      sons = {}
   }
   setmetatable(mediaObject, Media_mt)
   return mediaObject
end

--Getters
function Media:getId () return self.id end
function Media:getDescriptor () return self.descriptor end
function Media:getMediaType () return self.mediaType end
function Media:getType () return "media" end
function Media:getFather () return self.father end
function Media:getSons () return self.sons end
function Media:getRefer() return self.refer end
function Media:getSon (son)
   for pos, val in pairs(self.sons) do
      if val:getId() == son then
         return val
      end
   end
   for pos, val in pairs(self.properties) do
      if pos == son then
         return pos
      end
   end
   return false
end

--Setters
function Media:setId (id) 
   self.id = id 
   tabelaSimbolos[id] = self
   tabelaSimbolos.body[id] = tabelaSimbolos[id]
end
function Media:setFather(father) self.father = father end
function Media:setEnd(bool) self.hasEnd = bool end
function Media:addSon (son)
   table.insert(self.sons, son)
end
function Media:addProperty(name, value)
   self.properties[name] = value
end
function Media:setRefer (media, interface)
   self.refer = {
      media = media,
      interface = interface,
   }
end

function Media:createDescriptor() 
   if self.properties["rg"] ~= nil then
      if tabelaSimbolos.regions[self.properties["rg"]] then
         local id = self.properties["rg"]
         id = id.."Desc"
         self.descriptor = id

         --if tabelaSimbolos.descriptors[id] == nil then
         local newDesc = Descriptor.new(id)
         newDesc:setRegion(self.properties["rg"])
         tabelaSimbolos[id] = newDesc
         tabelaSimbolos.descriptors[id] = tabelaSimbolos[id]
         --[[else
         utils.printErro("Id "..id.." already declared.")
         end]]
      else
         utils.printErro("Region "..self.properties["rg"].." não declarada.")
      end
   end
end

-- Gerador de NCL
function Media:toNCL(indent) --Fazer checagens aqui
   if self.hasEnd == false then
      utils.printErro("Media "..self.id.." não possui end.", self.linha)
      return ""
   end
   local media = indent.."<media id=\""..self.id.."\" "

   self:createDescriptor()
   if self.descriptor then
      media = media.."descriptor=\""..self.descriptor.."\" "
   end
   if self.refer then
      media = media.." refer=\""..self.refer.media.."\" instance=\"instSame\""
   end

   local hasType, hasSource = nil, nil
   for pos, val in pairs(self.properties) do
      if pos == "src" then
         media = media.."src="..val.." "
         hasSource = true
      end
      if pos == "type" then
         media = media.."type="..val.." "
         hasType = true
      end
   end

   if not (hasType ~= nil or hasSource ~= nil or self.refer ~= nil) then
      utils.printErro("Media "..self.id.." deve ter source ou type.", self.linha)
      return ""
   end

   media = media..">"

   for pos,val in pairs(self.properties) do
      if (pos ~= "src" and pos ~= "type" and pos ~= "rg") then
         media = media..indent.."   <property name=\""..pos
         if val then
            media = media.."\" value="..val
         end
         media = media.."/>"
      end
   end

   for pos,val in pairs(self.sons) do
      media = media..val:toNCL(indent.."   ")
   end

   media = media..indent.."</media>"
   return media
end

