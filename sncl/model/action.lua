Action = {}
Action_mt = {}

Action_mt.__index = Action

function Action.new(action, component, interface, linha)
	local actionObject = {
		action = action,
		component = component,
		hasEnd = false,
		father = nil,
		interface = interface,
		linha = linha,
		params = {},
	}
	setmetatable(actionObject, Action_mt)
	return actionObject
end

function Action:getFather() return self.father end
function Action:getEnd() return self.hasEnd end
function Action:getType() return "action" end
function Action:getAction() return self.action end

function Action:setFather(father) self.father = father end
function Action:setEnd (bool) self.hasEnd = bool end
function Action:addParam (name, value) self.params[name] = value end

function Action:toNCL(indent)
	if self.hasEnd == false then
		utils.printErro("Action does not have end.", self.linha)
		return ""
	end

	if tabelaSimbolos[self.component] == nil then
		utils.printErro("Media "..self.component.." not declared.", self.linha)
		return ""
	else
		if self.interface then
			if tabelaSimbolos[self.component]:getRefer() ~= nil then
				local refer = tabelaSimbolos[self.component]:getRefer()
				local referredMedia = tabelaSimbolos[refer.media]
				if referredMedia ~= nil then
					if referredMedia:getSon(self.interface) == false and tabelaSimbolos[self.component]:getSon(self.interface) == false then
						utils.printErro("Interface "..self.interface.." of Media "..self.component.." not declared.", self.linha)
					end
				else
				utils.printerro("Media "..self.component.." not declared.", self.linha)
				end
			elseif not tabelaSimbolos[self.component]:getSon(self.interface) then
				utils.printErro("Media "..self.component.." does not have interface "..self.interface, self.linha)
				return ""
			end
		end
	end

	if (tabelaSimbolos.body[self.component]:getFather() == nil and self.father:getFather() == nil) or 
		tabelaSimbolos.body[self.component]:getFather():getId() == self.father:getFather():getId() then
	else
			utils.printErro("Media "..self.component.." and Link not in the same context.", self.linha)
			return ""
	end


	local action = indent.."<bind role=\""..self.action.."\" component=\""..self.component.."\""
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

