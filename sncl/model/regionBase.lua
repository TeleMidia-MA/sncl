RegionBase = {}
RegionBase_mt = {}

RegionBase_mt.__index = RegionBase

function RegionBase.new()
	local regionBaseObject = {
		id = nil,
		importBase = {},
		regions = {}
	}
	setmetatable(regionBaseObject, RegionBase_mt)
	return regionBaseObject
end

--Setters
function RegionBase:setId(id) self.id = id end

function RegionBase:addImportBase(importBase)
	table.insert(self.importBase, importBase)
end

function RegionBase:addProperty(property)
end

function RegionBase:addRegion(region)
	table.insert(self.region, regions)
end

--Getters

--Checagens

--Gerador de NCL
function RegionBase:toNCL()
	local NCL = "<regionBase id=\""..self.id.."\""

	for pos, val in pairs(self.importBase) do
		NCL = NCL.."\t"..val:toNCL().."\n"
	end
	for pos, val in pairs(self.regions) do
		NCL = NCL.."\t"..val:toNCL().."\n"
	end


	return NCL
end
