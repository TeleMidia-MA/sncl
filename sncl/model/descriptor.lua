Descriptor = {}
Descriptor_mt = {}

Descriptor_mt.__index = Descriptor

function Descriptor.new(id)
   local descriptorObject = {
      id = id,
      region = nil,
      properties = {}
   }
   setmetatable(descriptorObject, Descriptor_mt)
   return descriptorObject
end

-- Setters
function Descriptor:setId(id) 
   if tabelaSimbolos[id] then
      utils.printErro("Elemento com id "..id.." já declarado.")
      return
   end
   self.id = id 
end
function Descriptor:setRegion(region) self.region = region end

--Getters
function Descriptor:getId() return self.id end

function Descriptor:toNCL(indent)
   NCL = indent.."<descriptor id=\""..self.id.."\""
   NCL = NCL.." region=\""..self.region.."\" />"
   return NCL
end
