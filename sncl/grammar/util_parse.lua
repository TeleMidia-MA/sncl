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
	if sign then
		local name = str:sub(1, sign-1)
		local value = str:sub(sign+1)
		return name, value
	else
		return str
	end
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
		local barra = mediaString:find("%.")
		if barra then
			interface = mediaString:sub(barra+1)
			mediaString = mediaString:sub(1, barra-1)
		end
		local conditionTable = {
			condition = conditionString,
			media = mediaString,
			interface = interface,
			param = param,
		}
		if currentElement ~= nil then
			if currentElement:getType() == "link" then --Se for link, adicionar condicao
				currentElement:addCondition(conditionTable)
			else
				if currentElement:getType() == "context" then --Se for context, adcionar link
					local newLink = Link.new(linhaParser)
					newLink:setFather(currentElement)
					currentElement = newLink
					currentElement:addCondition(conditionTable)
					table.insert(tabelaSimbolos.body, newLink)
				end
			end
		else --Se for nil, adicionar link
			local newLink = Link.new(linhaParser)
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
			utils.printErro("Param is not inside a link.", linhaParser)
		end
	else
		utils.printErro("Param have to be inside a element.", linhaParser)
	end

end

function parseLinkAction (str)
	local words = {}
	for word in str:gmatch("%S+") do
		table.insert(words, word)
	end
	local action = words[1]
	local media = words[2]
	local interface = nil

	local barra = media:find("%.")

	if currentElement ~= nil then
		if currentElement:getType() == "link" then
			local newAction = Action.new(action, media, interface, linhaParser)
			newAction:setFather(currentElement)
			newAction:getFather():addAction(newAction)
			currentElement = newAction
		else
			utils.printErro("Action can only be declared inside of a link.", linhaParser)
		end
	else
		utils.printErro("Action can not be declared outside of a link", linhaParser)
	end
end

function parseLinkActionParam (str)
	str = str:gsub("%s+", "")
	local sign = str:find("=")
	local paramName = str:sub(1, sign-1)
	local paramValue = str:sub(sign+1)

	if currentElement ~= nil then
		if currentElement:getType() == "action" then
			currentElement:addParam(paramName, paramValue)
		else
			utils.printErro("Action parameter is not inside an action.")
		end
	else
		utils.printErro("Action parameter can only be declared inside of an action")
	end
end

function parsePort (str)
	local words = {}
	for word in str:gmatch("%S+") do
		table.insert(words, word)
	end

	local id = words[2]
	local media = words[3]
	local interface = nil

	local barra = media:find("%.")

	local newPort = nil

	if currentElement then
		if currentElement.getType() == "context" then
			newPort = Port.new(id, media, interface, currentElement, linhaParser)
			currentElement:addSon(newPort)
		else
			utils.printErro("Element can not have a port.")
		end
	else
		newPort = Port.new(id, media, nil)
	end

	if newPort ~= nil then
		tabelaSimbolos[id] = newPort
		tabelaSimbolos.body[id] = tabelaSimbolos[id]
	end
end

