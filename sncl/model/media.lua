Media = {}
Media_mt = {}

Media_mt.__index = Media

function Media.new(id)
	local mediaObject = {
		id = id, 
		hasEnd = false,
		father = nil,
		descriptor = nil,
		properties = {},
		sons = {}
	}
	setmetatable(mediaObject, Media_mt)
	return mediaObject
end

--Getters
function Media:getId() return self.id end
function Media:getSource() return self.source end
function Media:getRegion() return self.region end
function Media:getDescriptor() return self.descriptor end
function Media:getMediaType() return self.mediaType end
function Media:getType() return "media" end
function Media:getFather() return self.father end

--Setters
function Media:setId (id) self.id = id end
function Media:setFather(father) self.father = father end
function Media:setEnd(bool) self.hasEnd = bool end
function Media:addSon (son)
	table.insert(self.sons, son)
end
function Media:addProperty(name, value)
	self.properties[name] = value
end

function Media:createDescriptor() 
	if self.properties["rg"] ~= nil then
		if tabelaSimbolos.regions[self.properties["rg"]] then
			local id = self.properties["rg"]
			id = id.."Desc"
			self.descriptor = id

			--if tabelaSimbolos[id] == nil then
				local newDesc = Descriptor.new(id)
				newDesc:setRegion(self.properties["rg"])
				tabelaSimbolos[id] = newDesc
				tabelaSimbolos.descriptors[id] = tabelaSimbolos[id]
			--[[else
				utils.printErro("Id "..id.." already declared.")
			end]]
		else
			utils.printErro("Region "..self.properties["rg"].." not declared.")
		end
	else
	end
end

-- Gerador de NCL
function Media:toNCL(indent) --Fazer checagens aqui
	local media = indent.."<media id=\""..self.id.."\" "

	self:createDescriptor()
	if self.descriptor then
		media = media.."descriptor=\""..self.descriptor.."\" "
	end

	for pos, val in pairs(self.properties) do
		if utils.containsValue(mediaRestrictedProperties, pos) then
			if pos ~= "rg" then
				media = media..pos.."="..val.." "
			end
		end
	end

	media = media..">"

	for pos,val in pairs(self.properties) do
		if utils.containsValue(mediaProperties, pos) or utils.containsValue(mediaRestrictedProperties, pos) then
			if utils.containsValue(mediaProperties, pos) then
				media = media..indent.."   <property name=\""..pos.."\" value="..val.."/>"
			end
		else
			utils.printErro("Invalid media property "..pos..".")
		end
	end

	for pos,val in pairs(self.sons) do
		media = media..val:toNCL(indent.."   ")
	end

	media = media..indent.."</media>"
	return media
end

