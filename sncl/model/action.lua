Action = {}
Action_mt = {}

Action_mt.__index = Action

function Action.new(action, media)
	local actionObject = {
		hasEnd = false,
		father = nil,
		action = action,
		media = media,
		interface = nil,
		params = {},
	}
	setmetatable(actionObject, Action_mt)
	return actionObject
end

function Action:getFather() return self.father end
function Action:getEnd() return self.hasEnd end
function Action:getType() return "action" end
function Action:getAction() return self.action end
function Action:hasParams()
	local i = 0
	for __, __ in pairs(self.params) do
		i = i+1
	end
	if i == 0 then
		return false
	else
		return true
	end
end

function Action:setFather(father) self.father = father end
function Action:setEnd (bool) self.hasEnd = bool end
function Action:setInterface (interface) self.interface = interface end
function Action:addParam (name, value) self.params[name] = value end

function Action:toNCL(indent)
	local action = indent.."<bind role=\""..self.action.."\" component=\""..self.media.."\""
	if self.interface then
		action = action.." interface=\""..self.interface.."\""
	end
	action = action..">"
	for pos, val in pairs(self.params) do
		action = action..indent.."   <bindParam name=\""..pos.."\" value="..val.."/>"
	end
	action = action..indent.."</bind>"
	return action
end

