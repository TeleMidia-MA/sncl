Switch = {}
Switch_mt = {}

Switch_mt.__index = Switch

function Switch.new()
	local switchObject = {
		id = nil,
		refer = nil
	}
	setmetatable(switchObject, Switch_mt)
	return switchObject
end

function Switch:toNCL()
	local NCL = ""
	return NCL
end
