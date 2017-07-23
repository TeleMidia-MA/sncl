Condition = {}
Condition_mt = {}

Condition_mt.__index = Condition

function Condition.new(condition, conditionParam, media, interface, linha)
	local conditionObject = {
		condition = condition,
		conditionParam = conditionParam,
		media = media,
		interface = interface,
		linha = linha,
		father = nil,
	}
	setmetatable(conditionObject, Condition_mt)
	return conditionObject
end

function Condition:setFather (father)
	self.father = father
end
function Condition:addParam (param)
end

function Condition:getMedia ()
	return self.media
end
function Condition:getLinha()
	return self.linha
end
function Condition:getFather()
	return self.father
end
function Condition:getType()
	return "condition"
end
function Condition:getParam()
	return self.conditionParam
end

function Condition:toNCL (indent)
	if tabelaSimbolos[self.media] == nil then
		utils.printErro("Media "..self.media.." not declared.", self.linha)
		return ""
	else
		if self.interface then
			if not tabelaSimbolos[self.media]:getSon(self.interface) then
				utils.printErro("Media "..self.media.." does not have interface "..self.interface, self.linha)
				return ""
			end
		end
	end


	if (tabelaSimbolos.body[self.media]:getFather() == nil and self.father:getFather() == nil)
		or tabelaSimbolos.body[self.media]:getFather():getId() == self.father:getFather():getId() then
	else
			utils.printErro("Media "..self.media.." and Link not in the same context.", self.linha)
			return ""
	end


	local condition = indent.."<bind role=\""..self.condition.."\" component=\""..self.media.."\" "
	if self.interface then
		condition = condition.." interface=\""..self.interface.."\""
	end
	condition = condition..">"

	if self.conditionParam then
		if self.condition == "onSelection" then
			condition = condition..indent.."   <bindParam name=\"keyCode\" value=\""..self.conditionParam.."\"/>"
		else
			condition = condition..indent.."   <bindParam name=\"conditionVar\" value=\""..self.conditionParam.."\"/>"
		end
	end

	condition = condition..indent.."</bind>"
	return condition
end

