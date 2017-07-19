function parseId (str)
	local words = {}

	for word in str:gmatch("%S+") do -- Separar as palavras por espaco
		table.insert(words, word)
	end

	if #words == 2 then
		local id = words[2]
		return id
	else
		utils.printErro("Context nao pode ter mais de 2 Ids.")
		return nil
	end
end

function parseProperty (str)
	local sign = str:find("=")

	local name = str:sub(1, sign-1)
	local value = str:sub(sign+1)
	return name, value
end

function parseLinkCondition (str)
	--Separar as palavras por espaco
	local words = {}
	for word in str:gmatch("%S+") do
		table.insert(words, word)
	end

	if #words == 3 then
		local conditionString = words[1]
		local mediaString = words[2]

		local param, interface = nil, nil

		local arroba = mediaString:find("@")
		if arroba then
			param = mediaString:sub(arroba+1)
			mediaString = mediaString:sub(1,arroba-1)
		end
		local barra = mediaString:find("/")
		if barra then
			interface = mediaString:sub(barra+1)
			mediaString = mediaString:sub(1, barra-1)
		end
		local conditionTable = {
			condition = conditionString,
			media = mediaString,
			interface = interface,
			param = param
		}
		if currentElement ~= nil then
			if currentElement:getType() == "link" then --Se for link, adicionar condicao
				currentElement:addCondition(conditionTable)
			else
				if currentElement:getType() == "context" then --Se for context, adcionar link
					local newLink = Link.new()
					newLink:setFather(currentElement)
					currentElement = newLink
					currentElement:addCondition(conditionTable)
					table.insert(tabelaSimbolos.body, newLink)
				end
			end
		else --Se for nil, adicionar link
			local newLink = Link.new()
			currentElement = newLink
			currentElement:addCondition(conditionTable)
			table.insert(tabelaSimbolos.body, newLink)
		end
	else
		utils.printErro("Link do not have 3 things.")
	end
end

function parseLinkConditionParam (str)
	str = str:gsub("%s+", "")
	local sign = str:find("=")
	local paramName = str:sub(1, sign-1)
	local paramValue = str:sub(sign+1)
	if currentElement ~= nil then
		if currentElement:getType() == "link" then
			currentElement:addLinkParam(paramName, paramValue)
		else
			utils.printErro("Param is not inside a link.")
		end
	else
		utils.printErro("Param is inside a nil element.")
	end

end

function parseLinkAction (str)
	local words = {}
	for word in str:gmatch("%S+") do
		table.insert(words, word)
	end
	local action = words[1]
	local media = words[2]

	if currentElement ~= nil then
		if currentElement:getType() == "link" then
			local newAction = Action.new(action, media)
			newAction:setFather(currentElement)
			newAction:getFather():addAction(newAction)
			currentElement = newAction
		else
			utils.printErro("Action can only be declared inside of a link.")
		end
	else
		utils.printErro("Action can not be declared outside of a link")
	end
end

function parseLinkActionParam (str)
	str = str:gsub("%s+", "")
	local sign = str:find("=")
	local interface = str:sub(1, sign-1)
	local paramValue = str:sub(sign+1)

	if currentElement ~= nil then
		if currentElement:getType() == "action" then
			currentElement:setInterface(interface)
			currentElement:addParam("actionVar", paramValue)
		else
			utils.printErro("Action parameter is not inside an action.")
		end
	else
		utils.printErro("Action parameter can only be declare inside of an action")
	end
end
