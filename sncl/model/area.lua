Area = {}
Area_mt = {}

Area_mt.__index = Area
function Area.new(id)
	local areaObject = {
		id = id,
		father = false,
		hasEnd = false,
		properties = {},
	}
	setmetatable(areaObject, Area_mt)
	return areaObject
end

--Getters
function Area:getId() return self.id end
function Area:getProperties() return self.properties end
function Area:getType() return "area" end
function Area:getFather() return self.father end
function Area:getEnd() return self.hasEnd end

--Setters
function Area:setId(id) self.id = id end
function Area:setFather(father) self.father = father end
function Area:setEnd (bool) self.hasEnd = bool end

function Area:addProperty(name, value)
	self.properties[name] = value
end

-- Gerador de NCL
function Area:toNCL(indent)
	local newNCL = indent.."<area id=\""..self.id.."\">"

	for pos,val in pairs(self.properties) do
		newNCL = newNCL..indent.."   <property name=\""..pos.."\" value="..val.."/>"
	end
	newNCL = newNCL..indent.."</area>"

	return newNCL
end

