Region = {}
Region__mt = {}

Region__mt.__index = Region

function Region.new(id)
	local RegionObject = {
		id = id,
		father = nil,
		hasEnd = false,
		sons = {},
		properties = {},
	}
	setmetatable(RegionObject, Region__mt)
	return RegionObject
end

--Getters
function Region:getId() return self.id end
function Region.getType() return "region" end
function Region:getFather() return self.father end
function Region:getEnd() return self.hasEnd end

-- Setters
function Region:setFather(father) self.father = father end
function Region:setEnd (bool) self.hasEnd = bool end
function Region:addProperty(name, value)
	self.properties[name] = value
end
function Region:addSon(son)
	table.insert(self.sons, son)
end

-- Gerador de codigo
function Region:toNCL(indent)
	local newNCL = indent.."<region id=\""..self.id.."\">"

	for pos,val in pairs(self.properties) do
		newNCL = newNCL..indent.."   <property name=\""..pos.."\" value="..val.."/>"
	end

	for pos,val in pairs(self.sons) do
		newNCL = newNCL..val:toNCL(indent.."   ")
	end

	newNCL  = newNCL..indent.."</region>"
	return newNCL
end

local regionProperties = {
	"title","left","right","top","bottom","height",
	"width","zIndex"
}


