Media = {}
Media_mt = {}

Media_mt.__index = Media

function Media.new(id, linha)
	local mediaObject = {
		id = id, 
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
function Media:getSource () return self.source end
function Media:getRegion () return self.region end
function Media:getDescriptor () return self.descriptor end
function Media:getMediaType () return self.mediaType end
function Media:getType () return "media" end
function Media:getFather () return self.father end
function Media:getSons () return self.sons end
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
function Media:setId (id) self.id = id end
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
			utils.printErro("Region "..self.properties["rg"].." not declared.")
		end
	else
	end
end

-- Gerador de NCL
function Media:toNCL(indent) --Fazer checagens aqui
	if self.hasEnd == false then
		utils.printErro("Media "..self.id.." does not have end.", self.linha)
		return ""
	end
	local media = indent.."<media id=\""..self.id.."\" "

	self:createDescriptor()
	if self.descriptor then
		media = media.."descriptor=\""..self.descriptor.."\" "
	end
	if self.refer then
		media = media.." refer = \""..self.refer.media.."\" instance = \""..self.refer.interface.."\""
	end

	local hasType, hasSource = false, false
	for pos, val in pairs(self.properties) do
		if utils.containsValue(mediaRestrictedProperties, pos) then
			if pos == "src" then
				hasSource = true
			end
			if pos == "type" then
				hasType = true
			end
			if pos ~= "rg" then
				media = media..pos.."="..val.." "
			end
		end
	end

	if not hasType and not hasSource then
		utils.printErro("Media "..self.id.." must have a source or a type.", self.linha)
		return ""
	end

	media = media..">"

	for pos,val in pairs(self.properties) do
		if utils.containsValue(mediaProperties, pos) or utils.containsValue(mediaRestrictedProperties, pos) then
			if utils.containsValue(mediaProperties, pos) then
				media = media..indent.."   <property name=\""..pos
				if val then
					media = media.."\" value="..val
				end
				media = media.."/>"
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

